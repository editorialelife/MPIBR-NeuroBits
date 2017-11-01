classdef WidgetImageBrowserUi < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    %% --- properties --- %%
    properties (Access = private)
        
        text_status
        
        text_counterChannel
        text_counterStack
        pushButton_prevChannel
        pushButton_prevStack
        pushButton_nextChannel
        pushButton_nextStack
        
        popup_pickProjection
        pushButton_project
        checkBox_keepProjection
        
        popup_pickClim
        editBox_minClim
        editBox_maxClim
        
    end
    
    properties (Access = private)
        
        parent
        layoutWidget
        panelWidget
        panelStatus
        panelTabs
        varstepStack
        varstepChannel
        
    end
    
    properties (Constant = true, Access = protected, Hidden = true)
        
        UI_WINDOW_SIZE = [1, 1, 256, 256];
        UI_GRID_PADDING = 5;
        UI_GRID_SPACING = 5;
        UI_BUTTON_SIZE = [90, 26];
        UI_POPUP_CHOOSE_PROJECTION = {'max','mean','std'};
        UI_POPUP_CHOOSE_CLIM = {'auto', '8bit', '16bit', 'custom'};
        UI_LIMITS_CHOOS_CLIM = [-1, -1;...
                                0, 2^8-1;...
                                0, 2^16-1;...
                                0, 1];
        
    end
    
    %% --- events --- %%
    events
        
        event_changeChannel
        event_changeStack
        event_changeCLimit
        event_changeProjection
        
    end
    
    
    %% --- constructor methods --- %%
    methods
        
        function obj = WidgetImageBrowserUi(ui_parent)
            
            
            %%% set widget parent
            if isempty(ui_parent)
                
                obj.parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetImageBrowserUi',...
                    'Name', 'ImageBrowser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UI_WINDOW_SIZE);
                movegui(obj.parent, 'northwest');
                
            elseif isgraphics(ui_parent)
                
                obj.parent = ui_parent;
                
            else
                
                error('WidgetImageBrowser:Ui: invalid handle for parent');
                
            end
            
            %%% set widget layout
            obj.panelWidget = uix.Panel(...
                'Parent', obj.parent,...
                'Padding', obj.UI_GRID_PADDING,...
                'Title', 'ImageBrowser');
            
            obj.layoutWidget = uix.VBoxFlex(...
                'Parent', obj.panelWidget,...
                'DividerMarkings', 'off',...
                'Spacing', obj.UI_GRID_SPACING);
            
            %%% create status panel
            obj.panelStatus = uix.Panel(...
                'Parent', obj.layoutWidget,...
                'Padding', obj.UI_GRID_PADDING,...
                'Title', 'status');
            
            %%% create tab panel
            obj.panelTabs = uix.TabPanel(...
                'Parent', obj.layoutWidget,...
                'Padding', 0);
            
            %%% re-size panels
            set(obj.layoutWidget, 'Heights', [obj.UI_BUTTON_SIZE(2)*2, -1]);
            
            %%% populate panels
            obj.uistatus();
            obj.uitabnavigate();
            obj.uitabproject();
            obj.uitabviewlimits();
            
            %%% assign callbacks
            obj.uicallbacks();
            
        end
        
        function obj = uistatus(obj)
            
            obj.text_status = uicontrol(...
                'Parent', obj.panelStatus,...
                'Style', 'text',...
                'String', 'choose image',...
                'HorizontalAlignment', 'center');
            
        end
        
        function obj = uitabnavigate(obj)

            %% --- add new tab to group --- %%
            tabNavigate = uix.Panel('Parent', obj.panelTabs);
            obj.panelTabs.TabTitles(end) = {'navigate'};

            %% --- image navigation --- %%
            layoutNavigate = uiextras.VBoxFlex(...
                'Parent', tabNavigate);

            buttonGroup_channel = uix.HButtonBox(...
                'Parent', layoutNavigate,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            obj.text_counterChannel = uicontrol(...
                'Parent', buttonGroup_channel,...
                'Style', 'text',...
                'String', 'channel 1 / 1');    

            obj.pushButton_prevChannel = uicontrol(...
                'Parent', buttonGroup_channel,...
                'Style', 'pushbutton',...
                'String', '<<',...
                'Enable', 'on');

            obj.pushButton_nextChannel = uicontrol(...
                'Parent', buttonGroup_channel,...
                'Style', 'pushbutton',...
                'String', '>>',...
                'Enable', 'on');

            buttonGroup_stack = uix.HButtonBox(...
                'Parent', layoutNavigate,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            obj.text_counterStack = uicontrol(...
                'Parent', buttonGroup_stack,...
                'Style', 'text',...
                'String', 'stack 1 / 1');    

            obj.pushButton_prevStack = uicontrol(...
                'Parent', buttonGroup_stack,...
                'Style', 'pushbutton',...
                'String', '<<',...
                'Enable', 'on');

            obj.pushButton_nextStack = uicontrol(...
                'Parent', buttonGroup_stack,...
                'Style', 'pushbutton',...
                'String', '>>',...
                'Enable', 'on');


        end

        
        function obj = uitabproject(obj)

            %% --- add new tab to group --- %%
            tabProject = uix.Panel('Parent', obj.panelTabs);
            obj.panelTabs.TabTitles(end) = {'project'};

            %% --- image projection --- %%
            layoutProject = uix.VBoxFlex(...
                'Parent', tabProject);

            buttonGroup_popup = uix.HButtonBox(...
                'Parent', layoutProject,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            obj.popup_pickProjection = uicontrol(...
                'Parent', buttonGroup_popup,...
                'Style', 'popup',...
                'String', obj.UI_POPUP_CHOOSE_PROJECTION);

            buttonGroup_click = uix.HButtonBox(...
                'Parent', layoutProject,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            obj.pushButton_project = uicontrol(...
                'Parent', buttonGroup_click,...
                'Style', 'pushbutton',...
                'String', 'project');

            obj.checkBox_keepProjection = uicontrol(...
                'Parent', buttonGroup_click,...
                'Style', 'checkbox',...
                'String', 'keep',...
                'Value', 0);


        end

        
        function obj = uitabviewlimits(obj)

            %% --- add new tab to group --- %%
            tabViewLimit = uix.Panel('Parent', obj.panelTabs);
            obj.panelTabs.TabTitles(end) = {'view'};

            %% --- image navigation --- %%
            layoutViewLimit = uix.VBoxFlex(...
                'Parent', tabViewLimit);

            buttonGroup_pickClim = uix.HButtonBox(...
                'Parent', layoutViewLimit,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            obj.popup_pickClim = uicontrol(...
                'Parent', buttonGroup_pickClim,...
                'Style', 'popup',...
                'String', obj.UI_POPUP_CHOOSE_CLIM);

            buttonGroup_editClim = uix.HButtonBox(...
                'Parent', layoutViewLimit,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            uicontrol(...
                'Parent', buttonGroup_editClim,...
                'Style', 'text', ...
                'String', 'min');

            obj.editBox_minClim = uicontrol(...
                'Parent', buttonGroup_editClim,...
                'Style', 'edit',...
                'String', '0',...
                'Enable', 'off');

            obj.editBox_maxClim = uicontrol(...
                'Parent', buttonGroup_editClim,...
                'Style', 'edit',...
                'String', '1',...
                'Enable', 'off');

            uicontrol(...
                'Parent', buttonGroup_editClim,...
                'Style', 'text', ...
                'String', 'max');

        end
        
        function obj = enable(obj, varstate)
            
            set(obj.pushButton_nextChannel, 'Enable', varstate);
            set(obj.pushButton_nextStack, 'Enable', varstate);
            set(obj.pushButton_prevChannel, 'Enable', varstate);
            set(obj.pushButton_prevStack, 'Enable', varstate);
            set(obj.pushButton_project, 'Enable', varstate);
            set(obj.popup_pickProjection, 'Enable', varstate);
            set(obj.popup_pickClim, 'Enable', varstate);
            set(obj.checkBox_keepProjection, 'Enable', varstate);
            
        end
        
    end
    
    %% --- viewer interactions --- %%
    methods
        
        function obj = updateStatus(obj, vartext)
            
            set(obj.text_status, 'String', vartext);
            
        end
        
        function obj = updateLabelChannel(obj, vartext)
            
            set(obj.text_counterChannel, 'String', vartext);
            
        end
        
        function obj = updateLabelStack(obj, vartext)
            
            set(obj.text_counterStack, 'String', vartext);
            
        end
        
        function valueProjectionType = requestProjectionType(obj)
            
            valueProjectionType = obj.UI_POPUP_CHOOSE_PROJECTION{obj.popup_pickProjection.Value};
            
        end
        
        function valueProjectionKeep = requestProjectionIsKeep(obj)
            
            valueProjectionKeep = obj.checkBox_keepProjection.Value;
            
        end
        
        
        function valueCLimitValues = requestCLimitValues(obj)
            
            valueCLimitValues = obj.UI_LIMITS_CHOOS_CLIM(obj.popup_pickClim.Value,:);
            if obj.popup_pickClim.Value == size(obj.UI_LIMITS_CHOOS_CLIM, 1)
                
                minValue = str2double(obj.editBox_minClim.String);
                maxValue = str2double(obj.editBox_maxClim.String);
                valueCLimitValues = [minValue, maxValue];
                
            end
            
        end
        
        function valueStepChannel = requestStepChannel(obj)
            
            valueStepChannel = obj.varstepChannel;
            
        end
        
        function valueStepStack = requestStepStack(obj)
            
            valueStepStack = obj.varstepStack;
            
        end
        
        function obj = requestEnableChannel(obj, varstate)
            
            set(obj.pushButton_nextChannel, 'Enable', varstate);
            set(obj.pushButton_prevChannel, 'Enable', varstate);
            
        end
        
        function obj = requestEnableStack(obj, varstate)
            
            set(obj.pushButton_nextStack, 'Enable', varstate);
            set(obj.pushButton_prevStack, 'Enable', varstate);
            
        end
        
    end
    
    
    
    %% --- callbacks --- %%
    methods
        
        function obj = uicallbacks(obj)
            
            set(obj.pushButton_prevChannel, 'Callback', @obj.onClick_prevChannel);
            set(obj.pushButton_nextChannel, 'Callback', @obj.onClick_nextChannel);
            set(obj.pushButton_prevStack, 'Callback', @obj.onClick_prevStack);
            set(obj.pushButton_nextStack, 'Callback', @obj.onClick_nextStack);
            set(obj.pushButton_project, 'Callback', @obj.onRequest_project);
            set(obj.popup_pickProjection, 'Callback', @obj.onRequest_project);
            set(obj.checkBox_keepProjection, 'Callback', @obj.onCheck_keepProjection);
            set(obj.popup_pickClim, 'Callback', @obj.onPick_clim);
            set(obj.editBox_minClim, 'Callback', @obj.onEdit_clim);
            set(obj.editBox_maxClim, 'Callback', @obj.onEdit_clim);
            
        end
        
        
        
        function obj = onClick_prevChannel(obj, ~, ~)
            
            obj.varstepChannel = -1;
            notify(obj, 'event_changeChannel');
            
        end
        
        function obj = onClick_nextChannel(obj, ~, ~)
            
            obj.varstepChannel = 1;
            notify(obj, 'event_changeChannel');
            
        end
        
        function obj = onClick_prevStack(obj, ~, ~)
            
            obj.varstepStack = -1;
            notify(obj, 'event_changeStack');
            
        end
        
        function obj = onClick_nextStack(obj, ~, ~)
            
            obj.varstepStack = 1;
            notify(obj, 'event_changeStack');
            
        end
        
        function obj = onRequest_project(obj, ~, ~)
            
            notify(obj, 'event_changeProjection');
            
        end
        
        function obj = onCheck_keepProjection(obj, ~, ~)
            
            if obj.checkBox_keepProjection.Value == 1
                
                set(obj.pushButton_nextStack, 'Enable', 'off');
                set(obj.pushButton_prevStack, 'Enable', 'off');
                
            else
                
                set(obj.pushButton_nextStack, 'Enable', 'on');
                set(obj.pushButton_prevStack, 'Enable', 'on');
                
            end
            
        end
        
        function obj = onPick_clim(obj, ~, ~)
            
            switch obj.popup_pickClim.Value
                
                case 4
                    
                    set(obj.editBox_minClim, 'Enable', 'on');
                    set(obj.editBox_maxClim, 'Enable', 'on');
                    
                otherwise
                    
                    set(obj.editBox_minClim, 'Enable', 'off');
                    set(obj.editBox_maxClim, 'Enable', 'off');
                    
            end
            
            notify(obj, 'event_changeCLimit');
            
        end
        
        function obj = onEdit_clim(obj, ~, ~)
            
            minClim = round(str2double(obj.editBox_minClim.String));
            maxClim = round(str2double(obj.editBox_maxClim.String));
            
            if minClim < 0
                
                minClim = 0;
                
            end
            
            if maxClim <= minClim
                
                maxClim = minClim + 1;
                
            end
            
            set(obj.editBox_minClim, 'String', sprintf('%d', minClim));
            set(obj.editBox_maxClim, 'String', sprintf('%d', maxClim));
            
            notify(obj, 'event_changeCLimit');
            
        end
        
    end
    
    
end

