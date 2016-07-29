classdef ImageIO < handle
    %IMAGEIO read/write various image formats
    %   use BioFormats
    %   use TIFF lib
    %   metadata
    
    
    %% --- Metadata Properties --- %%%
    properties
        fileName = '';          % Image filename
        fileFullPath = '';      % Full filename, together with absolute path
        fileFolder = '';        % Folder containing the image
        data = [];              % TODO Do we really want to have the data???
        
        height = nan;           % Image height / number of rows
        width = nan;            % Image width / number of columns
        channels = nan;         % Number of image channels
        stacks = nan;           % Image stacks (Z axis)
        time = nan;             % Image timeseries
        tile = nan;             % Image tiles per stack
        
        data_type = '';         % Image datatype (uint8, int16, ...)
        
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
        
        objective_magnification
        objective_name 
    end
    
    properties (Constant = true)
      VERSION = '0.1'
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
      %   readBIO
      
        p = inputParser;
        p.addRequired('filename', @(x) ischar(x))
        
        p.parse(filename);
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
    end
    
    methods (Access = protected)
    end
    
end

