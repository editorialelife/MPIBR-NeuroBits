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
        
        filePath
        fileName
        
    end
    
    properties (Access = public)
        
        ui
        viewer
        engine
        
    end
    
    events
        
        event_treeExport
        
    end
    
    
    %% --- constructors --- %%%
    methods
        
        function obj = WidgetNeuroTree(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @(varin) (isempty(varin) || isgraphics(varin)));
            addParameter(parserObj, 'Viewer', [], @(varin) (isempty(varin) || isgraphics(varin, 'figure')));
            parse(parserObj, varargin{:});
            
            % create Ui
            obj.ui = WidgetNeuroTreeUi('Parent', parserObj.Results.Parent);
            if ~isa(obj.ui, 'WidgetNeuroTreeUi')
                error('WidgetNeuroTree: initializing Ui failed!');
            end
            
            % create Viewer
            obj.viewer = WidgetNeuroTreeViewer('Parent', parserObj.Results.Viewer);
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
            addlistener(obj.ui, 'event_new', @obj.fcnCallbackUi_eventNew);
            addlistener(obj.ui, 'event_clear', @obj.fcnCallbackUi_eventClear);
            addlistener(obj.ui, 'event_load', @obj.fcnCallbackUi_eventLoad);
            addlistener(obj.ui, 'event_export', @obj.fcnCallbackUi_eventExport);
            addlistener(obj.ui, 'event_tabSegment', @obj.fcnCallbackUi_eventSegment);
            addlistener(obj.ui, 'event_tabMask', @obj.fcnCallbackUi_eventMask);
            addlistener(obj.ui, 'thresholdIntensity', 'PostSet', @obj.fcnCallbackUi_eventMask);
            addlistener(obj.ui, 'thresholdNhood', 'PostSet', @obj.fcnCallbackUi_eventMask);
            addlistener(obj.ui, 'viewMask', 'PostSet', @obj.fcnCallbackUi_eventView);
            addlistener(obj.ui, 'viewTree', 'PostSet', @obj.fcnCallbackUi_eventView);
            
            
            
            % add Viewer callbacks
            addlistener(obj.viewer, 'event_clickDown', @obj.fcnCallbackViewer_clickDown);
            addlistener(obj.viewer, 'event_clickUp', @obj.fcnCallbackViewer_clickUp);
            addlistener(obj.viewer, 'event_clickDouble', @obj.fcnCallbackViewer_clickDouble);
            addlistener(obj.viewer, 'event_clickExtend', @obj.fcnCallbackViewer_clickExtend);
            addlistener(obj.viewer, 'event_moveMouse', @obj.fcnCallbackViewer_moveMouse);
            addlistener(obj.viewer, 'event_pressDigit', @obj.fcnCallbackViewer_pressDigit);
            addlistener(obj.viewer, 'event_pressDel', @obj.fcnCallbackViewer_pressDel);
            addlistener(obj.viewer, 'event_pressEsc', @obj.fcnCallbackViewer_pressEsc);
            addlistener(obj.viewer, 'event_hoverIdle', @obj.fcnCallbackViewer_hoverIdle);
            addlistener(obj.viewer, 'event_hoverLine', @obj.fcnCallbackViewer_hoverLine);
            addlistener(obj.viewer, 'event_hoverPoint', @obj.fcnCallbackViewer_hoverPoint);
            
            % add Model callbacks
            addlistener(obj.engine, 'mousePointer', 'PostSet', @obj.fcnCallbackEngine_updateMousePointer);
            addlistener(obj.engine, 'status', 'PostSet', @obj.fcnCallbackEngine_updateStatus);
            
        end
        
        
        
        
    end
    
    
    %% --- Ui callbacks --- %%
    methods (Access = private)
        
        %% @ event segment
        function obj = fcnCallbackUi_eventNew(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::New');
            obj.engine.transition(obj.engine.EVENT_SEGMENT, obj.viewer);
            
        end
        
        %% @ event clear
        function obj = fcnCallbackUi_eventClear(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Clear');
            obj.engine.transition(obj.engine.EVENT_CLEAR, obj.viewer);
            
        end
        
        %% @ event load
        function obj = fcnCallbackUi_eventLoad(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Load');
            obj.engine.transition(obj.engine.EVENT_LOAD, obj.viewer);
            
        end
        
        %% @ event export
        function obj = fcnCallbackUi_eventExport(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Export');
            notify(obj,'event_treeExport');
            obj.engine.transition(obj.engine.EVENT_EXPORT, {'Viewer', obj.viewer,...
                                                            'Path', obj.filePath....
                                                            'Name', obj.fileName});
            
        end
        
        %% @ event tab segment
        function obj = fcnCallbackUi_eventSegment(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Segment');
            obj.engine.transition(obj.engine.EVENT_SEGMENT, []);
            
        end
        
        %% @ event mask
        function obj = fcnCallbackUi_eventMask(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Mask');
            obj.engine.transition(obj.engine.EVENT_MASK, obj.viewer);
            
        end
        
        %% @ event view
        function obj = fcnCallbackUi_eventView(obj, ~, ~)
            
            disp('WidgetNeuroTree::UiEvent::Mask');
            obj.engine.transition(obj.engine.EVENT_VIEW, obj.viewer);
            
        end
        
    end
    
    
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
        
        %% @ event click extend
        function obj = fcnCallbackViewer_clickExtend(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_CLICKEXTEND, obj.viewer);
            
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
        
        %% @ event hover idle
        function obj = fcnCallbackViewer_hoverIdle(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_HOVERIDLE, obj.viewer);
            
        end
        
        %% @ event hover line
        function obj = fcnCallbackViewer_hoverLine(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_HOVERLINE, obj.viewer);
            
        end
        
        %% @ event hover point
        function obj = fcnCallbackViewer_hoverPoint(obj, ~, ~)
            
            obj.engine.transition(obj.engine.EVENT_HOVERPOINT, obj.viewer);
            
        end
        
        %% @ event postset mouse pointer
        function obj = fcnCallbackEngine_updateMousePointer(obj, ~, ~)
            
            obj.viewer.changeMousePointer(obj.engine.mousePointer);
            
        end
        
        %% @ event postset status
        function obj = fcnCallbackEngine_updateStatus(obj, ~, ~)
            
            obj.ui.changeStatus(obj.engine.status);
            
        end
        
        
    end
    
end % class end