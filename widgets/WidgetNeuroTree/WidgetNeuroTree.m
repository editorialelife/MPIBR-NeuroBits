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
        action
        state
        
    end
    
    properties (Access = private)
        
        STATE_NULL = 1;
        STATE_IDLE = 2;
        STATE_ANCHOR = 3;
        STATE_DRAW = 4;
        STATE_GRAB = 5;
        STATE_HOVER = 6;
        STATE_SELECTED = 7;
        STATE_REPOSITION = 8;
        sm = {'STATE_NULL','STATE_IDLE','STATE_ANCHOR','STATE_DRAW',...
              'STATE_GRAB','STATE_HOVER','STATE_SELECTED','STATE_REPOSITION'};
        
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
            obj.action = WidgetNeuroTreeAction();
            if ~isa(obj.action, 'WidgetNeuroTreeAction')
                error('WidgetNeuroTree: initializing Action failed!');
            end
            
            % create controller
            obj.controller();
            
        end
        
        
        function obj = controller(obj)
            
            % initialize state
            obj.state = obj.STATE_IDLE;
            
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
            %addlistener(obj.action, 'mousePointer', 'PostSet', @obj.fcnCallbackModel_updateMousePointer);
            
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
            
            fprintf('event_clickDown -> %s\n',obj.sm{obj.state});
            
            
            switch obj.state
                
                case {obj.STATE_ANCHOR, obj.STATE_DRAW}
                    obj.state = obj.STATE_DRAW;
                    obj.action.extend(obj.viewer);
                    
            end
            
        end
        
        
        %% @ event click up
        function obj = fcnCallbackViewer_clickUp(obj, ~, ~)
            
            fprintf('event_clickUp -> %s\n',obj.sm{obj.state});
            
            
            
        end
        
        %% @ event click double
        function obj = fcnCallbackViewer_clickDouble(obj, ~, ~)
            
            fprintf('event_clickDouble -> %s\n',obj.sm{obj.state});
            
            
            switch obj.state
                
                case obj.STATE_ANCHOR
                    obj.state = obj.STATE_IDLE;
                    obj.action.remove(obj.viewer);
                    
                case obj.STATE_DRAW
                    obj.state = obj.STATE_IDLE;
                    obj.action.complete(obj.viewer);
                    
            end
                    
            
        end
        
        %% @ event mouse move
        function obj = fcnCallbackViewer_moveMouse(obj, ~, ~)
            
            %disp('event_moveMouse');
            
            switch obj.state
                
                case obj.STATE_DRAW
                    obj.state = obj.STATE_DRAW;
                    obj.action.stretch(obj.viewer);
                    
            end
            
            
        end
        
        %% @ event press digit
        function obj = fcnCallbackViewer_pressDigit(obj, ~, ~)
            
            fprintf('event_pressDigit -> %s\n',obj.sm{obj.state});
            
            switch obj.state
                
                case obj.STATE_IDLE
                    obj.state = obj.STATE_ANCHOR;
                    obj.action.create(obj.viewer);
                    
            end
            
        end
        
        %% @ event press esc
        function obj = fcnCallbackViewer_pressEsc(obj, ~, ~)
            
            fprintf('event_pressEsc -> %s\n',obj.sm{obj.state});
            
            
            
        end
        
        %% @ event press del
        function obj = fcnCallbackViewer_pressDel(obj, ~, ~)
            
            fprintf('event_pressDel -> %s\n',obj.sm{obj.state});
            
            
        end
        
        %% @ event hover handle
        function obj = fcnCallbackViewer_hoverHandle(obj, ~, ~)
            
            fprintf('event_hoverHandle -> %s\n',obj.sm{obj.state});
            
            
        end
        
        %% @ event_postset_mouse_pointer
        function obj = fcnCallbackModel_updateMousePointer(obj, ~, ~)
            
            %obj.viewer.changeMousePointer(obj.model.mousePointer);
            
        end
        
        
    end
    
end % class end