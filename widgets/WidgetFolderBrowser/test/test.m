%% WidgetFolderBrowser
% test script and example usage
%
% Aug 2017
% 

clc
clear variables
close all


addpath([pwd, filesep, '..', filesep]);

%% evoke widget
obj = WidgetFolderBrowser();
if ~isa(obj, 'WidgetFolderBrowser')
    error('WidgetFolderBrowser :: test failed!');
end
