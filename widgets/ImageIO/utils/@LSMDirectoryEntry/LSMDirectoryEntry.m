classdef LSMDirectoryEntry
%CZIDIMENSIONENTRY Implementation of the Directory Entry schema
%   The class represents the information stored in the 12 bytes of a 
%   Directory Entry schema, according to the LSM File Format specification
%
% AUTHOR: Stefano Masneri
% Date: 13.3.2017
  
  properties
    tag;
    type;
    length;         % number of values in value
    value;          % File offset to the start of the values. If the values
                    % require not more than 4 bytes, the values itself rather
                    % than an offset are stored in the location value
  end
  
  properties (Constant = true)
    % TIFF TAGS
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
    % DATA TYPE
    TIF_BYTE = 1;
    TIF_ASCII = 2;
    TIF_SHORT = 3;
    TIF_LONG = 4;
    TIF_RATIONAL = 5;
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
    
      obj.tag = fread(lsmPtr, 1, 'uint16', byteOrder);
      obj.type = fread(lsmPtr, 1, 'uint16', byteOrder);
      obj.length = fread(lsmPtr, 1, 'uint32', byteOrder);
      obj.value = fread(lsmPtr, 1, 'uint32', byteOrder);
    end
  end
  
end

