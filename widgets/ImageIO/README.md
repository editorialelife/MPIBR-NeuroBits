# ImageIO
**Reading and writing image data formats with MatLab.**

This library aims to implement a generic Matlab wrapper for several image format types. It uses existing libraries (such as Matlab's bindings for Bioformat), define Matlab wrappers for existing C libraries (such as TiffLib) or implements from scratch file format specifications (like CZI) to achieve the goal.

The library defines an abstract class called **imageIO** which defines the image metadata as well as a few methods which every subclass is required to implement.

There are two ways to use this library to read the data:

1. via class construction: based on the input data, the user selects the appropriate class to create an object instance representing the data. A later call to othe **read** method allows the user to extract the desired data.
2. using the **imageIORead** function: a function which accepts as input a filename will check the filetype and will create the appropriate object to extract the required data and metadata.

In both cases the user can specify a subset of the data to extract. For more info on how to get a subset of the input data, refer to the *Examples* section below or check the Matlab help for the **imageIORead.m** function

## APIs

The library relies on other software. In particular we use two APIs:

1. BioFormats (version 5.1.10)
2. TiffLib (version 4.0.5)

## Reading metadata

The *imageIO* class defines a set of common information and metadata about the input file: 

* fileName = '';          % Image filename
* fileFullPath = '';      % Full filename, together with absolute path
* fileFolder = '';        % Folder containing the image
* fileExt = '';           % File extension
* height = nan;           % Image height / number of rows
* width = nan;            % Image width / number of columns
* channels = nan;         % Number of image channels
* stacks = nan;           % Image stacks (Z axis)
* series = 1;             % number of series (assume it is usually one)
* time = nan;             % Image timeseries
* tile = nan;             % Image tiles per stack
* numTilesRow = nan;      % Image tiles in vertical direction
* numTilesCol = nan;      % Image tiles in horizontal direction
* rowTilePos = nan;       % vertical position of tile
* colTilePos = nan;       % horizontal position of tile
* pixPerTileRow = nan;    % number of rows of pixels in a tile
* pixPerTileCol = nan;    % number of cols of pixels in a tile
* tileOverlap = nan;      % overlap between 2 adjacent tiles
* channelInfo;            % (if available) color info of each channel
* datatype = '';          % Image datatype (uint8, int16, ...)
* scaleSize = nan;        % Pixel physical size (x,y,z)
* scaleUnits = nan;       % Unit of measurement of scaleSize
* scaleTime = nan;        
* timePixel = nan;        % Time it takes to acquire a single pixel
* timeLine = nan;         % Time it takes to acquire a single line of pixels
* timeFrame = nan;        % Time it takes to acquire a single frame
* timeStack = nan;        % Time it takes to acquire a stack 
* zoom = nan;
* gain = nan;
* wavelengthExc = nan;
* wavelengthEm = nan;
* refractionMedia = '';
* refractionIndex = nan;
* NA = nan;               % Numerical aperture
* microscopeName = '';
* microscopeType = '';
* objectiveMagnification = nan;
* objectiveName = nan;

## Example usage

For details regarding usage of specific classes, please check the Matlab documentation of each class in the **+imageIO** package.

Here's a description on how to use the **imageIORead** function:

**IMAGEIOREAD** Main function for reading image data using imageIO library
   *imageIORead* provides a single interface for reading image data using
   any of the classes specified in the +imageIO package.
   
   The easiest way to use the function is to pass a filename as argument: the function
   will return the whole content of the image. Several arguments can be
   passed to restrict the amount of data returned by the function or, in
   case the user passed a folder as input, to specify the file pattern of
   the images to be read in the folder.
   
   When the user specifies a second
   output argument the function returns also the image reader object,
   which can be used later to read other data without requiring to parse
   again the file to extract all the metadata information
 
**INPUT**:
   * file: [mandatory] the input image to be read or a folder containing a collection of
     tiff images 
   * filePattern: [optional] used only when 'file' is a directory.
     Specifies the pattern used to number the images. It uses the same
     formatting rules used by Matlab and C 'sprintf' function. For example, 
     if the folder contains files like 'img_001.tif', 'img_002.tif' and so on, 
     the file pattern will be 'img_%03d.tif'. A more complicated
     pattern could be 'img_UII%02dX%02d_%02d_xyz-Table_%04d.ome.tif',
     where there are four number representing the X/Y tile position,
     the channel and the Z value. If no pattern is specified, it is
     assumed that the images represent a Z stack whose order is
     determined by alphabetical sorting of the filenames
   * dimensionOrder: [optional] used only when 'file' is a directory.
     Represents the order of the dimensions presented in the file
     pattern. Each dimension is represented by a single character, uppercase.
     Valid values could be 'Z', 'XYCZ', 'T'. If not specified,
     the value depends on the number of format tags in the file
     pattern: if 0 or 1 format tags specified, it will be 'Z', if 2
     format tags specified, it will be 'XY', if 3 tags specified, it
     will be 'XYC', if four tags specified, it will be 'XYCZ'. With
     five tags, it will be 'XYCZT'
   * overlap: [optional] used only when 'file' is a directory.
     Expected overlap (in percentage) between the tiles. If 'file' is not
     a directory, the value is inferred by the metadata contained in the
     file and, in that case, any user provided value would be overridden.
     If not specified, assumes 0

**NAME-VALUE INPUT ARGUMENTS**:
   Used to extract parts of the data.The user can specify subset
   of the images by specifying the dimension and the interval of interest
   as a Name-Value pair. If no arguments are given, all the data is
   extracted. For the Cols and Rows argument, the interval is intented
   per-tile. For example, if the user wants to keep only the top left tile,
   he won't specify any subset for 'Rows' and 'Cols' (that is, take them all),
   but will specify the subset 'TileRow' = 1 and 'TileCol' = 1. On the other
   hand, if the user wants to extract from a 800*600 image a version which
   is subsampled by a factor 2 he will specify Rows = 1:2:600
   and Cols = 1:2:800, and no subset for the tiles (i.e. use
   all tiles).
   
   * 'Cols': Specify which columns to extract
   * 'Rows': Specify which rows to extract
   * 'Channels': Specify which channels to extract
   * 'Stacks': Specify which planes to extract
   * 'Time': Specify which timeseries to extract
   * 'TileRows': Specify which row tiles to read.
   * 'TileCols': Specify which col tiles to read.

**OUTPUT**:
   
   * data: image data, up to 5 dimension (in this order: XYCZT). If only one
   	channel is extracted (or the input is single channel), the singleton
   	dimension relative to channel is squeezed.
   * imgPtr: imageIO instance (actually instance of a subclass of imageIO)
     that can be used to extract other data or access the image properties
     and metadata
 
**EXAMPLES**:
   
  * Reading all the content from single files:
     tiffData = imageIORead('myTiff.tif');
     cziData = imageIORead('aCZIFile.czi');
  * Reading a Z stack from a folder
     tiffStack = imageIORead('folderWithImages'); % no need to specify pattern
     tiffStack = imageIORead('folderWithImages', 'Stacks', 100:150); % subset
  * Reading complex datasets from a folder
     multiChTiffStack = imageIORead('folder', 'filePattern_Ch_%d_Z_%04d.tif', 'CZ');
  * Reading a subset from complex datasets from a folder
     multiChTiffStack = imageIORead('folder', 'filePattern_Pos_%02dx%02d_Ch_%d_Z_%04d.tif', ...
       'YXCZ', 'Channels', 2, 'TileRows', 1:2, 'TileCols', 1:3);
  * Read from file of size 4000x3000, subset of a factor 4, only first and third channel
     bioReaderData = imageIORead('sample.lsm', 'Channels', [1 3], 'Cols', ...
       1:4:4000, 'Rows', 1:4:3000);


## Folder containing test data
smb://storage.corp.brain.mpg.de/data/Projects/uImread/testdata

## Targeted image file formats
* TIFF --> open using Tiff library
* LSM --> open using BioFormat reader, not 100% working
* CZI --> open using our Matlab implementation
* MSR
* OBR
* XML based single images
* LIF
* SIF
* Sutter TIFF files --> Using our extension to Tiff library
* Slide Book Container (not in bioformats?)
* HDF
* multiple TIFF files in a folder --> opened using our Matlab implementation

## Current limitations of Bioformats
List of formats supported by bioformat:
https://www.openmicroscopy.org/site/support/bio-formats5.1/supported-formats.html#term-ratings-legend-and-definitions

BioFormat cannot cope with a bunch of datasets, both in LSM and CZI format

Possible disadvantages of open bioformat:

*	conversion to the OME format when opening an image (which guarantees interoperability, but also overhead)
*	Matlab interface is quite poor at the moment, and extracting specific metadata information it’s quite frustrating.
* Write is supported only for a fraction of the bioformat compatible formats.

