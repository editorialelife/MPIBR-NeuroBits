% Class WidgetFolderBrowser
% 
% user loads a file or a folder and emits
% event_fileUpdated
% 
%
classdef WidgetFolderBrowser < handle
    
    properties
        ext
        folderName
        fileName
        fileList
        fileIndex
    end
    
    properties (Access=protected)
        ui_parent
        ui_panel
        ui_pushButton_loadFile
        ui_pushButton_loadFolder
        ui_pushButton_prevFile
        ui_pushButton_nextFile
        ui_text_fileName
        ui_text_fileCounter
    end
    
    events (NotifyAccess=protected)
        event_fileUpdated;
    end
    
    methods
        function obj = WidgetFolderBrowser(varargin)
            
            p = inputParser;
            addParameter(p, 'Parent', [], @isgraphics);
            addParameter(p, 'Extension', '*.*', @isstr);
            parse(p, varargin{:});
            
            if isempty(p.Results.Parent)
                obj.ui_parent = figure;
            else
                obj.ui_parent = p.Results.Parent;
            end
            obj.ext = p.Results.Extension;
            
            obj.renderUI();
            
        end
        
        function obj = renderUI(obj)
            
            obj.ui_panel = uipanel(...
                'Parent', obj.ui_parent,...
                'BorderType', 'none',...
                'BackgroundColor', obj.BackgroundColor,...
                'Unit', 'normalized',...
                'Position', [0,0,1,1]);
            
            obj.ui_pushButton_loadFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load file',...
                'Enable', 'on',...
                'Callback', @obj.callbackFcn_loadFile,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],3,1));
            
            obj.ui_pushButton_loadFolder = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Load folder',...
                'Enable', 'on',...
                'Callback', @obj.callbackFcn_loadFolder,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],3,2));
            
            obj.ui_pushButton_prevFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Previous file',...
                'Enable', 'off',...
                'Callback', @obj.callbackFcn_prevFile,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],4,1));
            
            obj.ui_pushButton_nextFile = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'PushButton',...
                'String', 'Next file',...
                'Enable', 'off',...
                'Callback', @obj.callbackFcn_nextFile,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],4,2));
            
            obj.ui_text_fileName = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', 'load file or folder',...
                'BackgroundColor', obj.BackgroundColor,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],1,1:2));
            
            obj.ui_text_fileCounter = uicontrol(...
                'Parent', obj.ui_panel,...
                'Style', 'text',...
                'String', '0 / 0',...
                'BackgroundColor', obj.BackgroundColor,...
                'Units', 'normalized',...
                'Position', GridLayout([4,2],[0.01,0.01],2,1:2));
                
        end
        
        function value = BackgroundColor(obj)
            if isa(obj.ui_parent, 'matlab.ui.Figure')
                value = get(obj.ui_parent, 'Color');
            elseif isa(obj.ui_parent, 'matlab.ui.container.Panel')
                value = get(obj.ui_parent, 'BackgroundColor');
            end
        end
        
        function obj = loadFile(obj, fileName, pathName)
            
            % update properties
            obj.folderName = pathName(1:end-1); % uigetfile retunrns pathName with filesep
            obj.fileName = [pathName,fileName];
            obj.fileList = {obj.fileName};
            obj.fileIndex = 1;
            
            % update message
            [~, fileTag] = fileparts(obj.fileName);
            set(obj.ui_text_fileName,...
                'String', fileTag);
            set(obj.ui_text_fileCounter,...
                'String', sprintf('%d / %d',obj.fileIndex, size(obj.fileList,1)));
            
            % deactivate Next/Prev buttons
            set(obj.ui_pushButton_prevFile, 'Enable', 'off');
            set(obj.ui_pushButton_nextFile, 'Enable', 'off');
            
            % evoke event
            notify(obj, 'event_fileUpdated');
            
        end
        
        function obj = loadFolder(obj, pathName)
            
            folderInfo = dir([pathName, filesep, obj.ext]);
            if isempty(folderInfo)
                warndlg(sprintf('No files with the extension: %s found!', obj.ext));
            else
                
                % update properties
                obj.folderName = pathName;
                obj.fileList = cellfun(@(x) {[pathName, filesep, x]},{folderInfo.name}');
                obj.fileIndex = 1;
                
                % unlock Next/Prev buttons
                if size(obj.fileList, 1) > 1
                    set(obj.ui_pushButton_prevFile, 'Enable', 'on');
                    set(obj.ui_pushButton_nextFile, 'Enable', 'on');
                end
                
                % update file
                obj.updateFile();
                
            end
            
        end
        
        function obj = updateFile(obj)
            obj.fileName = obj.fileList{obj.fileIndex};
            [~, fileTag] = fileparts(obj.fileName);
            set(obj.ui_text_fileName,...
                'String', fileTag);
            set(obj.ui_text_fileCounter,...
                'String', sprintf('%d / %d', obj.fileIndex, size(obj.fileList,1)));
            notify(obj, 'event_fileUpdated');
        end
        
        %%% --- Callback functions --- %%%
        function callbackFcn_loadFile(obj, ~, ~)
            [file_name, path_name] = uigetfile(obj.ext, 'Pick a file ...');
            if ischar(file_name)
                obj.loadFile(file_name, path_name);
            end
        end
        
        function callbackFcn_loadFolder(obj, ~, ~)
            path_name = uigetdir(pwd, 'Pick a dirctory ...');
            if ischar(path_name)
                obj.loadFolder(path_name);
            end
        end
        
        function callbackFcn_prevFile(obj, ~, ~)
            if obj.fileIndex > 1
                obj.fileIndex = obj.fileIndex - 1;
            else
                obj.fileIndex = size(obj.fileList, 1);
            end
            obj.updateFile();
        end
        
        function callbackFcn_nextFile(obj, ~, ~)
            if obj.fileIndex < size(obj.fileList, 1)
                obj.fileIndex = obj.fileIndex + 1;
            else
                obj.fileIndex = 1;
            end
            obj.updateFile();
        end
    end
end


%%% --- Calculates Grid Layout --- %%%
function [uiGrid] = GridLayout(gridSize, margins, spanH, spanW)
    % function :: GridLayout
    %    input :: gridSize (HxW)
    %    input :: margins (HxW)
    %    input :: spanH
    %    input :: spanW
    %   method :: calculates GridLayout
    
    % calculate grid size
    gridHSize = (1 - margins(1) * (gridSize(1) + 1)) / gridSize(1);
    gridWSize = (1 - margins(2) * (gridSize(2) + 1)) / gridSize(2);

    % calculate box position
    gridHPos = flipud(cumsum([margins(1); repmat(gridHSize + margins(1), gridSize(1) - 1, 1)]));
    gridWPos = cumsum([margins(2); repmat(gridWSize + margins(2), gridSize(2) - 1, 1)]);

    % extract grid
    uiGrid = zeros(1,4);
    uiGrid(1) = gridWPos(spanW(1));
    uiGrid(2) = gridHPos(spanH(end));
    uiGrid(3) = length(spanW) * gridWSize + (length(spanW) - 1) * margins(2);
    uiGrid(4) = length(spanH) * gridHSize + (length(spanH) - 1) * margins(1);
    
end

