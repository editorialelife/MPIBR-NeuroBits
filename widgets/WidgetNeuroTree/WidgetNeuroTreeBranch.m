classdef WidgetNeuroTreeBranch < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        
        depth
        nodes
        indexBranch
        indexNode
        
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
    
    methods
        
        function obj = WidgetNeuroTreeBranch(varargin)
            
            %%% use input parser
            parserObj = inputParser;
            addParameter(parserObj, 'Axes', [], @(x) isgraphics(x, 'Axes'));
            addParameter(parserObj, 'BranchIndex', 0, @isIndex);
            addParameter(parserObj, 'Depth', 0, @isDepth);
            parse(parserObj, varargin{:});
            
            %%% assign properties
            obj.ui_axes = parserObj.Results.Axes;
            obj.indexBranch = parserObj.Results.BranchIndex;
            obj.depth = str2double(parserObj.Results.Depth);
            obj.nodes = obj.DEFAULT_NODE;
            obj.indexNode = 0;
            
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
        
        function obj = addNode(obj, point)
            
            % add point to nodes
            obj.indexNode = obj.indexNode + 1;
            obj.nodes(obj.indexNode, :) = point;
            
            % render line
            obj.renderLine(point);
            
            % render point
            obj.renderPoint(point);
            
        end
        
        function renderPoint(obj, point)
            
            obj.ui_point.XData(obj.indexNode) = point(1);
            obj.ui_point.YData(obj.indexNode) = point(2);
            set(obj.ui_point, 'Visible', 'on');
            
        end
        
        
        function obj = renderLine(obj, point)
            
            if obj.indexNode == 1
                
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
                ti = linspace(0,t(end),obj.SCALE_INTERPOLATION * obj.indexNode);
                
                
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
        
        
        function obj = select(obj, varstate)
            
            if varstate
                
                obj.ui_line.Color(4) = obj.ALPHA_SELECTED;
                obj.ui_point.MarkerSize = 2 * obj.MARKER_SIZE;
                
            else
                
                obj.ui_line.Color(4) = obj.ALPHA_DESELECTED;
                obj.ui_point.MarkerSize = obj.MARKER_SIZE;
                
            end
            
        end
        
        
        function obj = moveBranch(obj, offset)
            
            % update nodes
            obj.nodes = bsxfun(@plus, obj.nodes, offset);
            
            % update line
            obj.ui_line.XData = obj.ui_line.XData + offset(1);
            obj.ui_line.YData = obj.ui_line.YData + offset(2);
            
            % update points
            obj.ui_point.XData = obj.ui_point.XData + offset(1);
            obj.ui_point.YData = obj.ui_point.YData + offset(2);
            
        end
        
        function obj = moveNode(obj, offset, indexNode)
            
            % update nodes
            obj.nodes(indexNode,:) = obj.nodes(indexNode,:) + offset;
            
            % update point
            obj.ui_point.XData(indexNode) = obj.ui_point.XData(indexNode) + offset(1);
            obj.ui_point.YData(indexNode) = obj.ui_point.YData(indexNode) + offset(2);
            
            % update line
            obj.renderLine(obj.nodes(end,:));
            
        end
        
        function obj = rotateBranch(obj, theta)
            
            mtx = obj.nodes';
            
            % set center of rotation
            center = repmat(mean(mtx,2), 1, length(mtx));
            
            % calculate rotation matrix
            R = [cos(theta), -sin(theta);...
                 sin(theta), cos(theta)];
             
            % do the rotation
            mtx = R * (mtx - center) + center;
            obj.nodes(:,1) = mtx(1,:);
            obj.nodes(:,2) = mtx(2,:);
            
            
            % update points
            obj.ui_point.XData = obj.nodes(:,1);
            obj.ui_point.YData = obj.nodes(:,2);
            
            % update line
            obj.renderLine(obj.nodes(end,:));
            
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
