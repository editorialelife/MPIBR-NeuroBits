classdef WidgetNeuroTreeAction < handle
    
    properties (Access = private)
        
        filePath
        fileName
        
        dilation
        nhood
        mask
        path
        tree
        
        indexBranch
        indexNode
     
    end
    
    properties (SetObservable = true)
        
        mousePointer
        
    end
    
    methods
        
        function obj = WidgetNeuroTreeAction()
        end
        
        function obj = create(obj, objviewer)
            
            % constructor for branch
            disp('WidgetNeuroTree :: create');
            
            % update indexes
            obj.indexBranch = length(obj.tree) + 1;
            
            % add new branch
            obj.tree(obj.indexBranch) = WidgetNeuroTreeBranch(...
                                        'Axes', objviewer.handle_axes,...
                                        'Depth', str2double(objviewer.press_key),...
                                        'Index', obj.indexBranch);
            if ~isa(obj.tree(obj.indexBranch), 'WidgetNeuroTreeBranch')
                error('WidgetNeuroTree: initializing new Branch failed!');
            end
            
            
        end
        
        function obj = extend(obj, objviewer)
            
            % click
            disp('WidgetNeuroTree :: extend');
            
            % add node to branch
            obj.indexNode = obj.indexNode + 1;
            obj.tree(obj.indexBranch).addNode(obj.indexNode, objviewer.click_down);
            
        end
        
        function obj = stretch(obj, objviewer)
            
            %click
            disp('WidgetNeuroTree :: stretch');
            
            % strecth line
            obj.tree(obj.indexBranch).pullLine(objviewer.move_mouse);
            
        end
        
        function obj = complete(obj, objviewer)
            
            %click
            disp('WidgetNeuroTree :: complete');
            
            %obj.tree(obj.indexBranch).fix(obj.
            
        end
        
        function obj = pickup(obj, objviewer)
            
            %handle, click
            disp('WidgetNeuroTree :: pickup');
            
        end
        
        function obj = putdown(obj, objviewer)
            
            %handle click
            disp('WidgetNeuroTree :: putdown');
            
        end
        
        function obj = select(obj, objviewer)
            
            % handle
            disp('WidgetNeuroTree :: select');
            
        end
        
        function obj = deselect(obj, objviewer)
            
            % handle
            disp('WidgetNeuroTree :: deselect');
            
        end
        
        function obj = reposition(obj, objviewer)
            
            % click
            disp('WidgetNeuroTree :: reposition');
            
        end
        
        function obj = remove(obj, objviewer)
            
            % handle
            disp('WidgetNeuroTree :: remove');
            
        end
        
        function obj = undo(obj, objviewer)
            
            % handle
            disp('WidgetNeuroTree :: undo');
            
        end
        
        function obj = hover(obj, objviewer)
            
            % handle
            disp('WidgetNeuroTree :: hover');
            
        end
        
    end
    
end