classdef WidgetFolderBrowser < handle
%
% requires:
%   GUI Layout Toolbox
%   https://de.mathworks.com/matlabcentral/fileexchange/47982-gui-layout-toolbox
%
% Georgi Tushev
% sciclist@brain.mpg.de
% Max-Planck Institute For Brain Research
%

    properties (Access = private)
        
        ui
        model
        
    end
    
    events
        event_newFile
    end
    
    
    methods
        
        function obj = WidgetFolderBrowser(varargin)
            
            % parse input
            parserObj = inputParser;
            addParameter(parserObj, 'Parent', [], @(varhandle) (isempty(varhandle) || isgraphics(varhandle)));
            addParameter(parserObj, 'Extension', '*.*', @ischar);
            parse(parserObj, varargin{:});
            
            % ui component
            obj.ui = WidgetFolderBrowserUi(parserObj.Results.Parent);
            if ~isa(obj.ui, 'WidgetFolderBrowserUi')
                error('WidgetFolderBrowser: initializing ui failed!');
            end
            
            % model component
            obj.model = WidgetFolderBrowserModel(parserObj.Results.Extension);
            if ~isa(obj.model, 'WidgetFolderBrowserModel')
                error('WidgetFolderBrowserModel: initailizing model failed!');
            end
            
            % link ui events
            addlistener(obj.ui, 'event_fileLoad', @obj.fcnCallback_fileLoad);
            addlistener(obj.ui, 'event_fileNext', @obj.fcnCallback_fileNext);
            addlistener(obj.ui, 'event_filePrevious', @obj.fcnCallback_filePrevious);
            addlistener(obj.ui, 'event_folderLoad', @obj.fcnCallback_folderLoad);
            
            addlistener(obj.model, 'event_newFile', @obj.fcnCallback_requestNewFile);

        end
    end
    
    methods
        
        %% @ ui event_fileLoad
        function obj = fcnCallback_fileLoad(obj, ~, ~)
            
            obj.model.fileLoad();
            
        end
        
        %% @ ui event_fileNext
        function obj = fcnCallback_fileNext(obj, ~, ~)
            
            obj.model.fileUpdate(1);
            
        end
        
        %% @ ui event_filePrevious
        function obj = fcnCallback_filePrevious(obj, ~, ~)
            
            obj.model.fileUpdate(-1);
            
        end
        
        %% @ ui event_folderLoad
        function obj = fcnCallback_folderLoad(obj, ~, ~)
            
            obj.model.folderLoad();
            
        end
        
        %% @ request newfile
        function obj = fcnCallback_requestNewFile(obj, ~, event)

            obj.ui.updateFileName(obj.model.fileTag);
            obj.ui.updateFileCounter(obj.model.index, obj.model.listSize);
            
            userEventData = UserEventData(event.userdata);
            notify(obj, 'event_newFile', userEventData);
        end
        
    end
    
end