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
    cziPtr = 0;         % Pointer to the CZI file (returned by fopen)
    segmentTypes;       % SegmentTypes present in the file
    offsetToSegments;   % Offsets (from BOF) to the start of the data
    imageSubblocks = 0; % Total number of image subblock (ZISRAWSUBBLOCK segments)
  end
  
  properties (Constant = true)
    ID_ZISRAWFILE = 1;      % File Header segment, occurs only once per file. 
                            %   The segment is always located atposition 0
    ID_ZISRAWDIRECTORY = 2; % Directory segment containing a sequence of "DirectoryEntry" items.
    ID_ZISRAWSUBBLOCK = 3;  % Contains an ImageSubBlock containing an XML part, 
                            %   optional pixel data and binary attachments described by 
                            %   the AttachmentSchema within the XML part
    ID_ZISRAWMETADATA = 4;  % Contains Metadata consisting of an XML part and binary
                            %   attachments described by the AttachmentSchema within the XML part
    ID_ZISRAWATTACH = 5;    % Any kind of namend Attachment, some names are reserved for internal use.
    ID_ZISRAWATTDIR = 6;    % Attachments directory.
    ID_DELETED = 7;         % Indicates that the segment has been deleted (dropped) and should be skipped.
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
    obj = readMetadata(obj);   %IMPLEMENTED IN SEPARATE FILE
    obj = readRawFileSegm(obj);   %IMPLEMENTED IN SEPARATE FILE
  end
  
end

