function [ img ] = readRawSubblockSegm( obj, offsetInFile, dirEntry )
%READRAWSUBBLOCKSEGM Reads the data from a subblocjk segment
%   This function extracts only the data from a Subblock segment.
%   Metadata related to this segment (channels, position, datatype) should
%   have been retrieved previously and are assumed to be already known to
%   the CZIReader object.
%   INPUT
%     obj: a CZIReader instance
%     offsetInFile: the offset of this segment from beginning of file
%     dirEntry: directory entry associated to this block.
%   OUTPUT
%     img: data extracted from the subblock
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Position the file pointer
  fseek(obj.cziPtr, offsetInFile, 'bof');

  % Read sites
  metadataSize = int32(fread(obj.cziPtr, 1, 'int32'));
  attachSize   = int32(fread(obj.cziPtr, 1, 'int32'));
  dataSize     = int64(fread(obj.cziPtr, 1, 'int64'));
  
  % skip directory entry
  sizeDirEntry = 32 + dirEntry.dimensionCount * 20;
  fread(obj.cziPtr, sizeDirEntry, 'uint8');
  
  % skip fill bytes, if any
  fill = max(256 - sizeDirEntry, 0);
  if fill > 0
    fread(obj.cziPtr, fill, 'uint8');
  end
  
  % Metadata
  sbMetadata = fread(obj.cziPtr, metadataSize, '*char')';
  
  % Data
  img = cast(fread(obj.cziPtr, dataSize, obj.dataType), obj.dataType);
  
  % Attachments (ignore for the moment?)

end

