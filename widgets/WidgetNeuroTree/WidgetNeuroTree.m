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
        model
        viewer
        state
        
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
            
            % create model
            obj.model = WidgetNeuroTreeModel();
            if ~isa(obj.model, 'WidgetNeuroTreeModel')
                error('WidgetNeuroTree: initializing Model failed!');
            end
            
            
            % create controller
            obj.controller();
            
        end
        
        
        function obj = controller(obj)
            
            % initialize state
            % maybe move it to callback of new button
            obj.state = WidgetNeuroTreeStates.NULL;
            
            % add Ui callbacks
            addlistener(obj.ui, 'event_new', @obj.fcnCallbackUi_eventNew);
            addlistener(obj.ui, 'event_clear', @obj.fcnCallbackUi_eventClear);
            addlistener(obj.ui, 'event_load', @obj.fcnCallbackUi_eventLoad);
            addlistener(obj.ui, 'event_export', @obj.fcnCallbackUi_eventExport);
            %addlistener(obj.ui, 'event_edit', @obj.fcnCallbackUi_eventEdit);
            
            % add Viewer callbacks
            addlistener(obj.viewer, 'event_click_down', @obj.fcnCallbackViewer_clickDown);
            addlistener(obj.viewer, 'event_click_up', @obj.fcnCallbackViewer_clickUp);
            addlistener(obj.viewer, 'event_click_double', @obj.fcnCallbackViewer_clickDouble);
            addlistener(obj.viewer, 'event_move_mouse', @obj.fcnCallbackViewer_mouseMove);
            addlistener(obj.viewer, 'event_press_digit', @obj.fcnCallbackViewer_pressDigit);
            addlistener(obj.viewer, 'event_press_del', @obj.fcnCallbackViewer_pressDel);
            addlistener(obj.viewer, 'event_press_esc', @obj.fcnCallbackViewer_pressEsc);
            addlistener(obj.viewer, 'event_hover_handle', @obj.fcnCallbackViewer_hoverHandle);
            
            % add Model callbacks
            addlistener(obj.model, 'mousePointer', 'PostSet', @obj.fcnCallbackModel_updateMousePointer);
            
            
            
        end
        
    end
    
    %% --- Ui callbacks --- %%
    methods (Access = private)
        
        %% @ event new
        function obj = fcnCallbackUi_eventNew(obj, ~, ~)
            
            obj.state = WidgetNeuroTreeStates.IDLE;
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
    
    %% --- Viewer callbacks --- %%
    methods (Access = private)
        
        %% @ event click down
        function obj = fcnCallbackViewer_clickDown(obj, ~, ~)
            
            switch obj.state
                
                case WidgetNeuroTreeStates.DRAWING
                    obj.state = WidgetNeuroTreeStates.DRAWING;
                    obj.model.extend();
                    
                case WidgetNeuroTreeStates.HOVER
                    obj.state = WidgetNeuroTreeStates.REPOSITION;
                    obj.model.pickup();
                    
                case WidgetNeuroTreeStates.SELECTED
                    obj.state = WidgetNeuroTreeStates.IDLE;
                    obj.model.deselect();
                    
            end
            
        end
        
        %% @ event click up
        function obj = fcnCallbackViewer_clickUp(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.REPOSITION
                
                obj.state = WidgetNeuroTreeStates.HOVER;
                obj.model.putdown();
                
            end
            
        end
        
        %% @ event click double
        function obj = fcnCallbackViewer_clickDouble(obj, ~, ~)
            
            switch obj.state
                
                case WidgetNeuroTreeStates.DRAWING
                    obj.state = WidgetNeuroTreeStates.HOVER;
                    obj.model.complete();
                    
                case WidgetNeuroTreeStates.HOVER
                    obj.state = WidgetNeuroTreeStates.SELECTED;
                    obj.model.select();
                    
            end
            
        end
        
        %% @ event mouse move
        function obj = fcnCallbackViewer_mouseMove(obj, ~, ~)
            
            switch obj.state
                
                case WidgetNeuroTreeStates.DRAWING
                    obj.state = WidgetNeuroTreeStates.DRAWING;
                    obj.model.stretch();
                    
                case WidgetNeuroTreeStates.REPOSITION
                    obj.state = WidgetNeuroTreeStates.REPOSITION;
                    obj.model.reposition();
                    
            end
            
        end
        
        %% @ event press digit
        function obj = fcnCallbackViewer_pressDigit(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.IDLE
                
                obj.state = WidgetNeuroTreeStates.DRAWING;
                obj.model.create();
                
            end
            
        end
        
        %% @ event press esc
        function obj = fcnCallbackViewer_pressEsc(obj, ~, ~)
            
            switch obj.state
                
                case WidgetNeuroTreeStates.SELECTED
                    obj.state = WidgetNeuroTreeStates.IDLE;
                    obj.model.deselect();
                
                case WidgetNeuroTreeStates.DRAWING
                    obj.state = WidgetNeuroTreeStates.IDLE;
                    obj.model.complete();
                
            end
            
        end
        
        %% @ event press del
        function obj = fcnCallbackViewer_pressDel(obj, ~, ~)
            
            switch obj.state
                
                case WidgetNeuroTreeStates.DRAWING
                    obj.state = WidgetNeuroTreeStates.DRAWING;
                    obj.model.remove();

                case WidgetNeuroTreeStates.SELECTED
                    obj.state = WidgetNeuroTreeStates.IDLE;
                    obj.model.erase();

            end
            
        end
        
        %% @ event hover handle
        function obj = fcnCallbackViewer_hoverHandle(obj, ~, ~)
            
            if (obj.state == WidgetNeuroTreeStates.IDLE) || (obj.state == WidgetNeuroTreeStates.HOVER) 
                
                obj.state = WidgetNeuroTreeStates.HOVER;
                obj.model.hover();
                
            end
            
        end
        
        %% @ event_postset_mouse_pointer
        function obj = fcnCallbackModel_updateMousePointer(obj, ~, ~)
            
            obj.viewer.changeMousePointer(obj.model.mousePointer);
            
        end
        
    end
    
end % class end