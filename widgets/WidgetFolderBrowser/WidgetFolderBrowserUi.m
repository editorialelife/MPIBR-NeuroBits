classdef WidgetFolderBrowserUi < handle
%
% requires:
%   GUI Layout Toolbox
%   https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox
%
% Georgi Tushev
% sciclist@brain.mpg.de
% Max-Planck Institute For Brain Research
%
    
    properties
        
        parent
        panel
        layout
        
        buttonGroup_Load
        pushButton_LoadFile
        pushButton_LoadFolder
        
        buttonGroup_Navigate
        pushButton_PrevFile
        pushButton_NextFile
        
        text_FileName
        text_FileCounter
        
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
        
        function obj = WidgetFolderBrowserUi(varhandle)
            
            
            
            % render parent
            if isempty(varhandle)
                
                obj.parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hWidgetFolderBrowser',...
                    'Name', 'FolderBrowser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Position', obj.UIWINDOW_SIZE);
                movegui(obj.parent, 'northwest');
                    
            elseif isgraphics(varhandle)
                
                obj.parent = parserObj.Results.Parent;
                
            else
                
                error('uirender::invalid input variable for file constructor');
                
            end
            
            % render user interface
            obj.render();
            
        end
        
        function obj = render(obj)
            
            %%% --- create widget panel --- %%%
            obj.panel = uix.Panel(...
                'Parent', obj.parent,...
                'Padding', obj.UIGRID_PADDING,...
                'Title', 'FolderBrowser');
            
            obj.layout = uix.VBoxFlex(...
                'Parent', obj.panel,...
                'Padding', obj.UIGRID_PADDING);
            
            obj.text_FileName = uicontrol(...
                'Parent', obj.layout,...
                'Style', 'text',...
                'FontSize', obj.UIFONT_SIZE,...
                'String', 'load file or folder');
                
            obj.text_FileCounter = uicontrol(...
                'Parent', obj.layout,...
                'Style', 'text',...
                'FontSize', obj.UIFONT_SIZE,...
                'String', '0 / 0');
            
            obj.buttonGroup_Load = uix.HButtonBox(...
                'Parent', obj.layout,...
                'Padding', obj.UIGRID_PADDING,...
                'Spacing', obj.UIGRID_SPACING,...
                'ButtonSize', obj.UIBUTTON_SIZE);
            
            obj.pushButton_LoadFile = uicontrol(...
                'Parent', obj.buttonGroup_Load,...
                'Style', 'pushbutton',...
                'String', 'Load file',...
                'Enable', 'on',...
                'Callback', @obj.onClick_pushButton_LoadFile);
            
            obj.pushButton_LoadFolder = uicontrol(...
                'Parent', obj.buttonGroup_Load,...
                'Style', 'pushbutton',...
                'String', 'Load folder',...
                'Enable', 'on',...
                'Callback', @obj.onClick_pushButton_LoadFolder);
            
            obj.buttonGroup_Navigate = uix.HButtonBox(...
                'Parent', obj.layout,...
                'Padding', obj.UIGRID_PADDING,...
                'Spacing', obj.UIGRID_SPACING,...
                'ButtonSize', obj.UIBUTTON_SIZE);
            
            obj.pushButton_PrevFile = uicontrol(...
                'Parent', obj.buttonGroup_Navigate,...
                'Style', 'pushbutton',...
                'String', 'Previous',...
                'Enable', 'off',...
                'Callback', @obj.onClick_pushButton_PrevFile);
            
            obj.pushButton_NextFile = uicontrol(...
                'Parent', obj.buttonGroup_Navigate,...
                'Style', 'pushbutton',...
                'String', 'Next',...
                'Enable', 'off',...
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
