classdef SifReader < imageIO.ImageIO
  %SIFREADER Class used to read .sif image files
  %   This class is a wrapper around the mex file used to read .sif files.
  %   The mex file is provided only for windows, so the constructor will
  %   raise an error when called from mac or linux. The code is based
  %   on what has been implemented by Marcel.Lauterbach@brain.mpg.de for
  %   its function imread_universal.m
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 16.01.2017
  %   SEE ALSO: imageIO.imageIO
  
  properties
    useAndorMex; % if on windows, true --> use Andor wrapper
  end
  
  properties (Constant = true)
    % ANDOR API CONSTANTS
    ATSIF_ReadAll = 0;
    ATSIF_ReadHeaderOnly = 1; 
    % ANDOR API RETURN codes
    ATSIF_SUCCESS = 22002;
    ATSIF_SIF_FORMAT_ERROR = 22003;
    ATSIF_NO_SIF_LOADED = 22004;
    ATSIF_FILE_NOT_FOUND = 22005;
    ATSIF_FILE_ACCESS_ERROR = 22006;
    ATSIF_DATA_NOT_PRESENT = 22007;
  end
  
  methods
    function obj = SifReader(filename)
      % SIFREADER Constructs the BioReader object
      % The constructor calls the superclass constructor and then tries to
      % extract as many metadata as possible
      
      % Must call explicitly because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      % Check OS, will be used to decide how to extract data
      if ispc
        obj.useAndorMex = true;
        openWin(filename);
      else
        warning('SifReader: Reading data on Linux / Mac can fail or be inaccurate')
        obj.useAndorMex = false;
      end
      
      % Get metadata
      obj = obj.readMetadata();
    end
  end
  
  methods (Access = protected)
    function obj = readMetadata(obj)
    %READMETADATA Read all object metadata
    end
    
    function close(obj)
    %CLOSE close the file identifier  
      if obj.useAndorMex
        atsif_closefile;
      else
        %TODO
      end
    end
    
    function openWin(filename)
      atsif_setfileaccessmode(obj.ATSIF_ReadAll);
      
    end
  end

  
end

