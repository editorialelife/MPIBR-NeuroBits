# ImageIO
reading and writing various image data formats with MatLab

## APIs
BioFormats

TiffLib

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
* OBR
* XML based single images
* LIF
* SIF
* Sutter TIFF files
* Slide Book Container
* HDF
* multi TIFF files in a folder
