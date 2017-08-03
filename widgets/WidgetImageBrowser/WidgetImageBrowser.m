classdef WidgetImageBrowser < handle
    
    properties
        
        ui
        viewer
        model
        
    end
    
    methods
        
        function obj = WidgetImageBrowser()
            
            %obj.ui = WidgetImageBrowserUI([]);
            %obj.model = WidgetImageBrowserModel();
            obj.viewer = WidgetImageBrowserViewer();
            
        end
        
    end
    
end