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
    
    properties (Access = private)
        
        ui
        model
        viewer
        state
        
    end
    
    
    
    %% --- constructors --- %%%
    methods
        
        function obj = WidgetNeuroTree()
            
            % create MVC
            obj.ui = WidgetNeuroTreeUI();
            if ~isa(obj.ui, 'WidgetNeuroTreeUI')
                error('WidgetNeuroTree: initializing UI failed!');
            end
            
            % create Viewer
            obj.viewer = WidgetNeuroTreeViewer();
            if ~isa(obj.viewer, 'WidgetNeuroTreeViewer')
                error('WidgetNeuroTree: initializing Viewer failed!');
            end
            
            
            obj.model = WidgetNeuroTreeModel();
            if ~isa(obj.model, 'WidgetNeuroTreeModel')
                error('WidgetNeuroTree: initializing Model failed!');
            end
            
            
            % create controller
            obj.controller();
            
        end
        
        
        function obj = controller(obj)
            
            % add UI listeners
            
            % add Viewer listeners
            addlistener(obj.viewer, 'event_click_down', @obj.fcnCallbackViewer_clickDown);
            addlistener(obj.viewer, 'event_click_up', @obj.fcnCallbackViewer_clickUp);
            addlistener(obj.viewer, 'event_click_double', @obj.fcnCallbackViewer_clickDouble);
            addlistener(obj.viewer, 'event_move_mouse', @obj.fcnCallbackViewer_mouseMove);
            addlistener(obj.viewer, 'event_press_digit', @obj.fcnCallbackViewer_pressDigit);
            addlistener(obj.viewer, 'event_press_del', @obj.fcnCallbackViewer_pressDel);
            addlistener(obj.viewer, 'event_press_esc', @obj.fcnCallbackViewer_pressEsc);
            addlistener(obj.viewer, 'event_hover_handle', @obj.fcnCallbackViewer_hoverHandle);
            
            addlistener(obj.model, 'mousePointer', 'PostSet', @obj.fcnCallbackModel_updateMousePointer);
            
            % initialize state
            % maybe move it to callback of new button
            obj.state = WidgetNeuroTreeStates.IDLE;
            
        end
        
    end
    
    %% --- Controller callbacks --- %%
    methods
        
        %% @ event_click_down
        function obj = fcnCallbackViewer_clickDown(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.DRAWING
                
                obj.state = WidgetNeuroTreeStates.DRAWING;
                obj.model.extend();
                
            elseif obj.state == WidgetNeuroTreeStates.HOVER
                
                obj.state = WidgetNeuroTreeStates.REPOSITION;
                obj.model.pickup();
                
            elseif obj.state == WidgetNeuroTreeStates.SELECTED
                
                obj.state = WidgetNeuroTreeStates.IDLE;
                obj.model.deselect();
                
            end
            
        end
        
        %% @ event_click_up
        function obj = fcnCallbackViewer_clickUp(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.REPOSITION
                
                obj.state = WidgetNeuroTreeStates.HOVER;
                obj.model.putdown();
                
            end
            
        end
        
        %% @ event_click_double
        function obj = fcnCallbackViewer_clickDouble(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.DRAWING
                
                obj.state = WidgetNeuroTreeStates.HOVER;
                obj.model.complete();
                
            elseif obj.state == WidgetNeuroTreeStates.HOVER
                
                obj.state = WidgetNeuroTreeStates.SELECTED;
                obj.model.select();
                
            end
            
        end
        
        %% @ event_mouse_move
        function obj = fcnCallbackViewer_mouseMove(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.DRAWING
                
                obj.state = WidgetNeuroTreeStates.DRAWING;
                obj.model.stretch();
                
            elseif obj.state == WidgetNeuroTreeStates.REPOSITION
                
                obj.state = WidgetNeuroTreeStates.REPOSITION;
                obj.model.reposition();
                
            end
            
        end
        
        %% @ event_press_digit
        function obj = fcnCallbackViewer_pressDigit(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.IDLE
                
                obj.state = WidgetNeuroTreeStates.DRAWING;
                obj.model.create();
                
            end
            
        end
        
        %% @ event_press_esc
        function obj = fcnCallbackViewer_pressEsc(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.SELECTED
                
                obj.state = WidgetNeuroTreeStates.IDLE;
                obj.model.deselect();
                
            elseif obj.state == WidgetNeuroTreeStates.DRAWING
                
                obj.state = WidgetNeuroTreeStates.IDLE;
                obj.model.complete();
                
            end
            
        end
        
        %% @ event_press_del
        function obj = fcnCallbackViewer_pressDel(obj, ~, ~)
            
            if obj.state == WidgetNeuroTreeStates.DRAWING
                
                obj.state = WidgetNeuroTreeStates.DRAWING;
                obj.model.remove();
                
            elseif obj.state == WidgetNeuroTreeStates.SELECTED
                
                obj.state = WidgetNeuroTreeStates.IDLE;
                obj.model.erase();
                
            end
            
        end
        
        %% @ event_hover_handle
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