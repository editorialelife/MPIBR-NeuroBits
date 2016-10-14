function [ data ] = getAllData( obj )
%GETALLDATA Get all the image data
%   This method extracts all the image data from a CZIReader object
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, ...
  obj.series, obj.datatype);

% Now go through all the directory entries
for k = 1:length(obj.directoryEntries)
  dirEntry = obj.directoryEntries(k);
  tmpImg = obj.readRawSubblockSegm(dirEntry);
end

end

