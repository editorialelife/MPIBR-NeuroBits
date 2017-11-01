classdef WidgetNeuroTreeUi < handle
    %
    % WidgetNeuroTreeUI
    %
    % GUI Widget for 
    % user guided neuro tree segmentation
    % exporting/loading and modifying segmented ROIs
    % automatic linking of parent/child hierarchy
    % creating a ROI labeled mask
    %
    % requires:
    %    GUI Layout Toolbox
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties (Access = public)
        
        parent
        layoutWidget
        panelWidget
        panelStatus
        panelTabs
        
        text_status
        pushButton_mask
        pushButton_load
        pushButton_clear
        pushButton_export
        editBox_dilation
        editBox_nhood
        checkBox_autoDilation
        
        
    end
    
    properties (Access = private, Constant = true, Hidden = true)
        
        UI_WINDOW_SIZE = [1, 1, 256, 256];
        UI_GRID_PADDING = 5;
        UI_GRID_SPACING = 5;
        UI_BUTTON_SIZE = [90, 26];
        
    end
    
    events
        
        event_mask
        event_clear
        event_load
        event_export
        event_edit
        
    end
    
    %% --- constructors --- %%%
    methods
        
        function obj = WidgetNeuroTreeUi(varargin)
            
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @(varin) (isempty(varin) || isgraphics(varin)));
            parse(parserObj, varargin{:});
            
            
            %%% set widget parent
            if isempty(parserObj.Results.Parent)
                
                obj.parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetImageBrowserUI',...
                    'Name', 'DrawNeuroTree',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UI_WINDOW_SIZE);
                movegui(obj.parent, 'northwest');
                
            elseif isgraphics(parserObj.Results.Parent)
                
                obj.parent = parserObj.Results.Parent;
                
            else
                
                error('WidgetImageBrowser:UI: invalid handle for parent');
                
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
            
            %%% render ui elements
            obj.uirenderStatus();
            obj.uirenderTabSegment();
            obj.uirenderTabEdit();
            
            %%% assign callbacks
            obj.uicallbacks();
            
        end
        
    end
    
    %% --- UIRender --- %%
    methods
        
        function obj = uirenderStatus(obj)
            
            obj.text_status = uicontrol(...
                'Parent', obj.panelStatus,...
                'Style', 'text',...
                'String', 'segment a tree',...
                'HorizontalAlignment', 'center');
            
        end
        
        function obj = uirenderTabSegment(obj)
            
            tabSegment = uix.Panel('Parent', obj.panelTabs);
            obj.panelTabs.TabTitles(end) = {'segment'};

            layoutSegment = uix.VBoxFlex(...
                'Parent', tabSegment);

            buttonGroup_create = uix.HButtonBox(...
                'Parent', layoutSegment,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);
            
            obj.pushButton_mask = uicontrol(...
                'Parent', buttonGroup_create,...
                'Style', 'pushbutton',...
                'String', 'mask',...
                'Enable', 'on');

            obj.pushButton_clear = uicontrol(...
                'Parent', buttonGroup_create,...
                'Style', 'pushbutton',...
                'String', 'clear',...
                'Enable', 'on');

            buttonGroup_io = uix.HButtonBox(...
                'Parent', layoutSegment,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);

            
            obj.pushButton_load = uicontrol(...
                'Parent', buttonGroup_io,...
                'Style', 'pushbutton',...
                'String', 'load',...
                'Enable', 'on');

            obj.pushButton_export = uicontrol(...
                'Parent', buttonGroup_io,...
                'Style', 'pushbutton',...
                'String', 'export',...
                'Enable', 'on');
    
        end
        
        function obj = uirenderTabEdit(obj)
            
            tabEdit = uix.Panel('Parent', obj.panelTabs);
            obj.panelTabs.TabTitles(end) = {'edit'};

            layoutEdit = uix.VBoxFlex(...
                'Parent', tabEdit);
            
            uiGroup_auto = uix.HButtonBox(...
                'Parent', layoutEdit,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);
            
            obj.checkBox_autoDilation = uicontrol(...
                'Parent', uiGroup_auto,...
                'Style', 'checkbox',...
                'String', 'auto',...
                'Value' , 0,...
                'Enable', 'on');
            
            uix.Empty('Parent', uiGroup_auto);
            uix.Empty('Parent', uiGroup_auto);
            
            
            uiGroup_dilation = uix.HButtonBox(...
                'Parent', layoutEdit,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);
            
            uicontrol(...
                'Parent', uiGroup_dilation,...
                'Style', 'text',...
                'String', 'dilate [px]',...
                'HorizontalAlignment', 'center');

            obj.editBox_dilation = uicontrol(...
                'Parent', uiGroup_dilation,...
                'Style', 'edit',...
                'String', '5',...
                'Enable', 'on');

            uix.Empty('Parent', uiGroup_dilation);
            
            
            
            uiGroup_nhood = uix.HButtonBox(...
                'Parent', layoutEdit,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);
            
            uicontrol(...
                'Parent', uiGroup_nhood,...
                'Style', 'text',...
                'String', 'nhood [px]',...
                'HorizontalAlignment', 'center');

            obj.editBox_nhood = uicontrol(...
                'Parent', uiGroup_nhood,...
                'Style', 'edit',...
                'String', '5',...
                'Enable', 'on');
            
            uix.Empty('Parent', uiGroup_nhood);
            
            
        end
        
        
    end
    
    %% --- Assign Callbacks --- %%
    methods
        
        function obj = uicallbacks(obj)
            
            set(obj.pushButton_mask, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_clear, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_load, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_export, 'Callback', @obj.onClick_pushButton);
            set(obj.editBox_dilation, 'Callback', @obj.onEdit_dilation);
            set(obj.editBox_nhood, 'Callback', @obj.onEdit_dilation);
            set(obj.checkBox_autoDilation, 'Callback', @obj.onEdit_dilation);
            
        end
        
        function obj = onClick_pushButton(obj, hsource, ~)
            
            switch hsource
                
                case obj.pushButton_mask    
                    notify(obj, 'event_mask');
                    
                case obj.pushButton_clear
                    notify(obj, 'event_clear');
                    
                case obj.pushButton_load
                    notify(obj, 'event_load');
                    
                case obj.pushButton_export
                    notify(obj, 'event_export');
                    
            end
            
        end
        
        
        function obj = onEdit_dilation(obj, hsource, ~)
            
            if hsource == obj.checkBox_autoDilation
                
                if obj.checkBox_autoDilation.Value == 1
                    
                    set(obj.editBox_dilation, 'Enable', 'off');
                    set(obj.editBox_nhood, 'Enable', 'off');
                    
                else
                    
                    set(obj.editBox_dilation, 'Enable', 'on');
                    set(obj.editBox_nhood, 'Enable', 'on');
                    
                end
                
            end
            notify(obj, 'event_edit');
            
        end
    end
    
    %% --- request methods --- %%
    methods
        
        function value = requestEditDilation(obj)
            
            value = str2double(obj.editBox_dilation.String);
            
        end
        
        function value = requestEditNhood(obj)
            
            value = str2double(obj.editBox_nhood.String);
            
        end
        
        function value = requestEditAuto(obj)
            
            value = obj.checkBox_autoDilation.Value;
            
        end
        
        
    end
    
    %% --- update methods --- %%
    methods
        
        function obj = changeStatus(obj, vartext)
            
            set(obj.text_status, 'String', vartext);
            
        end
    end
    
end % class end
