classdef LSMReader < imageIO.ImageIO
  %LSMREADER Class used to read LSM files
  %   This class implements a Matlab API for reading files specified using
  %   the LSM file format (available here ../../docs/ImageFileFormatDescriptionLSM.pdf).
  %   The constructor of the class will do the heavy part of the job,
  %   namely parsing the header and segment files in order to extract the
  %   metadata required by the ImageIO library.
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 13.03.2017
  %   SEE ALSO: imageIO.imageIO
  
  properties
    lsmPtr = 0;              % Pointer to the LSM file (returned by fopen)
    verbose = false;         % set to true only when displaying additional inf
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
    %     'C', 'Z', 'T', 'S', 'TileRows', 'TileCols'
    % OUTPUT
    %   data: image data, up to 6 dimension (in this order: XYCZTS). If only one
    %   	channel is extracted (or the input is single channel), the singleton
    %   	dimension relative to channel is squeezed.
    % EXAMPLES
    %   myCZI = imageIO.CZIReader('testfile.czi');
    %   data = myCZI.getData(); %Reads all the data
    %   data = myCZI.getData('Cols', 1:10) %Reads only the first then rows
    %   data = myCZI.getData('Cols', 1:2:end) %Reads only the odd rows
    %   data = myCZI.getData('C', 1, 'Z', 4:8) %Reads stacks 4 to 8, only 1st channel
    %   data = myCZI.getData('TileRows', 1:6, 'TileCols, 2:4) %Reads first six rows of
    %     tiles, and column tiles from 2 to 4
    
      if isempty(varargin) % Read all the data
        data = obj.getAllData();
      elseif 1 == obj.tile
        data = obj.getDataNoTiles(varargin{:});
      else
        data = obj.getTiledData(varargin{:});
      end
    end
    
    data = getAllData(obj);       % IMPLEMENTED IN SEPARATE FILE
    
  end
  
  methods (Access = protected)
    obj = readMetadata(obj);      % IMPLEMENTED IN SEPARATE FILE
  end
  
end

