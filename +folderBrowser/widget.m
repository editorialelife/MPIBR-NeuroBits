classdef widget < handle
    
    properties
        
        ui
        model
        
    end
    
    methods
        
        function obj = widget(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @isempty);
            addParameter(parserObj, 'Extension', '*.*', @ischar);
            parse(parserObj, varargin{:});
            
            
            obj.ui = folderBrowser.uirender('Parent', parserObj.Results.Parent);
            %obj.model = ModelFolderBrowser('Extension', parserObj.Results.Extension);
            
            % link controler with view and model
            addlistener(obj.ui, 'event_fileLoad', @obj.fcnCallback_FileLoad);
            addlistener(obj.ui, 'event_fileNext', @obj.fcnCallback_FileNext);
            addlistener(obj.ui, 'event_filePrevious', @obj.fcnCallback_FilePrevious);
            addlistener(obj.ui, 'event_folderLoad', @obj.fcnCallback_FolderLoad);
             
        end
        
        function obj = fcnCallback_FileLoad(obj, ~, ~)
            disp('File load...');
        end
        
        function obj = fcnCallback_FileNext(obj, ~, ~)
            disp('File next...');
        end
        
        function obj = fcnCallback_FilePrevious(obj, ~, ~)
            disp('File previous...');
        end
        
        function obj = fcnCallback_FolderLoad(obj, ~, ~)
            disp('Folder load...');
        end
            
        
    end
    
end