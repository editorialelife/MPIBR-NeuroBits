classdef WidgetNeuroTreeEngine < handle
    
    properties (Access = public, SetObservable = true)
        
        mousePointer
        status
        
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
        
    end
    
    properties (Access = public, Constant = true)
        
        EVENT_CLICKDOWN = 1;
        EVENT_CLICKUP = 2;
        EVENT_CLICKDOUBLE = 3;
        EVENT_CLICKEXTEND = 4;
        EVENT_PRESSDIGIT = 5;
        EVENT_PRESSESC = 6;
        EVENT_PRESSDEL = 7;
        EVENT_MOVEMOUSE = 8;
        EVENT_HOVERIDLE = 9;
        EVENT_HOVERLINE = 10;
        EVENT_HOVERPOINT = 11;
        EVENT_SEGMENT = 12;
        EVENT_CLEAR = 13;
        EVENT_EXPORT = 14;
        EVENT_COUNT = 15;
        
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
                {{obj.STATE_IDLE, 'arrow', @obj.actionRemoveSelected}};
            
            %% rotate object
            obj.smtable(obj.STATE_OVERPOINT, obj.EVENT_CLICKEXTEND) = ...
                {{obj.STATE_ROTATE, 'cross', @obj.actionPickUp}};
            
            obj.smtable(obj.STATE_ROTATE, obj.EVENT_MOVEMOUSE) = ...
                {{obj.STATE_ROTATE, '', @obj.actionRotateBranch}};
            
            obj.smtable(obj.STATE_ROTATE, obj.EVENT_CLICKUP) = ...
                {{obj.STATE_IDLE, 'arrow', @obj.actionPutDown}};
            
            
            %% activate engin
            obj.smtable(obj.STATE_NULL, obj.EVENT_SEGMENT) = ...
                {{obj.STATE_IDLE, 'arrow', []}};
            
            %% deactivate engine
            obj.smtable(obj.STATE_IDLE, obj.EVENT_CLEAR) = ...
                {{obj.STATE_NULL, 'arrow', @obj.actionClearTree}};
            
            %% export tree
            obj.smtable(obj.STATE_IDLE, obj.EVENT_EXPORT) = ...
                {{obj.STATE_NULL, 'arrow', @obj.actionExportTree}};
            
            %% initialize state
            obj.state = obj.STATE_NULL;
            
            
        end
        
        function obj = transition(obj, event_fired, eventdata)
            
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
                    callback{3}(eventdata);
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
            
            % update status
            obj.status = 'branch created';
            
        end
        
        %% @ action extend branch
        function obj = actionExtend(obj, objviewer)
            
            % add node to branch
            obj.tree(obj.indexBranch).addNode(objviewer.click_down);
            
            % update status
            obj.status = 'branch extended';
            
        end
        
        %% @ action stretch branch
        function obj = acitonStretch(obj, objviewer)
            
            % strecth line
            obj.tree(obj.indexBranch).pullLine(objviewer.move_mouse);
            
        end
        
        %% @ action complete branch
        function obj = actionComplete(obj, ~)
            
            % fix branch
            obj.tree(obj.indexBranch).fixBranch();
            
            % update status
            obj.status = sprintf('branch completed %.4f px', obj.tree(obj.indexBranch).span());
        end
        
        
        %% @ action select branch
        function obj = actionSelect(obj, objviewer)
            
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
            
            % update status
            obj.status = 'branch selected';
            
        end
        
        %% @ action deselect
        function obj = actionDeselect(obj, ~)
            
            % highlight branch
            for k = 1 : length(obj.indexSelected)
                
                obj.tree(obj.indexSelected(k)).select(false);
                
            end
            obj.indexSelected = [];
            
            % update status
            obj.status = 'branch deselected';
            
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
            obj.grabbed_center = mean(obj.tree(obj.grabbed_indexBranch).nodes(), 1);
            obj.grabbed_angle = obj.calculateRotation(objviewer, obj.grabbed_center);
            
            % update status
            obj.status = 'branch picked up';
            
        end
        
        %% @ action putdown
        function obj = actionPutDown(obj, ~)
            
            obj.grabbed_indexBranch = [];
            obj.grabbed_indexNode = [];
            obj.grabbed_center = [];
            obj.grabbed_angle = [];
            
            % update status
            obj.status = 'branch released';
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
            
            % update branch index
            obj.tree(obj.indexBranch).delete();
            obj.tree(end) = [];
            
            % update last index
            obj.indexBranch = length(obj.tree);
            
            % update status
            obj.status = 'branch canceled';
            
        end
        
        %% @ action remove selected
        function obj = actionRemoveSelected(obj, ~)
            
            if any(obj.indexSelected)
                
                for k = 1 : length(obj.indexSelected)
                    
                    obj.tree(obj.indexSelected(k)).delete();
                    
                end
                
                obj.indexSelected = [];
            end
            
            % update status
            obj.status = 'branch removed selected';
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
        
        %% @ action clear tree
        function obj = actionClearTree(obj, ~)
            
            % delete branches
            for t = 1 : length(obj.tree)
                
                if isvalid(obj.tree(t))
                    
                    obj.tree(t).delete();
                    
                end
                
            end
            
            % deallocate tree
            obj.tree = [];
            
            obj.status = 'segment tree';
            
        end
           
        
        %% @ action export tree
        function obj = actionExportTree(obj, filename)
            
            % loop the tree
            vartxt = '';
            for t = 1 : length(obj.tree)
                if isvalid(obj.tree(t))
                    vartxt = sprintf('%s%s',vartxt,obj.tree(t).export);
                end
            end
            
            % write to file
            if ~isempty(vartxt)
                
                disp(vartxt);
                
                if isempty(filename)
                    filename = ['testWidgetNeuroTreeExport_',...
                                    datestr(now, 'yyyymmdd'),...
                                    '.txt'];
                end
                
                
                fw = fopen(filename, 'w');
                fprintf(fw,'%s',vartxt);
                fclose(fw);
                
                obj.status = 'export request :: done';
                
            else
                
                obj.status = 'export request :: empty tree';
                
            end
            
        end
    end
    
    
end

