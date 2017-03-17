function [ success ] = imageIOWrite( data, filename )
%IMAGEIOWRITE Write to disk data extracted using imageIO toolbox
%   imageIOWrite provides an interface to write on disk data which has been
%   extracted using the imageIO toolbox. The function behaves differently
%   depending on the size of the data input parameter. If the data has a
%   number of dimensions which is less than or equals to four (and one of
%   the dimensions, the one representing the channels, has size of at most
%   three), then the data will be written as a Tiff file. An additional
%   xml file will contain additional metadata information who couldn't be
%   stored in any of the Tiff tags. If the number of dimensions is bigger
%   than four, the file will be saved as a .mat object. This object will
%   contain 3 fields: The actual data content, the metadata as extracted by
%   the imageIO toolbox, and the metadata as stored in the original file.
%
% INPUT
%   data: mandatory, it contains the actual image data to be written
%     on disk
%   filename: Mandatory, it's the output filename. If the filename doesn't 
%     end in *.tif, the extension will be added automatically.
% OUTPUT
%   success: boolean flag, true if writing was successful, false otherwise
%
% DATE: 17.03.2017
% AUTHOR: stefano.masneri@brain.mpg.de
%
% SEE ALSO: imageIORead


end

