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
    
    properties (SetObservable)
        
        file
        
    end
    
    properties (Dependent)
        
        listSize
        
    end
    
    methods
        
        function obj = WidgetFolderBrowserModel(varchar)
            
            obj.extension = varchar;
            
        end
        
        function obj = fileLoad(obj)
            
            [fileName, pathName] = uigetfile(regexp(obj.extension, ',', 'split')', 'Pick a file ...');
            if ischar(fileName)
                
                obj.path = pathName(1:end-1); % uigetfile retunrns pathName with filesep
                obj.list = {[pathName, fileName]};
                obj.index = 1;
                obj.file = obj.list{obj.index};
                
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
                obj.file = obj.list{obj.index};
                
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
            
            % update filename
            obj.file = obj.list{obj.index};
            
        end
        
        function value = get.listSize(obj)
            
            value = length(obj.list);
            
        end
    end
end