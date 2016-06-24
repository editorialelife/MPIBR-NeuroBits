function [uigrid] = uiGridLayout(varargin)
%
%UIGRIDLAYOUT Calculates UI component position
%
%  uigrid = UIGRIDLAYOUT('PARENT', handle) returns ui component position
%  based on parent graphics position.
% 
%  UIGRIDLAYOUT(...,'GRID', [M, N]) specifies incorporation of a MxN grid
%  over the parent area, default [1, 1].
%
%  UIGRIDLAYOUT(...,'GAP', [K, L]) specifies gap margin. default [0, 0].
%
%  UIGRIDLAYOUT(...,'VERTICALSPAN', I) [1,M], indices of grid boxes to be
%  included vertically, default 1.
%
%  UIGRIDLAYOUT(...,'HORIZONTALSPAN', J) [1,N], indices of grid boxes to
%  be included horizontally, default 1.
%
%  UIGRIDLAYOUT(...,'MAXIMUMHEIGHT', H) constrain on UI component height,
%  default is grid box height.
%
%  UIGRIDLAYOUT(...,'MAXIMUMWIDTH', W) constrain on UI component width,
%  default is grid box width.
% 
%  UIGRIDLAYOUT(...,'ANCHOR', VARCHAR) strig defining how to anchor the
%  UI component inside the box if required height or width are smaller
%  than box space. Valid VARCHAR values are Center, North, South, West,
%  East, NorthWest, NorthEast, SouthWest, SouthEast, default is Center.
%
% Georgi Tushev
% Max-Planck Institute for Brain Research
% sciclist@brain.mpg.de
%
    
    parseObj = inputParser;
    addParameter(parseObj, 'Parent', [], @isgraphics);
    addParameter(parseObj, 'Grid', [1, 1], @isnumeric);
    addParameter(parseObj, 'Gap', [0, 0], @isnumeric);
    addParameter(parseObj, 'HorizontalSpan', 1, @isnumeric);
    addParameter(parseObj, 'VerticalSpan', 1, @isnumeric);
    addParameter(parseObj, 'MaximumHeight', 0, @isnumeric);
    addParameter(parseObj, 'MaximumWidth', 0, @isnumeric);
    addParameter(parseObj, 'Anchor', 'center', @ischar);
    
    parse(parseObj, varargin{:});
    
    % set variables
    parent = parseObj.Results.Parent;
    grid = parseObj.Results.Grid;
    gap = parseObj.Results.Gap;
    horSpan = parseObj.Results.HorizontalSpan;
    verSpan = parseObj.Results.VerticalSpan;
    maxHeight = parseObj.Results.MaximumHeight;
    maxWidth = parseObj.Results.MaximumWidth;
    anchor = parseObj.Results.Anchor;
    
    % get parent position
    position = get(parent, 'Position');
    
    % calculate grid size
    horGridSize = (position(3) - gap(2) * (grid(2) + 1)) / grid(2);
    verGridSize = (position(4) - gap(1) * (grid(1) + 1)) / grid(1);
    
    % calculate grid position
    verGridPos = flipud(cumsum([gap(1); repmat(verGridSize + gap(1), grid(1) - 1, 1)]));
    horGridPos = cumsum([gap(2); repmat(verGridSize + gap(2), grid(2) - 1, 1)]);

    % set temporary grid
    tmpGridXPos = horGridPos(horSpan(1));
    tmpGridYPos = verGridPos(verSpan(end));
    tmpGridWidth = length(horSpan) * horGridSize + (length(horSpan) - 1) * gap(2);
    tmpGridHeight = length(verSpan) * verGridSize + (length(verSpan) - 1) * gap(1);
    
    % set final grid size
    if (maxHeight < tmpGridHeight) && (maxHeight > 0)
        gridHeight = maxHeight;
    else
        gridHeight = tmpGridHeight;
    end

    if (maxWidth < tmpGridWidth) && (maxWidth > 0);
        gridWidth = maxWidth;
    else
        gridWidth = tmpGridWidth;
    end
    
    % set final grid position
    switch lower(anchor)
    
        case 'center'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth)/2;
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight)/2;
        
        case 'north'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth)/2;
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight);
        
        case 'south'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth)/2;
            gridYPos = tmpGridYPos;
        
        case 'west'
        
            gridXPos = tmpGridXPos;
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight)/2;
        
        case 'east'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth);
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight)/2;
        
        case 'northwest'
        
            gridXPos = tmpGridXPos;
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight);
        
        case 'northeast'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth);
            gridYPos = tmpGridYPos + (tmpGridHeight - gridHeight);
        
        case 'southwest'
        
            gridXPos = tmpGridXPos;
            gridYPos = tmpGridYPos;
        
        case 'southeast'
        
            gridXPos = tmpGridXPos + (tmpGridWidth - gridWidth);
            gridYPos = tmpGridYPos;
        
    end
    
    % export ui grid
    uigrid = [gridXPos,...
              gridYPos,...
              gridWidth,...
              gridHeight];
          
end