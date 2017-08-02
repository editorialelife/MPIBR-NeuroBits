classdef WidgetRender < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    %% --- properties --- %%
    properties (Access = public)
        
        text_status
        
        text_countChannel
        text_countStack
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
        
    end
    
    properties (Constant = true, Access = protected, Hidden = true)
        
        UI_WINDOW_SIZE = [1, 1, 256, 256];
        UI_GRID_PADDING = 5;
        UI_GRID_SPACING = 5;
        UI_BUTTON_SIZE = [90, 26];
        UI_POPUP_CHOOSE_PROJECTION = {'max','sum','std'};
        UI_POPUP_CHOOSE_CLIM = {'auto', '8bit', '16bit'};
        
    end
    
    %% --- events --- %%
    events
        
        event_delete
        event_navigate_prevChannel
        event_navigate_prevStack
        event_navigate_nextChannel
        event_navigate_nextStack
        event_request_project
        event_request_editclim
        
    end
    
    
    %% --- methods --- %%
    methods
        
        function obj = WidgetRender(varhandle)
            
            %%% set widget parent
            if isempty(varhandle)
                
                obj.parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetImageBrowserUI',...
                    'Name', 'ImageBrowser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UI_WINDOW_SIZE);
                movegui(obj.parent, 'northwest');
                
            elseif isgraphics(varhandle)
                
                obj.parent = varhandle;
                
            else
                
                error('ImageBrowser:uirender: invalid handle for parent');
                
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
            obj.WidgetRenderStatus();
            obj.WidgetRenderNavigate();
            obj.WidgetRenderProject();
            obj.WidgetRenderViewLimit();
            
            %%% assign callbacks
            obj.WidgetCallbacks();
            
        end
        
        function obj = delete(obj)
            
            notify(obj, 'event_delete');
            
        end
        
        function obj = WidgetRenderStatus(obj)
            
            obj.text_status = uicontrol(...
                'Parent', obj.panelStatus,...
                'Style', 'text',...
                'String', 'choose image',...
                'HorizontalAlignment', 'center');
            
        end
        
        
    end
    
    
    %% --- external methods --- %%
    methods
        
        obj = WidgetRenderNavigate(obj);
        obj = WidgetRenderProject(obj);
        obj = WidgetRenderViewLimit(obj);
        
    end
    
    
    %% --- callbacks --- %%
    methods
        
        function obj = WidgetCallbacks(obj)
            
            set(obj.pushButton_prevChannel, 'Callback', @obj.onClick_pushButton_prevChannel);
            set(obj.pushButton_nextChannel, 'Callback', @obj.onClick_pushButton_nextChannel);
            set(obj.pushButton_prevStack, 'Callback', @obj.onClick_pushButton_prevStack);
            set(obj.pushButton_nextStack, 'Callback', @obj.onClick_pushButton_nextStack);
            set(obj.pushButton_project, 'Callback', @obj.onRequest_project);
            set(obj.popup_pickProjection, 'Callback', @obj.onRequest_project);
            set(obj.popup_pickClim, 'Callback', @obj.onRequest_editClim);
            set(obj.editBox_minClim, 'Callback', @obj.onRequest_editClim);
            set(obj.editBox_maxClim, 'Callback', @obj.onRequest_editClim);
            
        end
        
        function obj = onClick_pushButton_prevChannel(obj, ~, ~)
            
            notify(obj, 'event_navigate_prevChannel');
            disp('prevChannel');
            
        end
        
        function obj = onClick_pushButton_nextChannel(obj, ~, ~)
            
            notify(obj, 'event_navigate_nextChannel');
            disp('nextChannel');
            
        end
        
        function obj = onClick_pushButton_prevStack(obj, ~, ~)
            
            notify(obj, 'event_navigate_prevStack');
            disp('prevStack');
            
        end
        
        function obj = onClick_pushButton_nextStack(obj, ~, ~)
            
            notify(obj, 'event_navigate_nextStack');
            disp('nextStack');
            
        end
        
        function obj = onRequest_project(obj, ~, ~)
            
            notify(obj, 'event_request_project');
            disp('project');
            
        end
        
        function obj = onRequest_editClim(obj, ~, ~)
            
            notify(obj, 'event_request_editclim');
            disp('editClim');
            
        end
        
    end
    
    
end

