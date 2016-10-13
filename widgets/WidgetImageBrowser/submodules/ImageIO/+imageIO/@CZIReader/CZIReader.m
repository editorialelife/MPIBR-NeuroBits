classdef CZIReader < imageIO.ImageIO
  %CZIREADER Class used to read CZI files
  %   This class implements a Matlab API for reading files specified using
  %   the CZI file format (available here ../../docs/DS_ZISRAW-FileFormat.pdf).
  %   The constructor of the class will do the heavy part of the job,
  %   namely parsing the header and segment files in order to extract the
  %   metadata required by the ImageIO library.
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 29.07.2016
  %   SEE ALSO: imageIO.imageIO
  
  properties
    cziPtr = 0;              % Pointer to the CZI file (returned by fopen)
    segmentTypes;            % SegmentTypes present in the file
    offsetToSegments;        % Offsets (from BOF) to the start of the data
    imageSubblocks = 0;      % Total number of image subblock (ZISRAWSUBBLOCK segments)
    offsetMetadataSegm = 0;  % Offset to the Metadata segment (1 per file)
    offsetDirectorySegm = 0; % Offset to the Directory segment (1 per file)
    offsetAttachDirSegm = 0; % Offset to the Attachment segment (1 per file)
    directoryEntries;        % Directory entry info associated to each subblock
  end
  
  methods
    function obj = CZIReader(filename)
    %CZIREADER Constructor of the class
    %The constructor calls the constructor of the superclass, and then
    %tries to parse the file to extract as much information as
    %possible from the file. No actual data is read in the constructor
    %SEE ALSO imageIO.ImageIO.ImageIO
      
      % Must call explictily because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      % Set as many properties from the superclass as possible
      obj = obj.readMetadata();
    end
    
    function close(obj)
    %CLOSE close the file identifier  
      if obj.cziPtr
        fclose(obj.cziPtr);
      end
    end
  end
  
  methods (Access = protected)
    obj = readRawMetadataSegm(obj);      %IMPLEMENTED IN SEPARATE FILE
    obj = readRawFileSegm(obj);          %IMPLEMENTED IN SEPARATE FILE
    obj = readRawAttachSegm(obj);        %IMPLEMENTED IN SEPARATE FILE
    obj = readRawDirSegm(obj);           %IMPLEMENTED IN SEPARATE FILE
  end
  
end

