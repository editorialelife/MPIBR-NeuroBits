classdef LSMFileInfo
  % LSMFileInfo LSM file metadata information
  % This class stores all the metadata related to LSM files created using
  % ZEISS confocal microscopes. This class is heavily based on the LSM file
  % toolbox developed by Peter Li (available on the Matlab file exchange: 
  % http://www.mathworks.com/matlabcentral/fileexchange/8412-lsm-file-toolbox)
  % The name of the class is based on the Java implementation in the Fiji
  % plugin LSM_Reader and has been chosen for consistency
  
  properties
    unknown = {};		%ensemble of fields whose meaning is unknown
    datatype = {};
    dimensions = 0;
    timestacksize = 0;
    voxelsizes = 0;
    scantype = 0;
    spectralscan = 0;
    magicNumber = 0;
    structureSize = 0;
    dimensionX = 0;
    dimensionY = 0;
    dimensionZ = 0;
    dimensionChannels = 0;
    dimensionTime = 0;
    intensityDataType = 0;
    thumbnailX = 0;
    thumbnailY = 0;
    voxelSizeX = 0;
    voxelSizeY = 0;
    voxelSizeZ = 0;
    originX = 0;
    originY = 0;
    originZ = 0;
    scanType = 0;
    spectralScan = 0;
    dataType = 0;
    timeInterval = 0;
    displayAspectX = 0;
    displayAspectY = 0;
    displayAspectZ = 0;
    displayAspectTime = 0;
    toolbarFlags = 0;
    objectiveSphereCorrection = 0;
    bitsPerSample = 0;
    scanInfo;           % instance of ScanInfo class
    channelColors;      % instance of ChannelColors class
    timeStamps;         % instance of TimeStamps class
  end
  
  methods
    function obj = LSMFileInfo(filename) %main function for parameters setting
    
      % if it's a directory, return. Will get the info in some other way
      if isdir(filename) || isempty(filename)
        return
      end
      
      if ~exist(filename, 'file')
        error(['Could not find file: ' filename]);
      end
      
      %get file ID for each file already opened (used to check whether we
      %should close filename or not)
      openFilesFIDs = fopen('all');
      
      fid = fopen(filename);
      if -1 == fid
        error(['Could not open file ', filename]);
      end
      
      % Read special LSM IFD
      ifd = obj.ifdread();
      lsmifd = ifd([ifd.tagcode] == 34412);
      if isempty(lsmifd)
        error('Could not find LSMINFO IFD entry');
      end
      
      %Read LSMINFO Header
      codes = LSMSpecs.getInstance();
            
      if fseek(fid, lsmifd.offset, 'bof')
        error(['Received error on file seek to LSMInfoOffset(' lsmifd.offset '): ' ferror(fid)]);
      end
      
      for i = 1:length(codes.LSMINF)
        
        %ugly hack to allow compatibility with lsminfo (which also uses a
        %hack for backward compatibility... ugly)
        if 23 == i
          fseek(fid, lsmifd.offset, 'bof');
        end
        
        mapKey = codes.LSMINF{i}{1};
        num    = codes.LSMINF{i}{2};
        type   = codes.LSMINF{i}{3};
        
        [value, readnum] = fread(fid, num, type);
        if readnum ~= num
          error(['Failed to read more than ' num2str(readnum) ' values for ' field '(' num2str(num) ')']);
        end
        
        % If value is character string, convert to char.
        if strfind(type, 'char')
            value = char(value);
        end
        
        if strfind(mapKey, '_')
          propName = util.fromUpperToCamelCase(mapKey);
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
          catch
            disp(['Property ' propName ' does not exist, skipping.'])
          end
        end
      end
      
      %Read additional small database ChannelColors
      chanCol = LSMChannelColors(fid, obj.offsetChannelColors); 
      obj.channelColors = chanCol;
      
      %Read additional small database TimeStamps
      timSta = LSMTimeStamps(fid, obj.offsetTimestamps);
      obj.timeStamps = timSta;
      
      % Read ScanInfo directory
      scanInf = LSMScanInfo(fid, obj.offsetScaninfo);
      obj.scanInfo = scanInf;
      
      %if fid was already opened before, then we should leave it open.
      if isempty(openFilesFIDs == fid)
        fclose(fid);
      end  
    end
  end
  
  methods (Access = private)
    function [ifd, offset] = ifdread(obj)
    % IFDREAD read IFD entries from TIFF file according to TIFF standard
    %   [IFD,OFFSET] = IFDREAD(FID)
    %
    %   The idf database is read into struct IFD.  The OFFSET to the beginning of
    %   image data is the last  piece of information in the database.
    %
    %   Extensively based on the work by Peter Li 30-Aug-05
    %   Some rights reserved.  Licensed under Creative Commons:
    %   http://creativecommons.org/licenses/by-nc-sa/3.0/
    
      fid = obj.lsmPtr;
    
      ENTRY_LENGTH = 12;
      IFD_TAGMAP = struct(                          ...
        'x254'      ,   'NewSubFileType'            ,...
        'x256'      ,   'ImageWidth'                ,...
        'x257'      ,   'ImageLength'               ,...
        'x258'      ,   'BitsPerSample'             ,...
        'x259'      ,   'Compression'               ,...
        'x262'      ,   'PhotometricInterpretation' ,...
        'x273'      ,   'StripOffsets'              ,...
        'x277'      ,   'SamplesPerPixel'           ,...
        'x279'      ,   'StripByteCounts'           ,...
        'x284'      ,   'PlanarConfiguration'       ,...
        'x34412'    ,   'LSMInfoOffset'             ...
      );
      if fseek(fid, 8, 'bof')
        error(['Received error on file seek to offset 8: ' ferror(fid)]);
      end
      numEntries = fread(fid, 1, 'uint16');
      entriesStartPos = ftell(fid);

      %preallocate ifd
      ifd.tagcode = uint16(0);
      ifd.typecode = uint16(0);
      ifd.count = uint32(0);
      ifd.tag='';
      ifd.bytes = 0;
      ifd.value = 0;
      
      for i = 1:numEntries
        % Go to ifd entry i
        if fseek(fid, entriesStartPos + ((i - 1) * ENTRY_LENGTH), 'bof')
          error(['Received error on file seek to position for entry ' num2str(i) ': ' ferror(fid)]);
        end

        ifd(i).tagcode     = fread(fid, 1, 'uint16');
        ifd(i).typecode    = fread(fid, 1, 'uint16');
        ifd(i).count       = fread(fid, 1, 'uint32');
        ifd(i).tag = structmap(ifd(i).tagcode, IFD_TAGMAP);
        switch ifd(i).typecode
          case {1, 2, 6, 7}   % uint8, uchar, int8, undef8
              ifd(i).bytes = 1;
          case {3, 8}         % uint16, int16
              ifd(i).bytes = 2;
          case {4, 9, 11}     % uint32, int32, float32
              ifd(i).bytes = 4;
          case {5, 10, 12}    % uint32 / uint32, int32 / int32, float64
              ifd(i).bytes = 8;
          otherwise
              error(['Illegal typecode: ' num2str(ifd(i).typecode) '.  Misformed IFD']);
        end

        % If the data take up more than 4 bytes, then the value is a
        % pointer to the data.  Otherwise the value is the data.
        if ((ifd(i).bytes * ifd(i).count) > 4)
          ifd(i).offset = fread(fid, 1, 'uint32');
          if fseek(fid, ifd(i).offset, 'bof')
            error(['Received error on file seek to data for entry ' num2str(i) '(' num2str(ifd(i).offset) '): ' ferror(fid)]);
          end
        end

        switch ifd(i).typecode
          case 1 % uint8
              ifd(i).value = fread(fid, ifd(i).count, 'uint8');
          case 2 % uchar
              ifd(i).value = fread(fid, ifd(i).count, 'uchar');
              char(ifd(i).value);
          case 3 % uint16
              ifd(i).value = fread(fid, ifd(i).count, 'uint16');
          case 4 % uint32
              ifd(i).value = fread(fid, ifd(i).count, 'uint32');
          case 5 % Two uint32, first a numerator, then a denominator, representing a fraction
              ifd(i).value = fread(fid, 2 * ifd(i).count, 'uint32');
              numerators   = fid(i).value(1:2:end);
              denominators = fid(i).value(2:2:end);
              ifd(i).value = double(numerators) ./ double(denominators);    
          case 6 % int8
              ifd(i).value = fread(fid, ifd(i).count, 'int8');
          case 7 % undef8
              ifd(i).value = fread(fid, ifd(i).count, 'uint8');
          case 8 % int16
              ifd(i).value = fread(fid, ifd(i).count, 'int16');
          case 9 % int32
              ifd(i).value = fread(fid, ifd(i).count, 'int32');
          case 10 % Two int32, first a numerator, then a denominator, representing a fraction
              ifd(i).value = fread(fid, 2 * ifd(i).count, 'int32');
              numerators   = fid(i).value(1:2:end);
              denominators = fid(i).value(2:2:end);
              ifd(i).value = double(numerators) ./ double(denominators);    
          case 11 % float32
              ifd(i).value = fread(fid, ifd(i).count, 'float32');
          case 12 % float64
              ifd(i).value = fread(fid, ifd(i).count, 'float64');
          otherwise
              error(['Illegal typecode: ' num2str(ifd(i).typecode) '.  Misformed IFD']);
        end
      end

      fseek(fid, entriesStartPos + (numEntries * ENTRY_LENGTH), -1);
      offset = fread(fid, 1, 'uint32');
    end
  end
  
end

