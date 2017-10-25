classdef WidgetNeuroTreeBranch < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        
        tag
        index
        parent
        isleaf
        depth
        nodes
        span
        pixels
        iter
        
    end
    
    
    properties (Access = public)
        
        ui_axes
        ui_point
        ui_line
        ui_label
        
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
    
    methods
        
        function obj = WidgetNeuroTreeBranch(varargin)
            
            %%% use input parser
            parserObj = inputParser;
            addParameter(parserObj, 'Axes', [], @(x) isgraphics(x, 'Axes'));
            addParameter(parserObj, 'Tag', 0, @isnumeric);
            addParameter(parserObj, 'Index', 0, @isIndex);
            addParameter(parserObj, 'Parent', [], @(x) isa(x, 'WidgetNeuroTreeBranch'));
            addParameter(parserObj, 'Depth', 0, @isDepth);
            parse(parserObj, varargin{:});
            
            %%% assign properties
            obj.ui_axes = parserObj.Results.Axes;
            obj.tag = parserObj.Results.Tag;
            obj.index = parserObj.Results.Index;
            obj.parent = parserObj.Results.Parent;
            obj.depth = str2double(parserObj.Results.Depth);
            obj.nodes = obj.DEFAULT_NODE;
            obj.span = 0;
            obj.pixels = [];
            obj.iter = 0;
            
            %%% guard check
            if isempty(obj.ui_axes)
                error('WidgetNeuroTreeBranch :: parent axes not provided!\n');
            end
            
            %%% create hidden handles
            hold(obj.ui_axes, 'on');
            
            obj.ui_point = plot(obj.nodes(:,1), obj.nodes(:,2), '*',...
                                'MarkerSize', obj.MARKER_SIZE,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_axes,...
                                'Visible', 'off');
           
            obj.ui_line = plot(obj.nodes(:,1),obj.nodes(:,2), '-',...
                                'LineWidth', obj.LINE_WIDTH,...
                                'Color', obj.COLOR_TABLE(obj.depth + 1, :),...
                                'Parent', obj.ui_axes,...
                                'Visible', 'off');
            obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
            
            obj.ui_label = text(obj.nodes(:,1), obj.nodes(:,2), '',...
                                'FontSize', obj.FONT_SIZE,...
                                'Parent', obj.ui_axes,...
                                'Visible', 'off');
            
            hold(obj.ui_axes, 'off');
            
            % reorder uistack
            % points need to be on top of line to retrieve node
            uistack(obj.ui_point, 'top');
            
            % integrate current branch index in user data
            set(obj.ui_point, 'UserData', obj.index);
            set(obj.ui_line, 'UserData', obj.index);
            set(obj.ui_label, 'UserData', obj.index);
            
        end
        
        function obj = addNode(obj, point)
            
            % add point to nodes
            obj.iter = obj.iter + 1;
            obj.nodes(obj.iter, :) = point;
            
            % render line
            obj.renderLine(point);
            
            % render point
            obj.renderPoint(point);
            
        end
        
        function renderPoint(obj, point)
            
            obj.ui_point.XData(obj.iter) = point(1);
            obj.ui_point.YData(obj.iter) = point(2);
            set(obj.ui_point, 'Visible', 'on');
            
        end
        
        
        function obj = renderLine(obj, point)
            
            if obj.iter == 1
                
                obj.ui_line.XData = repmat(point(1), 2, 1);
                obj.ui_line.YData = repmat(point(2), 2, 1);
                
            else
                
                if all(obj.nodes(end,:) == point)
                    xArray = obj.nodes(:,1);
                    yArray = obj.nodes(:,2);
                else
                    xArray = cat(1, obj.nodes(:,1), point(1));
                    yArray = cat(1, obj.nodes(:,2), point(2));
                end
                
                t = [0;cumsum(diff(xArray).^2 + diff(yArray).^2)];
                ti = linspace(0,t(end),obj.SCALE_INTERPOLATION * obj.iter);
                
                
                obj.ui_line.XData = pchip(t, xArray, ti);
                obj.ui_line.YData = pchip(t, yArray, ti);
                
            end
            set(obj.ui_line, 'Visible', 'on');
            
        end
        
        function obj = pullLine(obj, point)
            
            % update only last point
            % interpolation at this step
            % will dramatically slow down
            % ui experience
            
            % update line handler data
            obj.ui_line.XData(end) = point(1);
            obj.ui_line.YData(end) = point(2);
            
        end
        
        function obj = fixBranch(obj)
            
            % close polygon if depth is root
            if obj.depth == 0
                
                obj.renderLine(obj.nodes(1,:)+eps);
                
            end
            
            %% calculate pixels
            %% calculate linkage
            
        end
        
        %{
        
        function obj = remove(obj, indexNode)
            % REMOVE removes node from data and ui arrays
            
            % update nodes
            obj.nodes(indexNode, :) = [];
            
            % update point
            obj.ui_point.XData(indexNode) = [];
            obj.ui_point.YData(indexNode) = [];
            
            % update line
            obj.ui_line.XData(indexNode) = [];
            obj.ui_line.YData(indexNode) = [];
            
        end
        
        function obj = extend(obj, indexNode, point)
            % EXTEND append node to the branch
            
            % add point to nodes
            obj.nodes(indexNode, :) = point;
            
            % update point handler data
            obj.ui_point.XData(indexNode) = point(1);
            obj.ui_point.YData(indexNode) = point(2);
            set(obj.ui_point, 'Visible', 'on');
            
            % update line handler data
            obj.ui_line.XData(indexNode) = point(1);
            obj.ui_line.YData(indexNode) = point(2);
            set(obj.ui_line, 'Visible', 'on');
            
        end
        
        function obj = stretch(obj)
            % STRETCH extends branch without appending node
            
            % update line handler data
            obj.ui_line.XData(indexNode) = point(1);
            obj.ui_line.YData(indexNode) = point(2);
            
        end
        
        function obj = complete(obj)
            % COMPLETE complete branch drawing
            
            % close polygon if depth is root
            if obj.depth == 0
                
                % update line
                obj.ui_line.XData = cat(2, obj.ui_line.XData, obj.ui_line.XData(1));
                obj.ui_line.YData = cat(2, obj.ui_line.YData, obj.ui_line.YData(1));
                
            end
            
            % calculates branch length, pixels and neighbours
            % ???
            
        end
        
        function obj = select(obj)
            % SELECT highlight branch ui
            
            % change line Alpha property
            obj.ui_line.Color(4) = obj.ALPHA_SELECTED;
            
            % double the size of marker size
            obj.ui_point.MarkerSize = 2 * obj.MARKER_SIZE;
            
        end
        
        function obj = deselect(obj)
            % DESELECT remove branch ui highlight
            
            % change line Alpha property
            obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
            
            % revert point marker size
            obj.ui_point.MarkerSize = obj.MARKER_SIZE;
            
        end
        
        function obj = pickup(obj)
        end
        
        function obj = putdown(obj)
        end
        
        function obj = reposition(obj, offset)
            %REPOSITION update branch position with given offset
            
            % update nodes
            obj.nodes = bsxfun(@plus, obj.nodes, offset);
            
            % update line
            obj.ui_line.XData = obj.ui_line.XData + offset(1);
            obj.ui_line.YData = obj.ui_line.YData + offset(2);
            
            % update points
            obj.ui_point.XData = obj.ui_point.XData + offset(1);
            obj.ui_point.YData = obj.ui_point.YData + offset(2);
            
        end
        %}
        
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
