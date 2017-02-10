classdef LSMReader < imageIO.ImageIO
  %LSMREADER Class used to read LSM files
  %   This class implements a Matlab API for reading files specified using
  %   the LSM file format. The class relies on some existing implementations, 
  %   available in the Matlab FEX:
  %   http://www.mathworks.com/matlabcentral/fileexchange/8412-lsm-file-toolbox)
  %   for the metadata part
  %   http://www.mathworks.com/matlabcentral/fileexchange/46892-zeiss-laser-scanning-confocal-microscope-lsm-file-reader
  %   for reading the actual data content
  %   The constructor of the class will do the heavy part of the job,
  %   namely parsing the header and segment files in order to extract the
  %   metadata required by the ImageIO library.
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 06.02.2017
  %   SEE ALSO: imageIO.imageIO
  
  properties
    lsmPtr = 0;     % pointer to the lsm file
    byteOrder;      % big endian or little endian
    IFD;            % directory entries
    offsets;        % offset associated to each IFD
    bigTiff;        % true if the file is bigger than 4Gb
    datatypeInput;  % LSM format also supports 12 bits, unsupported by Matlab
  end
  
  properties (Constant = true)
    LSMTAG = 34412;
  end
  
  methods
    
    function obj = LSMReader(filename)
    %LSMREADER Constructor of the class
    %The constructor calls the constructor of the superclass, and then
    %tries to parse the file to extract as much information as
    %possible from the file. No actual data is read in the constructor
    %SEE ALSO imageIO.ImageIO.ImageIO
      
      % Must call explicitly because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      % Set as many properties from the superclass as possible
      obj = obj.readMetadata();
    end
    
    function delete(obj)
    %DELETE close the file identifier  
      if obj.lsmPtr
        fclose(obj.lsmPtr);
      end
    end
    
    function data = read(obj, varargin)
    %READ extracts image data
    % This function reads data from the LSM file. If no parameters
    % are specified for a specific dimension, all the data will be
    % extracted.
    % INPUT
    %   obj: class instance
    %   varargin: Name-Value arguments. Allowed parameters are 'Cols', 'Rows',
    %     'C', 'Z', 'T', 'TileRows', 'TileCols'
    % OUTPUT
    %   data: image data, up to 5 dimension (in this order: XYCZT). If only one
    %   	channel is extracted (or the input is single channel), the singleton
    %   	dimension relative to channel is squeezed.
    % EXAMPLES
    %   myLSM = imageIO.LSMReader('testfile.czi');
    %   data = myLSM.getData(); %Reads all the data
    %   data = myLSM.getData('Cols', 1:10) %Reads only the first then rows
    %   data = myLSM.getData('Cols', 1:2:end) %Reads only the odd rows
    %   data = myLSM.getData('C', 1, 'Z', 4:8) %Reads stacks 4 to 8, only 1st channel
    %   data = myLSM.getData('TileRows', 1:6, 'TileCols, 2:4) %Reads first six rows of
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
  
  methods (Access = protected)
    
    ifd = ifdread(obj);       % Implemented in separate file
    obj = readMetadata(obj);  % Implemented in separate file
    
    function obj = setChannelInfo(obj, chanInfo)
      for k = 1:obj.channels
        chanData = struct('name', chanInfo.names{k}, 'color', chanInfo.colors{k});
        obj.channelInfo = [obj.channelInfo, ChannelInfo(chanData, 'LSM')];
      end
    end
    
  end
  
end

