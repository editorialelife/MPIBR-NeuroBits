% NeuroBitsUnitTest
clc;
clear variables;
close all;

% example
filePath = '/Users/tushevg/Developer/Projects/NeuroBits/imgdb';
fileName = '255-aha-cnih-05_Maximum_intensity_projection';
fileExt = '.tif';
fileImage = [filePath filesep fileName fileExt];

img = imread(fileImage);
raw = img(:,:,2);

obj = WidgetDrawNeuroTree('Image',raw, 'FileName', fileName);
