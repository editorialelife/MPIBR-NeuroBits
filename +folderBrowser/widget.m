classdef widget < handle
%
% package FolderBrowser
% widget
%
% GUI Widget for browsing a folder
% user loads a file or a folder
% uses Model-View-Controller design
% role: controller
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
        
        ui
        model
        
    end
    
    methods
        
        function obj = widget(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isparent);
            addParameter(parserObj, 'Extension', '*.*', @ischar);
            parse(parserObj, varargin{:});
            
            
            obj.ui = folderBrowser.uirender(parserObj.Results.Parent);
            obj.model = folderBrowser.model(parserObj.Results.Extension);
            
            % link controler with view and model
            if isa(obj.ui, 'folderBrowser.uirender')
                
                addlistener(obj.ui, 'event_fileLoad', @obj.fcnCallback_FileLoad);
                addlistener(obj.ui, 'event_fileNext', @obj.fcnCallback_FileNext);
                addlistener(obj.ui, 'event_filePrevious', @obj.fcnCallback_FilePrevious);
                addlistener(obj.ui, 'event_folderLoad', @obj.fcnCallback_FolderLoad);

            end
            
            if isa(obj.model, 'folderBrowser.model')
                
                addlistener(obj.model, 'file', 'PostSet', @obj.fcnCallback_FileUpdated);
            end
            
        end
    end
    
    methods
        
        %%% --- callback functions --- %%%
        
        function obj = fcnCallback_FileLoad(obj, ~, ~)
            
            %disp('File load...');
            obj.model.fileLoad();
            
            set(obj.ui.pushButton_PrevFile, 'Enable', 'off');
            set(obj.ui.pushButton_NextFile, 'Enable', 'off');
            
        end
        
        function obj = fcnCallback_FileNext(obj, ~, ~)
            
            disp('File next...');
            obj.model.fileUpdate(1);
            
        end
        
        function obj = fcnCallback_FilePrevious(obj, ~, ~)
            
            disp('File previous...');
            obj.model.fileUpdate(-1);
            
        end
        
        function obj = fcnCallback_FolderLoad(obj, ~, ~)
            
            disp('Folder load...');
            obj.model.folderLoad();
            
            set(obj.ui.pushButton_PrevFile, 'Enable', 'on');
            set(obj.ui.pushButton_NextFile, 'Enable', 'on');
            
        end
        
        function obj = fcnCallback_FileUpdated(obj, ~, ~)
            
            %disp('File updated...');
            
            % update status
            [~, fileTag] = fileparts(obj.model.file);
            fprintf('file: %s\n', obj.model.file);
            
            set(obj.ui.text_FileName, 'String', fileTag);
            set(obj.ui.text_FileCounter, 'String', ...
                sprintf('%d / %d', obj.model.index, obj.model.listSize));
            
            
        end
        
    end
    
end



function tf = isparent(varin)

    tf = false;
    
    if isempty(varin) || isgraphics(varin)
        
        tf = true;
    
    end
end
