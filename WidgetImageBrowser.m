classdef WidgetImageBrowser < handle
    %
    % WidgetImageBrowser
    %
    % GUI Widget for browsing stack multichannel LSM/TIFF image
    % user loads an image file
    % browser either stacks or channels
    % visualize Max, Sum or Std projections
    %
    % requires:
    %    readLSMInfo.m
    %    readLSMImage.m
    %    uiGridLayout.m
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties
        
        indexChannel
        indexStack
        fileName
        metaData
        image
        
    end
    
    properties (Access = public, Hidden = true)
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        
    end
    
    properties (Access = private, Hidden = true)
        
        %%% --- ui handlers --- %%%
        ui_parent
        ui_panel
        
        ui_pushButton_PrevChannel
        ui_pushButton_NextChannel
        ui_pushButton_PrevStack
        ui_pushButton_NextStack
        ui_pushButton_ApplyProjection
        
        ui_text_ImageResolution
        ui_text_ChannelCounter
        ui_text_StackCounter
        
        ui_popup_PickProjection
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        BORDER_WIDTH = 0.015;
        BORDER_HEIGHT = 0.015;
        
    end
    
    methods
        
        % method :: WidgetImageBrowser
        %  input :: varargin
        % action :: class constructor
        function obj = WidgetImageBrowser(varargin)
            
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isgraphics);
            addParameter(parserObj, 'FileName', [], @ischar);
            addParameter(parserObj, 'Axes', [], @isgraphics);
            parse(parserObj, varargin{:});
            
            if isempty(parserObj.Results.Parent)
                obj.ui_parent = figure;
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            obj.fileName = parserObj.Results.FileName;
            
            
            % set defaults
            obj.indexChannel = 1;
            obj.indexStack = 1;
            
            % render user interface
            obj.renderUI();
            
            % if file is provided
            if ~isempty(obj.fileName)
                obj.loadImage();
            end
            
        end
        
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BorderType', 'none',...
                'BackgroundColor', obj.getParentColor(),...
                'Unit', 'normalized',...
                'Position', [0,0,1,1]);
            
            obj.ui_text_ChannelCounter = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'channel 0 / 0',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         1, 1:2));
            
            obj.ui_pushButton_PrevChannel = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_PrevChannel,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         1, 3));
            
            obj.ui_pushButton_NextChannel = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_NextChannel,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         1, 4));
            
            obj.ui_text_StackCounter = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'stack 0 / 0',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         2, 1:2));
            
            obj.ui_pushButton_PrevStack = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_PrevStack,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         2, 3));
            
            obj.ui_pushButton_NextStack = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_NextStack,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         2, 4));
            
            obj.ui_text_ImageResolution = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'load image',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         3, 1:4));
            
            obj.ui_pushButton_ApplyProjection = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Projection',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_ApplyProjection,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         4, 1:2));
            
            obj.ui_popup_PickProjection = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PopUp',...
                'String', {'Max';'Sum';'Std'},...
                'BackgroundColor', obj.getParentColor(),...
                'Callback', [],...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 4],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         4, 3:4));
            
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
        
        
        % method :: loadImage
        %  input :: class object, fileName
        % action :: load image from file name
        function obj = loadImage(obj, fileName)
            
            % assign new file name
            obj.fileName = fileName;
            
            % close previous image
            if ~isempty(obj.ih_figure) && isgraphics(obj.ih_figure)
                close(obj.ih_figure);
            end
            
            % read image file meta data
            obj.metaData = readLSMInfo(obj.fileName);
            
            % update new image
            obj.updateImage();
            
        end
        
        
        % method :: updateImage
        %  input :: class object
        % action :: reads and shows image
        function obj = updateImage(obj)
            
            % read image
            obj.readImage();
                                  
            % update user interface
            obj.updateStatus();
            
            % show image
            obj.showImage();
            
        end
        
        % method :: readImage
        %  input :: class object
        % action :: read image from current name
        function obj = readImage(obj)
            
            % read image
            obj.image = readLSMImage(obj.fileName,...
                                     obj.metaData,...
                                     obj.indexStack,...
                                     obj.indexChannel);
        end
        
        
        % method :: updateStatus
        %  input :: class object
        % action :: update status message
        function obj = updateStatus(obj)
            
            % update meta data message
            set(obj.ui_text_ImageResolution,...
                'String',sprintf('%d bits, H x W %d x %d\n(%.2f x %.2f um)',...
                obj.metaData.bitsPerSample,...
                obj.metaData.height,...
                obj.metaData.width,...
                obj.metaData.height * obj.metaData.yResolution,...
                obj.metaData.width * obj.metaData.xResolution));
            
            set(obj.ui_text_ChannelCounter,...
                'String',sprintf('channel %d / %d',...
                obj.indexChannel, obj.metaData.channels));
            
            set(obj.ui_text_StackCounter,...
                'String',sprintf('stack %d / %d',...
                obj.indexStack, obj.metaData.stacks));
            
            % update stack buttons callbacks
            if obj.metaData.stacks == 1
                set(obj.ui_pushButton_PrevStack,'Enable','off');
                set(obj.ui_pushButton_NextStack,'Enable','off');
                set(obj.ui_pushButton_ApplyProjection,'Enable','off');
            else
                set(obj.ui_pushButton_PrevStack,'Enable','on');
                set(obj.ui_pushButton_NextStack,'Enable','on');
                set(obj.ui_pushButton_ApplyProjection,'Enable','on');
            end
            
            % update channel buttons callbacks
            if obj.metaData.channels == 1
                set(obj.ui_pushButton_PrevChannel,'Enable','off');
                set(obj.ui_pushButton_NextChannel,'Enable','off');
            else
                set(obj.ui_pushButton_PrevChannel,'Enable','on');
                set(obj.ui_pushButton_NextChannel,'Enable','on');
            end
            
        end
        
        
        % method :: showImage
        %  input :: class object
        % action :: render image on figure
        function obj = showImage(obj)
            
            % create new axes
            if isempty(obj.ih_axes) || ~isgraphics(obj.ih_axes)
                
                % calculate figure resize ratio
                sizeImage = [obj.metaData.height, obj.metaData.width];
                sizeScrn = get(0, 'ScreenSize');
                ratioResize = floor(100*0.8*min(sizeScrn(3:4))/max(sizeImage(1:2)))/100;
                if ratioResize > 1
                    ratioResize = 1;
                end
                
                % calculate figure positions
                figW = ceil(sizeImage(2) * ratioResize);
                figH = ceil(sizeImage(1) * ratioResize);
                figX = round(0.5*(sizeScrn(3) - figW));
                figY = sizeScrn(4) - figH;
                
                obj.ih_figure = figure(...
                       'Color','w',...
                       'Visible','on',...
                       'MenuBar','none',...
                       'ToolBar','none',...
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
                
            else % update CData of old image
                
                set(obj.ih_image,'CData', obj.image);
                set(obj.ih_figure, 'Visible', 'on');
                
            end
            
            
        end
        
        
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
        % callback :: CloseFigure
        %    event :: on close request
        %   action :: dispose image figure
        function obj = fcnCallback_CloseFigure(obj, ~, ~)
            set(obj.ih_figure, 'Visible', 'off');
        end
        
        
        % callback :: PrevChannel
        %    event :: on PrevChannel button click
        %   action :: decrement channel index
        function obj = fcnCallback_PrevChannel(obj, ~, ~)
            obj.indexChannel = obj.indexChannel - 1;
            if (obj.indexChannel < 1)
                obj.indexChannel = obj.metaData.channels;
            end
            obj.updateImage();
        end
        
        
        % callback :: NrevChannel
        %    event :: on NrevChannel button click
        %   action :: increment channel index
        function obj = fcnCallback_NextChannel(obj, ~, ~)
            obj.indexChannel = obj.indexChannel + 1;
            if (obj.indexChannel > obj.metaData.channels)
                obj.indexChannel = 1;
            end
            obj.updateImage();
        end
        
        
        % callback :: PrevStack
        %    event :: on PrevStack button click
        %   action :: decrement stack index
        function obj = fcnCallback_PrevStack(obj, ~, ~)
            obj.indexStack = obj.indexStack - 1;
            if (obj.indexStack < 1)
                obj.indexStack = obj.metaData.stacks;
            end
            obj.updateImage();
        end
        
        
        % callback :: NextStack
        %    event :: on NextStack button click
        %   action :: increment stack index
        function obj = fcnCallback_NextStack(obj, ~, ~)
            obj.indexStack = obj.indexStack + 1;
            if (obj.indexStack > obj.metaData.stacks)
                obj.indexStack = 1;
            end
            obj.updateImage();
        end
        
        
        % callback :: ApplyProjection
        %    event :: on Projection button click
        %   action :: generate required image projection
        function obj = fcnCallback_ApplyProjection(obj, ~, ~)
            
            % read full stack
            img = readLSMImage(obj.fileName,...
                               obj.metaData,...
                               (1:obj.metaData.stacks)',...
                               obj.indexChannel);
            
            % get value from pop up
            
            switch obj.ui_popup_PickProjection.Value
                case 1
                    obj.image = max(img,[],3);
                case 2
                    % fix data range
                    obj.image = sum(img, 3);
                    
                case 3
                    % fix data range
                    obj.image = std(double(img),[],3);
            end
            
            % show image
            obj.showImage();
             
        end
        
    end
    
end