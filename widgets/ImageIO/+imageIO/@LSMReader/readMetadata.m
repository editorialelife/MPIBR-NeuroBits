function obj = readMetadata(obj)

% open file stream
obj.lsmPtr = fopen(filename);
if -1 == obj.lsmPtr
  error(['LSMReader.readMetadata: Could not open file ', filename]);
end

% Read special LSM IFD
lsmifd = ifd([ifd.tagcode] == obj.LSMTAG);
if isempty(lsmifd)
  error('LSMReader.readMetadata: Could not find LSMINFO IFD entry');
end

% Read LSMINFO Header
codes = LSMSpecs.getInstance();
if fseek(obj.lsmPtr, lsmifd.offset, 'bof')
  error(['LSMReader.readMetadata: Received error on file seek to LSMInfoOffset(' lsmifd.offset '): ' ferror(obj.lsmPtr)]);
end

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
  
  if strfind(mapKey, '_')
    propName = fromUpperToCamelCase(mapKey);
  elseif sum(isstrprop(mapKey, 'upper')) == length(mapKey)
    propName = lower(mapKey);
  else
    propName = mapKey;
  end
  
  % for "unknown" and "datatype" put all the values together in a
  % cell array (consistent with script from Peter Li)
  if isstrprop(mapKey(end), 'digit')
    propName = propName(1:end-1);
    obj.(propName) = [ obj.(propName) value ];
  else %otherwise just set property
    propName = [ lower(propName(1)) propName(2:end) ];
    try
      obj.(propName) = value;
    catch %do nothing
      %disp(['Property ' propName ' does not exist, skipping.'])
    end
  end
end

% Read additional small database ChannelColors
chanCol = LSMChannelColors(obj.lsmPtr, obj.offsetChannelColors);
obj.channelColors = chanCol;

% Read additional small database TimeStamps
timSta = LSMTimeStamps(obj.lsmPtr, obj.offsetTimestamps);
obj.timeStamps = timSta;

% Read ScanInfo directory
scanInf = LSMScanInfo(obj.lsmPtr, obj.offsetScaninfo);
obj.scanInfo = scanInf;

end

