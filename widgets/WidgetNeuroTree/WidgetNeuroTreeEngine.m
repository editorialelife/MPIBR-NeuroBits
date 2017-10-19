classdef WidgetNeuroTreeEngine < handle
    
    properties (Access = private)
        
        state
        smtable
        
    end
    
    properties (Access = private, Constant = true)
        
        STATE_NULL = 1;
        STATE_IDLE = 2;
        STATE_ANCHOR = 3;
        STATE_DRAW = 4;
        STATE_GRAB = 5;
        STATE_HOVER = 6;
        STATE_SELECTED = 7;
        STATE_REPOSITION = 8;
        STATE_COUNT = 9;
        STATE_LIST = {'STATE_NULL','STATE_IDLE','STATE_ANCHOR','STATE_DRAW',...
              'STATE_GRAB','STATE_HOVER','STATE_SELECTED','STATE_REPOSITION'};
       
    end
    
    properties (Access = public, Constant = true)
        
        EVENT_NULL = 1;
        EVENT_CLICKDOWN = 2;
        EVENT_CLICKUP = 3;
        EVENT_CLICKDOUBLE = 4;
        EVENT_PRESSDIGIT = 5;
        EVENT_PRESSESC = 6;
        EVENT_PRESSDEL = 7;
        EVENT_MOVEMOUSE = 8;
        EVENT_HOVERHANDLE = 9;
        EVENT_COUNT = 10;
        EVENT_LIST = {'EVENT_NULL','EVENT_CLICKDOWN','EVENT_CLICKUP',...
                      'EVENT_CLICKDOUBLE','EVENT_PRESSDIGIT',...
                      'EVENT_PRESSESC','EVENT_PRESSDEL',...
                      'EVENT_MOVEMOUSE','EVENT_HOVERHANDLE'};
        
    end
    
    methods
        
        function obj = WidgetNeuroTreeEngine()
            
            %% set state machine table
            obj.smtable = cell(obj.STATE_COUNT, obj.EVENT_COUNT);
            
            obj.smtable(obj.STATE_IDLE, obj.EVENT_PRESSDIGIT) = ...
                {{obj.STATE_ANCHOR, @obj.actionCreate}};
            
            obj.smtable(obj.STATE_ANCHOR, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_DRAW, @obj.acitonStretch}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, @obj.actionComplete}};
            
            %% initialize state
            obj.state = obj.STATE_IDLE;
            
        end
        
        function obj = transition(obj, event_fired, objviewer)
            
            callback = obj.smtable{obj.state, event_fired};
            
            if ~isempty(callback)
                
                obj.state = callback{1};
                callback{2}(objviewer);
                
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function obj = actionCreate(obj, objviewer)
            
            fprintf('actionCreate\n');
            
        end
        
        function obj = actionExtend(obj)
        end
        
        function obj = acitonStretch(obj)
        end
        
        function obj = actionComplete(obj)
        end
        
        function obj = actionPickUp(obj)
        end
        
        function obj = actionPutDown(obj)
        end
        
        function obj = actionSelect(obj)
        end
        
        function obj = actionDeselect(obj)
        end
        
        function obj = actionReposition(obj)
        end
        
        function obj = actionRemove(obj)
        end
        
        function obj = actionErase(obj)
        end
        
        function obj = actionHover(obj)
        end
           
    end
    
    
end

