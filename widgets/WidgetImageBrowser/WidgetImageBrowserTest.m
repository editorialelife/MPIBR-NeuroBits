%% WidgetImageBrowserTest
% test script and example usage
%
% Aug 2017
% 
clc
clear variables
close all

%% add ImageIO
%addpath(genpath('/Users/tushevg/Developer/Projects/MPIBR-Projects/ImageIO/'));

%obj = WidgetImageBrowser();


fileName = '/Users/tushevg/Desktop/Analysis/Camk2a/160517_UTRProject_Colocalization-CDS-UTR_Camk2a_Channel2UTR_Channel3CDS_Dish01_MIP_01.lsm';
if exist(fileName, 'file') == 2
    
    meta = imfinfo(fileName);
    tmp = imread(fileName);
    
else
    error('Error::WidgetImageBrowserTest::invalid input file');
end




%obj.read(file_name);

%reader = imageIO.TiffReader(file_name);

%% READ PART OF THE DATA
%dataImageJ = reader.read('Z', 3);

