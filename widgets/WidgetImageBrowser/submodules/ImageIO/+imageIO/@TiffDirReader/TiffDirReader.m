classdef TiffDirReader < ImageIO
  %TIFFDIRREADER Reads a collection of images from a folder
  %   This class creates an image from a collection of pictures in a
  %   folder. The class considers only tiff files inside the folder and
  %   inspects the filenames to extract information about what each file
  %   represents. 
  %
  %   Author: Stefano.Masneri@brain.mpge.de
  %   Date: 30.11.2016
  %   SEE ALSO: imageIO.TiffDirReader.TiffDirReader, imageIO.ImageIO, 
  %     imageIO.TiffReader, imageIO.TiffWriter, Tiff
  
  properties
    tiffPtrs;       % array of pointers to tiff files
    filePattern;    % string representing the file pattern
    dimensionOrder; % order used in the filenames to represent different dimensions
  end
  
  methods
    function obj = TiffDirReader(folder, filePattern, dimensionOrder)
    %TIFFDIRREADER Class constructor
    %The constructor checks at first if the user provided a directory as argument. 
    % If no directory is passed, a gui asks the user to select a directory.
    % The user can also specify a file pattern, which will later be used to 
    % choose the appropriate number of channels, Z stacks and so on. If no
    % pattern is provided, the class will assume that the folder will
    % contain images representing a volume containing as many Z slices as
    % files, with just one channel and one tile. 
    % INPUT
    %   folder: the folder containing tiff files 
    %   filePattern: the pattern used by the images. For example, if the
    %     folder contains files like 'img_0001.tif', 'img_0002.tif' and so on, 
    %     the file pattern will be 'img_%04d.tif'. A more complicated
    %     pattern could be 'img_UII%02dX%02d_%02d_xyz-Table_%04d.ome.tif',
    %     where there are four number representing the X/Y tile position,
    %     the channel and the Z value. If no pattern is specified, it is
    %     assumed that the images represent a Z stack whose order is
    %     determined by alphabetical sorting of the filenames
    %   dimensionOrder: the order of the dimensions presented in the file
    %     pattern. If not specified, the value depends on the number of
    %     format tags in the file pattern. Valid values could be 'Z',
    %     'XYCZ', 'T'
    % OUTPUT
    %  obj: the TiffDirReader object
    
      % args check
      if nargin > 3
        disp('TiffDirReader: All arguments after the 3rd will be ignored')
      end
      if 0 == nargin
        folder = uigetdir('', 'Select folder containing tiff images:');
        if isequal(folder, 0)
          error('TiffDirReader: You must select a folder!')
        end
      end
      if nargin >= 2
        obj.filePattern = filePattern;
      else
        obj.filePattern = '';
      end
      if nargin >= 3
        obj.dimensionOrder = dimensionOrder;
      else
        obj.dimensionOrder = '';
      end
      
      %set filename properties
      obj.fileFullPath = GetFullPath(folder);
      obj.fileFolder = folder;
      obj.fileName = folder;
      obj.fileExt = '';
    end
  end
  
  methods (Access = protected)
    
  end
  
end

