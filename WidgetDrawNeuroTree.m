classdef WidgetDrawNeuroTree < handle
    % draws a neuro tree
    
    properties
        image
        mask
        tree
    end
    
    properties (Hidden)
        filePath
        fileName
        fileExt
        
        state
        
        idxROI
        idxClick
    end
    
    properties % (Access = protected)
        ui_imageFigure
        ui_imageAxis
        ui_imageHandle
        ui_parent
    end
    
    properties (Constant, Hidden)
        STATE_EMPTY = 0;
        STATE_IDLE = 1;
        STATE_OVER_CLICK = 2;
        STATE_OVER_ROI = 3;
        STATE_DRAWING_ROI = 4;
        STATE_MOVE_CLICK = 5;
        STATE_MOVE_ROI = 6;
    end
    
    methods
        function obj = WidgetDrawNeuroTree(varargin)
            
            p = inputParser;
            addRequired(p, 'FileName', [], @isFileName);
            addParameter(p, 'Parent', [], @isgraphics);
            addParameter(p, 'Figure', [], @isgraphics);
            addParameter(p, 'Image', [], @isImageMatrix);
            
            parse(p, varargin{:});
            
            % assign fileName
            [fPath, fName, fExt] = fileparts(p.Results.fileName);
            if ~any(strcmp(fExt,{'.tif','.lsm'}))
                error('WidgetDrawNeuroTree:required input file to be TIFF or LSM');
            end
            obj.filePath = fPath;
            obj.fileName = fName;
            obj.fileExt = fExt;
            
            
            
            
            
            
            if isempty(p.Results.Parent)
                obj.ui_parent = figure;
            else
                obj.ui_parent = p.Results.Parent;
            end
            
            %obj.fileName = p.Results.fileName;
            %obj.image = p.Results.img;
            
            
        end
    end
    
end


%%% --- validate image matrix --- %%%
function value = isFileName(filename)

    % default return
    value = true;
    
    % check for char class
    if ~ischar(filename)
        value = false;
    end
    
    % check for valid file
    if ~(exist(filename, 'file') == 2)
        value = false;
    end
    
end


function value = isImageMatrix(mtx)

    % default return
    value = true;
    
    % check image class
    if ~(isa(mtx, 'uint8') || isa(mtx, 'uint16') || isa(mtx, 'double'))
        value = false;
    end
    
    % check if 2D image matrix
    [h, w, z] = size(mtx);
    if ~((h > 1) && (w > 1) && (z == 1))
        value = false;
    end
    
end
