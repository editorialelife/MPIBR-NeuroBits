classdef WidgetNeuroTree < handle
    %
    % WidgetNeuroTree
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
        
        ui
        viewer
        engine
        
    end
    
    
    
    
    %% --- constructors --- %%%
    methods
        
        function obj = WidgetNeuroTree()
            
            % create Ui
            obj.ui = WidgetNeuroTreeUi();
            if ~isa(obj.ui, 'WidgetNeuroTreeUi')
                error('WidgetNeuroTree: initializing Ui failed!');
            end
            
            % create Viewer
            obj.viewer = WidgetNeuroTreeViewer();
            if ~isa(obj.viewer, 'WidgetNeuroTreeViewer')
                error('WidgetNeuroTree: initializing Viewer failed!');
            end
            
            % create state-machine engine
            obj.engine = WidgetNeuroTreeEngine();
            if ~isa(obj.engine, 'WidgetNeuroTreeEngine')
                error('WidgetNeuroTree: initializing Engine failed!');
            end
            
            
            % create controller
            obj.controller();
            
        end
        
        
        function obj = controller(obj)
            
            % add Ui callbacks
            %{
            addlistener(obj.ui, 'event_new', @obj.fcnCallbackUi_eventNew);
            addlistener(obj.ui, 'event_clear', @obj.fcnCallbackUi_eventClear);
            addlistener(obj.ui, 'event_load', @obj.fcnCallbackUi_eventLoad);
            addlistener(obj.ui, 'event_export', @obj.fcnCallbackUi_eventExport);
            addlistener(obj.ui, 'event_edit', @obj.fcnCallbackUi_eventEdit);
            %}
            
            
            % add Viewer callbacks
            addlistener(obj.viewer, 'event_clickDown', @obj.fcnCallbackViewer_clickDown);
            addlistener(obj.viewer, 'event_clickUp', @obj.fcnCallbackViewer_clickUp);
            addlistener(obj.viewer, 'event_clickDouble', @obj.fcnCallbackViewer_clickDouble);
            addlistener(obj.viewer, 'event_moveMouse', @obj.fcnCallbackViewer_moveMouse);
            addlistener(obj.viewer, 'event_pressDigit', @obj.fcnCallbackViewer_pressDigit);
            addlistener(obj.viewer, 'event_pressDel', @obj.fcnCallbackViewer_pressDel);
            addlistener(obj.viewer, 'event_pressEsc', @obj.fcnCallbackViewer_pressEsc);
            addlistener(obj.viewer, 'event_hoverHandle', @obj.fcnCallbackViewer_hoverHandle);
            
            % add Model callbacks
            addlistener(obj.engine, 'mousePointer', 'PostSet', @obj.fcnCallbackModel_updateMousePointer);
            
        end
        
        
        
        
    end
    
    
    %% --- Ui callbacks --- %%
    %{
    methods (Access = private)
        
        %% @ event new
        function obj = fcnCallbackUi_eventNew(obj, ~, ~)
            
            disp('NEW');
            
        end
        
        %% @ event clear
        function obj = fcnCallbackUi_eventClear(obj, ~, ~)
            
            disp('CLEAR');
            
        end
        
        %% @ event load
        function obj = fcnCallbackUi_eventLoad(obj, ~, ~)
            
            disp('LOAD');
            
        end
        
        %% @ event export
        function obj = fcnCallbackUi_eventExport(obj, ~, ~)
            
            disp('EXPORT');
            
        end
        
    end
    %}
    
    %% --- Viewer callbacks --- %%
    methods (Access = private)
        
        %% @ event click down
        function obj = fcnCallbackViewer_clickDown(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_CLICKDOWN, obj.viewer);
            
        end
        
        
        %% @ event click up
        function obj = fcnCallbackViewer_clickUp(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_CLICKUP, obj.viewer);
            
        end
        
        %% @ event click double
        function obj = fcnCallbackViewer_clickDouble(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_CLICKDOUBLE, obj.viewer);
            
        end
        
        %% @ event mouse move
        function obj = fcnCallbackViewer_moveMouse(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_MOVEMOUSE, obj.viewer);
            
        end
        
        %% @ event press digit
        function obj = fcnCallbackViewer_pressDigit(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_PRESSDIGIT, obj.viewer);
            
        end
        
        %% @ event press esc
        function obj = fcnCallbackViewer_pressEsc(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_PRESSESC, obj.viewer);
            
        end
        
        %% @ event press del
        function obj = fcnCallbackViewer_pressDel(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_PRESSDEL, obj.viewer);
            
        end
        
        %% @ event hover handle
        function obj = fcnCallbackViewer_hoverHandle(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_HOVERHANDLE, obj.viewer);
            
        end
        
        %% @ event_postset_mouse_pointer
        function obj = fcnCallbackModel_updateMousePointer(obj, ~, ~)
            
            obj.viewer.changeMousePointer(obj.engine.mousePointer);
            
        end
        
        
    end
    
end % class end