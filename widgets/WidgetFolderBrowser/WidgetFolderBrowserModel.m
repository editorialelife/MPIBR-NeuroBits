classdef WidgetFolderBrowserModel < handle
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
        
        path
        extension
        list
        index
        
    end
    
    properties (Dependent)
        file
        listSize
        fileTag        
    end
    
    events
        event_newFile
    end

    
    methods
        
        function obj = WidgetFolderBrowserModel(varchar)
            
            obj.extension = varchar;
            
        end
        
        function obj = fileLoad(varargin)
            
            if nargin==1
                obj = varargin{1};
                [fileName, pathName] = uigetfile(regexp(obj.extension, ',', 'split')', 'Pick a file ...');
                obj.path = pathName(1:end-1); % uigetfile returns pathName with filesep
            elseif nargin==2 && exist(varargin{2}, 'file') %valid file as second argument
                [pathstr, name, ext] = fileparts(varargin{2});
                fileName = [name, ext];
                obj.path = pathstr;
            else
                error('Wrong number of input arguments');
            end
            
            if ischar(fileName)
                obj.list = {[pathName, fileName]};
                obj.index = 1;
                userEventData = UserEventData([pathName, fileName]);
                notify(obj, 'event_newFile', userEventData);
            end
            
        end
        
        function obj = folderLoad(obj)
            
            pathName = uigetdir(pwd, 'Pick a directory ...');
            
            % read folder information
            tempExtension = regexp(obj.extension, ',', 'split');
            folderInfo = [];
            for e = 1 : length(tempExtension)
                
                folderInfo = cat(1,folderInfo,dir([pathName, filesep, tempExtension{e}]));
                
            end
            
            % clean subdirectories and hidden files
            idxRemove = cat(1, folderInfo.isdir) | strncmp('.', {folderInfo.name}', 1);
            folderInfo(idxRemove) = [];
            
            if isempty(folderInfo)
                
                warndlg(sprintf('No files with the extension: %s found!', obj.extension));
                
            else
                
                % update properties
                obj.path = pathName;
                obj.list = cellfun(@(x) {[pathName, filesep, x]},{folderInfo.name}');
                obj.index = 1;
                
            end
            
        end
        
        function obj = fileUpdate(obj, varstep)
            
            % check varstep
            if varstep > obj.listSize
                
                varstep = sign(varstep) * 1;
                
            end
            
            % update index
            obj.index = obj.index + varstep;
            
            % constrain
            if obj.index > obj.listSize
                
                obj.index = obj.index - obj.listSize;
                
            end
            
            if obj.index <= 0
                
                obj.index = obj.listSize + obj.index;
            
            end
            
        end
        
        function value = get.listSize(obj)
            
            value = length(obj.list);
            
        end
        
        function vartag = get.fileTag(obj)
            
            [~, vartag] = fileparts(obj.file);
            
        end
        
        function varchar = get.file(obj)
            
            varchar = obj.list{obj.index};
            
        end
        
    end
end