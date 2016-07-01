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
        
        file
        
    end
    
    properties (Access = public, Hidden = true)
        
        image
        info
        
        %%% --- image figure handlers --- %%%
        ih_figure
        ih_axes
        ih_image
        
    end
    
    properties (Access = private, Hidden = true)
        
        %%% --- state properties --- %%%
        indexChannel
        indexStack
        span
        
        %%% --- ui handlers --- %%%
        ui_parent
        ui_grid
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
        
        GUI_WINDOW_POSITION = [1, 1, 250, 130];
        VERTICAL_GAP = [12, 2, 8];
        HORIZONTAL_GAP = [5, 2, 5];
        PUSHBUTTON_POSITION = [1, 1, 90, 26];
        PUSHBUTTON_HALFWIDTH = [1, 1, 45, 26];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        FONT_SIZE = 8;
        
    end
    
    events (NotifyAccess = protected)
        event_ImageBrowser_Show
        event_ImageBrowser_Hide
    end
    
    methods
        
        % method :: WidgetImageBrowser
        %  input :: varargin
        % action :: class constructor
        function obj = WidgetImageBrowser(varargin)
            
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isgraphics);
            addParameter(parserObj, 'FileName', [], @ischar);
            parse(parserObj, varargin{:});
            
            if isempty(parserObj.Results.Parent)
                
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hFolderBrowser',...
                    'Name', 'FolderBrowser',...
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
            
            % set filename
            obj.file = parserObj.Results.FileName;
            
            % set defaults
            obj.image = [];
            obj.info = [];
            obj.indexChannel = 1;
            obj.indexStack = 1;
            
            % render user interface
            obj.renderUI();
            
            % render image
            obj.renderImage();
            
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
                'Title', 'Image Browser',...
                'TitlePosition', 'lefttop',...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', abs(obj.GUI_WINDOW_POSITION - 4));
           
           
            %%% --- add UI elemnts --- %%%
            obj.ui_text_ImageResolution = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'text',...
                'String', 'load image',...
                'FontSize', obj.FONT_SIZE,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 1, 'HIndex', 1:4));
            obj.ui_grid.align(obj.ui_text_ImageResolution,...
                'VIndex', 1,...
                'HIndex', 1:4,...
                'Anchor', 'center');
            
            obj.ui_text_ChannelCounter = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'text',...
                'String', 'channel 0 / 0',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 2, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_ChannelCounter,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            
            obj.ui_pushButton_PrevChannel = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_UpdateImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_PrevChannel,...
                'VIndex', 2,...
                'HIndex', 3,...
                'Anchor', 'center');
            
            obj.ui_pushButton_NextChannel = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_UpdateImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_NextChannel,...
                'VIndex', 2,...
                'HIndex', 4,...
                'Anchor', 'center');
            
            obj.ui_text_StackCounter = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'text',...
                'String', 'stack 0 / 0',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 3, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_StackCounter,...
                'VIndex', 3,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_PrevStack = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_UpdateImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_PrevStack,...
                'VIndex', 3,...
                'HIndex', 3,...
                'Anchor', 'center');
            
            obj.ui_pushButton_NextStack = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_UpdateImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_NextStack,...
                'VIndex', 3,...
                'HIndex', 4,...
                'Anchor', 'center');
            
            obj.ui_pushButton_ApplyProjection = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Projection',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_ApplyProjection,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_ApplyProjection,...
                'VIndex', 4,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_popup_PickProjection = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PopUp',...
                'String', {'Max';'Sum';'Std'},...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Enable', 'off',...
                'Callback', [],...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_popup_PickProjection,...
                'VIndex', 4,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
        end
        
        % method :: renderImage
        %  input :: class object
        % action :: creates image figure
        function obj = renderImage(obj)
            
            
            % calculate screen dimensions
            sizeScrn = get(0, 'ScreenSize');
            obj.span = floor(0.8 * min(sizeScrn(3:4)));
            
            % allocate empty image
            obj.image = 255 .* ones(obj.span, obj.span, 'uint8');
            
            % render image handlers
        	obj.ih_figure = figure(...
            	'Color','w',...
                'Visible','off',...
                'MenuBar','figure',...
                'ToolBar','figure',...
                'Name','',...
                'NumberTitle','off',...
                'Units','pixels',...
                'Position', [ 1, 1, obj.span, obj.span],...
                'CloseRequestFcn', @obj.fcnCallback_CloseImageFigure);
                   
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
            
            % update position
            movegui(obj.ih_figure, 'north');
            
        end
        
        % method :: resizeImageFigure
        %  input :: class object
        % action :: adapt image figure to new image dimensions
        function obj = resizeImageFigure(obj)
            
            % re-render image handler
            obj.ih_image = imshow(...
                obj.image, [],...
                'Parent', obj.ih_axes,...
                'Border', 'tight',...
                'InitialMagnification', 'fit');
            
            set(obj.ih_figure, 'Visible', 'on');
            
            % notify that image is shown
            notify(obj, 'event_ImageBrowser_Show');
            
        end
        % method :: readImageInfo
        %  input :: class object
        % action :: reads image meta data
        function obj = readImageInfo(obj)
            
            obj.info = readLSMInfo(obj.file);
            
        end
        
        % method :: readImageCData
        %  input :: class object
        % action :: reads image pixel data
        function obj = readImageCData(obj)
            
            obj.image = readLSMImage(obj.file,...
                                     obj.info,...
                                     obj.indexStack,...
                                     obj.indexChannel);
                                 
        end
        
        % method :: updateFileName
        %  input :: class object, fileName
        % action :: update file name and image figure
        function obj = updateFileName(obj, fileName)
            
            % set new file name
            obj.file = fileName;
            [~, name] = fileparts(obj.file);
            set(obj.ih_figure, 'Name', name);
            
            % read image info
            obj.readImageInfo();
            
            % set default indexes
            obj.indexStack = 1;
            obj.indexChannel = 1;
            
            % read current image
            obj.readImageCData();
            
            % resize image figure
            obj.resizeImageFigure();
            
            % enable button group
            obj.enableButtonGroup();
            
            % update status
            obj.updateStatus();
            
        end
        
        % method :: updateCData
        %  input :: class object
        % action :: update image pixel data
        function obj = updateCData(obj)
            
            % update CData
            set(obj.ih_image, 'CData', obj.image);
            
            % update figure visibility
            set(obj.ih_figure, 'Visible', 'on');
            
            % notify that image is shown
            notify(obj, 'event_ImageBrowser_Show');
            
        end
        
        
        % method :: enableButtonGroup
        %  input :: class object
        % action :: update button group
        function obj = enableButtonGroup(obj)
            
            % update stack buttons callbacks
            if obj.info.stacks == 1
                
                set(obj.ui_pushButton_PrevStack, 'Enable', 'off');
                set(obj.ui_pushButton_NextStack, 'Enable', 'off');
                set(obj.ui_pushButton_ApplyProjection, 'Enable', 'off');
                set(obj.ui_popup_PickProjection, 'Enable', 'off');
                
            else
                
                set(obj.ui_pushButton_PrevStack, 'Enable','on');
                set(obj.ui_pushButton_NextStack, 'Enable','on');
                set(obj.ui_pushButton_ApplyProjection, 'Enable','on');
                set(obj.ui_popup_PickProjection, 'Enable', 'on');
                
            end
            
            % update channel buttons callbacks
            if obj.info.channels == 1
                
                set(obj.ui_pushButton_PrevChannel, 'Enable', 'off');
                set(obj.ui_pushButton_NextChannel, 'Enable', 'off');
                
            else
                
                set(obj.ui_pushButton_PrevChannel, 'Enable', 'on');
                set(obj.ui_pushButton_NextChannel, 'Enable', 'on');
                
            end
            
        end
        
        
        % method :: updateStatus
        %  input :: class object
        % action :: update status message
        function obj = updateStatus(obj)
            
            % update meta data message
            set(obj.ui_text_ImageResolution,...
                'String',sprintf('%d bits, HxW %d x %d (%.2f x %.2f um), intensity [%d, %d]',...
                obj.info.bitsPerSample,...
                obj.info.height,...
                obj.info.width,...
                obj.info.height * obj.info.yResolution,...
                obj.info.width * obj.info.xResolution,...
                min(obj.image(:)),...
                max(obj.image(:))));
            obj.ui_grid.align(obj.ui_text_ImageResolution,...
                'VIndex', 1,...
                'HIndex', 1:4,...
                'Anchor', 'center');
            
            set(obj.ui_text_ChannelCounter,...
                'String',sprintf('channel %d / %d',...
                obj.indexChannel, obj.info.channels));
            obj.ui_grid.align(obj.ui_text_ChannelCounter,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            set(obj.ui_text_StackCounter,...
                'String',sprintf('stack %d / %d',...
                obj.indexStack, obj.info.stacks));
            obj.ui_grid.align(obj.ui_text_StackCounter,...
                'VIndex', 3,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
        end
        
        % method :: dispose
        %  input :: class object
        % action :: class destructor
        function obj = dispose(obj)
            
            % check if image figure exists
            if isgraphics(obj.ih_figure, 'figure')
                delete(obj.ih_figure);
            end
            
            % remove grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % check if parent is figure or was inherit
            if isgraphics(obj.ui_parent, 'figure')
                delete(obj.ui_parent);
            end
            
            % dispose class object
            delete(obj);
            
        end
        
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close UI window request
        %   action :: call class destructor method
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            obj.dispose();
            
        end
        
        
        % callback :: CloseImageWindow
        %    event :: on close image request
        %   action :: dispose image figure
        function obj = fcnCallback_CloseImageFigure(obj, ~, ~)
            
            % hide figure
            set(obj.ih_figure, 'Visible', 'off');
            
            % fire an event
            notify(obj, 'event_ImageBrowser_Hide');
            
        end
        
        % callback :: UpdateImage
        %    event :: on browsing button click
        %   action :: reads and re-render image from file
        function obj = fcnCallback_UpdateImage(obj, hSrc, ~)
            
            % update image index
            switch hSrc
                case obj.ui_pushButton_PrevChannel
                    
                    obj.indexChannel = obj.indexChannel - 1;
                    if (obj.indexChannel < 1)
                        obj.indexChannel = obj.info.channels;
                    end
                    
                case obj.ui_pushButton_NextChannel
                    
                    obj.indexChannel = obj.indexChannel + 1;
                    if (obj.indexChannel > obj.info.channels)
                        obj.indexChannel = 1;
                    end
                    
                case obj.ui_pushButton_PrevStack
                    
                    obj.indexStack = obj.indexStack - 1;
                    if (obj.indexStack < 1)
                        obj.indexStack = obj.info.stacks;
                    end
                    
                case obj.ui_pushButton_NextStack
                    
                    obj.indexStack = obj.indexStack + 1;
                    if (obj.indexStack > obj.info.stacks)
                        obj.indexStack = 1;
                    end
                    
            end
            
            % update status
            obj.updateStatus();
            
            % read current image
            obj.readImageCData();
            
            % update CData
            obj.updateCData();
            
        end
        
        
        % callback :: ApplyProjection
        %    event :: on Projection button click
        %   action :: generate required image projection
        function obj = fcnCallback_ApplyProjection(obj, ~, ~)
            
            % update stack index
            indexStackLast = obj.indexStack;
            obj.indexStack = (1:obj.info.stacks)';
            
            % read full stack
            obj.readImageCData();
            
            % re-initialize index
            obj.indexStack = indexStackLast;
            
            
            % get value from pop up
            switch obj.ui_popup_PickProjection.Value
                case 1
                    
                    obj.image = max(obj.image,[],3);
                    
                case 2
                    
                    % rescale
                    obj.image = im2uint16(sum(obj.image, 3));
                    
                case 3
                    
                    % rescale
                    obj.image = im2uint16(std(double(obj.image),[],3));
                    
            end
            
            % update CData
            obj.updateCData();
             
        end
        
    end
    
end