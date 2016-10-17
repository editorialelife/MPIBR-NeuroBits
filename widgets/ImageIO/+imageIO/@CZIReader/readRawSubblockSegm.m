function [ blkData ] = readRawSubblockSegm( obj, dirEntry )
%READRAWSUBBLOCKSEGM Reads the data from a subblocjk segment
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
  fseek(obj.cziPtr, dirEntry.filePosition + 32, 'bof'); % + 32 to ignore header

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
  end
  
  % skip directory entry
  sizeDirEntry = 32 + dirEntry.dimensionCount * 20;
  fread(obj.cziPtr, sizeDirEntry, 'uint8');
  
  % skip fill bytes, if any
  fill = max(256 - sizeDirEntry, 0);
  if fill > 0
    fread(obj.cziPtr, fill, 'uint8');
  end
  
  % Metadata
  fread(obj.cziPtr, metadataSize, '*char');
  
  % Data
  blkData = cast(fread(obj.cziPtr, dataSize, obj.datatype), obj.datatype);
  blkData = reshape(blkData, obj.pixPerTileRow, obj.pixPerTileCol)';
  
  % Attachments (ignore for the moment?)

end

