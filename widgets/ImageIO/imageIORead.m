function [data, imgPtr] = imageIORead( file, varargin )
%IMAGEIOREAD Main function for reading image data using imageIO library
%   Imageioread provides a single interface for reading image data using
%   any of the classes specified in the +imageIO package. The easiest way
%   to use the function is to pass a filename as argument: the function
%   will return the whole content of the image. Several arguments can be
%   passed to restrict the amount of data returned by the function or, in
%   case the user passed a folder as input, to specify the file pattern of
%   the images to be read in the folder. When the user specifies a second
%   output argument the function returns also the image reader object,
%   which can be used later to read other data without requiring to parse
%   again the file to extract all the metadata information
% 
% INPUT:
%   file: [mandatory] the input image to be read or a folder containing a collection of
%     tiff images 
%   filePattern: [optional] used only when 'file' is a directory.
%     Specifies the pattern used to number the images. It uses the same
%     formatting rules used by Matlab and C 'sprintf' function. For example, 
%     if the folder contains files like 'img_001.tif', 'img_002.tif' and so on, 
%     the file pattern will be 'img_%03d.tif'. A more complicated
%     pattern could be 'img_UII%02dX%02d_%02d_xyz-Table_%04d.ome.tif',
%     where there are four number representing the X/Y tile position,
%     the channel and the Z value. If no pattern is specified, it is
%     assumed that the images represent a Z stack whose order is
%     determined by alphabetical sorting of the filenames
%   dimensionOrder: [optional] used only when 'file' is a directory.
%     Represents the order of the dimensions presented in the file
%     pattern. Valid values could be 'Z', 'XYCZ', 'T'. If not specified,
%     the value depends on the number of format tags in the file
%     pattern: if 0 or 1 format tags specified, it will be 'Z', if 2
%     format tags specified, it will be 'XY', if 3 tags specified, it
%     will be 'XYC', if four tags specified, it will be 'XYCZ'. With
%     five tags, it will be 'XYCZT'
%   overlap: [optional] used only when 'file' is a directory.
%     Expected overlap (in percentage) between the tiles. If 'file' is not
%     a directory, the value is inferred by the metadata contained in the
%     file and, in that case, any user provided value would be overridden.
%     If not specified, assumes 0
% NAME-VALUE INPUT ARGUMENTS:
%   Used to extract parts of the data.The user can specify subset
%   of the images by specifying the dimension and the interval of interest
%   as a Name-Value pair. If no arguments are given, all the data is
%   extracted. For the Cols and Rows argument, the interval is intented
%   per-tile. For example, if the user wants to keep only the top left tile,
%   he won't specify any subset for 'Rows' and 'Cols' (that is, take them all),
%   but will specify the subset 'TileRow' = 1 and 'TileCol' = 1. On the other
%   hand, if the user wants to extract from a 800*600 image a version which
%   is subsampled by a factor 2 he will specify Rows = 1:2:600
%   and Cols = 1:2:800, and no subset for the tiles (i.e. use
%   all tiles).
%   'Cols': Specify which columns to extract
%   'Rows': Specify which rows to extract
%   'Channel': Specify which channels to extract
%   'Stack': Specify which planes to extract
%   'Time': Specify which timeseries to extract
%   'TileRow': Specify which row tiles to read.
%   'TileCol': Specify which col tiles to read.
% OUTPUT:
%   data: image data, up to 5 dimension (in this order: XYCZT). If only one
%   	channel is extracted (or the input is single channel), the singleton
%   	dimension relative to channel is squeezed.
%   imgPtr: imageIO instance (actually instance of a subclass of imageIO)
%     that can be used to extract other data or access the image properties
%     and metadata
% EXAMPLES:
%   Reading all the content from single files:
%     tiffData = imageIORead('myTiff.tif');
%     cziData = imageIORead('aCZIFile.czi');
%   Reading a Z stack from a folder
%     tiffStack = imageIORead('folderWithImages'); % no need to specify pattern
%     tiffStack = imageIORead('folderWithImages', 'Stack', 100:150); % subset
%   Reading complex datasets from a folder
%     multiChTiffStack = imageIORead('folder', 'filePattern_Ch_%d_Z_%04d.tif', 'CZ');
%   Reading a subset from complex datasets from a folder
%     multiChTiffStack = imageIORead('folder', 'filePattern_Pos_%02dx%02d_Ch_%d_Z_%04d.tif', ...
%       'YXCZ', 'Channel', 2, 'TileRow', 1:2, 'TileCol', 1:3);
%   Read from file of size 4000x3000, subset of a factor 4, only first and third channel
%     bioReaderData = imageIORead('sample.lsm', 'Channel', [1 3], 'Cols', ...
%       1:4:4000, 'Rows', 1:4:3000);
% DATE: 02.12.2016
% AUTHOR: stefano.masneri@brain.mpg.de
%
% SEE ALSO:
%   imageIO, imageIO.imageIO, imageIO.TiffReader, imageIO.BioReader, 
%   imageIO.CZIReader, imageIO.TiffDirReader


end

