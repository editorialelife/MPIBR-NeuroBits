function obj = readMetadata(obj)

% open file stream
obj.lsmPtr = fopen(obj.fileFullPath);
if -1 == obj.lsmPtr
  error(['LSMReader.readMetadata: Could not open file ', filename]);
end

% Read special LSM IFD
ifd = obj.ifdread();
lsmifd = ifd([ifd.tagcode] == obj.LSMTAG);
if isempty(lsmifd)
  error('LSMReader.readMetadata: Could not find LSMINFO IFD entry');
end

% Read LSMINFO Header
codes = LSMSpecs.getInstance();
if fseek(obj.lsmPtr, lsmifd.offset, 'bof')
  error(['LSMReader.readMetadata: Received error on file seek to LSMInfoOffset(' lsmifd.offset '): ' ferror(obj.lsmPtr)]);
end

obj.originalMetadata = struct('unknown', {[]}, 'datatype', {[]});

% Go through all the properties
for i = 1:length(codes.LSMINF)
  
  %ugly hack to allow compatibility with lsminfo (which also uses a
  %hack for backward compatibility... ugly)
  if 23 == i
    fseek(obj.lsmPtr, lsmifd.offset, 'bof');
  end
  
  mapKey = codes.LSMINF{i}{1};
  num    = codes.LSMINF{i}{2};
  type   = codes.LSMINF{i}{3};
  
  [value, readnum] = fread(obj.lsmPtr, num, type);
  if readnum ~= num
    error(['LSMReader.readMetadata: Failed to read more than ' num2str(readnum) ' values for ' field '(' num2str(num) ')']);
  end
  
  % If value is character string, convert to char.
  if strfind(type, 'char')
    value = char(value);
  end
  
  % for "unknown" and "datatype" put all the values together in a
  % cell array (consistent with script from Peter Li)
  if isstrprop(mapKey(end), 'digit')
    mapKey = mapKey(1:end-1);
    obj.originalMetadata.(mapKey) = [ obj.originalMetadata.(mapKey) {value} ];
  else %otherwise just set property
    obj.originalMetadata.(mapKey) = value;
  end
end

% Read additional small database ChannelColors
obj.originalMetadata.channelColors = LSMChannelColors(obj.lsmPtr, obj.originalMetadata.OFFSET_CHANNELSCOLORS);

% Read additional small database TimeStamps
obj.originalMetadata.timeStamps = LSMTimeStamps(obj.lsmPtr, obj.originalMetadata.OFFSET_TIMESTAMPS);

% Read ScanInfo directory
obj.originalMetadata.scanInfo = LSMScanInfo(obj.lsmPtr, obj.originalMetadata.OFFSET_SCANINFO);

% Set the metadata just read into the appropriate properties
obj.height = obj.originalMetadata.DimensionX;
obj.width = obj.originalMetadata.DimensionY;
obj.channels = obj.originalMetadata.DimensionChannels;
obj.stacks = obj.originalMetadata.DimensionZ;
obj.time = obj.originalMetadata.DimensionTime;
obj = obj.setChannelInfo(obj.originalMetadata.channelColors);
obj.scaleSize = obj.originalMetadata.VOXELSIZES;

% Finally, use the BioFormat reader to get info about overlap and number of
% tiles.
bfPtr = bfGetReader(obj.fileFullPath);
ome = bfPtr.getMetadataStore();
obj.datatype = char(ome.getPixelsType(0));
try
  obj.tile = ome.getImageCount();
catch
  obj.tile = 1;
end
obj = obj.setTileProperties(ome);
if obj.tile ~= 1
  obj.height = round(obj.pixPerTileRow * (1 + (obj.numTilesRow - 1) * (1 - obj.tileOverlap)));
  obj.width = round(obj.pixPerTileCol * (1 + (obj.numTilesCol - 1) * (1 - obj.tileOverlap)));
end

end

