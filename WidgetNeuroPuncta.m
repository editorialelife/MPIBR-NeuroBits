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
        linkmask
        
        width
        height
    end
    
    properties (Access = private, Hidden = true)
        
        %%% --- find puncta --- %%%
        dilationSize
        intensityLevel
        linkedCount
        
        %%% --- puncta properties --- %%%
        puncta_Count
        puncta_IDs
        puncta_Position
        puncta_Area
        puncta_Intensity
        puncta_Pixels
        puncta_Link
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        ih_patch
        
        %%% --- UI components --- %%%
        ui_parent
        ui_grid
        ui_panel
        
        ui_pushButton_Segment
        ui_pushButton_Load
        ui_pushButton_Link
        ui_pushButton_Export
        
        ui_text_Status
        ui_text_LabelSize
        ui_text_LabelIntensity
        
        ui_edit_Size
        ui_edit_Level
        
        ui_checkBox_ViewMask
        
    end
    
    properties (Constant, Hidden)
        
        %%% --- UI properties --- %%%
        GUI_WINDOW_POSITION = [1, 1, 250, 130];
        VERTICAL_GAP = [12, 2, 8];
        HORIZONTAL_GAP = [5, 2, 5];
        PUSHBUTTON_POSITION = [1, 1, 90, 26];
        EDITBOX_POSITION = [1, 1, 45, 20];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        FONT_SIZE = 8;
        
        %%% --- Puncta Dilation --- %%%
        RANGE_DILATION = [1,30];
        RANGE_INTENSITY = [0,100];
        PATCH_ALPHA_OFF = 0;
        PATCH_ALPHA_ON = 0.2;
        LIME_GREEN = [50, 205, 50];
        ORANGE_RED = [255, 69, 0];
        
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
                    'Tag', 'hNeuroPuncta',...
                    'Name', 'NeuroPuncta',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Resize', 'off',...
                    'Units', 'pixels',...
                    'Position', obj.GUI_WINDOW_POSITION,...
                    'CloseRequestFcn', @obj.fcnCallback_CloseUIWindow);
                movegui(obj.ui_parent, 'northwest');
                
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            % set default properties
            obj.setDefaultProperties();
            
            % render UI
            obj.renderUI();
            
        end
        
        
        % method :: setDefaultProperties
        %  input :: class object
        % action :: set hidden properties default values
        function obj = setDefaultProperties(obj)
            
            %%%  --- find puncta --- %%%
            obj.dilationSize = 5;
            obj.intensityLevel = 0.5;
            obj.linkedCount = 0;
            
            %%% --- puncta properties --- %%%
            obj.puncta_Count = 0;
            obj.puncta_IDs = 0;
            obj.puncta_Position = [0,0];
            obj.puncta_Area = 0;
            obj.puncta_Intensity = 0;
            obj.puncta_Pixels = 0;
            obj.puncta_Link = 0;
            
        end
        
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            %%% --- create grid object --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_parent,...
                'VGrid', 4,...
                'HGrid', 4,...
                'VGap', obj.VERTICAL_GAP,...
                'HGap', obj.HORIZONTAL_GAP);
            
            %%% --- create widget panel --- %%%
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Neuro Puncta',...
                'TitlePosition', 'lefttop',...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', abs(obj.GUI_WINDOW_POSITION - 4));
            
            
            %%% --- render pushButtons --- %%% 
            obj.ui_pushButton_Segment = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Segment',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Segment,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_Segment,...
                'VIndex', 1,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_Load = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Load',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Load,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);                         
            obj.ui_grid.align(obj.ui_pushButton_Load,...
                'VIndex', 1,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
            obj.ui_pushButton_Link = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Link 0 / 0',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Link,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_Link,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');                         
                                     
            obj.ui_pushButton_Export = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Export',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_Export,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_Export,...
                'VIndex', 2,...
                'HIndex', 3:4,...
                'Anchor', 'center');                        
            
            %%% --- status message --- %%%
            obj.ui_text_Status = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'Text',...
                'String', 'choose image to segment',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 3, 'HIndex', 1:3));
           obj.ui_grid.align(obj.ui_text_Status,...
               'VIndex', 3,...
               'HIndex', 1:3,...
               'Anchor', 'center');
                                     
            obj.ui_checkBox_ViewMask = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'CheckBox',...
                'String', 'mask',...
                'Value', 0,...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_ViewMask,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_checkBox_ViewMask,...
                'VIndex', 3,...
                'HIndex', 4,...
                'Anchor', 'west');
            
            
            %%% --- mask properties --- %%%
            obj.ui_text_LabelSize = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'Text',...
                'String', 'size[px]',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 1));
            obj.ui_grid.align(obj.ui_text_LabelSize,...
                'VIndex', 4,...
                'HIndex', 1,...
                'Anchor', 'east');
            
            obj.ui_edit_Size = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'Edit',...
                'String', '5',...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_ParseEditBox,...
                'Units', 'pixels',...
                'Position', obj.EDITBOX_POSITION);
            obj.ui_grid.align(obj.ui_edit_Size,...
                'VIndex', 4,...
                'HIndex', 2,...
                'Anchor', 'west');   
            
            
            obj.ui_text_LabelIntensity = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'Text',...
                'String', 'intensity[%]',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 3));
            obj.ui_grid.align(obj.ui_text_LabelIntensity,...
                'VIndex', 4,...
                'HIndex', 3,...
                'Anchor', 'east');
            
            obj.ui_edit_Level = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'Edit',...
                'String', '20',...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_ParseEditBox,...
                'Units', 'pixels',...
                'Position', obj.EDITBOX_POSITION);
            obj.ui_grid.align(obj.ui_edit_Level,...
                'VIndex', 4,...
                'HIndex', 4,...
                'Anchor', 'west'); 
        end
        
        
        % method :: unlockUI
        %  input :: class object
        % action :: unlocks user interface
        function obj = unlockUI(obj)
            
            set(obj.ui_pushButton_Segment, 'Enable', 'on');
            set(obj.ui_pushButton_Load, 'Enable', 'on');
            set(obj.ui_edit_Size, 'Enable', 'on');
            set(obj.ui_edit_Level, 'Enable', 'on');
            
        end
        
        % method :: lockUI
        %  input :: class object
        % action :: locks user interface
        function obj = lockUI(obj)
            
            set(obj.ui_pushButton_Segment, 'Enable', 'off');
            set(obj.ui_pushButton_Load, 'Enable', 'off');
            set(obj.ui_pushButton_Link, 'Enable', 'off');
            set(obj.ui_pushButton_Export, 'Enable', 'off');
            set(obj.ui_edit_Size, 'Enable', 'off');
            set(obj.ui_edit_Level, 'Enable', 'off');
            
        end
        
        % method :: dispose
        %  input :: class object
        % action :: class destructor
        function obj = dispose(obj)
            
            % remove patch
            if isgraphics(obj.ih_patch, 'Image')
                delete(obj.ih_patch);
            end
            
            % remove grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % check if parent is figure or was inherit
            if isgraphics(obj.ui_parent,'figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
            
        end
        
        %%% ------------------------ %%%
        %%% --- ANALYSIS METHODS --- %%%
        %%% ------------------------ %%%
        
        % method :: segment
        %  input :: class object, varargin
        % action :: assign current image handlers and file name
        function obj = segment(obj, varargin)
            
            % use parser
            parserObj = inputParser;
            addParameter(parserObj, 'FileName', [], @ischar);
            addParameter(parserObj, 'Figure', [], @isgraphics);
            addParameter(parserObj, 'Axes', [], @isgraphics);
            addParameter(parserObj, 'Image', [], @isgraphics);
            addParameter(parserObj, 'Tree', [], @(x) validateattributes(x,{'WidgetNeuroTree'}));
            addParameter(parserObj, 'LinkMask', [], @(x) validateattributes(x,{'double'},{'matrix'}));
            parse(parserObj, varargin{:});
            
            % assign input variables
            [obj.path, obj.name] = fileparts(parserObj.Results.FileName);
            
            obj.ih_figure = parserObj.Results.Figure;
            obj.ih_axes = parserObj.Results.Axes;
            obj.ih_image = parserObj.Results.Image;
            
            obj.image = get(obj.ih_image, 'CData');
            [obj.height, obj.width] = size(obj.image);
            obj.mask = false(obj.height, obj.width);
            
            obj.tree = parserObj.Results.Tree;
            obj.linkmask = parserObj.Results.LinkMask;
            
            % if linkmask is empty define an empty mask
            if isempty(obj.linkmask)
                obj.linkmask = false(obj.height, obj.width);
            end
            
            % create patch
            obj.createPatch();
            
            % run pipeline
            obj.runPipeline();
            
        end
        
        % method :: createPatch
        %  input :: class object
        % action :: creates image patch
        function obj = createPatch(obj)
            
            % create patch
            obj.patch = zeros(obj.height, obj.width, 3, 'uint8');
            
            % assign patch to image figure
            hold(obj.ih_axes, 'on');
            obj.ih_patch = imshow(obj.patch, [],...
                                 'Border', 'tight',...
                                 'InitialMagnification', 'fit',...
                                 'Parent', obj.ih_axes);
            set(obj.ih_patch, 'AlphaData', obj.PATCH_ALPHA_OFF); 
            hold(obj.ih_axes, 'off');
            
        end
        
        % method :: findPuncta
        %  input :: class object
        % action :: process image to locate puncta
        function obj = findPuncta(obj)
            
            % dilation mask
            dilationMask = obj.image == imdilate(obj.image, strel('disk', obj.dilationSize));
            
            % intensity mask
            threshold = obj.intensityLevel * max(obj.image(:));
            disp(threshold);
            
            intensityMask = obj.image > threshold;
            
            % compile binary mask
            obj.mask = dilationMask & intensityMask;
            
            figure(),imshow(intensityMask);
            
            %{
            % locate ROIs
            rois = regionprops(obj.mask, obj.image,...
                               'Centroid',...
                               'Area',...
                               'MeanIntensity',...
                               'PixelIdxList');
            
            % assign result
            obj.puncta_Count = length(rois);
            obj.puncta_IDs = (1:obj.puncta_Count)';
            obj.puncta_Position = cat(1, rois.Centroid);
            obj.puncta_Area = cat(1, rois.Area);
            obj.puncta_Intensity = cat(1, rois.MeanIntensity);
            obj.puncta_Pixels = cat(1, rois.PixelIdxList);
            obj.puncta_Link = zeros(obj.puncta_Count, 1);
            %}
        end
        
        
        % method :: updatePatch
        %  input :: class object
        % action :: update patch with puncta
        function obj = updatePatch(obj)
            
            % dilate mask
            dilatedMask = imdilate(obj.mask, strel('disk',5));
            
            % update patch color based on linked
            for c = 1 : 3
                patchColor = obj.patch(:,:,c);
                patchColor(dilatedMask & obj.linkmask) = obj.LIME_GREEN(c);
                patchColor(dilatedMask & ~obj.linkmask) = obj.ORANGE_RED(c);
                obj.patch(:,:,c) = patchColor;
            end
            
        end
        
        % method :: updateStatus
        %  input :: class object
        % action :: update current status
        function obj = updateStatus(obj)
            
            status = sprintf('count %d, intensity %.2f, linked %d',...
                             obj.puncta_Count,...
                             mean(obj.puncta_Intensity));
           set(obj.ui_text_Status, 'String', status);
           obj.ui_grid.align(obj.ui_text_Status,...
               'VIndex', 3,...
               'HIndex', 1:3,...
               'Anchor', 'center');
           
        end
        
        % method :: runPipeline
        %  input :: class object
        % action :: run sequence of methods
        function obj = runPipeline(obj)
            
            % check if image is set
            if isgraphics(obj.ih_image, 'image')
            
                
                %fprintf('Run ... ');
                tic
                % find puncta
                obj.findPuncta();
                
                % update patch
                %obj.updatePatch();
            
                % update status
                obj.updateStatus();
            
                %fprintf('done. %4.f sec\n', toc);
            end
            
        end
        
        % method :: showMask
        %  input :: class object
        % action :: show current patch
        function obj = showMask(obj)
            set(obj.ih_patch, 'CData', obj.patch);
            set(obj.ih_patch, 'AlphaData', (obj.mask > 0) .* obj.PATCH_ALPHA_ON);
            
        end
        
        % method :: hideMask
        %  input :: class object
        % action :: hide current patch
        function obj = hideMask(obj)
            set(obj.ih_patch, 'AlphaData', obj.PATCH_ALPHA_OFF);
        end
        
        %%% ----------------------------- %%%
        %%% --- UI CALLBACK FUNCTIONS --- %%%
        %%% ----------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close request
        %   action :: calls class destructor method
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            obj.dispose();
            
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
        
        
        % callback :: ParseEditBox
        %    event :: on changing edit box
        %   action :: update edit box input
        function obj = fcnCallback_ParseEditBox(obj, hSrc, ~)
            
            if hSrc == obj.ui_edit_Size
                
                % parse dilation size
                obj.dilationSize = fcnHelper_ParseEditBox(get(obj.ui_edit_Size, 'String'),...
                                                          obj.RANGE_DILATION);
                
                % update edit box string
                set(obj.ui_edit_MinSize, 'String', sprintf('%d', obj.dilationSize));
            
            elseif hSrc == obj.ui_edit_Level
                   
                % parse min intensity
                obj.intensityLevel = fcnHelper_ParseEditBox(get(obj.ui_edit_Level, 'String'),...
                                                            obj.RANGE_INTENSITY);
                
                % update edit box string
                set(obj.ui_edit_Level, 'String', sprintf('%d', obj.intensityThreshold));
                
                % restrict level to [0, 1] range
                obj.intensityLevel = obj.intensityLevel / 100;
                
            end
            
            % run pipeline
            obj.runPipeline();
            
        end
        
    end
    
end


function value = fcnHelper_ParseEditBox(varchar, varrange)

    % get number out of string
    value = regexp(varchar, '[\d]+','match');
    
    % check if parsing is valid
    if isempty(value)
        value = 0;
    else
        value = str2double(value);
    end

    % compare range
    if value < varrange(1)
        value = varrange(1);
    end
    
    if value > varrange(2)
        value = varrange(2);
    end
    
end
