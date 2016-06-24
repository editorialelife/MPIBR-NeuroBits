function [] = uiAlignText(handle, anchor)
%
% UIALIGNTEXT(handle, acnhor) Aligns uicontrol text component
% with given acnhor
%

    % check handle
    if ~isgraphics(handle,'uicontrol')
        error('uiAlignText:IsGraphics', 'provided handle is not graphics of type uicontrol.')
    end

    if ~strcmp(handle.Style, 'text')
            error('uiAlignText:IsText', 'provided handle is not uicontrol with style text.');
    end
    
    % check anchor
    if ~any(strcmpi(anchor,...
                  {'center','north','south','west','east',...
                   'northwest','northeast','southwest','southeast'}))
               
        error('uiAlignText:anchor', 'unknown anchor position.');
        
    end        
    
    % get current text extent
    extent = get(handle, 'Extent');
    
    % get current text parent
    position = get(handle, 'Position');
    
    % update grid
    tmpGridXPos = position(1);
    tmpGridYPos = position(2);
    tmpGridWidth = position(3);
    tmpGridHeight = position(4);
    
    
    % set final grid size
    if extent(4) < tmpGridHeight
        gridHeight = extent(4);
    else
        gridHeight = tmpGridHeight;
    end

    if extent(3) < tmpGridWidth
        gridWidth = extent(3);
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
        
        otherwise
            
            error('uiGridLayout:Anchor','unknown anchor position.');
            
    end
    
    % export ui grid
    uigrid = [gridXPos,...
              gridYPos,...
              gridWidth,...
              gridHeight];
          
    % reset position
    set(handle, 'Position', uigrid);
    
end

