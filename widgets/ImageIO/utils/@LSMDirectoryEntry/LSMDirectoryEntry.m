classdef LSMDirectoryEntry
%CZIDIMENSIONENTRY Implementation of the Directory Entry schema
%   The class represents the information stored in the 12 bytes of a 
%   Directory Entry schema, according to the LSM File Format specification
%
% AUTHOR: Stefano Masneri
% Date: 13.3.2017
  
  properties
  end
  
  properties (Constant = true)
    TIF_NEWSUBFILETYPE = 254;
    TIF_IMAGEWIDTH = 256;
    TIF_IMAGELENGTH = 257;
    TIF_BITSPERSAMPLE = 258;
    TIF_COMPRESSION = 259;
    TIF_PHOTOMETRICINTERPRETATION = 262;
    TIF_STRIPOFFSETS = 273;
    TIF_SAMPLESPERPIXEL = 277;
    TIF_STRIPBYTECOUNTS = 279;
    TIF_PLANARCONFIGURATION = 284;
    TIF_PREDICTOR = 317;
    TIF_COLORMAP = 320;
    TIF_CZ_LSMINFO = 34412;
  end
  
  methods
    function obj = LSMDirectoryEntry()
      %LSMDIRECTORYENTRY Constructor
      %Does nothing
    end
    
    function obj = init(obj, lsmPtr, byteOrder)
    %INIT initializes the LSMDirectoryEntry object
    % The function reads from file the fields related to the
    % Director yEntry
    % INPUT
    %   lsmPtr: file identifier of the lsm file. It is assumed that the
    %     position in the file is at the start at the Directory Entry
    %     field
    % OUTPUT
    %   obj: the instance of the class 
    end
  end
  
end

