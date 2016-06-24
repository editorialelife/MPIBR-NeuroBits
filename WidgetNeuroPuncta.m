classdef WidgetNeuroPuncta < handle
    %
    % WidgetNeuroPuncta
    %
    % GUI Widget for 
    % user guided neuro puncta segmentation
    % puncta from FISH or PLA methods
    % exporting/loading segmented ROIs
    % automatic linking of puncta and NeuroTree mask
    % creating a ROI labeled mask
    %
    % requires:
    %    class NeuroTreeBranch
    %    uiGridLayout.m
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties
        path
        name
        
        image
        mask
        patch
        tree
        
        width
        height
    end
    
    properties (Access = private, Hidden = true)
        
        dilate
        intensity
        linked
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        ih_patch
        ih_centers
        
        
        %%% --- UI components --- %%%
        ui_parent
        ui_panel
        
        ui_pushButton_Segment
        ui_pushButton_Load
        ui_pushButton_Link
        ui_pushButton_Export
        
        ui_text_Status
        ui_text_LabelSize
        ui_text_LabelIntensity
        
        ui_edit_MinSize
        ui_edit_MinIntensity
        
        ui_checkBox_ViewMask
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        GUI_WINDOW_POSITION = [0, 0.455, 0.15, 0.40];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY
        GRID_MARGIN_H = 0.015;
        GRID_MARGIN_W = 0.015;
        FONT_SIZE = 10;
        
        %%% --- Puncta Dilation --- %%%
        MIN_DILATE_SIZE = 10;
        MAX_DILATE_SIZE = 30;
        PATCH_ALPHA_OFF = 0;
        PATCH_ALPHA_ON = 0.2;
        
    end
    
    events (NotifyAccess = protected)
        event_NeuroPuncta_Segment
    end
    
    methods
        
        % method :: WidgetNeuroPuncta
        %  input :: varargin
        % action :: class constructor
        function obj = WidgetNeuroPuncta(varargin)
            
            % use parser
            parserObj = inputParser;
            
            % define inputs
            addParameter(parserObj, 'Parent', [], @isgraphics);
            
            % parse varargin
            parse(parserObj, varargin{:});
            
            % set UI parent
            if isempty(parserObj.Results.Parent)
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hDrawNeuroPunctaUI',...
                    'Name', 'Find Neuro Puncta',...
                    'NumberTitle', 'off',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Units', 'normalized', ...
                    'Position', obj.GUI_WINDOW_POSITION,...
                    'CloseRequestFcn', @obj.fcnCallback_CloseUIWindow);
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            % set default properties
            obj.setDefaultProperties();
            
            % render UI
            obj.renderUI();
            
            % set defaults
            obj.dilate = 5;
            obj.intensity = 0.5;
            
        end
        
        
        % method :: setDefaultProperties
        %  input :: class object
        % action :: set hidden properties default values
        function obj = setDefaultProperties(obj)
            
            % set defaults
            obj.tree = [];
            obj.linked = 0;
            obj.mask = zeros(obj.height, obj.width);
            obj.patch = zeros(obj.height, obj.width, 3, 'like', obj.image);
            
        end
        
        
        % method :: getParentColor
        %  input :: class object
        % action :: returns value of Parent Color/BackgroundColor property
        function value = getParentColor(obj)
            if isgraphics(obj.ui_parent, 'figure')
                value = get(obj.ui_parent, 'Color');
            elseif isgraphics(obj.ui_parent, 'uipanel')
                value = get(obj.ui_parent, 'BackgroundColor');
            end
        end
        
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            hPanel = uipanel(...
                'Parent', obj.ui_parent,...
                'BorderType', 'none',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', [0, 0, 1, 1]);
            
            %%% --- render pushButtons --- %%% 
            obj.ui_pushButton_Segment = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Segment',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Segment,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         1, 1));
                                     
                                     
            obj.ui_pushButton_Load = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Load',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Load,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         2, 1));                         
            
            obj.ui_pushButton_Link = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Link 0 / 0',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Link,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 1));
                                     
                                     
            obj.ui_pushButton_Export = uicontrol(...
                'Parent', hPanel,...
                'Style', 'PushButton',...
                'String', 'Export',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Export,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 1));
                                    
            %%% --- mask properties --- %%%
            obj.ui_checkBox_ViewMask = uicontrol(...
                'Parent', hPanel,...
                'Style', 'CheckBox',...
                'String', 'view mask',...
                'Value', 0,...
                'Enable', 'off',...
                'BackgroundColor', obj.getParentColor(),...
                'FontSize', obj.FONT_SIZE,...
                'Callback', @obj.fcnCallback_ViewMask,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,2],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         3, 2));
            
            obj.ui_text_LabelSize = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Text',...
                'String', 'size[px]',...
                'BackgroundColor', obj.getParentColor(),...
                'HorizontalAlignment', 'center',...
                'FontSize', obj.FONT_SIZE,...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H, obj.GRID_MARGIN_W],...
                                         4, 3));
                                     
            obj.ui_edit_MinSize = uicontrol(...
                'Parent', hPanel,...
                'Style', 'Edit',...
                'String', '5',...
                'Enable', 'off',...
                'BackgroundColor', obj.getParentColor(),...
                'FontSize', obj.FONT_SIZE,...
                'Callback', @obj.fcnCallback_DilationSize,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4,4],...
                                         [obj.GRID_MARGIN_H *5, obj.GRID_MARGIN_W *5],...
                                         4, 4));
            
        end
        
        
        % method :: unlockUI
        %  input :: class object
        % action :: unlocks user interface
        function obj = unlockUI(obj)
            
            set(obj.ui_pushButton_Segment, 'Enable', 'on');
            set(obj.ui_pushButton_Load, 'Enable', 'on');
            set(obj.ui_edit_MinSize, 'Enable', 'on');
            set(obj.ui_edit_MinIntensity, 'Enable', 'on');
            
        end
        
        % method :: lockUI
        %  input :: class object
        % action :: locks user interface
        function obj = lockUI(obj)
            
            set(obj.ui_pushButton_Segment, 'Enable', 'off');
            set(obj.ui_pushButton_Load, 'Enable', 'off');
            set(obj.ui_pushButton_Link, 'Enable', 'off');
            set(obj.ui_pushButton_Export, 'Enable', 'off');
            set(obj.ui_edit_MinSize, 'Enable', 'off');
            set(obj.ui_edit_MinIntensity, 'Enable', 'off');
            
        end
        
        %%% ----------------------------- %%%
        %%% --- UI CALLBACK FUNCTIONS --- %%%
        %%% ----------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close request
        %   action :: class destructor
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            if isgraphics(obj.ui_parent,'figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
        end
        
        
        % callback :: Segment
        %    event :: on segment push button
        %   action :: initialize segmentation with current image
        function obj = fcnCallback_Segment(obj, ~, ~)
            
            % notify segment puncta
            notify(obj, 'event_NeuroPuncta_Segment');
            
        end
        
        % callback :: Load
        %    event :: on load puncta push button
        %   action :: loads exported puncta list
        function obj = fcnCallback_Load(obj, ~, ~)
            
            % notify segment puncta
            notify(obj, 'event_NeuroPuncta_Segment');
            
        end
        
        
        % callback :: Link
        %    event :: on link push button
        %   action :: link puncta with tree mask
        function obj = fcnCallback_Link(obj, ~, ~)
        end
        
        
        % callback :: Export
        %    event :: on save puncta push button
        %   action :: exports current puncta in txt format
        function obj = fcnCallback_Export(obj, ~, ~)
        end
        
        % callback :: ViewMask
        %    event :: on view mask push button
        %   action :: view puncta mask
        function obj = fcnCallback_ViewMask(obj, ~, ~)
        end
        
        
        % callback :: DilationSize
        %    event :: on dilation size edit box
        %   action :: view puncta mask
        function obj = fcnCallback_DilationSize(obj, ~, ~)
        end
        
        
        %%% ------------------------ %%%
        %%% --- ANALYSIS METHODS --- %%%
        %%% ------------------------ %%%
        
        % respond :: startSegmentation
        %   event :: on event segment
        %   input :: fileName, imageMatrix
        function obj = startSegmentation(obj, fileName, imageMatrix)
            
            % assign input file
            [obj.path, obj.name] = fileparts(fileName);
            
            % assign input image
            obj.image = imageMatrix;
            [obj.height, obj.width] = size(obj.image);
            
            % show image
            obj.renderImage();
            
            % apply segmentation
            obj.applySegmentation();
            
        end
        
        % method :: renderImage
        %  input :: class object
        % action :: render image
        function obj = renderImage(obj)
            
            % calculate figure resize ratio
            sizeScrn = get(0, 'ScreenSize');
            ratioResize = floor(100*0.8*min(sizeScrn(3:4))/max([obj.height, obj.width]))/100;
            if ratioResize > 1
            	ratioResize = 1;
            end
                
            % calculate figure positions
            figW = ceil(obj.width * ratioResize);
            figH = ceil(obj.height * ratioResize);
            figX = round(0.5*(sizeScrn(3) - figW));
            figY = sizeScrn(4) - figH;
                
            obj.ih_figure = figure(...
            	'Color','w',...
                'Visible','on',...
                'MenuBar','none',...
                'ToolBar','figure',...
                'Name','',...
                'NumberTitle','off',...
                'Units','pixels',...
                'Position', [figX, figY, figW, figH],...
                'CloseRequestFcn', @obj.fcnCallback_CloseFigure);
                   
            obj.ih_axes = axes(...
                'Parent', obj.ih_figure,...
                'Units','normalized',...
                'XTick',[],...
                'YTick',[],...
                'Position',[0,0,1,1]);
                
            obj.ih_image = imshow(...
                obj.image,[],...
                'Parent', obj.ih_axes,...
                'Border','tight',...
                'InitialMagnification','fit');
            
            
            hold(obj.ih_axes, 'on');
            obj.patch = zeros(obj.height, obj.width, 3, 'like', obj.image);
            obj.ih_patch = imshow(...
                obj.patch,...
                'Parent', obj.ih_axes,...
                'Border','tight',...
                'InitialMagnification','fit');
            set(obj.ih_patch, 'AlphaData', obj.PATCH_ALPHA_OFF);
            hold(obj.ih_axes, 'off');
            %}
                
        end
        
        % method :: applySegmentation
        %  input :: class object
        % action :: detect 2D local maxima
        function obj = applySegmentation(obj)
            
            % create binary mask
            bry = (obj.image == imdilate(obj.image, strel('disk',obj.dilate))) & (obj.image > obj.intensity.*max(obj.image(:)));
            
            rp = regionprops(bry,'Centroid');
            cnt = cat(1, rp.Centroid);
            
            obj.mask = false(obj.height, obj.width);
            obj.mask = imdilate(obj.mask, strel('disk',20));
            
            obj.patch(repmat(obj.mask,1,1,3)) = uint16(2^16-1);
            
            
            hold(obj.ih_axes, 'on');
            set(obj.ih_patch, 'AlphaData', obj.mask .* obj.PATCH_ALPHA_ON);
            %obj.ih_centers = plot(cnt(:,1), cnt(:,2), 'r.');
            hold(obj.ih_axes, 'off');
            
        end
        
        
        % callback :: close figure
        function obj = fcnCallback_CloseFigure(obj, ~, ~)
            delete(obj.ih_figure);
        end
        
    end
    
end

