 classdef NeuroBits < handle
    %
    % NeuroBits
    %
    % widget based GUI for
    % user guided neuronal tree segmentation
    %
    % FolderBrowser
    % ImageBrowser
    % NeuroTree
    % NeuroPuncta
    % 
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties (Access = private, Hidden = true)
        file
        
        %%% --- UI Components --- %%%
        ui_parent
        ui_grid
        
        %%% --- Widget Objects --- %%%
        widget_FolderBrowser
        widget_ImageBrowser
        widget_NeuroTree
        widget_NeuroPuncta
        widget_BatchProcessing
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        UIWINDOW_SIZE = [1, 1, 266, 680];
        GRID_VGAP = [5, 5, 5];
        GRID_HGAP = [5, 5, 5];
        BACKGROUND_COLOR = [1, 1, 1];
        
    end
    
    %% --- class constructor / destructor --- %%
    methods
        
        function obj = NeuroBits()
            %NEUROBITS class constructor
            
            % render widget panels
            obj.renderWidgetInterface();
            
            % initialize widget objects
            obj.linkWidgets();
            
        end
        
        function obj = dispose(obj)
            %DISPOSE class destructor
            
            % dispose WidgetFolderBrowser
            if isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                obj.widget_FolderBrowser.dispose();
            end
            
            % dispose WidgetImageBrowser
            if isa(obj.widget_ImageBrowser, 'WidgetImageBrowser')
                obj.widget_ImageBrowser.dispose();
            end
            
            % dispose WidgetNeuroTree
            if isa(obj.widget_NeuroTree, 'WidgetNeuroTree')
                obj.widget_NeuroTree.dispose();
            end
            
            % dispose WidgetNeuroPuncta
            if isa(obj.widget_NeuroPuncta, 'WidgetNeuroPuncta')
                obj.widget_NeuroPuncta.dispose();
            end
            
            % dispose WidgetBatchProcessing
            if isa(obj.widget_BatchProcessing, 'WidgetBatchProcessing')
                obj.widget_BatchProcessing.dispose();
            end
            
            
            % remove grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % remove user interface
            if isgraphics(obj.ui_parent, 'Figure')
                delete(obj.ui_parent);
            end
            
            % delete object
            delete(obj);
            
        end
        
        function obj = renderWidgetInterface(obj)
            %RENDERWIDGETINTERFACE
            
            %%% --- Main Figure --- %%%
            obj.ui_parent = figure(...
                'Visible', 'on',...
                'Tag', 'hNeuroBits',...
                'Name', 'NeuroBits',...
                'MenuBar', 'none',...
                'ToolBar', 'none',...
                'NumberTitle', 'off',...
                'Color', obj.BACKGROUND_COLOR,...
                'Resize', 'off',...
                'Units', 'pixels',...
                'Position', obj.UIWINDOW_SIZE,...
                'CloseRequestFcn', @obj.fcnCallback_closeUserInterface);
            movegui(obj.ui_parent, 'northwest');
            
            %%% --- Create Grid --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_parent,...
                'VGrid', 5,...
                'HGrid', 1,...
                'VGap', obj.GRID_VGAP,...
                'HGap', obj.GRID_HGAP);
            
            %%% --- Folder Browser --- %%%
            ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 1, 'HIndex', 1));
            obj.widget_FolderBrowser = WidgetFolderBrowser(...
                                      'Parent', ui_panel,...
                                      'Extension', '*.lsm');
            
            %%% --- Image Browser --- %%%
            ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 2, 'HIndex', 1));
            obj.widget_ImageBrowser = WidgetImageBrowser('Parent', ui_panel);
            
            %%% --- DrawTree --- %%%
            ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 3, 'HIndex', 1));
            obj.widget_NeuroTree = WidgetNeuroTree('Parent', ui_panel);
                                   
            
            %%% --- Find Puncta --- %%%
            ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 1));
            obj.widget_NeuroPuncta = WidgetNeuroPuncta('Parent', ui_panel);
            
            
            %%% --- Batch Processing --- %%%
            ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 5, 'HIndex', 1));
            obj.widget_BatchProcessing = WidgetBatchProcessing('Parent', ui_panel);
            
        end
        
        function obj = linkWidgets(obj)
            %LINKWIDGETS
            
            % start FolderBrowser
            if isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                
                addlistener(obj.widget_FolderBrowser,...
                            'event_fileUpdated',...
                            @obj.fcnCallback_FileUpdate);
            end
            
            % start ImageBrowser
            if isa(obj.widget_ImageBrowser, 'WidgetImageBrowser')
                
                addlistener(obj.widget_ImageBrowser,...
                            'event_ImageBrowser_Show',...
                            @obj.fcnCallback_ImageShow);
                        
                addlistener(obj.widget_ImageBrowser,...
                            'event_ImageBrowser_Hide',...
                            @obj.fcnCallback_ImageHide);
                        
            end
            
            
            % start NeuroTree
            if isa(obj.widget_NeuroTree, 'WidgetNeuroTree')
                
            	addlistener(obj.widget_NeuroTree,...
                            'event_NeuroTree_GetImage',...
                            @obj.fcnCallback_SegmentTree);
                        
            end
            
            
            % start NeuroPuncta
            if isa(obj.widget_NeuroPuncta, 'WidgetNeuroPuncta')
                
                addlistener(obj.widget_NeuroPuncta,...
                            'event_NeuroPuncta_Segment',...
                            @obj.fcnCallback_SegmentPuncta);
                        
            end
            
        end
        
        
        
    end
    
    %% --- user interface callback --- %%
    methods
        
        function obj = fcnCallback_closeUserInterface(obj, ~, ~)
            %FCNCALLBACK_closeUserIntarface
            
            obj.dispose();
            
        end
        
        % callback :: FileUpdate
        %    event :: on FileUpdated event from FileBrowser widget
        %   action :: load image in ImageBrowser widget
        function obj = fcnCallback_FileUpdate(obj, ~, ~)
            
            disp('FILE_UPDATED');
            % evoke load method in WidgetImageBrowser
            obj.file = obj.widget_FolderBrowser.list{obj.widget_FolderBrowser.index};
            obj.widget_ImageBrowser.open(obj.file);
            
            
        end
        
        % callback :: ImageShow
        %    event :: on ImageShow event from ImageBrowser widget
        %   action :: unlocks GUI for dependant widgets
        function obj = fcnCallback_ImageShow(obj, ~, ~)
            
            disp('IMAGE_SHOW');
            obj.widget_NeuroTree.clear();
            obj.widget_NeuroTree.enable([], 'off');
            obj.widget_NeuroTree.enable(1:2, 'on');
            
        end
        
        % callback :: ImageHide
        %    event :: on ImageHide event from ImageBrowser widget
        %   action :: locks GUI for dependant widgets
        function obj = fcnCallback_ImageHide(obj, ~, ~)
            
            disp('IMAGE_HIDE');
            obj.widget_NeuroTree.clear();
            obj.widget_NeuroTree.enable([],'off');
            
        end
        
        % callback :: SegmentTree
        %    event :: on SegmentTree event from NeuroTree widget
        %   action :: initialize NeuroTree input image
        function obj = fcnCallback_SegmentTree(obj, ~, ~)
            
            disp('SEGMENT TREE');
            obj.widget_NeuroTree.start('FileName', obj.file,...
                                       'Figure', obj.widget_ImageBrowser.iw_figure,...
                                       'Axes', obj.widget_ImageBrowser.iw_axes,...
                                       'Image',obj.widget_ImageBrowser.iw_image);
        end
        
        % callback :: SegmentPuncta
        %    event :: on SegmentPuncta event from NeuroPuncta widget
        %   action :: initialize NeuroPuncta input image
        function obj = fcnCallback_SegmentPuncta(obj, ~, ~)
            
            %{
            obj.widget_NeuroPuncta.segment(...
                'FileName', obj.file,...
                'Figure', obj.widget_ImageBrowser.ih_figure,...
                'Axes', obj.widget_ImageBrowser.ih_axes,...
                'Image', obj.widget_ImageBrowser.ih_image);
            %}
            %obj.widget_NeuroPuncta.startSegmentation(obj.file,...
            %                                         obj.widget_ImageBrowser.image);
            
        end
        
    end
    
end