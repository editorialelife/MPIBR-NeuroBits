classdef CZIDirectoryEntry
%CZIDIRECTORYENTRY Implementation of the Directory Entry schema
%   The class represents the information stored in the DimrectionEntryDV schema, 
%   according to the CZI FileFormat specification
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  properties (SetAccess = protected)
    schemaType;         % Always "DV"
    pixelType;          % The type of the image pixels
    filePosition;       % Seek offset of the referenced SubBlockSegment
                        % relative to the first byte of the file
    compression;        % code representing the compression used
    dimensionCount;     % number of entries. Minimum is 1
    dimensionEntries;   % Variable length array of dimensions. Each dimension
                        % can occur only once. It's an array of
                        % CZIDimensionEntry objects
  end
  
  properties (Constant = true)
    
  end
  
  methods
    function obj = CZIDirectoryEntry(cziPtr)
      %CZIDIRECTORYENTRY Constructor
      % The function reads from file the fields related to the
      % DirectoryEntry
      % INPUT
      %   cziPtr: file identifier of the czi file. It is assumed that the
      %     position in the file is at the start at the DimensionEntry
      %     field
      % OUTPUT
      %   obj: the instance of the class
      
      obj.schemaType = deblank(fread(cziPtr, 2, '*char')');
      obj.pixelType = int32(fread(cziPtr, 1, 'int32'));
      obj.filePosition = int32(fread(cziPtr, 1, 'int32'));
      obj.compression = float(fread(cziPtr, 1, 'float'));
      obj.dimensionCount = int32(fread(cziPtr, 1, 'int32'));
    end
  end
  
end


