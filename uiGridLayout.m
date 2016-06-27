classdef uiGridLayout < handle
%UIGRIDLAYOUT Calculates UI component position
%
%  obj = UIGRIDLAYOUT('PARENT', handle) class constructor based on
%  parent graphics position.
%
%  obj = UIGRIDLAYOUT(..., 'VGRID', varnum) set vertical grid count
%
%  obj = UIGRIDLAYOUT(..., 'HGRID', varnum) set horizontal grid count
%  
%  obj = UIGRIDLAYOUT(..., 'VGAP', varvector) set vertical gap offset,
%  varvector can be 1x1, 1x2 or 1x3, defining top, middle and bottom offset
%
%  obj = UIGRIDLAYOUT(..., 'HGAP', varvector) set horizontal gap offset,
%  varvector can be 1x1, 1x2 or 1x3, defining left, center and right offset
%
%  obj.getGrid() method to return default 1,1 grid box position
%
%  obj.getGrid('VIndex', varvector) specify indexes of grid boxes to
%  include in vertical position, max(varvector) <= VGRID
%
%  obj.getGrid('HIndex', varvector) specify indexes of grid boxes to
%  include in horizontal position, max(varvector) <= HGRID
%
%  obj.align(handle) aligns given handle that is a child uicontrol in the
%  grid.
%
%  obj.align(...,'VIndex', varvector, 'HIndex', varvector) specify vertical
%  and horizontal grid position to align the handle
%
%  obj.align(...,'Anchor', varchar) specify the method of alignment.
%  VARCHAR can be center(default), north, south, west, east, northwest,
%  northeast, southwest, southeast
%
% Georgi Tushev
% Max-Planck Institute for Brain Research
% sciclist@brain.mpg.de
%


    properties
        parent
        
        verGrid_Count
        verGrid_Pos
        verGrid_Size
        verGrid_GapTop
        verGrid_GapMiddle
        verGrid_GapBottom
        
        horGrid_Count
        horGrid_Pos
        horGrid_Size
        horGrid_GapLeft
        horGrid_GapCenter
        horGrid_GapRight
        
    end
    
    methods
        
        % method :: uiGridLaout
        %  input :: varargin
        % action :: class constructor
        function obj = uiGridLayout(varargin)
            
            % use parser class
            parseObj = inputParser;
            addParameter(parseObj, 'Parent', [],@isgraphics);
            addParameter(parseObj, 'VGrid', 1, @isnumeric);
            addParameter(parseObj, 'HGrid', 1, @isnumeric);
            addParameter(parseObj, 'VGap', [0, 0, 0], @isgap);
            addParameter(parseObj, 'HGap', [0, 0, 0], @isgap);
            parse(parseObj, varargin{:});
            
            % parse main properties
            obj.parent = parseObj.Results.Parent;
            obj.verGrid_Count = parseObj.Results.VGrid;
            obj.horGrid_Count = parseObj.Results.HGrid;
            
            % parse gap properties
            obj.setGridGap(parseObj.Results.VGap, 'vertical');
            obj.setGridGap(parseObj.Results.HGap, 'horizontal');
            
            % calculate grid size
            obj.setGridSize();
            
            % calulate grid position
            obj.setGridPosition();
            
        end
        
        % method :: getGrid
        %  input :: class object, varargin
        % action :: calculate grid coordinates
        function grid = getGrid(obj, varargin)
            
            % use parser
            parseObj = inputParser;
            addParameter(parseObj, 'VIndex', 1, @(x) validateattributes(x,{'double'},{'vector'}));
            addParameter(parseObj, 'HIndex', 1, @(x) validateattributes(x,{'double'},{'vector'}));
            parse(parseObj, varargin{:});
            
            % set each grid index
            gridVIndex = parseObj.Results.VIndex;
            if isempty(gridVIndex) || (max(gridVIndex) > obj.verGrid_Count)
                error('uiGridLayout:gridVIndex','grid index outside gird.');
            end
            
            gridHIndex = parseObj.Results.HIndex;
            if isempty(gridHIndex) || (max(gridHIndex) > obj.horGrid_Count)
                error('uiGridLayout:gridHIndex','grid index outside gird.');
            end
            
            % calculate temp grid
            grid(1) = obj.horGrid_Pos(gridHIndex(1));
            grid(2) = obj.verGrid_Pos(gridVIndex(end));
            grid(3) = length(gridHIndex) * obj.horGrid_Size + (length(gridHIndex) - 1) * obj.horGrid_GapCenter;
            grid(4) = length(gridVIndex) * obj.verGrid_Size + (length(gridVIndex) - 1) * obj.verGrid_GapMiddle;
            
        end
        
        % method :: align
        %  input :: class object, handle, varargin
        % action :: align handle to grid
        function obj = align(obj, handle, varargin)
            
            % use parser
            parseObj = inputParser;
            addParameter(parseObj, 'VIndex', 1, @(x) validateattributes(x,{'double'},{'vector'}));
            addParameter(parseObj, 'HIndex', 1, @(x) validateattributes(x,{'double'},{'vector'}));
            addParameter(parseObj, 'Anchor', 'center', @isanchor);
            parse(parseObj, varargin{:});
            
            % set vars
            VIndex = parseObj.Results.VIndex;
            HIndex = parseObj.Results.HIndex;
            anchor = parseObj.Results.Anchor;
            
            % check if handle's parent is the uiGridLayout parent
            if get(handle, 'Parent') ~= obj.parent
                error('uiGridLayout:HandleMismatch','given handle has different parent.');
            end
            
            % get constraints
            if isgraphics(handle, 'uicontrol') && strcmp(get(handle,'style'),'text')
                position = get(handle, 'Extent');
            else
                position = get(handle, 'Position');
            end
            VMax = position(4);
            HMax = position(3);
            
            % get current grid
            tempgrid = obj.getGrid('VIndex',VIndex, 'HIndex', HIndex);
            
            % update size
            if VMax < tempgrid(4)
                grid(4) = VMax;
            else
                grid(4) = tempgrid(4);
            end
            
            if HMax < tempgrid(3)
                grid(3) = HMax;
            else
                grid(3) = tempgrid(3);
            end
            
            % update position
            % set final grid position
            switch lower(anchor)
    
                case 'center'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3))/2;
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4))/2;
        
                case 'north'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3))/2;
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4));
        
                case 'south'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3))/2;
                    grid(2) = tempgrid(2);
        
                case 'west'
        
                    grid(1) = tempgrid(1);
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4))/2;
        
                case 'east'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3));
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4))/2;
        
                case 'northwest'
        
                    grid(1) = tempgrid(1);
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4));
        
                case 'northeast'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3));
                    grid(2) = tempgrid(2) + (tempgrid(4) - grid(4));
        
                case 'southwest'
        
                    grid(1) = tempgrid(1);
                    grid(2) = tempgrid(2);
        
                case 'southeast'
        
                    grid(1) = tempgrid(1) + (tempgrid(3) - grid(3));
                    grid(2) = tempgrid(2);
        
            end
            
            % update handle position
            set(handle, 'Position', grid);
            
        end
        
        % method :: setGridPosition
        %  input :: class object
        % action :: calculate grid position
        function obj = setGridPosition(obj)
            
            % calculate grid position
            obj.verGrid_Pos = flipud(cumsum(...
                              [obj.verGrid_GapBottom;...
                               repmat(obj.verGrid_Size + obj.verGrid_GapMiddle,...
                                      obj.verGrid_Count - 1, 1)]));
            obj.horGrid_Pos = cumsum(...
                              [obj.horGrid_GapLeft;...
                               repmat(obj.horGrid_Size + obj.horGrid_GapCenter,...
                                      obj.horGrid_Count -1, 1)]);
            
        end
        
        % method :: setGridSize
        %  input :: class object
        % action :: calculate grid size
        function obj = setGridSize(obj)
            
            % get parent position
            position = get(obj.parent, 'Position');
    
            % calculate grid size
            obj.verGrid_Size = (position(4) - ...
                               obj.verGrid_GapTop - ...
                               obj.verGrid_GapMiddle * (obj.verGrid_Count - 1) - ...
                               obj.verGrid_GapBottom) / obj.verGrid_Count;
                           
            
            obj.horGrid_Size = (position(3) - ...
                               obj.horGrid_GapLeft - ...
                               obj.horGrid_GapCenter * (obj.horGrid_Count - 1) - ...
                               obj.horGrid_GapRight) / obj.horGrid_Count;               
            
        end
        
        
        % method :: setGridGap
        %  input :: class object, gap, direction
        % action :: assign gap based on provided values and direction
        function obj = setGridGap(obj, gap, direction)
            
            % distribute gaps based on 
            % provided values
            switch length(gap)
                case 1
                    
                    maxGap = gap;
                    medGap = gap;
                    minGap = gap;
                    
                case 2
                    
                    maxGap = gap(1);
                    medGap = gap(2);
                    minGap = gap(1);
                    
                case 3
                    
                    maxGap = gap(1);
                    medGap = gap(2);
                    minGap = gap(3);
                    
            end
            
            % assign based on direction
            if strcmpi('vertical', direction)
                
                obj.verGrid_GapTop = maxGap;
                obj.verGrid_GapMiddle = medGap;
                obj.verGrid_GapBottom = minGap;
                
            elseif strcmpi('horizontal', direction)
                
                obj.horGrid_GapLeft = maxGap;
                obj.horGrid_GapCenter = medGap;
                obj.horGrid_GapRight = minGap;
                
            end
            
        end
    end
    
end

%%% --- parser functions --- %%%
function tf = isanchor(varchar)

    % default output
    tf = true;
    
    % check class
    if ~ischar(varchar)
        tf = false;
    end
    
    % check if in list
    reflist = {'center',...
               'north',...
               'south',...
               'west',...
               'east',...
               'northwest',...
               'northeast',...
               'southwest',...
               'souteast'};
    
    if ~any(strcmpi(varchar, reflist))
        tf = false;
    end
                              

end


function tf = isgap(varvalue)

    % default output
    tf = true;
    
    % check class
    if ~isa(varvalue, 'double')
        tf = false;
    end
    
    % check dimension
    if isempty(varvalue) || (length(varvalue) > 3)
        tf = false;
    end

    % check for full number
    if any(rem(varvalue,1))
        tf = false;
    end
    
end
