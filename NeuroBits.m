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
        
        GUI_WINDOW_POSITION = [1, 1, 250, 650];
        BORDER_GAP = [5, 5];
        
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        FONT_SIZE = 8;
   
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
            
            
            % initialize listeners
            addlistener(obj.widget_FolderBrowser, 'event_fileUpdated', @obj.fcnCallback_FileUpdate);
            %{
            addlistener(obj.widget_ImageBrowser, 'event_ImageBrowser_Show', @obj.fcnCallback_ImageShow);
            addlistener(obj.widget_ImageBrowser, 'event_ImageBrowser_Hide', @obj.fcnCallback_ImageHide);
            %addlistener(obj.widget_NeuroTree, 'event_segmentTree', @obj.fcnCallback_SegmentTree);
            addlistener(obj.widget_NeuroPuncta, 'event_NeuroPuncta_Segment', @obj.fcnCallback_SegmentPuncta);
            %}
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
            
            %%% --- Folder Browser --- %%%
            obj.ui_panel_FolderBrowser = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Folder Browser',...
                'TitlePosition', 'lefttop',...
                'FontSize', obj.FONT_SIZE,...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', uiGridLayout('Parent', obj.ui_parent,...
                                         'Grid', [5,1],...
                                         'Gap', obj.BORDER_GAP,...
                                         'HorizontalSpan', 1,...
                                         'VerticalSpan', 1));
            
            
            %%% --- Image Browser --- %%%
            obj.ui_panel_ImageBrowser = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Image Browser',...
                'TitlePosition', 'lefttop',...
                'FontSize', obj.FONT_SIZE,...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', uiGridLayout('Parent', obj.ui_parent,...
                                         'Grid', [5,1],...
                                         'Gap', obj.BORDER_GAP,...
                                         'HorizontalSpan', 1,...
                                         'VerticalSpan', 2));
            
            
            %%% --- DrawTree --- %%%
            %{
            hPan_NeuroTree = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Neuro Tree',...
                'TitlePosition', 'lefttop',...
                'FontSize', obj.FONT_SIZE,...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'normalized',...
                'Position', uiGridLayout([5, 1],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         3, 1));
            obj.widget_NeuroTree = WidgetNeuroTree('Parent', hPan_NeuroTree);
            %}
            %{
            %%% --- Find Puncta --- %%%
            hPan_NeuroPuncta = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Neuro Puncta',...
                'TitlePosition', 'lefttop',...
                'FontSize', obj.FONT_SIZE,...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'normalized',...
                'Position', uiGridLayout([5, 1],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         4, 1));
            obj.widget_NeuroPuncta = WidgetNeuroPuncta('Parent', hPan_NeuroPuncta);                         
            %}
            
            %%% --- Batch Processing --- %%%
            %{
            hPan_Batch = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Batch Job',...
                'TitlePosition', 'lefttop',...
                'FontSize', obj.FONT_SIZE,...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'normalized',...
                'Position', uiGridLayout([5, 1],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         5, 1));
          %}                           
            
        end
        
        % method :: renderWidgets
        %  input :: class object
        % action :: initializes widget object
        function obj = renderWidgets(obj)
            
            % start FolderBrowser
            obj.widget_FolderBrowser = WidgetFolderBrowser(...
                'Parent', obj.ui_panel_FolderBrowser,...
                'Extension', '*.lsm');
            
            % start ImageBrowser
            obj.widget_ImageBrowser = WidgetImageBrowser(...
                'Parent', obj.ui_panel_ImageBrowser);
            
            
        end
        
        
        
        % method :: initWidgetNeuroTree
        %  input :: class object
        % action :: initialize neuro tree
        function obj = initWidgetNeuroTree(obj)
            
            % pass current file name to WidgetNeuroTree
            [filePath, fileName] = fileparts(obj.file);
            obj.widget_NeuroTree.path = filePath;
            obj.widget_NeuroTree.name = fileName;
            
            % pass current image figure handles to WidgetNeuroTree
            obj.widget_NeuroTree.ih_figure = obj.widget_ImageBrowser.ih_figure;
            obj.widget_NeuroTree.ih_axes = obj.widget_ImageBrowser.ih_axes;
            obj.widget_NeuroTree.ih_image = obj.widget_ImageBrowser.ih_image;
            
            % unlock NeuroTree user interface
            obj.widget_NeuroTree.unlockUI();
            
        end
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close request
        %   action :: class detructor
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            if isa(obj.widget_FolderBrowser, 'WidgetFolderBrowser')
                delete(obj.widget_FolderBrowser);
            end
            
            %if isgraphics(obj.widget_ImageBrowser.ih_figure, 'Figure')
            %    delete(obj.widget_ImageBrowser.ih_figure);
            %end
            
            if isgraphics(obj.ui_parent, 'Figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
        end
        
        % callback :: FileUpdate
        %    event :: on FileUpdated event from FileBrowser widget
        %   action :: load image in ImageBrowser widget
        function obj = fcnCallback_FileUpdate(obj, ~, ~)
            
            % evoke load method in WidgetImageBrowser
            obj.file = obj.widget_FolderBrowser.list{obj.widget_FolderBrowser.index};
            obj.widget_ImageBrowser.updateFileName(obj.file);
            
        end
        
        % callback :: ImageShow
        %    event :: on ImageShow event from ImageBrowser widget
        %   action :: unlocks GUI for dependant widgets
        function obj = fcnCallback_ImageShow(obj, ~, ~)
            
            %obj.widget_NeuroTree.unlockUI();
            obj.widget_NeuroPuncta.unlockUI();
            
        end
        
        % callback :: ImageHide
        %    event :: on ImageHide event from ImageBrowser widget
        %   action :: locks GUI for dependant widgets
        function obj = fcnCallback_ImageHide(obj, ~, ~)
            
            %obj.widget_NeuroTree.lockUI();
            obj.widget_NeuroPuncta.lockUI();
            
        end
        
        % callback :: SegmentTree
        %    event :: on SegmentTree event from NeuroTree widget
        %   action :: initialize NeuroTree input image
        function obj = fcnCallback_SegmentTree(obj, ~, ~)
        end
        
        % callback :: SegmentPuncta
        %    event :: on SegmentPuncta event from NeuroPuncta widget
        %   action :: initialize NeuroPuncta input image
        function obj = fcnCallback_SegmentPuncta(obj, ~, ~)
            
            obj.widget_NeuroPuncta.startSegmentation(obj.file,...
                                                     obj.widget_ImageBrowser.image);
            
        end
        
    end
    
end