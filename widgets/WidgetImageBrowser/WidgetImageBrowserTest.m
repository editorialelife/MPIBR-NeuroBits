%% WidgetImageBrowserTest
% test script and example usage
%
% Aug 2017
% 
clc
clear variables
close all

%% add ImageIO
addpath(genpath('/Users/tushevg/Developer/Projects/MPIBR-Projects/ImageIO/'));

obj = WidgetImageBrowser();


file_name = '/Users/tushevg/Desktop/imgdb/BatchProcessed/160517_UTRProject_Colocalization-CDS-UTR_Calm3_Channel2UTR_Channel3CDS_Dish01-OME_TIFF-Export-01_s5.ome_maxProjection.tif';
obj.read(file_name);

%reader = imageIO.TiffReader(file_name);

%% READ PART OF THE DATA
%dataImageJ = reader.read('Z', 3);

