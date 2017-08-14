%% WidgetImageBrowser
% test script and example usage
%
% Aug 2017
% 
clc
clear variables
close all

addpath([pwd,filesep,'..',filesep]);

obj = WidgetImageBrowser();


file_name = '/Volumes/data/Projects/NeuroBits/examples/Caspar_Example_Data/Control/141219_Camk2a_40x_Ctrl_image01.tif';
obj.read(file_name);

%iptr = imageIOPtr(file_name);
%tmp = iptr.read('C', 1, 'Z', 1);

