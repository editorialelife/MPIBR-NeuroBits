classdef WidgetDrawNeuroTree < handle
    % draws a neuro tree
    
    properties
        image
        mask
        tree
    end
    
    properties (Hidden)
        fileName
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
            addParameter(p, 'Parent', [], @isgraphics);
            addParameter(p, 'ImageHandle', [], @isgraphics);
            addParameter(p, 'ImageMatrix', [], @isImageMatrix);
            addParameter(p, 'FileName', [], @ischar);
            
            parse(p, varargin{:});
            
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
function value = isImageMatrix(mtx)

    % default return;
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
