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
    rowIndex;                % maps the absolute Y position of the subblock to 
                             % the index row position in the tiled image
    colIndex;                % maps the absolute X position of the subblock to 
                             % the index column position in the tiled image
    wrongMetadata = false;   % set to true if the information acquired from the 
                             % metadata block and the directory block is
                             % contradictory
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
    
    function data = getData(obj, varargin)
    %GETDATA extracts image data
    % This function reads data from the bioformat file. If no parameters
    % are specified for a specific dimension, all the data will be
    % extracted.
    % INPUT
    %   obj: class instance
    %   varargin: Name-Value arguments. Allowed parameters are 'X', 'Y',
    %     'C', 'Z', 'T', 'S', 'TileRows', 'TileCols'
    % OUTPUT
    %   data: image data, up to 6 dimension (in this order: XYCZTS). If only one
    %   	channel is extracted (or the input is single channel), the singleton
    %   	dimension relative to channel is squeezed.
    % EXAMPLES
    %   myCZI = CZIReader('testfile.czi');
    %   data = myCZI.getData(); %Reads all the data
    %   data = myCZI.getData('X', 1:10) %Reads only the first then rows
    %   data = myCZI.getData('X', 1:2:end) %Reads only the odd rows
    %   data = myCZI.getData('C', 1, 'Z', 4:8) %Reads stacks 4 to 8, only 1st channel
    %   data = myCZI.getData('TileRow', 1:6, 'TileCol, 2:4) %Reads first six rows of
    %     tiles, and column tiles from 2 to 4
    
      if isempty(varargin) % Read all the data
        data = obj.getAllData();
      elseif 1 == obj.tile
        data = obj.getDataNoTiles(varargin{:});
      else
        data = obj.getTiledData(varargin{:});
      end
    end
  end

  methods
    data = getAllData(obj);                   % IMPLEMENTED IN SEPARATE FILE
  end
  
  methods (Access = protected)
    obj = readRawFileSegm(obj);               % IMPLEMENTED IN SEPARATE FILE
    obj = readRawDirSegm(obj);                % IMPLEMENTED IN SEPARATE FILE
    [data, obj] = readRawSubblockSegm(obj, varargin); % IMPLEMENTED IN SEPARATE FILE
    obj = readRawMetadataSegm(obj);           % IMPLEMENTED IN SEPARATE FILE
    obj = readRawAttachSegm(obj);             % IMPLEMENTED IN SEPARATE FILE   
  end
  
end

