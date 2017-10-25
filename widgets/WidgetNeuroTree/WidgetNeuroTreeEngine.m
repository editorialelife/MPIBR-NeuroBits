classdef WidgetNeuroTreeEngine < handle
    
    properties (Access = public, SetObservable = true)
        
        mousePointer
        
    end
    
    properties (Access = public)
        
        state
        smtable
        tree
        indexBranch
        
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
                {{obj.STATE_ANCHOR, 'crosshair', @obj.actionCreate}};
            
            obj.smtable(obj.STATE_ANCHOR, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, '', @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, '', @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_DRAW, '', @obj.acitonStretch}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, 'arrow', @obj.actionComplete}};
            
            %% initialize state
            obj.state = obj.STATE_IDLE;
            
        end
        
        function obj = transition(obj, event_fired, objviewer)
            
            callback = obj.smtable{obj.state, event_fired};
            
            if ~isempty(callback)
                
                % set next state
                obj.state = callback{1};
                
                % set mouse pointer
                if ~isempty(callback{2})
                obj.mousePointer = callback{2};
                end
                
                % evoke callback function
                callback{3}(objviewer);
                
            end
            
        end
        
    end
    
    methods (Access = private)
        
        function obj = actionCreate(obj, objviewer)
            
            % constructor for branch
            fprintf('WidgetNeuroTree :: create branch\n');
            
            % update branch index
            obj.indexBranch = length(obj.tree) + 1;
            
            % allocate new branch
            newBranch = WidgetNeuroTreeBranch(...
                        'Axes', objviewer.handle_axes,...
                        'Depth', objviewer.press_key,...
                        'Index', obj.indexBranch);
            
            if ~isa(newBranch, 'WidgetNeuroTreeBranch')
                error('WidgetNeuroTree: initializing new Branch failed!');
            end
            
            % add branch to tree
            obj.tree = cat(1, obj.tree, newBranch);
            
        end
        
        function obj = actionExtend(obj, objviewer)
            
            % constructor for branch
            fprintf('WidgetNeuroTree :: extend branch\n');
            
            % add node to branch
            obj.tree(obj.indexBranch).addNode(objviewer.click_down);
            
        end
        
        function obj = acitonStretch(obj, objviewer)
            
            % click
            %fprintf('WidgetNeuroTree :: stretch\n');
            
            % strecth line
            obj.tree(obj.indexBranch).pullLine(objviewer.move_mouse);
            
        end
        
        function obj = actionComplete(obj, ~)
            
            % click
            fprintf('WidgetNeuroTree :: complete\n');
            
            % fix branch
            obj.tree(obj.indexBranch).fixBranch();
            
        end
        
        function obj = actionPickUp(obj, objviewer)
        end
        
        function obj = actionPutDown(obj, objviewer)
        end
        
        function obj = actionSelect(obj, objviewer)
        end
        
        function obj = actionDeselect(obj, objviewer)
        end
        
        function obj = actionReposition(obj, objviewer)
        end
        
        function obj = actionRemove(obj, objviewer)
        end
        
        function obj = actionErase(obj, objviewer)
        end
        
        function obj = actionHover(obj, objviewer)
        end
           
    end
    
    
end

