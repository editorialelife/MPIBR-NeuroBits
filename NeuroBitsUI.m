classdef NeuroBitsUI < handle
    
    properties (Access = public, Hidden = true)
        
        ui_parent
        ui_layout
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        UIWINDOW_SIZE = [1, 1, 280, 600];
        
    end
    
    methods
        
        function obj = NeuroBitsUI()
            
            obj.renderUI();
            
        end
        
        function obj = renderUI(obj)
            
            obj.ui_parent = figure(...
                'Visible', 'on',...
                'Tag', 'hNeuroBitsUI',...
                'Name', 'NeuroBits',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'Position', obj.UIWINDOW_SIZE,...
                'NumberTitle', 'off');
            movegui(obj.ui_parent, 'northwest');
            
            obj.ui_layout = uiextras.VBoxFlex('Parent', obj.ui_parent, 'Spacing', 5, 'Padding', 5);
            
        end
        
    end
    
    
end