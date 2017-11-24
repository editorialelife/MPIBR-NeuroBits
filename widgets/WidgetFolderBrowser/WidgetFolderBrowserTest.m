%% WidgetFolderBrowserTest
% test script and example usage
%
% Aug 2017
% 

function WidgetFolderBrowserTest()

    %% clean test
    clc
    clear variables
    close all

    
    %% evoke widget
    obj = WidgetFolderBrowser();
    if ~isa(obj, 'WidgetFolderBrowser')
        error('WidgetFolderBrowser :: test failed!');
    end

    %% set listener callback
    addlistener(obj, 'file', 'PostSet', @fcnCallback_testEvent);

end

function fcnCallback_testEvent(~, ~)

    disp('EVENT_FILE');
    
end
