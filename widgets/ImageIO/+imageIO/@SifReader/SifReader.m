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
  end
  
  properties (Constant = true)
    % ANDOR API codes
    ATSIF_SUCCESS = 22002;
    ATSIF_SIF_FORMAT_ERROR = 22003;
    ATSIF_NO_SIF_LOADED = 22004;
    ATSIF_FILE_NOT_FOUND = 22005;
    ATSIF_FILE_ACCESS_ERROR = 22006;
    ATSIF_DATA_NOT_PRESENT = 22007;
  end
  
  methods
  end
  
end

