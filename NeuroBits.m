classdef NeuroBits < handle
    
    properties (Access = private)
        
        ui_parent
        
    end
    
    properties (Access = private, Constant = true)
        
        SCALE_HEIGHT = 0.9;
        SCALE_WIDTH = 0.2;
        PATH_WIDGETS = [pwd, filesep, 'widgets'];
        
    end
    
    methods
        
        %% constructor
        function obj = NeuroBits()
            
            %% detect screen resolution
            figureSize = get(0, 'ScreenSize');
            figureSize(3) = figureSize(3) * obj.SCALE_WIDTH;
            figureSize(4) = figureSize(4) * obj.SCALE_HEIGHT;
            
            %% create parent figure
            obj.ui_parent = figure(...
                'Visible', 'on',...
                'Tag', 'hNeuroBits',...
                'Name', 'NeuroBits',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'Position', figureSize,...
                'NumberTitle', 'off');
            movegui(obj.ui_parent, 'northwest');
            
            %% add widgets
            addpath(genpath(obj.PATH_WIDGETS));
            
            %% 
            
        end
        
        %% destructor
        function delete(obj)
            
            rmpath(genpath(obj.PATH_WIDGETS));
            
        end
        
    end
    
    
end