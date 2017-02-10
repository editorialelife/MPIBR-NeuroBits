classdef LSMScanInfo
  %LSMSCANINFO Simple class representing the ScanInfo part of LSM metadata
  %
  
  properties
    entryName = '';
    entryDescription = '';
    entryNotes = '';
    entryObjective = '';
    specialScan = '';
    scanType = '';
    scanMode = '';
    stacksCount = 0;
    linesPerPlane = 0;
    samplesPerLine = 0;
    planesPerVolume = 0;
    imagesWidth = 0;
    imagesHeight = 0;
    numberOfPlanes = 0;
    imagesNumberStacks = 0;
    imagesNumberChannels = 0;
    linescanXY = 0;
    scanDirection = 0;
    h10000063 = 0;
    timeSeries = 0;
    orignalScanData = 0;
    zoomX = 0;
    zoomY = 0;
    zoomZ = 0;
    sample_0X = 0;
    sample_0Y = 0;
    sample_0Z = 0;
    sampleSpacing = 0;
    lineSpacing = 0;
    planeSpacing = 0;
    rotation = 0;
    h10000023 = 0;
    precession = 0;
    sample_0Time = 0;
    startScanTriggerIn = '';
    startScanTriggerOut = '';
    startScanEvent = 0;
    startScanTime = 0;
    stopScanTriggerIn = '';
    stopScanTriggerOut = '';
    stopScanEvent = 0;
    startScanTime2 = 0;
    useRois = 0;
    useReducedMemoryRois = 0;
    user = '';
    useBccorecction = 0;
    positionBccorrection1 = 0;
    positionBccorrection2 = 0;
    interpolationy = 0;
    cameraBinning = 0;
    cameraSupersampling = 0;
    cameraFrameWidth = 0;
    cameraFrameHeight = 0;
    cameraOffsetx = 0;
    cameraOffsety = 0;
    h10000059 = 0;
    h10000064 = 0;
    h1000005A = 0;
    h1000005B = 0;
    h1000005C = 0;
    h1000005D = 0;
    h1000005E = 0;
    h1000005F = 0;
    h10000060 = 0;
    h10000061 = 0;
    h10000062 = 0;
    laserName = '';
    laserAcquire = 0;
    laserPower = 0;
    pixelTime = {};
    timeBetweenStacks = {};
    multiplexType = {};
    multiplexOrder = {};
    samplingMode = {};
    samplingMethod = {};
    samplingNumber = {};
    entryAcquire = {};
    trackName = {};
    bleachTrack = {};
    bleachAfterScanNumber = {};
    bleachScanNumber = {};
    triggerIn = {};
    triggerOut = {};
    isRatioTrack = {};
    bleachCount = {};
    spiCenterWavelength = {};
    h4000003F = {};
    idFieldStop = {};
    fieldStopValue = {};
    transmittedLight = {};
    h4000003A = {};
    detectorGain = {};
    h70000004 = {};
    amplifierGain = {};
    h70000006 = {};
    amplifierOffset = {};
    h70000008 = {};
    pinholeDiameter = {};
    h7000000A = {};
    h70000001 = {};
    h70000002 = {};
    detectorName = {};
    amplifierName = {};
    pinholeName = {};
    filterSetName = {};
    filterName = {};
    h70000011 = {};
    h70000012 = {};
    integratorName = {};
    detectionChannelName = {};
    detectorGainBc1 = {};
    detectorGainBc2 = {};
    amplifierGainBc1 = {};
    amplifierGainBc2 = {};
    amplifierOffsetBc1 = {};
    amplifierOffsetBc2 = {};
    spectralScanChannels = {};
    spiWaveLengthStart = {};
    spiWavelengthEnd = {};
    h70000024 = {};
    h70000025 = {};
    dyeName = {};
    dyeFolder = {};
    h70000028 = {};
    h70000029 = {};
    h70000030 = {};
    filterSet = {};
    filter = {};
    bsName = {};
    illName = {};
    power = {};
    wavelength = {};
    acquire = {};
    h90000009 = {};
    powerBc1 = {};
    powerBc2 = {};
    dataName = {};
    hD0000003 = {};
    color = {};
    sampletype = {};
    bitsPerSample = {};
    ratioType = {};
    ratioTrack1 = {};
    ratioTrack2 = {};
    ratioChannel1 = {};
    ratioChannel2 = {};
    ratioConst1 = {};
    ratioConst2 = {};
    ratioConst3 = {};
    ratioConst4 = {};
    ratioConst5 = {};
    ratioConst6 = {};
    
    collimator1Position;
    collimator1Name;
    idTubelens;
    idTubelensPosition;
    collimator2Position;
    collimator2Name;
    repeatBleach;
    enableSpotBleachPos;
    spotBleachPosx;
    spotBleachPosy;
    bleachPositionZ;
  end
  
  methods
    function obj = LSMScanInfo(fid, offsetScanInformation)
      if fseek(fid, offsetScanInformation, 'bof')
        error(['Received error on file seek to SCANINFO_OFFSET(' offsetScanInformation '): ' ferror(fid)]); 
      end
      % The algorithm for reading the scaninfo database depends on keeping track of a
      % "level" hierarchy.  As the database is read, some entries are level
      % instructions, navigating up or down the hierarchy.  The database is done when
      % the hierarchy steps back to level 0.
      level = 0;
      %Read LSMINFO Header
      codes = LSMSpecs.getInstance();
      while(1)
        taghex      = dec2hex(fread(fid, 1, 'uint32'));
        typecode    = fread(fid, 1, 'uint32');
        size        = fread(fid, 1, 'uint32');
        tag         = obj.getFromSpecs(['h' taghex], codes.SCANINFO_HEXTAGMAP);
        
        switch typecode
          case 0 % Special case: this is a level instruction entry
            if (hex2dec(taghex) == hex2dec('FFFFFFFF'))
                level = level - 1;
            else
                level = level + 1;
            end
          case 2 % string
              count = size;
              value = char(fread(fid, count, 'uchar')');
              value = value(1:end-1);
          case 4 % int32
              count = size / 4;
              value = fread(fid, count, 'uint32');
          case 5 % float64
              count = size / 8;
              value = fread(fid, count, 'float64');
          otherwise 
              fseek(fid, size, 0);
              value = '?';
        end
        
        % If this was just a level instruction entry ignore it, otherwise try to
        % record entry.
        if typecode > 0
          if isempty(tag)
            propName = [ 'h' taghex ];
          else
            propName = util.fromUpperToCamelCase(tag);
          end
          obj = obj.appendField(propName, value);
        end
                
        if ( 0 == level)
          break;
        end
      end
      
    end
  end
  
  methods (Access = private)
    function tag = getFromSpecs(SI, code, hexToTagMap)
      tag = [];
      for k=1:length(hexToTagMap)
        if strcmp(code, hexToTagMap{k}{1})
          tag = hexToTagMap{k}{2};
          break;
        end
      end
    end
    
    function SI = appendField(SI, propName, value)
      try
        if iscell(SI.(propName)) % Already converted this field into cells
          SI.(propName){end+1} = value;
        else     % just set it
          SI.(propName) = value;
        end
      catch
        % DO NOTHING
      end
    end
  end
  
end