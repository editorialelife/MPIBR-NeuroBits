function obj = readRawDirSegm( obj )
%READRAWDIRSEGM Read metadata for segment of type ZISRAWDIRECTORY
%   Extract information from ZISRAWDIRECTORY segments. 
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Get entry info
  entryCount = int32(fread(obj.cziPtr, 1, 'int32'));
  fread(obj.cziPtr, 31, 'int32');  % reserved

  % Now read all entries. Each item is a copy of the DirectoryEntry in the referenced
  % SubBlock segment.
  obj.directoryEntries = repmat(CZIDirectoryEntry(), 1, entryCount);
  for k = 1:entryCount
    obj.directoryEntries(k) = obj.directoryEntries(k).init(obj.cziPtr);
  end

end

