classdef WidgetNeuroTreeModel < handle
    
    properties (Access = private)
        
        filePath
        fileName
        
        dilation
        nhood
        mask
        path
        tree
     
    end
    
    properties (SetObservable = true)
        
        mousePointer
        
    end
    
    methods
        
        function obj = WidgetNeuroTreeModel()
        end
        
        function obj = create(obj, click, digit)
            
            % constructor for branch
            disp('WidgetNeuroTree :: create');
            
        end
        
        function obj = extend(obj, click)
            
            disp('WidgetNeuroTree :: extend');
            
        end
        
        function obj = stretch(obj, click)
            
            disp('WidgetNeuroTree :: stretch');
            
        end
        
        function obj = complete(obj, click)
            
            disp('WidgetNeuroTree :: complete');
            
        end
        
        function obj = pickup(obj, handle, click)
            
            disp('WidgetNeuroTree :: pickup');
            
        end
        
        function obj = putdown(obj, handle, click)
            
            disp('WidgetNeuroTree :: putdown');
            
        end
        
        function obj = select(obj, handle)
            
            disp('WidgetNeuroTree :: select');
            
        end
        
        function obj = deselect(obj, handle)
            
            disp('WidgetNeuroTree :: deselect');
            
        end
        
        function obj = reposition(obj, click)
            
            disp('WidgetNeuroTree :: reposition');
            
        end
        
        function obj = remove(obj, handle)
            
            disp('WidgetNeuroTree :: remove');
            
        end
        
        function obj = erase(obj, handle)
            
            disp('WidgetNeuroTree :: erase');
            
        end
        
        function obj = hover(obj, handle)
            
            disp('WidgetNeuroTree :: hover');
            
        end
        
    end
    
end