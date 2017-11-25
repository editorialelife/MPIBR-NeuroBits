classdef NeuroBits < handle
    
    properties (Access = public)
        
        widget_FolderBrowser
        widget_ImageBrowser
        widget_NeuroTree
        
    end
    
    properties (Access = private)
        
        ui_parent
        ui_layout
        
    end
    
    properties (Access = private, Constant = true)
        
        SCALE_HEIGHT = 0.9;
        SCALE_WIDTH = 0.2;
        PATH_WIDGETS = 'widgets';
        UI_GRID_PADDING = 5;
        UI_GRID_SPACING = 5;
        
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
                'NumberTitle', 'off',...
                'CloseRequestFcn', @obj.fcnCallback_closeRequest);
            movegui(obj.ui_parent, 'northwest');
            
            %% create layout
            obj.ui_layout = uix.VBox(...
                'Parent', obj.ui_parent,...
                'Spacing', obj.UI_GRID_SPACING);
            
            %% add widgets path
            addpath(genpath([pwd, filesep, obj.PATH_WIDGETS]));
            
            %% initialize FolderBrowser
            obj.widget_FolderBrowser = WidgetFolderBrowser('Parent', obj.ui_layout,...
                                                           'Extension', '*.lsm');
            if ~isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                error('NeruoBits :: failed to initialize WidgetFolderBrowser');
            end
            
            %% initialize ImageBrowser
            obj.widget_ImageBrowser = WidgetImageBrowser('Parent', obj.ui_layout);
            if ~isa(obj.widget_ImageBrowser, 'WidgetImageBrowser')
                error('NeruoBits :: failed to initialize WidgetImageBrowser');
            end
            
            %% initialize NeuroTree
            obj.widget_NeuroTree = WidgetNeuroTree('Parent', obj.ui_layout,...
                                                   'Viewer', obj.widget_ImageBrowser.viewer.parent);
            if ~isa(obj.widget_NeuroTree, 'WidgetNeuroTree')
                error('NeruoBits :: failed to initialize WidgetNeuroTree');
            end
            
            %% add controller
            addlistener(obj.widget_FolderBrowser, 'file', 'PostSet', @obj.fcnCallback_requestFile);
            addlistener(obj.widget_NeuroTree, 'event_treeExport', @obj.fcnCallback_requestTreeExport);
        end
        
        %% destructor
        function delete(obj)
            
            rmpath(genpath([pwd, filesep, obj.PATH_WIDGETS]));
            
        end
        
        %% request close
        function obj = fcnCallback_closeRequest(obj, ~, ~)
            
            if isgraphics(obj.ui_parent, 'figure')
                delete(obj.ui_parent);
            end
            
            obj.delete();
            
        end
        
        %% request file
        function obj = fcnCallback_requestFile(obj, ~, ~)
            
            obj.widget_ImageBrowser.read(obj.widget_FolderBrowser.file);
            
        end
        
        %% request tree export
        function obj = fcnCallback_requestTreeExport(obj, ~, ~)
            
            [filePath, fileName] = fileparts(obj.widget_FolderBrowser.file);
            obj.widget_NeuroTree.filePath = filePath;
            obj.widget_NeuroTree.fileName = fileName;
            
        end
        
    end
    
    
end