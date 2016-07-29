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
    tifPtr;         % pointer to a Matlab Tiff class
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
      obj.tifPtr = Tiff(obj.fileFullPath, 'r');
    end
  
    
    
    function close(obj)
    %CLOSE Close object instances.
    %Close performs the cleanup and release of the instantiated object
      obj.tifPtr.close();
    end
  end
  
end

