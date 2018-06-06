classdef WidgetNeuroTreeBranch < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        
        tag
        parent
        children
        depth
        indexBranch
        indexNode
        
    end
    
    properties (Access = public, Dependent = true)
        
        span
        nodes
        export
        
    end
    
    properties (Access = private)
        
        ui_axes
        ui_point
        ui_line
        
    end
    
    properties(Access = private, Constant = true, Hidden = true)
        
        LINE_WIDTH = 4;
        MARKER_SIZE = 5;
        FONT_SIZE = 10;
        DEFAULT_NODE = [-1,-1];
        ALPHA_DESELECTED = 0.5;
        ALPHA_SELECTED = 1.0;
        SCALE_INTERPOLATION = 32;
        
        COLOR_TABLE = [255, 255, 255;...  % white
                       255,   0,   0;...  % red
                       255, 165,   0;...  % orange
                       255, 255,   0;...  % yellow
                        60, 179, 113;...  % dark green
                         0, 255, 255;...  % cyan
                       100, 149, 237;...  % light blue
                         0,   0, 255;...  % blue
                       128,   0, 128;...  % dark purple
                       255,  20, 147]...  % pink
                       ./255;
        
    end
    
    %% constructor / destructor
    methods
        
        function obj = WidgetNeuroTreeBranch(varargin)
            
            %%% use input parser
            parserObj = inputParser;
            addParameter(parserObj, 'Axes', [], @(x) isgraphics(x, 'Axes'));
            addParameter(parserObj, 'BranchIndex', 0, @isIndex);
            addParameter(parserObj, 'Depth', 0, @isDepth);
            parse(parserObj, varargin{:});
            
            %%% assign properties
            obj.tag = 0;
            obj.parent = [];
            obj.children = [];
            obj.ui_axes = parserObj.Results.Axes;
            obj.indexBranch = parserObj.Results.BranchIndex;
            obj.depth = str2double(parserObj.Results.Depth);
            obj.indexNode = 0;
            
            %%% guard check
            if isempty(obj.ui_axes)
                error('WidgetNeuroTreeBranch :: parent axes not provided!\n');
            end
            
            %%% create hidden handles
            hold(obj.ui_axes, 'on');
            
            obj.ui_point = plot(obj.DEFAULT_NODE(:,1), obj.DEFAULT_NODE(:,2), '*',...
                                'MarkerSize', obj.MARKER_SIZE,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_axes,...
                                'Visible', 'off');
           
            obj.ui_line = plot(obj.DEFAULT_NODE(:,1),obj.DEFAULT_NODE(:,2), '-',...
                                'LineWidth', obj.LINE_WIDTH,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_axes,...
                                'Visible', 'off');
            obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
            
            hold(obj.ui_axes, 'off');
            
            % reorder uistack
            % points need to be on top of line to retrieve node
            uistack(obj.ui_point, 'top');
            
            % integrate current branch index in user data
            set(obj.ui_point, 'UserData', obj.indexBranch);
            set(obj.ui_line, 'UserData', obj.indexBranch);
            
        end
        
        function delete(obj)
            
            delete(obj.ui_point);
            delete(obj.ui_line);
            
        end
        
    end
    
    %% branch manipulations
    methods
        
        %% addNode
        function obj = addNode(obj, point)
            
            % add point to nodes
            obj.indexNode = obj.indexNode + 1;
            
            % render point
            obj.ui_point.XData(obj.indexNode) = point(1);
            obj.ui_point.YData(obj.indexNode) = point(2);
            set(obj.ui_point, 'Visible', 'on');
            
            % render line
            obj.renderLine([]);
            
        end
        
        %% renderLine
        function obj = renderLine(obj, point)
            
            xArray = obj.ui_point.XData;
            yArray = obj.ui_point.YData;
            
            % add new point
            if ~isempty(point)
                
                xArray = cat(2, xArray, point(1));
                yArray = cat(2, yArray, point(2));
                
            end
            
            % single point
            if obj.indexNode == 1
                
                xArray = cat(2, xArray, xArray);
                yArray = cat(2, yArray, yArray);
                
            else                
            
                % generate interpolation base
                t = [0, cumsum(diff(xArray).^2 + diff(yArray).^2)];
                ti = linspace(0,t(end),obj.SCALE_INTERPOLATION * obj.indexNode);
             
                % shape - preserving interpolation
                xArray = pchip(t, xArray, ti);
                yArray = pchip(t, yArray, ti);
                
            end
            
            % update line
            obj.ui_line.XData = xArray;
            obj.ui_line.YData = yArray;
                
            set(obj.ui_line, 'Visible', 'on');
            
        end
        
        %% pullLine
        function obj = pullLine(obj, point)
            
            % update only last point
            % interpolation at this step
            % will dramatically slow down
            % ui experience
            
            % update line handler data
            obj.ui_line.XData(end) = point(1);
            obj.ui_line.YData(end) = point(2);
            
        end
        
        %% fix
        function obj = fixBranch(obj)
            
            % close polygon if depth is root
            if obj.depth == 0
                
                obj.renderLine([obj.ui_point.XData(1),...
                                obj.ui_point.YData(1)]);
                
            end
            
        end
        
        %% select/deselect branch
        function obj = select(obj, varstate)
            
            if varstate
                
                obj.ui_line.Color(4) = obj.ALPHA_SELECTED;
                obj.ui_point.MarkerSize = 2 * obj.MARKER_SIZE;
                
            else
                
                obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
                obj.ui_point.MarkerSize = obj.MARKER_SIZE;
                
            end
            
        end
        
        %% move branch
        function obj = moveBranch(obj, offset)
            
            % update points
            obj.ui_point.XData = obj.ui_point.XData + offset(1);
            obj.ui_point.YData = obj.ui_point.YData + offset(2);
            
            % update line
            obj.ui_line.XData = obj.ui_line.XData + offset(1);
            obj.ui_line.YData = obj.ui_line.YData + offset(2);
            
        end
        
        %% move node
        function obj = moveNode(obj, offset, indexNode)
            
            % update point
            obj.ui_point.XData(indexNode) = obj.ui_point.XData(indexNode) + offset(1);
            obj.ui_point.YData(indexNode) = obj.ui_point.YData(indexNode) + offset(2);
            
            % update line
            if obj.depth == 0
                
                obj.renderLine([obj.ui_point.XData(1),...
                                obj.ui_point.YData(1)]);
                            
            else
                
                obj.renderLine([]);
                
            end
            
        end
        
        %% rotate branch
        function obj = rotateBranch(obj, theta)
            
            arrayPoint = [obj.ui_point.XData; obj.ui_point.YData];
            arrayLine = [obj.ui_line.XData; obj.ui_line.YData];
            
            % calculate center of mass
            centerOfMass = mean(arrayPoint, 2);
            
            % calculate rotation matrix
            R = [cos(theta), -sin(theta);...
                 sin(theta), cos(theta)];
            
            % rotate
            arrayPoint = R * (arrayPoint - centerOfMass) + centerOfMass;
            arrayLine = R * (arrayLine - centerOfMass) + centerOfMass;
             
            % update points
            obj.ui_point.XData = arrayPoint(1,:);
            obj.ui_point.YData = arrayPoint(2,:);
            
            % update line
            obj.ui_line.XData = arrayLine(1,:);
            obj.ui_line.YData = arrayLine(2,:);
            
        end
        
        
        %% load branch 
        function obj = load(obj, vartxt)
            
            % parse text
            obj.indexBranch = sscanf(vartxt{1}, 'branch=%d');
            obj.depth = sscanf(vartxt{2}, 'depth=%d');
            obj.tag = sscanf(vartxt{3}, 'tag=%d');
            obj.parent = sscanf(vartxt{4}, 'parent=%d');
            obj.children = str2double(regexp(vartxt{5},'\d*','match'));
            %obj.span = sscanf(vartxt{6}, 'span=%f');
            nodeCount = sscanf(vartxt{7}, 'nodes=%d');
            xData = str2double(regexp(vartxt{8}, '\d+\.?\d*', 'match'));
            yData = str2double(regexp(vartxt{9}, '\d+\.?\d*', 'match'));
            
            if (nodeCount ~= length(xData)) || (length(xData) ~= length(yData))
                error('WidgetNeuroTreeBranch::LoadBranch:: inconsistent nodes count!');
            end
            
            % integrate current branch index in user data
            set(obj.ui_point, 'UserData', obj.indexBranch);
            set(obj.ui_line, 'UserData', obj.indexBranch);
            
            % set color
            set(obj.ui_point, 'Color', obj.COLOR_TABLE(obj.depth + 1, :));
            set(obj.ui_line, 'Color', obj.COLOR_TABLE(obj.depth + 1, :));
            obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
            
            % set nodes
            for n = 1 : nodeCount
          
                obj.addNode([xData(n),yData(n)]);
                
            end
            obj.fixBranch();
            
            % reorder uistack
            % points need to be on top of line to retrieve node
            uistack(obj.ui_point, 'top');
            
        end
         
    end
    
    %% branch dependen properties
    methods
        
        %% return branch nodes
        function varmtx = get.nodes(obj)
            
            if any(obj.ui_point.XData) && any(obj.ui_point.YData)
                
                varmtx = [obj.ui_point.XData; obj.ui_point.YData];
                
            end
            
        end
        
        %% return span
        function value = get.span(obj)
            
            arrayLine = [obj.ui_line.XData; obj.ui_line.YData];
            dist = sqrt(sum(diff(arrayLine, [], 2) .^ 2, 1));
            value = sum(dist);
            
        end
        
        %% return branch properties
        function vartext = get.export(obj)
            
            vartext = sprintf('branch=%d\n', obj.indexBranch);
            vartext = sprintf('%sdepth=%d\n', vartext, obj.depth);
            vartext = sprintf('%stag=%d\n', vartext, obj.tag);
            vartext = sprintf('%sparent=%d\n', vartext, obj.parent);
            childrenList = sprintf('%d,', obj.children);
            childrenList(end) = [];
            vartext = sprintf('%schildren=%s\n', vartext, childrenList);
            vartext = sprintf('%sspan=%.4f\n', vartext, obj.span);
            vartext = sprintf('%snodes=%d\n', vartext, obj.indexNode);
            xPosList = sprintf('%.2f,', obj.ui_point.XData);
            xPosList(end) = [];
            yPosList = sprintf('%.2f,', obj.ui_point.YData);
            yPosList(end) = [];
            vartext = sprintf('%sx=%s\n', vartext, xPosList);
            vartext = sprintf('%sy=%s\n', vartext, yPosList);
            vartext = sprintf('%s\n', vartext);
            
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
