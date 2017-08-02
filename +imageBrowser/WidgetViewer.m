classdef iwrender < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        parent
        imaxes
        
    end
    
    properties
        
        UI_WINDOW_SIZE = [1, 1, 512, 512];
        UI_GRID_PADDING = 5;
        
    end
    
    methods
        
        function obj = iwrender()
            
            obj.parent = figure(...
                'Visible', 'on',...
                'Tag', 'hWidgetImageBrowserIW',...
                'Name', '',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'NumberTitle', 'off',...
                'Position', obj.UI_WINDOW_SIZE);
            movegui(obj.parent, 'north');
            
            obj.render();
            
        end
        
        function obj = render(obj)
            
            layout = uiextras.HBoxFlex(...
                'Parent', obj.parent,...
                'Padding', obj.UI_GRID_PADDING);
            
            
            obj.imaxes = axes(...
                'Parent', layout,...
                'ActivePositionProperty', 'position',...
                'XTick', [],...
                'YTick', [],...
                'XColor', 'none',...
                'YColor', 'none');
            
            viewmenu = uimenu( obj.parent,...
                'Label', 'View');
            uimenu(viewmenu,...
                   'Label','Auto',...
                   'Checked', 'on');
       
        end
        
    end
    
end

