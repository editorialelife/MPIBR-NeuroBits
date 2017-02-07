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

