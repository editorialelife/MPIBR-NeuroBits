function obj = readRawDirSegm( obj )
%READRAWFILESEGM Read metadata for segment of type ZISRAWDIRECTORY
%   Extract information from ZISRAWDIRECTORY segments. 
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Get entry info
  entryCount = int32(fread(obj.cziPtr, 1, 'int32'));
  reserved = int32(fread(obj.cziPtr, 31, 'int32'));  % currently unused

  % Now read all entries. Each item is a copy of the DirectoryEntry in the referenced
  % SubBlock segment.

end

