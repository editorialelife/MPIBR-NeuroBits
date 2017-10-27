classdef WidgetNeuroTreeEngine < handle
    
    properties (Access = public, SetObservable = true)
        
        mousePointer
        
    end
    
    properties (Access = public)
        
        state
        smtable
        tree
        indexBranch
        indexSelected
        grabbed_indexBranch
        grabbed_indexNode
        grabbed_center
        grabbed_angle
        
    end
    
    properties (Access = private, Constant = true)
        
        STATE_NULL = 1;
        STATE_IDLE = 2;
        STATE_ANCHOR = 3;
        STATE_DRAW = 4;
        STATE_OVERLINE = 5;
        STATE_OVERPOINT = 6;
        STATE_GRABSELECTED = 7;
        STATE_GRABLINE = 8;
        STATE_GRABPOINT = 9;
        STATE_ROTATE = 10;
        STATE_COUNT = 11;
        STATE_LIST = {'STATE_NULL','STATE_IDLE','STATE_ANCHOR','STATE_DRAW',...
              'STATE_GRAB','STATE_OVERLINE','STATE_OVERPOINT','STATE_REPOSITION'};
       
    end
    
    properties (Access = public, Constant = true)
        
        EVENT_NULL = 1;
        EVENT_CLICKDOWN = 2;
        EVENT_CLICKUP = 3;
        EVENT_CLICKDOUBLE = 4;
        EVENT_CLICKEXTEND = 5;
        EVENT_PRESSDIGIT = 6;
        EVENT_PRESSESC = 7;
        EVENT_PRESSDEL = 8;
        EVENT_MOVEMOUSE = 9;
        EVENT_HOVERIDLE = 10;
        EVENT_HOVERLINE = 11;
        EVENT_HOVERPOINT = 12;
        EVENT_COUNT = 13;
        EVENT_LIST = {'EVENT_NULL','EVENT_CLICKDOWN','EVENT_CLICKUP',...
                      'EVENT_CLICKDOUBLE','EVENT_PRESSDIGIT',...
                      'EVENT_PRESSESC','EVENT_PRESSDEL',...
                      'EVENT_MOVEMOUSE','EVENT_HOVERHANDLE'};
        
    end
    
    methods
        
        function obj = WidgetNeuroTreeEngine()
            
            %% set state machine table
            obj.smtable = cell(obj.STATE_COUNT, obj.EVENT_COUNT);
            
            %% start drawing
            obj.smtable(obj.STATE_IDLE, obj.EVENT_PRESSDIGIT) = ...
                {{obj.STATE_ANCHOR, 'crosshair', @obj.actionCreate}};
            
            obj.smtable(obj.STATE_ANCHOR, obj.EVENT_PRESSESC) = ...
                {{obj.STATE_IDLE, 'arrow', @obj.actionCancel}};
            
            obj.smtable(obj.STATE_ANCHOR, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, '', @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_DRAW, '', @obj.actionExtend}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_DRAW, '', @obj.acitonStretch}};
            
            obj.smtable(obj.STATE_DRAW, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, 'arrow', @obj.actionComplete}};
            
            %% hover over objects
            obj.smtable(obj.STATE_IDLE, obj.EVENT_HOVERLINE) = ...
                {{obj.STATE_OVERLINE, 'hand', []}};
            
            obj.smtable(obj.STATE_IDLE, obj.EVENT_HOVERPOINT) = ...
                {{obj.STATE_OVERPOINT, 'circle', []}};
            
            obj.smtable(obj.STATE_OVERLINE, obj.EVENT_HOVERIDLE) = ...
                {{obj.STATE_IDLE, 'arrow', []}};
            
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_HOVERIDLE) = ...
                {{obj.STATE_IDLE, 'arrow', []}};
            
            obj.smtable(obj.STATE_OVERLINE, obj.EVENT_HOVERPOINT) = ...
                {{obj.STATE_OVERPOINT, 'circle', []}};
            
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_HOVERLINE) = ...
                {{obj.STATE_OVERLINE, 'hand', []}};
            
            %% select objects
            obj.smtable(obj.STATE_OVERLINE, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, '', @obj.actionSelect}};
            
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, '', @obj.actionSelect}};
            
            obj.smtable(obj.STATE_IDLE, obj.EVENT_CLICKDOUBLE) = ...
                {{obj.STATE_IDLE, '', @obj.actionDeselect}};
            
            %% move line
            obj.smtable(obj.STATE_OVERLINE, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_GRABLINE, 'cross', @obj.actionPickUp}};
            
            obj.smtable(obj.STATE_GRABLINE, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_GRABLINE, '', @obj.actionRepositionLine}};
            
            obj.smtable(obj.STATE_GRABLINE, obj.EVENT_CLICKUP) = ...
                {{obj.STATE_OVERLINE, 'hand', @obj.actionPutDown}};
            
            %% move selected
            obj.smtable(obj.STATE_IDLE, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_GRABSELECTED, 'arrow', []}};
            
            obj.smtable(obj.STATE_GRABSELECTED, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_GRABSELECTED, '', @obj.actionRepositionSelected}};
            
            obj.smtable(obj.STATE_GRABSELECTED, obj.EVENT_CLICKUP) = ...
                {{obj.STATE_IDLE, 'arrow', []}};
            
            %% move point
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_CLICKDOWN) = ...
                {{obj.STATE_GRABPOINT, 'cross', @obj.actionPickUp}};
            
            obj.smtable(obj.STATE_GRABPOINT, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_GRABPOINT, '', @obj.actionRepositionPoint}};
            
            obj.smtable(obj.STATE_GRABPOINT, obj.EVENT_CLICKUP) = ...
                {{obj.STATE_OVERPOINT, 'circle', @obj.actionPutDown}};
            
            %% remove selected
            obj.smtable(obj.STATE_IDLE, obj.EVENT_PRESSDEL) = ...
                {{obj.STATE_IDLE, '', @obj.actionRemoveSelected}};
            
            %% rotate object
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_CLICKEXTEND) = ...
                {{obj.STATE_ROTATE, 'cross', @obj.actionPickUp}};
            
            obj.smtable(obj.STATE_ROTATE, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_ROTATE, '', @obj.actionRotateBranch}};
            
            obj.smtable(obj.STATE_ROTATE, obj.EVENT_CLICKUP) = ...
                {{obj.STATE_IDLE, 'arrow', @obj.actionPutDown}};
            
            
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
                if ~isempty(callback{3})
                    callback{3}(objviewer);
                end
                
            end
            
        end
        
        function offset = calculateOffset(~, objviewer)
            
            % calculate offset
            offset = objviewer.move_mouse - objviewer.click_down;
            objviewer.click_down = objviewer.move_mouse;
            
        end
        
        function theta = calculateRotation(~, objviewer, center)
            
            % calculate the angle theta from the deltaY and deltaX values
            % (atan2 returns radians values from [-pi, pi])
            % 0 currently points EAST.
            % NOTE: By preserving Y and X param order to atan2,  we are expecting 
            % a CLOCKWISE angle direction.
            theta = atan2(objviewer.move_mouse(2) - center(2),...
                          objviewer.move_mouse(1) - center(1));
            
        end
        
    end
    
    methods (Access = private)
        
        %% @ action create branch
        function obj = actionCreate(obj, objviewer)
            
            % constructor for branch
            fprintf('WidgetNeuroTree :: create branch\n');
            
            % update branch index
            obj.indexBranch = length(obj.tree) + 1;
            
            % allocate new branch
            newBranch = WidgetNeuroTreeBranch(...
                        'Axes', objviewer.handle_axes,...
                        'Depth', objviewer.press_key,...
                        'BranchIndex', obj.indexBranch);
            
            if ~isa(newBranch, 'WidgetNeuroTreeBranch')
                error('WidgetNeuroTree: initializing new Branch failed!');
            end
            
            % add branch to tree
            obj.tree = cat(2, obj.tree, newBranch);
            
        end
        
        %% @ action extend branch
        function obj = actionExtend(obj, objviewer)
            
            % constructor for branch
            fprintf('WidgetNeuroTree :: extend branch\n');
            
            % add node to branch
            obj.tree(obj.indexBranch).addNode(objviewer.click_down);
            
        end
        
        %% @ action stretch branch
        function obj = acitonStretch(obj, objviewer)
            
            % click
            %fprintf('WidgetNeuroTree :: stretch\n');
            
            % strecth line
            obj.tree(obj.indexBranch).pullLine(objviewer.move_mouse);
            
        end
        
        %% @ action complete branch
        function obj = actionComplete(obj, ~)
            
            % click
            fprintf('WidgetNeuroTree :: complete\n');
            
            % fix branch
            obj.tree(obj.indexBranch).fixBranch();
            
        end
        
        
        %% @ action select branch
        function obj = actionSelect(obj, objviewer)
            
            % click 
            fprintf('WidgetNeuroTree :: select\n');
            
            % note selected index
            % line and point UserData contains current index
            indexToSelect = objviewer.hover_handle.UserData;
            
            if any(obj.indexSelected == indexToSelect)
                
                % deselect current
                obj.tree(indexToSelect).select(false);
                obj.indexSelected(obj.indexSelected == indexToSelect) = [];
                
            else
                
                % add current to selection
                obj.indexSelected = cat(2, obj.indexSelected, indexToSelect);
                obj.tree(obj.indexSelected(end)).select(true);
                
            end
            
            
            
        end
        
        %% @ action deselect
        function obj = actionDeselect(obj, ~)
            
            % click 
            fprintf('WidgetNeuroTree :: deselect\n');
            
            % highlight branch
            for k = 1 : length(obj.indexSelected)
                
                obj.tree(obj.indexSelected(k)).select(false);
                
            end
            obj.indexSelected = [];
            
        end
        
        %% @ action pick up
        function obj = actionPickUp(obj, objviewer)
            
            % retrieve current handle branch index
            obj.grabbed_indexBranch = objviewer.hover_handle.UserData;
            
            % retrieve closest node relative to click
            dist = sqrt(sum(bsxfun(@minus, [objviewer.hover_handle.XData',...
                                            objviewer.hover_handle.YData'],...
                                            objviewer.click_down) .^ 2, 2));
            [~, obj.grabbed_indexNode] = min(dist);
            
            % calculate grabbed angle relative to branch center of mass
            obj.grabbed_center = mean(obj.tree(obj.grabbed_indexBranch,:).nodes, 1);
            obj.grabbed_angle = obj.calculateRotation(objviewer, obj.grabbed_center);
            
        end
        
        %% @ action putdown
        function obj = actionPutDown(obj, ~)
            
            obj.grabbed_indexBranch = [];
            obj.grabbed_indexNode = [];
            obj.grabbed_center = [];
            obj.grabbed_angle = [];
            
        end
        
        %% @ action reposition point
        function obj = actionRepositionPoint(obj, objviewer)
            
            % calculate displacement
            offset = obj.calculateOffset(objviewer);
            
            % evoke reposition
            obj.tree(obj.grabbed_indexBranch).moveNode(offset, obj.grabbed_indexNode);
            
        end
        
        %% @ action reposition line
        function obj = actionRepositionLine(obj, objviewer)
            
            % calculate displacement
            offset = obj.calculateOffset(objviewer);
            
            % evoke reposition
            obj.tree(obj.grabbed_indexBranch).moveBranch(offset);
            
        end
        
        %% @ action reposition selected
        function obj = actionRepositionSelected(obj, objviewer)
            
            if any(obj.indexSelected)
                
                % calculate displacement
                offset = obj.calculateOffset(objviewer);
                
                % evoke reposition
                % highlight branch
                for k = 1 : length(obj.indexSelected)

                    obj.tree(obj.indexSelected(k)).moveBranch(offset);

                end
                

            end
            
        end
        
        %% @ action cancel branch
        function obj = actionCancel(obj, ~)
            
            % message
            fprintf('WidgetNeuroTree :: cancel branch\n');
            
            % update branch index
            obj.tree(obj.indexBranch).delete();
            obj.tree(end) = [];
            
            % update last index
            obj.indexBranch = length(obj.tree);
            
        end
        
        %% @ action remove selected
        function obj = actionRemoveSelected(obj, ~)
            
            % message
            fprintf('WidgetNeuroTree :: remove selected\n');
            
            if any(obj.indexSelected)
                
                for k = 1 : length(obj.indexSelected)
                    
                    obj.tree(obj.indexSelected(k)).delete();
                    
                end
                
                obj.indexSelected = [];
            end
            
        end
        
        %% @ action rotate branch
        function obj = actionRotateBranch(obj, objviewer)
            
            % calculate rotation angle in degrees
            theta = obj.calculateRotation(objviewer,obj.grabbed_center);
            
            % evoke reposition
            obj.tree(obj.grabbed_indexBranch).rotateBranch(theta - obj.grabbed_angle);
            
            % update grabbed angle
            obj.grabbed_angle = theta;
            
        end
        
           
    end
    
    
end

