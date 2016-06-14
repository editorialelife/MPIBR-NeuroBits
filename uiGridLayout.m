function [uiGrid] = uiGridLayout(gridSize, margins, spanH, spanW)
	% uiGridLayout
    % calculates a grid position for UI component
    %
    %  input :: gridSize (H x W) - determine number of boxes
    %  input :: margins (H x W) - margins between grid boxes
    %  input :: spanH - number of boxes to combine in height
    %  input :: spanW - number of boxes to combine in width
    % method :: calculates GridLayout
    %
    % Georgi Tushev
    % Max-Planck Institute for Brain Research
    % georgi.tushev@brain.mpg.de
    
    % calculate grid size
    gridHSize = (1 - margins(1) * (gridSize(1) + 1)) / gridSize(1);
    gridWSize = (1 - margins(2) * (gridSize(2) + 1)) / gridSize(2);

    % calculate box position
    gridHPos = flipud(cumsum([margins(1); repmat(gridHSize + margins(1), gridSize(1) - 1, 1)]));
    gridWPos = cumsum([margins(2); repmat(gridWSize + margins(2), gridSize(2) - 1, 1)]);

    % extract grid
    uiGrid = zeros(1,4);
    uiGrid(1) = gridWPos(spanW(1));
    uiGrid(2) = gridHPos(spanH(end));
    uiGrid(3) = length(spanW) * gridWSize + (length(spanW) - 1) * margins(2);
    uiGrid(4) = length(spanH) * gridHSize + (length(spanH) - 1) * margins(1);
    
end