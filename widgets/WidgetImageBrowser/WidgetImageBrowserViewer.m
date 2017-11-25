classdef WidgetImageBrowserViewer < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        
        parent
        vaxes
        vimage
        
    end
    
    
    properties (Access = private)
        
        layout
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        UI_GRID_PADDING = 5;
        
    end
    
    methods
        
        function obj = WidgetImageBrowserViewer()
            
            % calculate screen size
            screenSize = get(0, 'ScreenSize');
            screenSize = floor(0.8 * min(screenSize(3:4)));
            
            obj.parent = figure(...
                'Visible', 'on',...
                'Tag', 'hImageBrowserWidgetViewer',...
                'Name', '',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'NumberTitle', 'off',...
                'Position', [1, 1,...
                             screenSize + obj.UI_GRID_PADDING,...
                             screenSize + obj.UI_GRID_PADDING]);
            movegui(obj.parent, 'north');
            
            obj.layout = uiextras.HBoxFlex(...
                'Parent', obj.parent,...
                'Padding', obj.UI_GRID_PADDING);
            
            
            obj.vaxes = axes(...
                'Parent', obj.layout,...
                'ActivePositionProperty', 'position',...
                'XTick', [],...
                'YTick', [],...
                'XColor', 'none',...
                'YColor', 'none');
            
            obj.vimage = imshow(...
                zeros(screenSize, screenSize, 'uint8'),...
                [],...
                'Parent', obj.vaxes,...
                'XData', [0, 1],...
                'YData', [0, 1]);
            
            
        end
        
        
        
        
        function obj = updateCLimit(obj, varclim)
            
            if all(varclim < 0)
                
                varclim = [min(obj.vimage.CData(:)),...
                           max(obj.vimage.CData(:))];
            end
            
            obj.vaxes.CLim = varclim;
            
        end
        
        function obj = updatePreview(obj, img)
            
            obj.vimage.CData = img;
            
            set(obj.vimage,...
                'XData', [1, size(img, 2)],...
                'YData', [1, size(img, 1)]);
            
            set(obj.vaxes,...
                'XLim', [1, size(img,2)],...
                'YLim', [1, size(img,1)]);
            
                           
            
        end
        
    end
    
end

