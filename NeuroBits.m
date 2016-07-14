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
        
        ui_panel_FolderBrowser
        ui_panel_ImageBrowser
        ui_panel_NeuroTree
        ui_panel_NeuroPuncta
        ui_panel_BatchJob
        
        %%% --- Widget Objects --- %%%
        widget_FolderBrowser
        widget_ImageBrowser
        widget_NeuroTree
        widget_NeuroPuncta
        widget_BatchJob
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        GUI_WINDOW_POSITION = [1, 1, 260, 680];
        VERTICAL_GAP = [5, 5, 5];
        HORIZONTAL_GAP = [5, 5, 5];
        BACKGROUND_COLOR = [1, 1, 1];
        
    end
    
    methods
        
        % method :: NeuroBits
        %  input :: class object
        % action :: class constructor
        function obj = NeuroBits()
            
            % render widget panels
            obj.renderUI();
            
            % initialize widget objects
            obj.renderWidgets();
            
            
        end
        
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            
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
                'Position', obj.GUI_WINDOW_POSITION,...
                'CloseRequestFcn', @obj.fcnCallback_CloseUIWindow);
            movegui(obj.ui_parent, 'northwest');
            
            %%% --- Create Grid --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_parent,...
                'VGrid', 5,...
                'HGrid', 1,...
                'VGap', obj.VERTICAL_GAP,...
                'HGap', obj.HORIZONTAL_GAP);
            
            %%% --- Folder Browser --- %%%
            obj.ui_panel_FolderBrowser = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 1, 'HIndex', 1));
                                         
            %%% --- Image Browser --- %%%
            obj.ui_panel_ImageBrowser = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 2, 'HIndex', 1));
            
            %%% --- DrawTree --- %%%
            obj.ui_panel_NeuroTree = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 3, 'HIndex', 1));
            
            %%% --- Find Puncta --- %%%
            obj.ui_panel_NeuroPuncta = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 4, 'HIndex', 1));
            
            
            %%% --- Batch Processing --- %%%
            obj.ui_panel_BatchJob = uipanel(...
                'Parent', obj.ui_parent,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'BorderType', 'none',...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 5, 'HIndex', 1));
            
        end
        
        % method :: renderWidgets
        %  input :: class object
        % action :: initializes widget object
        function obj = renderWidgets(obj)
            
            % start FolderBrowser
            obj.widget_FolderBrowser = WidgetFolderBrowser(...
                'Parent', obj.ui_panel_FolderBrowser,...
                'Extension', '*.lsm');
            if isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                addlistener(obj.widget_FolderBrowser, 'event_fileUpdated', @obj.fcnCallback_FileUpdate);
            end
            
            % start ImageBrowser
            obj.widget_ImageBrowser = WidgetImageBrowser(...
                'Parent', obj.ui_panel_ImageBrowser);
            if isa(obj.widget_ImageBrowser, 'WidgetImageBrowser')
                addlistener(obj.widget_ImageBrowser, 'event_ImageBrowser_Show', @obj.fcnCallback_ImageShow);
                addlistener(obj.widget_ImageBrowser, 'event_ImageBrowser_Hide', @obj.fcnCallback_ImageHide);
            end
            
            
            % start NeuroTree
            obj.widget_NeuroTree = WidgetNeuroTree(...
                'Parent', obj.ui_panel_NeuroTree);
            if isa(obj.widget_NeuroTree, 'WidgetNeuroTree')
            	addlistener(obj.widget_NeuroTree, 'event_NeuroTree_GetImage', @obj.fcnCallback_SegmentTree);
            end
            
            
            % start NeuroPuncta
            obj.widget_NeuroPuncta = WidgetNeuroPuncta(...
                'Parent', obj.ui_panel_NeuroPuncta);
            if isa(obj.widget_NeuroPuncta, 'WidgetNeuroPuncta')
                addlistener(obj.widget_NeuroPuncta, 'event_NeuroPuncta_Segment', @obj.fcnCallback_SegmentPuncta);
            end
            
        end
        
        % method :: dispose
        %  input :: class object
        % action :: class destructor
        function obj = dispose(obj)
            
            % dispose WidgetFolderBrowser
            if isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                obj.widget_FolderBrowser.dispose();
            end
            
            % dispose WidgetImageBrowser
            if isa(obj.widget_ImageBrowser, 'WidgetImageBrowser')
                obj.widget_ImageBrowser.dispose();
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
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close request
        %   action :: class detructor
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
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