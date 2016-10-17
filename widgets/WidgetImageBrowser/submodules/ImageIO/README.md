# ImageIO
**Reading and writing image data formats with MatLab.**

This library aims to implement a generic Matlab wrapper for several image format types. It uses existing libraries (such as Matlab's bindings for Bioformat), define Matlab wrappers for existing C libraries (such as TiffLib) or implements from scratch file format specifications (like CZI) to achieve the goal.

The library defines an abstract class called **imageIO** which defines the image metadata as well as a few methods which every subclass is required to implement.

Usage of the class is still to be defined. Ideally there should be two ways to read data:

1. via class construction: based on the input data, the user selects the appropriate class to create an object instance representing the data. A later call to one of the *reading* methods will allow the user to extract the desired data
2. via function: a function which accepts as input a filename will check the filetype and will create the appropriate object to extract the required data and metadata

## APIs

The library relies on other software. In particular we use two APIs:

1. BioFormats (version 5.1.10)
2. TiffLib (version 4.0.5)

## Reading meta data

* dimension
* offset (start time)
* size scale [either value or vector]
* time scale [either value or vector]
* pixel (dwell) time
* line time
* frame time
* stack time
* averaging value
* STED wavelength
* tile info (x,y,overlap)
* refraction media
* objective magnification
* objective name
* NA
* microscope name
* microscope type
* tile position (vector)
* laser power (each channel)
* gain (each channel)
* pinhole
* binning (x/y)
* data type

## Optional inputs
function that wrap up around the class for single calls

## Reading pixel data
* X
* Y
* color
* Z
*time
*tile 

## Provide folder for test data
smb://storage.corp.brain.mpg.de/data/Projects/uImread/testdata

## Targeted image file formats
* TIFF 
* LSM
* CZI
* MSR
* OBR (not in bioformats?)
* XML based single images
* LIF
* SIF (not in bioformats?)
* Sutter TIFF files (not in bioformats?)
* Slide Book Container (not in bioformats?)
* HDF
* multi TIFF files in a folder


## Current limitations of Bioformats
List of formats supported by bioformat:
https://www.openmicroscopy.org/site/support/bio-formats5.1/supported-formats.html#term-ratings-legend-and-definitions

Possible disadvantages of open bioformat:

*	conversion to the OME format when opening an image (which guarantees interoperability, but also overhead)
*	Matlab interface is quite poor at the moment, and extracting specific metadata information it’s quite frustrating.
*  Write is supported only for a fraction of the bioformat compatible formats.
