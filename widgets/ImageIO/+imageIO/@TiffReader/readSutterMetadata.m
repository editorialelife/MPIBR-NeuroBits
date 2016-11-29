function [ obj ] = readSutterMetadata( obj, imageDesc )
%READSUTTERMETADATA Extract metadata ofr SutterMOM Tiff files
%   Parse the ImageDescription Tiff tag and extract the relevant
%   information. 
%   INPUT
%     obj: current TiffReader object
%     imageDesc: string containing the ImageDescription tag content 
%   OUTPUT
%     obj: the updated TiffReader object
%
%   AUTHOR: Stefano.Masneri@brain.mpg.de
%   DATE: 29.11.2016
%   SEE ALSO: imageIO.TiffReader, imageIO.TiffReader.readMetadata

% first, convert the string into a Name-Value array

tmp = strsplit(imageDesc, {'\f','\n','\r','\t','\v'},'CollapseDelimiters', true);
metadata = cellfun(@(x) strsplit(x, '='), tmp, 'UniformOutput', false);

end

