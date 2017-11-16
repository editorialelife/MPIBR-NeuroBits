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
    
    properties (Access = public, SetObservable = true)
        
        viewMask
        viewTree
        thresholdIntensity
        thresholdNhood
        
    end
    
    properties (Access = private)
        
        uiPanel_status
        uiPanel_tabs
        
        text_status
        
        pushButton_new
        pushButton_clear
        pushButton_load
        pushButton_export
        
        slider_intensity
        slider_nhood
        editBox_intensity
        editBox_nhood
        
        checkBox_viewMask
        checkBox_viewTree
        
    end
    
    properties (Access = private, Constant = true, Hidden = true)
        
        UI_WINDOW_SIZE = [1, 1, 256, 256];
        UI_GRID_PADDING = 5;
        UI_GRID_SPACING = 5;
        UI_BUTTON_SIZE = [90, 26];
        UI_EDIT_SIZE = [45, 26];
        
        DEFAULT_INTENSITY = [0, 20, 100];
        DEFAULT_NHOOD = [0, 5, 20];
        
    end
    
    events
        
        event_new
        event_clear
        event_load
        event_export
        event_tabSegment
        event_tabMask
        
    end
    
    %% --- constructors --- %%%
    methods
        
        function obj = WidgetNeuroTreeUi(varargin)
            
            %%% parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @(varin) (isempty(varin) || isgraphics(varin)));
            parse(parserObj, varargin{:});
            varhandle = parserObj.Results.Parent;
            
            
            %%% set widget parent
            if isempty(varhandle)
                
                uiParent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetNeuroTreeUi',...
                    'Name', 'DrawNeuroTree',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UI_WINDOW_SIZE);
                movegui(uiParent, 'northwest');
                
            elseif isgraphics(varhandle)
                
                uiParent = varhandle;
                
            else
                
                error('WidgetNeuroTreeUi: invalid handle for parent');
                
            end
            
            %%% set widget panel
            uiPanel_widget = uix.Panel(...
                'Parent', uiParent,...
                'Padding', obj.UI_GRID_PADDING,...
                'Title', 'NeuroTree');
            
            %%% set widget layout
            uiLayout = uix.VBox(...
                'Parent', uiPanel_widget,...
                'Spacing', obj.UI_GRID_SPACING);
            
            obj.uiPanel_status = uix.Panel(...
                'Parent', uiLayout,...
                'Padding', obj.UI_GRID_PADDING,...
                'Title', 'status');
            
            obj.uiPanel_tabs = uix.TabPanel(...
                'Parent', uiLayout);
            
            %%% re-size panels
            set(uiLayout, 'Heights', [obj.UI_BUTTON_SIZE(2)*2, -1]);
            
            %%% render ui elements
            obj.renderUi_status();
            obj.renderUi_segment();
            obj.renderUi_mask();
            
            %%% assign callbacks
            obj.uiCallbacks();
            
        end
        
    end
    
    %% --- Render UI elements --- %%
    methods (Access = private)
        
        function obj = renderUi_status(obj)
            
            obj.text_status = uicontrol(...
                'Parent', obj.uiPanel_status,...
                'Style', 'text',...
                'String', 'segment a tree',...
                'HorizontalAlignment', 'center');
            
        end
        
        function obj = renderUi_segment(obj)
            
            tabPanel = uix.Panel('Parent', obj.uiPanel_tabs);
            obj.uiPanel_tabs.TabTitles(end) = {'segment'};
            
            uiTabLayout = uix.VBox(...
                'Parent', tabPanel);
            
            buttonGroup_create = uix.HButtonBox(...
                'Parent', uiTabLayout,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING,...
                'ButtonSize', obj.UI_BUTTON_SIZE);
            
            obj.pushButton_new = uicontrol(...
                'Parent', buttonGroup_create,...
                'Style', 'pushbutton',...
                'String', 'new',...
                'Enable', 'on');

            obj.pushButton_clear = uicontrol(...
                'Parent', buttonGroup_create,...
                'Style', 'pushbutton',...
                'String', 'clear',...
                'Enable', 'on');

            buttonGroup_io = uix.HButtonBox(...
                'Parent', uiTabLayout,...
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
            
            uix.Empty('Parent', uiTabLayout);
            
        end
        
        function obj = renderUi_mask(obj)
            
            tabPanel = uix.Panel('Parent', obj.uiPanel_tabs);
            obj.uiPanel_tabs.TabTitles(end) = {'mask'};
            
            uiTabLayout = uix.VBox(...
                'Parent', tabPanel,...
                'Spacing', obj.UI_GRID_SPACING,...
                'Padding', obj.UI_GRID_PADDING);
            
            [obj.slider_intensity, ...
             obj.editBox_intensity] = obj.renderUi_slider(uiTabLayout,...
                                                      obj.DEFAULT_INTENSITY, ...
                                                      'intensity [%]');
            [obj.slider_nhood, ...
             obj.editBox_nhood] = obj.renderUi_slider(uiTabLayout, ...
                                                  obj.DEFAULT_NHOOD, ...
                                                      'nhood [px]');                                      
            
            %%% add checkboxes
            uiHGroup = uix.HBox(...
                'Parent', uiTabLayout,...
                'Padding', obj.UI_GRID_PADDING,...
                'Spacing', obj.UI_GRID_SPACING);
            
            obj.checkBox_viewMask = uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'checkbox',...
                'String', 'show mask',...
                'Value' , 1,...
                'Enable', 'on');
            
            obj.checkBox_viewTree = uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'checkbox',...
                'String', 'show tree',...
                'Value' , 1,...
                'Enable', 'on');
            
        end
        
        
        function [hslider, hedit] = renderUi_slider(obj, parent, defaults, label)
            
            %%% parse values
            valueMin = defaults(1);
            valueDefault = defaults(2);
            valueMax = defaults(3);
            
            uiVGroup = uix.VBox(...
                'Parent', parent,...
                'Spacing', obj.UI_GRID_SPACING);
            
            %%% label + edit box
            uiHGroup = uix.HBox(...
                'Parent', uiVGroup);
            
            uix.Empty('Parent', uiHGroup);
            
            uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'text',...
                'String', label);
            
            hedit = uicontrol(...
                'Parent', uix.HButtonBox(...
                                         'Parent', uiHGroup,...
                                         'ButtonSize', obj.UI_EDIT_SIZE),...
                'Style', 'edit',...
                'String', sprintf('%.2f', valueDefault));
            
            set(uiHGroup, 'Widths', [-1, -2, -1]);
            
            %%% limits + slider
            uiHGroup = uix.HBox(...
                'Parent', uiVGroup);
            
            uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'text',...
                'String', sprintf('%d', valueMin));
            
            hslider = uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'slider',...
                'Value', valueDefault,...
                'Min', valueMin,...
                'Max', valueMax);
                
            uicontrol(...
                'Parent', uiHGroup,...
                'Style', 'text',...
                'String', sprintf('%d', valueMax));
            
            set(uiHGroup, 'Widths', [-0.5, -3, -0.5]);
            
        end
        
    end
    
    %% --- Assign Callbacks --- %%
    methods
        
        function obj = uiCallbacks(obj)
            
            set(obj.pushButton_new, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_clear, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_load, 'Callback', @obj.onClick_pushButton);
            set(obj.pushButton_export, 'Callback', @obj.onClick_pushButton);
            
            set(obj.editBox_intensity, 'Callback', @obj.onClick_editBox);
            set(obj.editBox_nhood, 'Callback', @obj.onClick_editBox);
            
            set(obj.slider_intensity, 'Callback', @obj.onMove_slider);
            set(obj.slider_nhood, 'Callback', @obj.onMove_slider);
            
            set(obj.checkBox_viewMask, 'Callback', @obj.onClick_checkBox);
            set(obj.checkBox_viewTree, 'Callback', @obj.onClick_checkBox);
            
            set(obj.uiPanel_tabs, 'SelectionChangedFcn', @obj.onChange_tabPanel);
            
        end
        
        function obj = onClick_pushButton(obj, hsource, ~)
            
            switch hsource
                
                case obj.pushButton_new    
                    notify(obj, 'event_new');
                    
                case obj.pushButton_clear
                    notify(obj, 'event_clear');
                    
                case obj.pushButton_load
                    notify(obj, 'event_load');
                    
                case obj.pushButton_export
                    notify(obj, 'event_export');
                    
            end
            
        end
        
        
        function obj = onClick_editBox(obj, hsource, ~)
            
            valuePrevious = hsource.Value;
            valueNow = str2double(hsource.String);
            
            %%% check if not nan
            if isnan(valueNow)
                valueNow = valuePrevious;
            end
            
            %%% compare range
            switch hsource
                case obj.editBox_intensity
                    
                    if (valueNow < obj.DEFAULT_INTENSITY(1)) || (valueNow > obj.DEFAULT_INTENSITY(3))
                        valueNow = valuePrevious;
                    end
                    obj.slider_intensity.Value = valueNow;
                    obj.thresholdIntensity = valueNow;
                    
                case obj.editBox_nhood
                    
                    if (valueNow < obj.DEFAULT_NHOOD(1)) || (valueNow > obj.DEFAULT_NHOOD(3))
                        valueNow = valuePrevious;
                    end
                    obj.slider_nhood.Value = valueNow;
                    obj.thresholdNhood = valueNow;
                    
            end
            
            %%% update text
            hsource.Value = valueNow;
            hsource.String = sprintf('%.2f', valueNow);
            
        end
        
        
        function obj = onMove_slider(obj, hsource, ~)
            
            switch hsource
                case obj.slider_intensity
                    
                    obj.editBox_intensity.String = sprintf('%.2f', hsource.Value);
                    obj.editBox_intensity.Value = hsource.Value;
                    obj.thresholdIntensity = hsource.Value;
                    
                case obj.slider_nhood
                    
                    obj.editBox_nhood.String = sprintf('%.2f', hsource.Value);
                    obj.editBox_nhood.Value = hsource.Value;
                    obj.thresholdNhood = hsource.Value;
                    
            end
            
        end
        
        function obj = onClick_checkBox(obj, hsource, ~)
            
            switch hsource
                
                case obj.checkBox_viewTree
                    obj.viewTree = hsource.Value;
                    
                case obj.checkBox_viewMask
                    obj.viewMask = hsource.Value;
            end
            
        end
        
        function obj = onChange_tabPanel(obj, ~, ~)
            
            if (obj.uiPanel_tabs.Selection == 1)
                
                notify(obj, 'event_tabSegment');
                
            elseif (obj.uiPanel_tabs.Selection == 2)
                
                notify(obj, 'event_tabMask');
                
            end
            
        end
        
    end
    
    %% --- update methods --- %%
    methods
        
        function obj = changeStatus(obj, vartext)
            
            set(obj.text_status, 'String', vartext);
            
        end
    end
    
end % class end
