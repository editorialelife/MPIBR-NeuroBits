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
        ui_pushButton_LoadFile
        ui_pushButton_LoadFolder
        ui_pushButton_PrevFile
        ui_pushButton_NextFile
        ui_text_FileName
        ui_text_FileCounter
    end
    
    properties (Constant = true, Access = private, Hidden = true)
        
        BORDER_WIDTH = 0.015;
        BORDER_HEIGHT = 0.015;
        
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
            addParameter(parserObj, 'Extension', '*.*', @isstr);
            parse(parserObj, varargin{:});
            
            % set input properties
            if isempty(parserObj.Results.Parent)
                obj.ui_parent = figure;
            else
                obj.ui_parent = parserObj.Results.Parent;
            end
            
            obj.ext = parserObj.Results.Extension;
            
            % render user interface
            obj.renderUI();
            
        end
        
        
        % method :: getParentColor
        %  input :: class object
        % action :: returns value of Parent Color/BackgroundColor property
        function value = getParentColor(obj)
            if isgraphics(obj.ui_parent, 'figure')
                value = get(obj.ui_parent, 'Color');
            elseif isgraphics(obj.ui_parent, 'uipanel')
                value = get(obj.ui_parent, 'BackgroundColor');
            end
        end
        
        
        % method :: renderUI
        %  input :: class object
        % action :: render user interface
        function obj = renderUI(obj)
            
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BorderType', 'none',...
                'BackgroundColor', obj.getParentColor(),...
                'Unit', 'normalized',...
                'Position', [0, 0, 1, 1]);
            
            obj.ui_pushButton_LoadFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load file',...
                'Enable', 'on',...
                'Callback', @obj.fcnCallback_LoadFile,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         3, 1));
            
            obj.ui_pushButton_LoadFolder = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load folder',...
                'Enable', 'on',...
                'Callback', @obj.fcnCallback_LoadFolder,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         3, 2));
            
            obj.ui_pushButton_PrevFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Previous file',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_PrevFile,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         4, 1));
            
            obj.ui_pushButton_NextFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Next file',...
                'Enable', 'off',...
                'Callback', @obj.fcnCallback_NextFile,...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         4, 2));
            
            obj.ui_text_FileName = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'load file or folder',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         1, 1:2));
            
            obj.ui_text_FileCounter = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', '0 / 0',...
                'BackgroundColor', obj.getParentColor(),...
                'Units', 'normalized',...
                'Position', uiGridLayout([4, 2],...
                                         [obj.BORDER_HEIGHT, obj.BORDER_WIDTH],...
                                         2, 1:2));
            
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
            [~, fileTag] = fileparts(obj.file);
            set(obj.ui_text_FileName,...
                'String', fileTag);
            set(obj.ui_text_FileCounter,...
                'String', sprintf('%d / %d',obj.index, size(obj.list,1)));
            
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
            
            folderInfo = dir([pathName, filesep, obj.ext]);
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
            [~, fileTag] = fileparts(obj.file);
            set(obj.ui_text_FileName,...
                'String', fileTag);
            set(obj.ui_text_FileCounter,...
                'String', sprintf('%d / %d', obj.index, size(obj.list,1)));
            
            % evoke event
            notify(obj, 'event_fileUpdated');
            
        end
        
        
        %%% -------------------------- %%%
        %%% --- CALLBACK FUNCTIONS --- %%%
        %%% -------------------------- %%%
        
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