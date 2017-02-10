function [ data ] = getAllData( obj )
%GETALLDATA Get all the image data
%   This method extracts all the image data from an LSMReader object
%
% AUTHOR: Stefano Masneri
% Date: 08.02.2017


obj = obj.getIFD();

progBar = TextProgressBar('LSMReader --> Extracting data: ', 30);

data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, obj.datatype);

numSteps = obj.Channels * obj.stacks * obj.time;

end

