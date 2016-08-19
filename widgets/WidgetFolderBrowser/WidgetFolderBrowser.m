classdef WidgetFolderBrowser < handle
    %
    % WidgetFolderBrowser
    %
    % GUI Widget for browsing a folder
    % user loads a file or a folder
    % emits event on each updated file
    %
    % requires:
    %    uiGridLayout.m
    %
    % Friedrich Kretschmer
    % Georgi Tushev
    % sciclist@brain.mpg.de
    % Max-Planck Institute For Brain Research
    %
    
    properties
        folder
        file
        ext
        list
        index
    end
    
    properties (Access = protected)
        
        ui_parent
        ui_panel
        ui_grid
        
        ui_pushButton_LoadFile
        ui_pushButton_LoadFolder
        ui_pushButton_PrevFile
        ui_pushButton_NextFile
        ui_text_FileName
        ui_text_FileCounter
        
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        UIWINDOW_SIZE = [1, 1, 256, 130];
        GRID_VGAP = [15, 2, 5];
        GRID_HGAP = [5, 2, 5];
        BACKGROUND_COLOR = [1, 1, 1]; % WHITE COLOR
        FOREGROUND_COLOR = [0.5, 0.5, 0.5]; % GRAY COLOR
        PUSHBUTTON_SIZE = [1, 1, 90, 26];
        
    end
    
    events (NotifyAccess = protected)
        
        event_fileUpdated
        
    end
    
    methods
        
        % method :: WidgetFolderBrowser
        %  input :: varargin
        % action :: class constructor
        function obj = WidgetFolderBrowser(varargin)
            
            % use parser
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isgraphics);
            addParameter(parserObj, 'Extension', '*.*', @ischar);
            parse(parserObj, varargin{:});
            
            % set input properties
            if isempty(parserObj.Results.Parent)
                
                obj.ui_parent = figure(...
                    'Visible', 'on',...
                    'Tag', 'hFolderBrowser',...
                    'Name', 'FolderBrowser',...
                    'MenuBar', 'none',...
                    'ToolBar', 'none',...
                    'NumberTitle', 'off',...
                    'Color', obj.BACKGROUND_COLOR,...
                    'Resize', 'off',...
                    'Units', 'pixels',...
                    'Position', obj.UIWINDOW_SIZE,...
                    'CloseRequestFcn', @obj.fcnCallback_CloseUIWindow);
                movegui(obj.ui_parent, 'northwest');
                
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            obj.ext = parserObj.Results.Extension;
            
            % render user interface
            obj.renderUI();
            
        end
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            %%% --- create widget panel --- %%%
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'Title', 'Folder Browser',...
                'TitlePosition', 'lefttop',...
                'BorderType', 'line',...
                'HighlightColor', obj.FOREGROUND_COLOR,...
                'ForegroundColor', obj.FOREGROUND_COLOR,...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'normalized',...
                'Position', [0, 0, 1, 1],...
                'Units', 'pixels');
            
            %%% --- create grid object --- %%%
            obj.ui_grid = uiGridLayout(...
                'Parent', obj.ui_panel,...
                'VGrid', 4,...
                'HGrid', 2,...
                'VGap', obj.GRID_VGAP,...
                'HGap', obj.GRID_HGAP);
            
            %%% --- add UI elemnts --- %%%
            obj.ui_text_FileName = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'load file or folder',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 1, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_FileName,...
                'VIndex', 1,...
                'HIndex', 1:2,...
                'Anchor', 'center');
                                     
            obj.ui_text_FileCounter = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', '0 / 0',...
                'BackgroundColor', obj.BACKGROUND_COLOR,...
                'Units', 'pixels',...
                'Position', obj.ui_grid.getGrid('VIndex', 2, 'HIndex', 1:2));
            obj.ui_grid.align(obj.ui_text_FileCounter,...
                'VIndex', 2,...
                'HIndex', 1:2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_LoadFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load file',...
                'Enable', 'on',...
                'Callback', @obj.fcnCallback_LoadFile,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SIZE);
            obj.ui_grid.align(obj.ui_pushButton_LoadFile,...
                'VIndex', 3,...
                'HIndex', 1,...
                'Anchor', 'center');
                                    
            obj.ui_pushButton_LoadFolder = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load folder',...
                'Enable', 'on',...
                'Callback', @obj.fcnCallback_LoadFolder,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SIZE);
            obj.ui_grid.align(obj.ui_pushButton_LoadFolder,...
                'VIndex', 3,...
                'HIndex', 2,...
                'Anchor', 'center');
            
            obj.ui_pushButton_PrevFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Previous file',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_PrevFile,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SIZE);
            obj.ui_grid.align(obj.ui_pushButton_PrevFile,...
                'VIndex', 4,...
                'HIndex', 1,...
                'Anchor', 'center');
                                  
            obj.ui_pushButton_NextFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Next file',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_NextFile,...
                'Units', 'pixels',...
                'Position', obj.PUSHBUTTON_SIZE);
            obj.ui_grid.align(obj.ui_pushButton_NextFile,...
                'VIndex', 4,...
                'HIndex', 2,...
                'Anchor', 'center');
            
        end
        
        
        % method :: loadFile
        %  input :: class object, fileName, pathName
        % action :: loads file with given name and path
        function obj = loadFile(obj, fileName, pathName)
            
            % update properties
            obj.folder = pathName(1:end-1); % uigetfile retunrns pathName with filesep
            obj.file = [pathName,fileName];
            obj.list = {obj.file};
            obj.index = 1;
            
            % update message
            obj.updateStatus();
            
            % deactivate Next/Prev buttons
            set(obj.ui_pushButton_PrevFile, 'Enable', 'off');
            set(obj.ui_pushButton_NextFile, 'Enable', 'off');
            
            % evoke event
            notify(obj, 'event_fileUpdated');
            
        end
        
        
        % method :: loadFolder
        %  input :: class object, pathName
        % action :: loads file list with given extension
        function obj = loadFolder(obj, pathName)
            
            % read folder information
            folderInfo = dir([pathName, filesep, obj.ext]);
            
            % clean subdirectories
            folderInfo(cat(1,folderInfo.isdir)) = [];
            
            if isempty(folderInfo)
                warndlg(sprintf('No files with the extension: %s found!', obj.ext));
            else
                
                % update properties
                obj.folder = pathName;
                obj.list = cellfun(@(x) {[pathName, filesep, x]},{folderInfo.name}');
                obj.index = 1;
                
                
                % unlock Next/Prev buttons
                if size(obj.list, 1) > 1
                    set(obj.ui_pushButton_PrevFile, 'Enable', 'on');
                    set(obj.ui_pushButton_NextFile, 'Enable', 'on');
                end
                
                % update file
                obj.updateFile();
                
            end
            
        end
        
        
        % method :: updateFile
        %  input :: class object
        % action :: update current file name and index
        function obj = updateFile(obj)
            
            % current file from list
            obj.file = obj.list{obj.index};
            
            % update status
            obj.updateStatus();
            
            % evoke event
            notify(obj, 'event_fileUpdated');
            
        end
        
        % method :: updateStatus
        %  input :: class object
        % action :: updates status for current file name and index
        function obj = updateStatus(obj)
            
            % update status
            [~, fileTag] = fileparts(obj.file);
            
            set(obj.ui_text_FileName,...
                'String', fileTag);
            obj.ui_grid.align(obj.ui_text_FileName, 'VIndex', 1, 'HIndex', 1:2, 'Anchor', 'center');
            
            set(obj.ui_text_FileCounter,...
                'String', sprintf('%d / %d', obj.index, size(obj.list,1)));
            obj.ui_grid.align(obj.ui_text_FileCounter, 'VIndex', 2, 'HIndex', 1:2, 'Anchor', 'center');
            
        end
        
        % method :: dispose
        %  input :: class object
        % action :: class destructor
        function obj = dispose(obj)
            
            % remove grid
            if isa(obj.ui_grid, 'uiGridLayout')
                delete(obj.ui_grid);
            end
            
            % check if parent is figure or was inherit
            if isgraphics(obj.ui_parent, 'figure')
                delete(obj.ui_parent);
            end
            
            delete(obj);
        end
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
        % callback :: CloseUIWindow
        %    event :: on close UI window request
        %   action :: call class destructor method
        function obj = fcnCallback_CloseUIWindow(obj, ~, ~)
            
            obj.dispose();
            
        end
        
        
        % callback :: LoadFile
        %    event :: on Load File button click
        %   action :: loads single file
        function obj = fcnCallback_LoadFile(obj, ~, ~)
            [file_name, path_name] = uigetfile(obj.ext, 'Pick a file ...');
            if ischar(file_name)
                obj.loadFile(file_name, path_name);
            end
        end
        
        
        % callback :: LoadFolder
        %    event :: on Load Folder button click
        %   action :: loads file list from folder
        function obj = fcnCallback_LoadFolder(obj, ~, ~)
            path_name = uigetdir(pwd, 'Pick a dirctory ...');
            if ischar(path_name)
                obj.loadFolder(path_name);
            end
        end
        
        
        % callback :: PrevFile
        %    event :: on Prev File button click
        %   action :: decrement file index
        function obj = fcnCallback_PrevFile(obj, ~, ~)
            if obj.index > 1
                obj.index = obj.index - 1;
            else
                obj.index = size(obj.list, 1);
            end
            obj.updateFile();
        end
        
        
        % callback :: NextFile
        %    event :: on Next File button click
        %   action :: increment file index
        function obj = fcnCallback_NextFile(obj, ~, ~)
            if obj.index < size(obj.list, 1)
                obj.index = obj.index + 1;
            else
                obj.index = 1;
            end
            obj.updateFile();
        end
        
    end
    
end