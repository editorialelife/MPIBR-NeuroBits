classdef uirender < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        
        ui_parent
        ui_panel
        ui_layout
        
        ui_buttonGroup_Load
        ui_pushButton_LoadFile
        ui_pushButton_LoadFolder
        
        ui_buttonGroup_Navigate
        ui_pushButton_PrevFile
        ui_pushButton_NextFile
        
        ui_text_FileName
        ui_text_FileCounter
        
    end
    
    events (NotifyAccess = protected)
        
        event_fileLoad
        event_fileNext
        event_filePrevious
        event_folderLoad
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        UIWINDOW_SIZE = [1, 1, 256, 256];
        UIGRID_PADDING = 5;
        UIGRID_SPACING = 5;
        UIBUTTON_SIZE = [90, 26];
        UIFONT_SIZE = 10;
        
    end
    
    methods
        
        function obj = uirender(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isparent);
            parse(parserObj, varargin{:});
            
            % render parent
            if isempty(parserObj.Results.Parent)
                
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetFolderBrowser',...
                    'Name', 'FolderBrowser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UIWINDOW_SIZE);
                movegui(obj.ui_parent, 'northwest');
                    
            else
                
                obj.ui_parent = parserObj.Results.Parent;
                
            end
            
            % render user interface
            obj.render();
            
        end
        
        function obj = render(obj)
            
            %%% --- create widget panel --- %%%
            obj.ui_panel = uiextras.Panel(...
                'Parent', obj.ui_parent,...
                'Padding', obj.UIGRID_PADDING,...
                'Title', 'FolderBrowser');
            
            obj.ui_layout = uiextras.VBoxFlex(...
                'Parent', obj.ui_panel,...
                'Padding', obj.UIGRID_PADDING);
            
            obj.ui_text_FileName = uicontrol(...
                'Parent', obj.ui_layout,...
                'Style', 'text',...
                'FontSize', obj.UIFONT_SIZE,...
                'String', 'load file or folder');
                
            obj.ui_text_FileCounter = uicontrol(...
                'Parent', obj.ui_layout,...
                'Style', 'text',...
                'FontSize', obj.UIFONT_SIZE,...
                'String', '0 / 0');
            
            obj.ui_buttonGroup_Load = uiextras.HButtonBox(...
                'Parent', obj.ui_layout,...
                'Padding', obj.UIGRID_PADDING,...
                'Spacing', obj.UIGRID_SPACING,...
                'ButtonSize', obj.UIBUTTON_SIZE);
            
            obj.ui_pushButton_LoadFile = uicontrol(...
                'Parent', obj.ui_buttonGroup_Load,...
                'Style', 'pushbutton',...
                'String', 'Load file',...
                'Enable', 'on',...
                'Callback', @obj.onClick_pushButton_LoadFile);
            
            obj.ui_pushButton_LoadFolder = uicontrol(...
                'Parent', obj.ui_buttonGroup_Load,...
                'Style', 'pushbutton',...
                'String', 'Load folder',...
                'Enable', 'on',...
                'Callback', @obj.onClick_pushButton_LoadFolder);
            
            obj.ui_buttonGroup_Navigate = uiextras.HButtonBox(...
                'Parent', obj.ui_layout,...
                'Padding', obj.UIGRID_PADDING,...
                'Spacing', obj.UIGRID_SPACING,...
                'ButtonSize', obj.UIBUTTON_SIZE);
            
            obj.ui_pushButton_PrevFile = uicontrol(...
                'Parent', obj.ui_buttonGroup_Navigate,...
                'Style', 'pushbutton',...
                'String', 'Previous',...
                'Enable', 'on',...
                'Callback', @obj.onClick_pushButton_PrevFile);
            
            obj.ui_pushButton_NextFile = uicontrol(...
                'Parent', obj.ui_buttonGroup_Navigate,...
                'Style', 'pushbutton',...
                'String', 'Next',...
                'Enable', 'on',...
                'Callback',@obj.onClick_pushButton_NextFile);
            
        end
        
        function obj = onClick_pushButton_LoadFile(obj, ~, ~)
            
            notify(obj, 'event_fileLoad');
            
        end
        
        function obj = onClick_pushButton_LoadFolder(obj, ~, ~)
            
            notify(obj, 'event_folderLoad');
            
        end
        
        
        function obj = onClick_pushButton_PrevFile(obj, ~, ~)
            
            notify(obj, 'event_filePrevious');
            
        end
        
        
        function obj = onClick_pushButton_NextFile(obj, ~, ~)
            
            notify(obj, 'event_fileNext');
            
        end
        
        
    end
    
end

function tf = isparent(varin)
    tf = false;
    if isempty(varin)
        tf = true;
    elseif isgraphics(varin)
        tf = true;
    end
end