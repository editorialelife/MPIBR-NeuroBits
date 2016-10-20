function [ blkData ] = readRawSubblockSegm( obj, dirEntry )
%READRAWSUBBLOCKSEGM Reads the data from a subblock segment
%   This function extracts only the data from a Subblock segment.
%   Metadata related to this segment (channels, position, datatype) should
%   have been retrieved previously and are assumed to be already known to
%   the CZIReader object.
%   INPUT
%     obj: a CZIReader instance
%     dirEntry: directory entry associated to this block.
%   OUTPUT
%     img: data extracted from the subblock
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Position the file pointer
  if nargin > 1
    fseek(obj.cziPtr, dirEntry.filePosition + 32, 'bof'); % + 32 to ignore header
  end

  % Read sizes
  metadataSize = int32(fread(obj.cziPtr, 1, 'int32'));
  attachSize   = int32(fread(obj.cziPtr, 1, 'int32'));
  dataSize     = int64(fread(obj.cziPtr, 1, 'int64'));
  switch obj.datatype
    case 'int16'
      dataSize = dataSize / 2;
    case 'uint16'
      dataSize = dataSize / 2;
    case 'int32'
      dataSize = dataSize / 4;
    case 'uint32'
      dataSize = dataSize / 4;
    case 'float'
      dataSize = dataSize / 4;
    case 'double'
      dataSize = dataSize / 8;
    otherwise
      error('CZIReader.readRawSubblockSegm: unsupported datatype');
  end
  
  % skip directory entry, if already specified
  if nargin > 1
    sizeDirEntry = 32 + dirEntry.dimensionCount * 20;
    fread(obj.cziPtr, sizeDirEntry, 'uint8');
  else
    dirEntry = CZIDirectoryEntry();
    dirEntry = dirEntry.init(obj.cziPtr);
    dirEntry = obj.analyzeDirEntry(dirEntry);
    sizeDirEntry = 32 + dirEntry.dimensionCount * 20;
  end
  
  % skip fill bytes, if any
  fill = max(256 - (sizeDirEntry + 16), 0);
  if fill > 0
    unused = fread(obj.cziPtr, fill, '*char')';
  end
  
  % Metadata - ignore for the moment
  metadata = fread(obj.cziPtr, metadataSize, '*char')';
  if ~isempty(metadata)
    metadataStruct = xml2struct(metadata);
  end
  
  % Data
  if nargout > 0
    datatype = [obj.datatype '=>' obj.datatype];
    blkData = fread(obj.cziPtr, dataSize, datatype);
    blkData = reshape(blkData, obj.pixPerTileRow, obj.pixPerTileCol)';
  end
  
  % Attachments - ignore for the moment
  % fread(obj.cziPtr, attachSize, '*char');
  
end

