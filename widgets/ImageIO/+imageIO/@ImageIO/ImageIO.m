classdef (Abstract = true) ImageIO < handle
    %IMAGEIO read/write various image formats
    %   use BioFormats
    %   use TIFF lib
    %   metadata
    
    
    %% --- Metadata Properties --- %%%
    properties (SetAccess = protected)
        fileName = '';          % Image filename
        fileFullPath = '';      % Full filename, together with absolute path
        fileFolder = '';        % Folder containing the image
        fileExt = '';           % File extension
        
        height = nan;           % Image height / number of rows
        width = nan;            % Image width / number of columns
        channels = nan;         % Number of image channels
        stacks = nan;           % Image stacks (Z axis)
        series = nan;           % number of series
        time = nan;             % Image timeseries
        tile = nan;             % Image tiles per stack
        numTilesRow = nan;      % Image tiles in vertical direction
        numTilesCol = nan;      % Image tiles in horizontal direction
        rowTilePos = nan;       % vertical position of tile
        colTilePos = nan;       % horizontal position of tile
        pixPerTileRow = nan;    % number of rows of pixels in a tile
        pixPerTileCol = nan;    % number of cols of pixels in a tile
        tileOverlap = nan;      % overlap between 2 adjacent tiles
        
        channelInfo;            % (if available) color info of each channel
        
        data_type = '';         % Image datatype (uint8, int16, ...)
        
        pixelSizeX;             % Pixel physical size along X axis
        pixelSizeY;             % Pixel physical size along Y axis
        pixelSizeZ;             % Pixel physical size along Z axis
        
        scale_size %x,y,z,t
        scale_units
        scale_time
        
        time_pixel
        time_line
        time_frame
        time_stack
        
        zoom = nan;
        gain = nan;
        
        wavelengthExc = nan;
        wavelengthEm = nan;
        refraction_media
        NA = nan;               % Numerical aperture
        
        microscope_name = '';
        microscope_type = '';
        
        objective_magnification;
        objective_name;
    end
    
    properties (Constant = true)
      VERSION = '0.1';
      DIMORDER = 'XYCZT'; 
    end
    
    methods
      function obj = ImageIO(filename)
      %IMAGEIO ImageIo Constructor
      %Performs basic assignments common to all classes
      % INPUT
      %   filename: The file to open, a char array
      % OUTPUT
      %   obj: the returned ImageIO object
      % SEE ALSO
      %   imageIO.readBIO, imageIO.TiffReader
      
        p = inputParser;
        p.addRequired('filename', @(x) ischar(x))
        
        p.parse(filename);
        
        obj.fileFullPath = GetFullPath(filename);
        [obj.fileFolder, obj.fileName, obj.fileExt] = fileparts(obj.fileFullPath);
      end
      
      function [major, minor] = getVersion(object)
      %GETVERSION Gets the class version
      %Returns the class version as two parameters one is the major
      %(used for releases) and one is the minor, used for small incremental
      %improvements
        C = strsplit(object.VERSION, '.');
        if length(C) ~= 2
          error('ImageIO.getVersion: Error parsing version string')
        end
        major = str2double(C{1});
        minor = str2double(C{2});
      end
    end
    
    methods (Abstract = true)
    % Here we have the methods that each subclass MUST implement
      close(obj);
      %obj = readMetadata(obj);
    end
    
    methods (Access = protected)
    end
    
end

