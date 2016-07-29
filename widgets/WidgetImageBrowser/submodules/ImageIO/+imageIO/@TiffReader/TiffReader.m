classdef TiffReader < imageIO.ImageIO
  %TIFFREADER Wrapper for Tiff interface, based on Matlab TIFF class
  %   This class is just a single wrapper around Matlab Tiff class, adapted
  %   to conform to the structure of the imageIO library. Unlike
  %   TiffWriter, this class does not interface directly with the Tiff
  %   library, since no speed-ups are expected compared to the Matlab
  %   version.
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 29.07.2016
  %   SEE ALSO: imageIO.TiffWriter, Tiff
  
  properties
    tiffPtr;         % pointer to a Matlab Tiff class
    
    % Other properties. Assuming that for multistack images they remain
    % constant over the stack
    XResolution;    % resolution on horizontal axis
    YResolution;    % resolution on vertical haxis
    resolutionUnit; % unit of measurement for resolution (none, inch, centimeter)
    
    colormap;       % colormap used. Empty array if none
    compression;    % compression scheme used
    
    tagNames;       % Cell of available tags
  end
  
  methods
    function obj = TiffReader(filename)
    %TIFFREADER Constructor of the class
    %The constructor calls the constructor of the superclass, and then
    %tries to parse the Tiff tags to extract as much information as
    %possible from the file. No actual data is read in the constructor
    %SEE ALSO imageIO.ImageIO.ImageIO
      
      % Must call explictily because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      % Use Matlab interface
      obj.tiffPtr = Tiff(obj.fileFullPath, 'r');
      
      % Set as many properties from the superclass as possible
      obj = obj.readMetadata();
    end
  
    function close(obj)
    %CLOSE Close object instances.
    %Close performs the cleanup and release of the instantiated object
      obj.tiffPtr.close();
    end
  end
  
  methods (Access = protected)
    function obj = readMetadata(obj)
      %First get usual info with imfinfo
      try
        imgInfo = imfinfo(obj.fileFullPath);
        obj.stacks = length(imgInfo);
        obj.height = imgInfo(1).Height;
        obj.width = imgInfo(1).Width;
        obj.channel = length(imgInfo(1).BitsPerSample);
        obj.time = nan; % Or should we set 1?
        obj.tile = 1;   % Standard TIFF does not have multitiled images
        obj.XResolution = imgInfo(1).XResolution;
        obj.YResolution = imgInfo(1).YResolution;
        obj.colormap = imgInfo(1).Colormap;
      catch ME
        error('TiffReader.TiffReader: Cannot read metadata. %s', ME.message)
      end
      % now use the Tiff pointer
      obj.compression = obj.tiffPtr.compression;
      obj.tagNames = obj.tiffPtr.getTagNames;
      % retrieve datatype
      sampleFormat = obj.tiffPtr.getTag('SampleFormat');
      bps = obj.tiffPtr.getTag('BitsPerSample');
      switch sampleFormat
        case 1 % UInt
          obj.data_type = ['uint' num2str(bps)];
        case 2 % Int
          obj.data_type = ['int' num2str(bps)];
        case 3 % IEEEFP
          if 64 == bps
            obj.data_type = 'double';
          elseif 32 == bps
            obj.data_type = 'float';
          else
            warning('TiffReader.readMetadata: unrecognized BitsPerSample value')
          end
        otherwise  % Void or complex types are unsupported
        warning('TiffReader.readMetadata: unsupported sample format')
      end
    end
  end
  
end

