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
        EVENT_LOAD = 15;
        EVENT_MASK = 16;
        EVENT_COUNT = 17;
        
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
            
            %% load tree
            obj.smtable(obj.STATE_NULL, obj.EVENT_LOAD) = ...
                {{obj.STATE_NULL, 'arrow', @obj.actionLoadTree}};
            
            %% create mask
            obj.smtable(obj.STATE_NULL, obj.EVENT_MASK) = ...
                {{obj.STATE_NULL, 'arrow', @obj.actionCreateMask}};
            
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
        function obj = actionExportTree(obj, eventdata)
            
            % recast eventdata
            parserObj = inputParser;
            addParameter(parserObj, 'Viewer',[], @(varobj) isa(varobj, 'WidgetNeuroTreeViewer'));
            addParameter(parserObj, 'Path', pwd, @(varchar) ischar(varchar) && exist(varchar,'dir') == 7);
            addParameter(parserObj, 'Name', 'testTree', @(varchar) ischar(varchar));
            parse(parserObj, eventdata{:});
            objviewer = parserObj.Results.Viewer;
            filePath = parserObj.Results.Path;
            fileName = parserObj.Results.Name;
            imgsize = objviewer.size();
            
            % loop the tree
            vartxt = '';
            for b = 1 : length(obj.tree)
                if isvalid(obj.tree(b))
                    vartxt = sprintf('%s%s',vartxt,obj.tree(b).export);
                end
            end
            
            % write to file
            if ~isempty(vartxt)
                
                
                % create output file
                fileOut = [filePath,...
                           filesep,...
                           fileName,...
                           '_neuroTree_',...
                           datestr(now,'ddmmmyyyy')];
                       
                % check if file exists
                if exist([fileOut,'.txt'], 'file') == 2
                    choice = questdlg('Overwrite NeuroTree file?','NeuroTree:Export','Yes','No','Yes');
                    if strcmp(choice, 'No')
                        fileOut = [obj.path,...
                                   filesep,...
                                   obj.name,...
                                   '_neuroTree_',...
                                   datestr(now,'HHMMSS-ddmmmyyyy')];
                    end
                end
                
                % export text
                fpWrite = fopen([fileOut,'.txt'], 'w');
                fprintf(fpWrite, 'file_path=%s\n', filePath);
                fprintf(fpWrite, 'file_name=%s\n', fileName);
                %fprintf(fpWrite, 'dilation[px]=%d\n', dilation);
                %fprintf(fpWrite, 'nhood[px]=%d\n', nhood);
                fprintf(fpWrite, 'width[px]=%d\n',imgsize(2));
                fprintf(fpWrite, 'height[px]%d\n',imgsize(1));
                fprintf(fpWrite, '\n');
                fprintf(fpWrite,'%s',vartxt);
                fclose(fpWrite);
                
                % export image
                print(objviewer.handle_figure, '-dpng','-r300',[fileOut,'.png']);
                
                obj.status = 'export request :: done';
                
            else
                
                obj.status = 'export request :: empty tree';
                
            end
            
        end
        
        
        %% @ action load tree
        function obj = actionLoadTree(obj, objviewer)
            
            %LOAD load tree file
            % choose file to load
            [fileName, filePath] = uigetfile({'*_neuroTree_*.txt', 'WidgetNeuroTree files'},'Pick a file');
            
            % open file to read
            fpRead = fopen([filePath, fileName], 'r');
            txt = textscan(fpRead, '%s', 'delimiter', '\n');
            fclose(fpRead);
            txt = txt{:};
            
            % read dilation
            %queryTxt = 'dilation[px]=';
            %idxTxtDilation = strncmp(queryTxt, txt, length(queryTxt));
            %obj.dilation = sscanf(txt{idxTxtDilation},'dilation[px]=%d');
            
            % read nhood
            %queryTxt = 'nhood[px]=';
            %idxTxtNhood = strncmp(queryTxt, txt, length(queryTxt));
            %obj.nhood = sscanf(txt{idxTxtNhood},'nhood[px]=%d');
            
            % read branch info
            idxTxtBranch = strncmp('branch', txt, 6);
            idxTxtBranch = cumsum(idxTxtBranch);
            branchCount = max(idxTxtBranch);
            
            for b = 1 : branchCount
                
                if sum(idxTxtBranch == b) == 10
                    
                    % allocate new branch
                    newBranch = WidgetNeuroTreeBranch(...
                        'Axes', objviewer.handle_axes,...
                        'Depth', '0',...
                        'BranchIndex', obj.indexBranch);
            
                    if ~isa(newBranch, 'WidgetNeuroTreeBranch')
                        error('WidgetNeuroTree: initializing new Branch failed!');
                    end
            
                    % add branch to tree
                    obj.tree = cat(2, obj.tree, newBranch);
                    obj.tree(b).load(txt(idxTxtBranch == b));
                    
                else
                    warning('NeuroTreeBranch:load','incomplete branch data.');
                end
                
            end
            
            % update user message
            obj.status = sprintf('load request :: tree with %d branches',branchCount);
            
        end
        
        
        %% @ action create mask
        function obj = actionCreateMask(obj, objviewer)
            
            % get image dimensions
            imgsize = objviewer.size();
            disp(imgsize);
            % accumulate mask
            mask = zeros(prod(imgsize),1);
            for b = 1 : length(obj.tree)
                
                % retrieve nodes
                nodes = obj.tree(b).nodes;
                if obj.tree(b).depth == 0
                    nodes = cat(1,nodes,nodes(1,:));
                end
                
                % calculate cumulative pixel distance along line
                dNodes = sqrt(sum(diff(nodes, [], 1).^2, 2));
                csNodes = cat(1, 0, cumsum(dNodes));
                
                % resample nodes at sub-pixel intervals
                sampleCsNodes = linspace(0, csNodes(end), ceil(csNodes(end)/0.5));
                sampleNodes = interp1(csNodes, nodes, sampleCsNodes,'pchip');
                sampleNodes = round(sampleNodes);
                
                % filter outside borders
                idxFilter = any(sampleNodes < 1, 2) | ...
                            (sampleNodes(:,1) > imgsize(2)) | ...
                            (sampleNodes(:,2) > imgsize(1));
                sampleNodes(idxFilter,:) = [];
                
                disp(sampleNodes);
                
                % get pixels
                %pixels = sub2ind(imgsize, sampleNodes(:,2), sampleNodes(:,1));
                
                % fill mask with branch id
                %mask(pixels) = obj.tree(b).indexBranch;
                
            end
            
            %mask = reshape(mask, imgsize(1), imgsize(2));
            
            %figure('color','w');
            %imagesc(mask);
            
            
        end
        
        
    end
    
    
end

