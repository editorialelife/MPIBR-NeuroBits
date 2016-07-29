classdef TiffWriter < imageIO.ImageIO
  %TIFFWRITER Wrapper for Tiff interface, based on libTIFF library
  %   This class is a single wrapper around libTiff class and the mex files
  %   developed to perform fast writing of multiplane Tiff files, adapted 
  %   to conform to the structure of the imageIO library. This class does
  %   not implement the whole TIFF standard but only a subset. Furthermore,
  %   mex files exist only for Windows and Linux, 64 bit versions. When no
  %   fast method is available (e.g. for logicals, float 32 bit or BigTiff)
  %   the class reverts to the Matlab slow implementation.
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 29.07.2016
  %   SEE ALSO: imageIO.TiffReader, Tiff, 
  
  properties
    XResolution;    % resolution on horizontal axis
    YResolution;    % resolution on vertical haxis
    resolutionUnit; % unit of measurement for resolution (none, inch, centimeter)
    
    colormap;       % colormap used. Empty array if none
    compression;    % compression scheme used
    
    isRGB;          % true if the image is RGB
    isBig;          % true if the data to write is bigger than 4Gb
  end
  
  methods
    function obj = TiffWriter(varargin)
    %TIFFWRITER Constructor of the class
    %The constructor calls the constructor of the superclass, and then
    %parses the input in order to get the information required to write the
    %data. The constructor tries to be consistent with the (horrible)
    %syntax that matlab uses in imread, that is adding an optional "map"
    %parameter before the filename, followed by some Name-Value pairs. The
    %function parseArgs takes care of this.
    % SYNTAX:
    %   obj = imwritetiff( filename, varargin )
    %     filename is the only mandatory parameter. If no other
    %     parameters are specified, the function uses the default ones.
    %   obj = imwritetiff( map, filename, varargin ) 
    %     alternative where the user specifies a colormap as the first
    %     argument.
    % INPUT:
    %   filename the filename used to save data on disk
    %   numImages total number of images that should be written to file
    %   close (true/false): The file will only be closed if close  is set to true
    %     By default close is false and the file is left open for further write
    %     operations. In this case the user has to call obj.close() 
    %     once he is done with writing to this file.
    %   compression compression used when saved images. default is 'lzw',
    %     other values allowed are 'none', 'lzw', 'deflate', 'packbits'
    %   writeMode file opening mode. Default is 'create' (to create a new file).
    %     Other accepted values are 'append', to append to a file previously
    %     closed, or 'write' to add data to an already opened file. PLEASE NOTE
    %     that calling 'append' on a file which was already opened will close
    %     the file and then re-open it, losing the advantages of fast tiff
    %     writing. If the file is already opoened the correct behaviour is to
    %     use the 'write' mode.
    %   isRGB explicitly specifies if the data should be saved as an RGB color
    %     image. Default is false.
    %   checkExistence (true/false) specifies if checks should be performed for the existance
    %     of the file to a) warn if it is overwritten and b) create it if 
    %     writemode write is used on a nonexisting file. 
    %     Can be very timeconsuming on large folder and can therefore be turned
    %     off. Default true.
    %   isBig boolean specifying whether the final files will be bigger than 4
    %     Gb. Default false
    %   resolution A two-element vector containing the XResolution and YResolution,
    %     or a scalar indicating both resolutions; the default value is 72
    %   resolutionUnit Specifies the unit used to specify the resolution
    %     parameter. Can be 'inch', 'centimeter', 'cm', 'millimeter', 'mm', 'micrometer',
    %     'um', or 'unknown' (the default)
    % OUTPUT:
    %   obj the constructed object
    %SEE ALSO imageIO.ImageIO.ImageIO, TiffWriter.parseArgs
    
      %
    
      % Must call explictily because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      % parse input
      p = inputParser;
    end
    
  end
  
  methods (Static = true)
    function close()
      %CLOSE Close object instances.
      %Close performs the cleanup and release of the instantiated object.
      %This method is static because the fast method fro writing Tiff
      %requires that at most one file is open at the same time, so calling
      %the close will just close the instance opened, indipendently from
      %what the user has been doing
      multitiff.close();
    end
  end
  
end

