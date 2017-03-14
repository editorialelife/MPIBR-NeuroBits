function obj = readMetadata( obj )
%READMETADATA Read the metadata information and stores it in the object
%properties
%   This function parses the file according to the LSM file specifications,
%   and stores header and segment information that is hten used to fill all
%   the metadata fields of the object.
%
% AUTHOR: Stefano Masneri
% Date: 13.3.2017

%open file for reading
[obj.lsmPtr, errMsg] = fopen(obj.fileFullPath);
if obj.lsmPtr < 0
  error(['LSMReader.readMetadata: Could not open file ', filename, ' - ' errMsg]);
end

s = dir(obj.fileFullPath);
filesize = s.bytes;
if filesize > 2^32
  obj.bigTiff = true;
else
  obj.bigTiff = false;
end

%read TIFF header
byteOrder = fread(obj.lsmPtr, 2, '*char')';
if ~(strcmp(byteOrder,'II')) %only little endian allowed!
  error('LSMReader.readMetadata: This is not a correct LSM file');
end
fortytwo = fread(obj.lsmPtr, 1, 'uint16', obj.BYTE_ORDER);
if fortytwo ~= 42
  error('LSMReader.readMetadata: This is not a correct LSM file');
end
offsetFirstIFD = fread(obj.lsmPtr, 1, 'uint32', obj.BYTE_ORDER);
fseek(obj.lsmPtr, offsetFirstIFD, 'bof');

% Now read the first image directory, the one containing all the metadata
imgDir = LSMImageDirectory();
imgDir = imgDir.init(obj.lsmPtr, obj.BYTE_ORDER);
infoDirEntry = imgDir.dirEntryArray([imgDir.dirEntryArray.tag] == obj.TIF_CZ_LSMINFO );

% Create the LSMInfo object checking the specific Directory Entry
if infoDirEntry.isOffset
  fseek(obj.lsmPtr, infoDirEntry.value, 'bof');
  obj.originalMetadata = LSMInfo(obj.lsmPtr, obj.BYTE_ORDER);
else
  error('LSMReader.readMetadata: CZ_LSMINFO tag should contain offset to metadata')
end


  
end

