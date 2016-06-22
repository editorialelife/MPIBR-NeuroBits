classdef NeuroTreeBranch < handle
    %
    % NeuroTreeBranch
    %
    % support class for WidgetNeuroTree 
    % keep properties per tree branch
    % draw methods for branch
    %
    % used by:
    %    WidgetNeuroTree
    %
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties
        tag
        index
        parent
        children
        depth
        nodes
        span
        pixels
    end
    
    properties (Access = private)
        ui_parent
        ui_point
        ui_line
        ui_label
    end
    
    properties(Constant = true, Hidden = true)
        
        LINE_WIDTH = 4;
        LINE_ALPHA = 0.5;
        MARKER_SIZE = 5;
        FONT_SIZE = 10;
        DEFAULT_NODE = [0,0];
        
        BRANCH_POINT_RADIUS = 100;
        
        COLOR_TABLE = [255,0,0;...   % red
                      255,125,0;... % orange
                      255,255,0;... % yellow
                      125,255,0;... % spring green
                      0,255,0;...   % green
                      0,255,125;... % turquoise
                      0,255,255;... % cyan
                      0,125,255;... % ocean
                      0,0,255;...   % blue
                      125,0,255;... % violet
                      255,0,255;... % magenta
                      255,0,125]... % raspberry
                      ./255; 
                  
    end
    
    methods
        
        % method :: NeuroTreeBranch
        %  input :: varargin
        % action :: class constructor
        function obj = NeuroTreeBranch(varargin)
            
            % use parser
            parserObj = inputParser;
            
            % define inputs
            addParameter(parserObj, 'Index', [], @isIndex);
            addParameter(parserObj, 'Depth', [], @isDepth);
            addParameter(parserObj, 'Parent', [], @(x) isgraphics(x, 'Axes'));
            
            % parse varargin
            parse(parserObj, varargin{:});
            
            % set properties
            obj.index = parserObj.Results.Index;
            obj.depth = str2double(parserObj.Results.Depth);
            obj.ui_parent = parserObj.Results.Parent;
            
            % allocateBranch
            obj.allocateBranch();
            
        end
        
        % method :: allocateBranch
        %  input :: class object
        % action :: set default properties
        function obj = allocateBranch(obj)
            
            % set defaults
            obj.tag = 0;
            obj.parent = [];
            obj.children = [];
            obj.nodes = obj.DEFAULT_NODE;
            obj.span = 0;
            
            % set graphics handles
            hold(obj.ui_parent, 'on');
            
            obj.ui_point = plot(obj.nodes(:,1), obj.nodes(:,2), '*',...
                                'MarkerSize', obj.MARKER_SIZE,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_parent,...
                                'Visible', 'off');
           
            obj.ui_line = plot(obj.nodes(:,1),obj.nodes(:,2), '-',...
                                'LineWidth', obj.LINE_WIDTH,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_parent,...
                                'Visible', 'off');
            obj.ui_line.Color(4) = obj.LINE_ALPHA;
            
            obj.ui_label = text(obj.nodes(:,1), obj.nodes(:,2), '',...
                                'FontSize', obj.FONT_SIZE,...
                                'Parent', obj.ui_parent,...
                                'Visible', 'off');
                            
            hold(obj.ui_parent, 'off');
            
            
            % integrate current branch index in user data
            set(obj.ui_point, 'UserData', obj.index);
            set(obj.ui_line, 'UserData', obj.index);
            set(obj.ui_label, 'UserData', obj.index);
            
        end
        
        
        % method :: extendBranch
        %  input :: class object, indexNode, click
        % action :: add node to branch
        function obj = extendBranch(obj, indexNode, click)
            
            % add click to nodes
            obj.nodes(indexNode,:) = click;
            
            % update point
            obj.ui_point.XData(indexNode) = click(1);
            obj.ui_point.YData(indexNode) = click(2);
            set(obj.ui_point, 'Visible', 'on');
            
            % update line
            obj.ui_line.XData(indexNode) = click(1);
            obj.ui_line.YData(indexNode) = click(2);
            set(obj.ui_line, 'Visible', 'on');
            
        end
        
        % method :: stretchBranch
        %  input :: class object, indexNode, click
        % action :: elongate branch without adding a node
        function obj = stretchBranch(obj, indexNode, click)
            
            % update line
            obj.ui_line.XData(indexNode) = click(1);
            obj.ui_line.YData(indexNode) = click(2);
            
        end
        
        % method :: completeBranch
        %  input :: class object, height, width
        % action :: complete branch and calculate length and pixels
        function obj = completeBranch(obj, height, width)
            
            % reorder uistack
            % points need to be on top of line to retrieve node
            uistack(obj.ui_point, 'up');
            
            % closed polygon at root
            if obj.depth == 0
                
                % update nodes
                obj.nodes = cat(1, obj.nodes, obj.nodes(1,:));
                
                % update line
                obj.ui_line.XData = cat(2, obj.ui_line.XData, obj.ui_line.XData(1));
                obj.ui_line.YData = cat(2, obj.ui_line.YData, obj.ui_line.YData(1));
            end
            
            % set branch length
            obj.measureBranch();
            
            % create pixel array
            obj.nodesToPixels(height, width);
            
        end
        
        
        % method :: updateBranch
        %  input :: class object, deltaClick
        % action :: update branch ui components
        function obj = updateBranch(obj, deltaClick)
            
            % update nodes
            obj.nodes = bsxfun(@plus, obj.nodes, deltaClick);
            
            % update line
            obj.ui_line.XData = obj.ui_line.XData + deltaClick(1);
            obj.ui_line.YData = obj.ui_line.YData + deltaClick(2);
            
            % update points
            obj.ui_point.XData = obj.ui_point.XData + deltaClick(1);
            obj.ui_point.YData = obj.ui_point.YData + deltaClick(2);
            
        end
        
        % method :: updateNode
        %  input :: class object, indexNode, deltaClick
        % action :: update given node in ui components
        function obj = updateNode(obj, indexNode, deltaClick)
            
            % update nodes
            obj.nodes(indexNode,:) = deltaClick;
            
            % update line
            obj.ui_line.XData(indexNode) = deltaClick(1);
            obj.ui_line.YData(indexNode) = deltaClick(2);
            
            % update points
            obj.ui_point.XData(indexNode) = deltaClick(1);
            obj.ui_point.YData(indexNode) = deltaClick(2);
            
        end
        
        % method :: selectBranch
        %  input :: class object
        % action :: highlight branch ui
        function obj = selectBranch(obj)
            
            % remove line Alpha property
            obj.ui_line.Color(4) = 1;
            
            % double the size of marker size
            obj.ui_point.MarkerSize = 2 * obj.MARKER_SIZE;
            
        end
        
        % method :: deselectBranch
        %  input :: class object
        % action :: highlight branch ui
        function obj = deselectBranch(obj)
            
            % revert line Alpha value
            obj.ui_line.Color(4) = obj.LINE_ALPHA;
            
            % revert point marker size
            obj.ui_point.MarkerSize = obj.MARKER_SIZE;
            
        end
        
        % method :: measureBranch
        %  input :: class object
        % action :: measure length of current branch
        function obj = measureBranch(obj)
            
            diffLength = sqrt(sum(diff(obj.nodes, [], 1).^2, 2));
            obj.span = sum(diffLength);
            
        end
        
        % method :: reindexBranch
        %  input :: class object, indexNew
        % action :: reindex current branch index
        function obj = reindexBranch(obj, indexBranch)
            
            % update index
            obj.index = indexBranch;
            
            % update UserData property in ui elements
            set(obj.ui_point, 'UserData', obj.index);
            set(obj.ui_line, 'UserData', obj.index);
            set(obj.ui_label, 'UserData', obj.index);
            
            % destroy available parent/children annotation
            obj.tag = [];
            obj.parent = [];
            obj.children  = [];
            
        end
        
        % method :: disposeNode
        %  input :: calss object, indexNode
        % action :: remove node  from array
        function obj = disposeNode(obj, indexNode)
            
            % update nodes
            obj.nodes(indexNode, :) = [];
            
            % update point
            obj.ui_point.XData(indexNode) = [];
            obj.ui_point.YData(indexNode) = [];
            
            % update line
            obj.ui_line.XData(indexNode) = [];
            obj.ui_line.YData(indexNode) = [];
                
        end
        
        % method :: disposeBranch
        %  input :: class object
        % action :: dispose ui elements of current branch
        function obj = disposeBranch(obj)
            
            delete(obj.ui_point);
            delete(obj.ui_line);
            delete(obj.ui_label);
            delete(obj);
            
        end
        
        
        % method :: linkParent
        %  input :: class object, listNodes
        %  input :: depthPerNode, minTreeDepth, indexBranchPerNode
        % action :: finds closest parent node
        function obj = linkParent(obj, listNodes, depthPerNode, minTreeDepth, indexBranchPerNode)
            
            % check branch order
            if obj.depth == minTreeDepth
                
                obj.parent = 0;
                
            else
                
                parentNodesIndex = depthPerNode == (obj.depth - 1);
                parentNodes = listNodes(parentNodesIndex, :);
                parentIndex = indexBranchPerNode(parentNodesIndex);
                
                
                distNodes = sqrt(sum(bsxfun(@minus, parentNodes, obj.nodes(1,:)).^2, 2));
                [minDistNodes, indexMinDistNodes] = min(distNodes);
                
                % add parent index
                if minDistNodes <= obj.BRANCH_POINT_RADIUS
                    obj.parent = parentIndex(indexMinDistNodes);
                end
                
            end
            
        end
        
        % method :: linkChildren
        %  input :: class object, listNodes
        %  input :: depthPerNode, maxTreeDepth, indexBranchPerNode
        % action :: finds closest child node
        function obj = linkChildren(obj, listNodes, depthPerNode, maxTreeDepth, indexBranchPerNode)
            
            % check branch order
            if obj.depth == maxTreeDepth
                
                obj.children = 0;
                
            else
                
                childrenNodesIndex = depthPerNode == (obj.depth + 1);
                childrenNodes = listNodes(childrenNodesIndex, :);
                childrenIndex = indexBranchPerNode(childrenNodesIndex);
                
                countNodes = size(obj.nodes, 1);
                
                % for closed polygon nodes check children around each node
                % else just check children around last node
                if obj.depth == 0
                    k = 1;
                else
                    k = countNodes;
                end
                
                % loop through required nodes
                tempChildren = [];
                for n = k : countNodes
                    
                    distNodes = sqrt(sum(bsxfun(@minus, childrenNodes, obj.nodes(k,:)).^2, 2));
                    
                    % add parent index
                    if any(distNodes <= obj.BRANCH_POINT_RADIUS)
                        tempChildren = cat(1, tempChildren, childrenIndex(distNodes <= obj.BRANCH_POINT_RADIUS));
                    end
                
                end
                
                obj.children = unique(tempChildren);
                
                
            end
            
        end
        
        
        % method :: nodesToPixels
        %  input :: class object, height, width
        % action :: takes nodes and return pixels
        function obj = nodesToPixels(obj, height, width)
            
            % calculate cumulative pixel distance along line
            dNodes = sqrt(sum(diff(obj.nodes, [], 1).^2, 2));
            csNodes = cat(1, 0, cumsum(dNodes));
            
            % resample nodes at sub-pixel intervals
            sampleCsNodes = linspace(0, csNodes(end), ceil(csNodes(end)/0.5));
            sampleNodes = interp1(csNodes, obj.nodes, sampleCsNodes);
            sampleNodes = round(sampleNodes);
            
            % return pixel indexes
            obj.pixels = sub2ind([height, width], sampleNodes(:,2), sampleNodes(:,1));
            
        end
        
        
        % method :: getBranchColor
        %  input :: class object
        % action :: returns current branch color
        function value = getBranchColor(obj)
            value = round(255 .* obj.COLOR_TABLE(obj.depth + 1, :));
        end
        
    end
    
end

% parser :: isIndex
%  input :: parserValue
% action :: check if parserValue is valid index
function tf = isIndex(parserValue)

    % default output
    tf = true;
    
    % check if numeric
    if ~isnumeric(parserValue)
        tf = false;
    end
    
    % check if whole number
    if rem(parserValue, 1) ~= 0
        tf = false;
    end
    
end

% parser :: isDepth
%  input :: parserValue
% action :: check if parserValue is valid depth
function tf = isDepth(parserValue)

    % default output
    tf = true;
    
    % check if char
    if ~ischar(parserValue)
        tf = false;
    end
    
    % check if in range
    if (parserValue < '0') || (parserValue > '9')
        tf = false;
    end
    
end
