function [ success ] = imageIOWrite( data, metadata, filename )
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
%   contain 2 fields, one for the actual data content and the other  for the 
%   metadata extracted by the imageIO toolbox
%
% INPUT
%   data: mandatory, it contains the actual image data to be written
%     on disk
%   metadata: metadata obtained when using the imageIO Toolbox
%   filename: Mandatory, it's the output filename. If the filename doesn't 
%     end in *.tif, the extension will be added automatically.
% OUTPUT
%   success: boolean flag, true if writing was successful, false otherwise
%
% EXAMPLE
%   [data, metadata] = imageIORead('/some/test/data/img.czi'); %get Data
%   success = imageIOWrite(data, metadata, 'myData.tif');
%
% DATE: 17.03.2017
% AUTHOR: stefano.masneri@brain.mpg.de
%
% SEE ALSO: imageIORead

% Parse input
p = inputParser;
p.addRequired(data, @isnumeric);
p.addRequired(filename, @ischar);
p.parse(data, filename);

% Check extension is correct
[folder, name, ext] = fileparts(filename);

if ~strcmpi(ext, '.tif')
  filename = fullfile(folder, [name '.tif']);
end

% Set filename for metadata file
filenameXml = fullfile(folder, [name '.xml']);

% Check number of dimensions
if 1 == ndims(data)
  warning('ImageIOWrite: data should be at least 2-dimensional')
  success = false;
  return
elseif ndims(data) <= 4 && size(data, 3) <= 3
  writeTiff = true;
else
  writeTiff = false;
end

if writeTiff
  try
  catch
    success = false;
    return
  end
else % write .mat
  try
    
  catch
    success = false;
    return
  end
end

success = true;

  function createXml(metadata)
  %CREATEXML Transform the metadata into an xml string
  end

end

