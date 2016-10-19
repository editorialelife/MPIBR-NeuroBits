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
    filePtr;         % pointer to a file. Used in some special cases
    % Other properties. Assuming that for multistack images they remain
    % constant over the stack
    XResolution;    % resolution on horizontal axis
    YResolution;    % resolution on vertical haxis
    resolutionUnit; % unit of measurement for resolution (none, inch, centimeter)
    bps;            % bits per sample used
    colormap;       % colormap used. Empty array if none
    compression;    % compression scheme used
    
    tagNames;       % Cell of available tags. Useful if the user wants to access 
                    % additonal metadata
    isImageJFmt;    % true if the Tiff is non-standard and was created via imageJ
    offsetToImg;    % offset to first image in the stack. Used only if isImageJFmt is true
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
      
      % Is a valid Tiff as default behaviour
      obj.isImageJFmt = false;
      
      % Use Matlab interface
      obj.tiffPtr = Tiff(obj.fileFullPath, 'r');
      
      % Set as many properties from the superclass as possible
      obj = obj.readMetadata();
      
      if obj.isImageJFmt % handle file differently
        obj.filePtr = fopen(obj.fileFullPath);
        fseek(obj.filePtr, obj.offsetToImg, 'bof');
      end
    end
    
    function data = read(obj)
    %READ read all the image data
    %This function reads all the planes of the image. If the file has
    %only one plane just returns that.
    % INPUT
    %   
    % OUTPUT
    %   data: the whole image content
      
      data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.datatype);
      
      if obj.isImageJFmt
        fseek(obj.filePtr, obj.offsetToImg, 'bof');
        imageSize = obj.height * obj.width * obj.channels;
        precision = [ obj.datatype '=>'  obj.datatype ];
        for k = 1:obj.stacks
          image = fread(obj.filePtr, imageSize, precision);
          image = reshape(image, [obj.width, obj.height, obj.channels]);
          data(:, :, :, k) = image';
        end
      else
        for k = 1:obj.stacks
          data(:, :, :, k) = obj.readImage(k);
        end
      end
      
    end
    
    function img = readImage( obj, n )
    %READIMAGE read one image plane
    %This function reads one single plane of the image. If the file has
    %only one plane just returns that.
    % INPUT
    %   n the directory (aka the plane) to read. If bigger than the number
    %     of stacks, issue a warning and return an empty array. If not
    %     specified, return the image in the current directory
    % OUTPUT
    %   img the image just read
    
      if ~obj.isImageJFmt
        if 1 == nargin % n not specified
          img = obj.tiffPtr.read();
        elseif n > obj.stacks
          warning('TiffReader.readImage: Cannot read image. n is bigger than the number of stacks')
          img = [];
        else % valid n
          obj.tiffPtr.setDirectory(n);
          img = obj.tiffPtr.read();
        end
      else
        imageSize = obj.height * obj.width * obj.channels * obj.bps / 8;
        if n > obj.stacks
          warning('TiffReader.readImage: Cannot read image. n is bigger than the number of stacks')
          img = [];
        else
          if nargin > 1 % n specified
            fseek(obj.filePtr, obj.offsetToImg + (k-1)*imageSize, 'bof');
          end
          img = fread(obj.filePtr, imageSize, obj.datatype);
          img = reshape(img, [obj.height, obj.width, obj.channels]);
        end
      end
    end
  
    function close(obj)
    %CLOSE Close object instances.
    %Close performs the cleanup and release of the instantiated object
      obj.tiffPtr.close();
      if obj.filePtr > 0
        fclose(obj.filePtr);
      end
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
        obj.channels = length(imgInfo(1).BitsPerSample);
        obj.time = nan; % Or should we set 1?
        obj.tile = 1;   % Standard TIFF does not have multitiled images
        obj.XResolution = imgInfo(1).XResolution;
        obj.YResolution = imgInfo(1).YResolution;
        obj.colormap = imgInfo(1).Colormap;
      catch ME
        error('TiffReader.TiffReader: Cannot read metadata. %s', ME.message)
      end
      % now use the Tiff pointer
      obj.compression = obj.tiffPtr.Compression;
      obj.tagNames = obj.tiffPtr.getTagNames;
      % retrieve datatype
      sampleFormat = obj.tiffPtr.getTag('SampleFormat');
      obj.bps = obj.tiffPtr.getTag('BitsPerSample');
      switch sampleFormat
        case 1 % UInt
          obj.datatype = ['uint' num2str(obj.bps)];
        case 2 % Int
          obj.datatype = ['int' num2str(obj.bps)];
        case 3 % IEEEFP
          if 64 == obj.bps
            obj.datatype = 'double';
          elseif 32 == obj.bps
            obj.datatype = 'float';
          else
            warning('TiffReader.readMetadata: unrecognized BitsPerSample value')
          end
        otherwise  % Void or complex types are unsupported
        warning('TiffReader.readMetadata: unsupported sample format')
      end
      
      % check for custom ImageJ multitiff format -_-'
      try
        imageDesc = obj.tiffPtr.getTag('ImageDescription');
      catch
        imageDesc = '';
      end
      if length(imageDesc) > 7 && strcmpi('ImageJ', imageDesc(1:6))
        % look for number of images
        obj.isImageJFmt = true;
        k = strfind(imageDesc, 'images=');
        m = strfind(imageDesc, sprintf('\n'));
        m = m(m>k);
        if ~isempty(k)
          obj.stacks = str2double(imageDesc(k(1)+7 : m(1)));
        end
      end
      
      if obj.isImageJFmt
        off = obj.tiffPtr.getTag('StripOffsets');
        obj.offsetToImg = off(1);
      end
    end
  end
  
end

