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
    
    %% --- Properties --- %%
    properties
        
        file
        meta
        cdata
        clim
        channel
        stack
        screen
        
    end
    
    properties (Access = public, Hidden = true)
        % Image Window
        
        iw_figure
        iw_axes
        iw_image
        
    end
    
    properties (Access = private, Hidden = true)
        % User Interface
        
        %%% --- image window --- %%%
        iw_panel
        iw_grid
        
        iw_status
        
        iw_pushButton_plusCLim
        iw_pushButton_minusCLim
        
        iw_edit_maxCLim
        iw_edit_minCLim
        iw_edit_usedCLim
        
        iw_popup_pickClass
        iw_checkBox_autoCLim
        
        %%% --- ui handlers --- %%%
        ui_parent
        ui_grid
        ui_panel
        
        ui_pushButton_prevChannel
        ui_pushButton_nextChannel
        ui_pushButton_prevStack
        ui_pushButton_nextStack
        ui_pushButton_project
        
        ui_text_counterChannel
        ui_text_counterStack
        
        ui_popup_pickProjection
        ui_checkBox_keepProjection
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        GUI_WINDOW_POSITION = [1, 1, 250, 130];
        VERTICAL_GAP = [12, 2, 8];
        HORIZONTAL_GAP = [5, 2, 5];
        PUSHBUTTON_POSITION = [1, 1, 90, 26];
        PUSHBUTTON_HALFWIDTH = [1, 1, 45, 26];
        PUSHBUTTON_SMALL = [1, 1, 16, 16];
        
        POPUP_POSITION = [1, 1, 90, 26];
        
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        
        IMG_WINDOW_MARGIN = 32;
        IMG_CLIM_TYPE = {' 8 bit', '12 bit', '16 bit'};
        IMG_CLIM_MAX = [2^8, 2^12, 2^16];
        IMG_PROJ_TYPE = {'max', 'sum', 'std'};
        
    end
    %% --- Events --- %%
    events (NotifyAccess = protected)
        
        event_ImageBrowser_Show
        event_ImageBrowser_Hide
        
    end
    
    %% --- Constructor / Destructor --- %%%
    methods
        
        function obj = WidgetImageBrowser(varargin)
            %WIDGETIMAGEBROWSER class constructor
            
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isgraphics);
            parse(parserObj, varargin{:});
            
            if isempty(parserObj.Results.Parent)
                
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hImageBrowser',...
                    'Name', 'Image Browser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Resize', 'off',...
                    'Units', 'pixels',...
                    'Position', obj.GUI_WINDOW_POSITION,...
                    'CloseRequestFcn', @obj.fcnCallback_closeUI);
                movegui(obj.ui_parent, 'northwest');
                
            else
                
                obj.ui_parent = parserObj.Results.Parent;
                
            end
            
            % set defaults
            obj.defaults();
            
            % render user interface
            obj.renderUI();
            
            % render image window
            obj.renderIW();
            
        end
        
        
        function obj = defaults(obj)
            %DEFAULTS set default values for class properties
            
            % calculate screen dimensions
            screenSize = get(0, 'ScreenSize');
            obj.screen = floor(0.8 * min(screenSize(3:4)));
            
            % allocate empty image
            obj.cdata = zeros(obj.screen, obj.screen, 'uint16');
            obj.clim = [0, obj.IMG_CLIM_MAX(2) - 1];
            
            
            obj.file = [];
            obj.meta = [];
            obj.channel = 1;
            obj.stack = 1;
            
            
            
        end
        
        
        function obj = dispose(obj)
            %DISPOSE class destructor
            
            % remove image window grid
            if isa(obj.iw_grid, 'uiGridLayout')
                delete(obj.iw_grid);
            end
            
            % remove user interface grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % check if image window exists
            if isgraphics(obj.iw_figure, 'figure')
                delete(obj.iw_figure);
            end
            
            % check if parent is figure or was inherit
            if isgraphics(obj.ui_parent, 'figure')
                delete(obj.ui_parent);
            end
            
            % dispose class object
            delete(obj);
            
        end
        
    end
    
    %% --- Render User Interface and Image Window --- %%
    methods
        
        function obj = renderUI(obj)
            %RENDERUI renders user interface panel
            
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
            obj.ui_text_counterChannel = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'text',...
                'String', 'channel 0 / 0',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 1, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_counterChannel,...
                'VIndex', 1,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_prevChannel = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_changeImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_prevChannel,...
                'VIndex', 1,...
                'HIndex', 3,...
                'Anchor', 'center');
            
            obj.ui_pushButton_nextChannel = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_changeImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_nextChannel,...
                'VIndex', 1,...
                'HIndex', 4,...
                'Anchor', 'center');
            
            obj.ui_text_counterStack = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'text',...
                'String', 'stack 0 / 0',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 2, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_counterStack,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_prevStack = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '<<',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_changeImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_prevStack,...
                'VIndex', 2,...
                'HIndex', 3,...
                'Anchor', 'center');
            
            obj.ui_pushButton_nextStack = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', '>>',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_changeImage,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_HALFWIDTH);
            obj.ui_grid.align(obj.ui_pushButton_nextStack,...
                'VIndex', 2,...
                'HIndex', 4,...
                'Anchor', 'center');
            
            obj.ui_popup_pickProjection = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PopUp',...
                'String', obj.IMG_PROJ_TYPE,...
                'Value', 1,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Enable', 'off',...
                'Units', 'pixels',...
                'Position', obj.POPUP_POSITION);
            obj.ui_grid.align(obj.ui_popup_pickProjection,...
                'VIndex', 3,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_project = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'PushButton',...
                'String', 'Projection',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_project,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_POSITION);
            obj.ui_grid.align(obj.ui_pushButton_project,...
                'VIndex', 3,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
            obj.ui_checkBox_keepProjection = uicontrol(...
                'Parent', obj.ui_parent,...
                'Style', 'CheckBox',...
                'String', 'keep projection',...
                'Value', 0,...
                'Enable', 'off',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Callback', @obj.fcnCallback_keepProjection,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 3:4));
            obj.ui_grid.align(obj.ui_checkBox_keepProjection,...
                'VIndex', 4,...
                'HIndex', 3:4,...
                'Anchor', 'center');
            
        end
        
        
        function obj = renderIW(obj)
            %RENDERIW renders image window panel
            
            % render image window handlers
            obj.iw_figure = figure(...
                'Visible','off',...
                'MenuBar','none',...
                'ToolBar','figure',...
                'Name','',...
                'NumberTitle','off',...
                'Resize', 'off',...
                'Units','pixels',...
                'Position', [ 1, 1,...
                             obj.screen + obj.IMG_WINDOW_MARGIN/2,...
                             obj.screen + obj.IMG_WINDOW_MARGIN],...
                'CloseRequestFcn', @obj.fcnCallback_closeIW);
            movegui(obj.iw_figure, 'north');
            
            obj.iw_axes = axes(...
                'Parent', obj.iw_figure,...
                'Units', 'pixels',...
                'Position', [obj.IMG_WINDOW_MARGIN / 4,...
                             obj.IMG_WINDOW_MARGIN / 4,...
                             obj.screen,...
                             obj.screen]);
                         
            obj.iw_image = image(...
                obj.cdata,...
                'Parent', obj.iw_axes,...
                'CDataMapping', 'scaled');
            set(obj.iw_axes,...
                'XTick', [],...
                'YTick', [],...
                'CLim', obj.clim);
            colormap(obj.iw_axes, 'gray');
            
            % render UI elements on image window
            obj.iw_panel = uipanel(...
                'Parent', obj.iw_figure,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position',[obj.IMG_WINDOW_MARGIN / 4,...
                            obj.screen + obj.IMG_WINDOW_MARGIN / 4 + obj.IMG_WINDOW_MARGIN / 8,...
                            obj.screen,...
                            obj.IMG_WINDOW_MARGIN / 2 + obj.IMG_WINDOW_MARGIN / 8]);
            
            obj.iw_grid = uiGridLayout(...
                'Parent', obj.iw_panel,...
                'VGrid', 1,...
                'HGrid', 22,...
                'HGap',[0, 2, 0],...
                'VGap',[0, 0, 0]);
            
            obj.iw_status = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'text',...
                'String', 'status message',...
                'Units', 'pixels',...
                'Position', obj.iw_grid.getGrid('VIndex', 1, 'HIndex', 1:11));
            obj.iw_grid.align(obj.iw_status, 'VIndex', 1, 'HIndex', 1:11, 'Anchor', 'west');
            
            obj.iw_popup_pickClass = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'popupmenu',...
                'String', obj.IMG_CLIM_TYPE,...
                'Value', 2,...
                'Callback', @obj.fcnCallback_pickClass,...
                'Units', 'pixels',...
                'Position', obj.iw_grid.getGrid('VIndex', 1, 'HIndex', 11:13));
            obj.iw_grid.align(obj.iw_popup_pickClass,...
                'VIndex', 1,...
                'HIndex', 12:14,...
                'Anchor', 'center');
            
            
            obj.iw_pushButton_minusCLim = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'PushButton',...
                'String', '-',...
                'TooltipString', 'right click on box to decrement CLim',...
                'Callback', @obj.fcnCallback_pushCLim,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SMALL);
            obj.iw_grid.align(obj.iw_pushButton_minusCLim,...
                'VIndex', 1,...
                'HIndex', 15,...
                'Anchor','east');
            
            obj.iw_pushButton_plusCLim = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'PushButton',...
                'String', '+',...
                'TooltipString', 'right click on box to increment CLim',...
                'Callback', @obj.fcnCallback_pushCLim,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SMALL);
            obj.iw_grid.align(obj.iw_pushButton_plusCLim,...
                'VIndex', 1,...
                'HIndex', 20,...
                'Anchor','west');
            
            obj.iw_edit_minCLim = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'edit',...
                'String', sprintf('%d', obj.clim(1)),...
                'Callback', @obj.fcnCallback_editCLim,...
                'ButtonDownFcn', @obj.fcnCallback_setUsedCLim,...
                'Units', 'pixels',...
                'Position', obj.iw_grid.getGrid('VIndex', 1, 'HIndex', 16:17));
            obj.iw_grid.align(obj.iw_edit_minCLim,...
                'VIndex', 1,...
                'HIndex', 16:17,...
                'Anchor', 'center');
            
            obj.iw_edit_maxCLim = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'edit',...
                'String', sprintf('%d', obj.clim(2)),...
                'Callback', @obj.fcnCallback_editCLim,...
                'ButtonDownFcn', @obj.fcnCallback_setUsedCLim,...
                'Units', 'pixels',...
                'Position', obj.iw_grid.getGrid('VIndex', 1, 'HIndex', 18:19));
            obj.iw_grid.align(obj.iw_edit_maxCLim,...
                'VIndex', 1,...
                'HIndex', 18:19,...
                'Anchor', 'center');
            
            obj.iw_checkBox_autoCLim = uicontrol(...
                'Parent', obj.iw_panel,...
                'Style', 'checkbox',...
                'String', 'auto',...
                'Value', 0,...
                'Enable', 'on',...
                'Callback', @obj.fcnCallback_autoCLim,...
                'Units', 'pixels',...
                'Position', obj.iw_grid.getGrid('VIndex', 1, 'HIndex', 21:22));
            obj.iw_grid.align(obj.iw_checkBox_autoCLim,...
                'VIndex', 1,...
                'HIndex', 21:22,...
                'Anchor', 'center');
            
            % default used handle
            obj.iw_edit_usedCLim = obj.iw_edit_maxCLim;
            
        end
        
    end
    
    %% --- Callbacks --- %%
    methods
        
        function obj = fcnCallback_closeUI(obj, ~, ~)
            %FCN_CALLBACK_CLOSEUI trigger dispose method
            % on user close request
            
            obj.dispose();
            
        end
        
        function obj = fcnCallback_closeIW(obj, ~, ~)
            %FCN_CALLBACK_CLOSEIW trigger event Hide and
            % hides image window on user close request
            
            % hide figure
            set(obj.iw_figure, 'Visible', 'off');
            
            % fire an event
            notify(obj, 'event_ImageBrowser_Hide');
            
        end
        
        
        function obj = fcnCallback_changeImage(obj, hSrc, ~)
            %FCNCALLBACK_CHANGEIMAGE increment / decrement
            % stack / channel counters and calls read pipeline
            
            % update image index
            switch hSrc
                case obj.ui_pushButton_prevChannel
                    
                    obj.channel = obj.channel - 1;
                    if (obj.channel < 1)
                        obj.channel = obj.meta.channels;
                    end
                    
                case obj.ui_pushButton_nextChannel
                    
                    obj.channel = obj.channel + 1;
                    if (obj.channel > obj.meta.channels)
                        obj.channel = 1;
                    end
                    
                case obj.ui_pushButton_prevStack
                    
                    obj.stack = obj.stack - 1;
                    if (obj.stack < 1)
                        obj.stack = obj.meta.stacks;
                    end
                    
                case obj.ui_pushButton_nextStack
                    
                    obj.stack = obj.stack + 1;
                    if (obj.stack > obj.meta.stacks)
                        obj.stack = 1;
                    end
                    
            end
            
            % pipeline
            if get(obj.ui_checkBox_keepProjection, 'Value') == 1
                
                obj.project();
                
            else
                
                obj.readCData();
                obj.updateCData();
                obj.status();
                
            end
            
            
        end
        
        
        function obj = fcnCallback_project(obj, ~, ~)
            %FCNCALLBACK_PROJECT apply projection
            
            obj.project();
            
        end
        
        function obj = fcnCallback_keepProjection(obj, hSrc, ~)
            
            % enable / disable stack buttons
            value = get(hSrc, 'Value');
            if value == 1
                
                set(obj.ui_pushButton_prevStack, 'Enable', 'off');
                set(obj.ui_pushButton_nextStack, 'Enable', 'off');
                set(obj.ui_pushButton_project, 'Enable', 'off');
                set(obj.ui_popup_pickProjection, 'Enable', 'off');
                
                obj.project();
                
            elseif value == 0
                
                set(obj.ui_pushButton_prevStack, 'Enable', 'on');
                set(obj.ui_pushButton_nextStack, 'Enable', 'on');
                set(obj.ui_pushButton_project, 'Enable', 'on');
                set(obj.ui_popup_pickProjection, 'Enable', 'on');
                
            end
            
        end
        
        
        function obj = fcnCallback_pickClass(obj, hSrc, ~)
            
            % get current value
            classIndex = get(hSrc, 'Value');
            
            % update CLim
            obj.clim(1) = 0;
            obj.clim(2) = obj.IMG_CLIM_MAX(classIndex) - 1;
            
            % update automatic CLim
            set(obj.iw_checkBox_autoCLim, 'Value', 0);
            
            % update axes CLim
            obj.rescale(obj.clim);
            
        end
        
        function obj = fcnCallback_setUsedCLim(obj, hSrc, ~)
            %FCNCALLBACK_SETUSEDCLIM sets the last used CLIM
            
            if hSrc == obj.iw_edit_minCLim
                
                obj.iw_edit_usedCLim = obj.iw_edit_minCLim;
                
            elseif hSrc == obj.iw_edit_maxCLim
                
                obj.iw_edit_usedCLim = obj.iw_edit_maxCLim;
                
            end
            
        end
        
        
        function obj = fcnCallback_editCLim(obj, hSrc, ~)
            %FCNCALLBACK_EDITCLIM edit CLim range
            
            % set CLim index
            if hSrc == obj.iw_edit_minCLim
                
                index = 1;
                obj.iw_edit_usedCLim = obj.iw_edit_minCLim;
                
            elseif hSrc == obj.iw_edit_maxCLim
                
                index = 2;
                obj.iw_edit_usedCLim = obj.iw_edit_maxCLim;
                
            end
            
            % parse value
            varchar = get(hSrc, 'String');
            varchar = regexp(varchar, '\d+', 'match');
            value = str2double(varchar);
            
            % check value range
            value(isempty(value)) = obj.clim(index);
            value(isnan(value)) = obj.clim(index);
            value(value < 0) = 0;
            maxCLim = obj.IMG_CLIM_MAX(get(obj.iw_popup_pickClass, 'Value'));
            value(value >= maxCLim) = maxCLim - 1;
            
            % set value & check for overlap
            oldValue = obj.clim(index);
            obj.clim(index) = value;
            if diff(obj.clim) <= 0
                obj.clim(index) = oldValue;
            end
            
            % update axes CLim
            obj.rescale(obj.clim);
            
        end
        
        
        function obj = fcnCallback_pushCLim(obj, hSrc, ~)
            %FCNCALLBACK_PUSHCLIM adjust CLim range
            
            % set increment value
            if hSrc == obj.iw_pushButton_minusCLim
                
                increment = -1;
            
            elseif hSrc == obj.iw_pushButton_plusCLim
                
                increment = 1;
                
            end
            
            % set CLim index
            if obj.iw_edit_usedCLim == obj.iw_edit_minCLim
                
                index = 1;
                
            elseif obj.iw_edit_usedCLim == obj.iw_edit_maxCLim
                
                index = 2;
                
            end
            
            % update CLim
            obj.clim(index) = obj.clim(index) + increment;
            
            % check if CLim overlap
            if diff(obj.clim) == 0
                
                obj.clim(index) = obj.clim(index) - increment;
                
            end
            
            % check CLim range
            obj.clim(obj.clim < 0) = 0;
            maxCLim = obj.IMG_CLIM_MAX(get(obj.iw_popup_pickClass, 'Value'));
            obj.clim(obj.clim == maxCLim) = maxCLim - 1;
            
            % update axes CLim
            obj.rescale(obj.clim);
            
        end
        
        
        function obj = fcnCallback_autoCLim(obj, ~, ~)
            %FCNCALLBACK set CLim to current image min and max values
            
            obj.autoscale();
            
        end
        
        
    end
    
    %% --- Functional Methods --- %%
    methods
        
        function obj = enable(obj)
            %ENABLE activate/deactivate buttons
            
            % update stack buttons callbacks
            if obj.meta.stacks == 1
                
                set(obj.ui_pushButton_prevStack, 'Enable', 'off');
                set(obj.ui_pushButton_nextStack, 'Enable', 'off');
                set(obj.ui_pushButton_project, 'Enable', 'off');
                set(obj.ui_popup_pickProjection, 'Enable', 'off');
                set(obj.ui_checkBox_keepProjection, 'Enable', 'off');
                
            else
                
                set(obj.ui_pushButton_prevStack, 'Enable', 'on');
                set(obj.ui_pushButton_nextStack, 'Enable', 'on');
                set(obj.ui_pushButton_project, 'Enable', 'on');
                set(obj.ui_popup_pickProjection, 'Enable', 'on');
                set(obj.ui_checkBox_keepProjection, 'Enable', 'on');
                
            end
            
            % update channel buttons callback
            if obj.meta.channels == 1
                
                set(obj.ui_pushButton_prevChannel, 'Enable', 'off');
                set(obj.ui_pushButton_nextChannel, 'Enable', 'off');
                
            else
                
                set(obj.ui_pushButton_prevChannel, 'Enable', 'on');
                set(obj.ui_pushButton_nextChannel, 'Enable', 'on');
                
            end
            
            % check if keep projection is active
            if get(obj.ui_checkBox_keepProjection, 'Value') == 1
                
                set(obj.ui_pushButton_prevStack, 'Enable', 'off');
                set(obj.ui_pushButton_nextStack, 'Enable', 'off');
                set(obj.ui_pushButton_project, 'Enable', 'off');
                set(obj.ui_popup_pickProjection, 'Enable', 'off');
                
            end
            
        end
        
        
        function obj = open(obj, fileName)
            %OPEN open new file name to browser
            
            % set file name
            obj.file = fileName;
            [~, fileTag] = fileparts(obj.file);
            set(obj.iw_figure, 'Name', fileTag);
            
            % read meta info
            obj.readMetaData();
            
            % either read curren or project
            if get(obj.ui_checkBox_keepProjection, 'Value') == 1
                
                obj.project();
                
            else
                
                obj.stack = 1;
                obj.channel = 1;
                obj.readCData();
                obj.updateCData();
                
            end
            
            % enable UI
            obj.enable();
            
            % status
            obj.status();
            
        end
        
        function obj = autoscale(obj)
            %AUTOSCALE sets axes clim on each image
            
            if get(obj.iw_checkBox_autoCLim, 'Value') == 1
                
                obj.clim(1) = min(obj.cdata(:));
                obj.clim(2) = max(obj.cdata(:));
                
            elseif get(obj.iw_checkBox_autoCLim, 'Value') == 0
                
                obj.clim(1) = 0;
                obj.clim(2) = obj.IMG_CLIM_MAX(get(obj.iw_popup_pickClass, 'Value'));
                
            end
            
            % check CLim range
            obj.clim(obj.clim < 0) = 0;
            maxCLim = obj.IMG_CLIM_MAX(get(obj.iw_popup_pickClass, 'Value'));
            obj.clim(obj.clim >= maxCLim) = maxCLim - 1;
            
            % check overlap
            if diff(obj.clim) <= 0
                
                if obj.clim(2) < (maxCLim - 2)
                    obj.clim(2) = obj.clim(2) + 1;
                else
                    obj.clim(1) = obj.clim(1) - 1;
                end
                
            end
            
            % update axes CLim
            obj.rescale(obj.clim);
            
        end
        
        
        function obj = rescale(obj, clim)
            %RESCALE sets axes clim property to the required one
            
            % reset text
            set(obj.iw_edit_minCLim, 'String', sprintf('%d', obj.clim(1)));
            set(obj.iw_edit_maxCLim, 'String', sprintf('%d', obj.clim(2)));
            
            % update CLim axes property
            set(obj.iw_axes, 'CLim', clim);
            
        end
        
        function obj = readMetaData(obj)
            %READMETADATA reads meta data from image file
            
            obj.meta = readLSMInfo(obj.file);
            
        end
        
        function obj = readCData(obj)
            %READCDATA reads pixel data from image file
            
            obj.cdata = readLSMImage(obj.file,...
                                     obj.meta,...
                                     obj.stack,...
                                     obj.channel);
                                 
        end
        
        function obj = updateCData(obj)
            %UPDATECDATA updates pixels data on axes
            
            % rescale axes
            obj.autoscale();
            
            % update CData 
            set(obj.iw_image, 'CData', obj.cdata);
            
            % set axes limits
            set(obj.iw_axes, 'XLim', [0.5, size(obj.cdata,2) + 0.5]);
            set(obj.iw_axes, 'YLim', [0.5, size(obj.cdata,1) + 0.5]);
            
            
            % update fiugre visibility
            set(obj.iw_figure, 'Visible', 'on');
            
            % notify that image is shown
            notify(obj, 'event_ImageBrowser_Show');
            
        end
        
        function obj = project(obj)
            %PROJECT executes image projection
            
            % old stack position
            stackNow = obj.stack;
            obj.stack = (1:obj.meta.stacks)';
            
            % read full stack
            obj.readCData();
            
            % restore stack position
            obj.stack = stackNow;
            
            % get value from pop up
            switch get(obj.ui_popup_pickProjection, 'Value')
                case 1
                    
                    obj.cdata = max(obj.cdata, [], 3);
                    
                case 2
                    
                    obj.cdata = im2uint16(sum(double(obj.cdata), 3));
                    set(obj.iw_popup_pickClass, 'Value', 3);
                    obj.clim = [0,obj.IMG_CLIM_MAX(3) - 1];
                    obj.rescale(obj.clim);
                    
                case 3
                    
                    obj.cdata = im2uint16(std(double(obj.cdata), [], 3));
                    set(obj.iw_popup_pickClass, 'Value', 3);
                    obj.clim = [0,obj.IMG_CLIM_MAX(3) - 1];
                    obj.rescale(obj.clim);
                    
            end
            
            % update CData
            obj.updateCData();
            
            obj.status();
            
        end
        
        
        function obj = status(obj)
            
            % compose message
            varchar = sprintf('%s, %dx%d (%.2fx%.2f um), intensity [%d,%d]',...
                              obj.IMG_CLIM_TYPE{get(obj.iw_popup_pickClass,'Value')},...
                              obj.meta.height,...
                              obj.meta.width,...
                              obj.meta.height * obj.meta.yResolution,...
                              obj.meta.width * obj.meta.xResolution,...
                              min(obj.cdata(:)),...
                              max(obj.cdata(:)));
           
           % update status message
           set(obj.iw_status, 'String', varchar);
           obj.iw_grid.align(obj.iw_status,...
               'VIndex', 1,...
               'HIndex', 1:11,...
               'Anchor', 'west');
           
           % update channel
           set(obj.ui_text_counterChannel, 'String',...
               sprintf('channel %d / %d',...
               obj.channel, obj.meta.channels));
           obj.ui_grid.align(obj.ui_text_counterChannel,...
               'VIndex', 1,...
               'HIndex', 1:2,...
               'Anchor', 'center');
           
           % update stack
           set(obj.ui_text_counterStack, 'String',...
               sprintf('stack %d / %d',...
               obj.stack, obj.meta.stacks));
           obj.ui_grid.align(obj.ui_text_counterStack,...
               'VIndex', 2,...
               'HIndex', 1:2,...
               'Anchor', 'center');
                              
        end
        
    end
end