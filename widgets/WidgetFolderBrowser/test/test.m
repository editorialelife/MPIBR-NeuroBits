%% WidgetFolderBrowser
% test script and example usage
%
% Aug 2017
% 

[qry_path, ~, ~] = fileparts(mfilename('fullpath'));

addpath(genpath([qry_path,'../']));

obj = WidgetFolderBrowser();
