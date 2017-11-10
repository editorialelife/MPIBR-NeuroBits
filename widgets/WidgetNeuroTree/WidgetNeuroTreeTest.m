%% WidgetNeuroTreeTest
% test script and example usage
%
% Aug 2017
% 
    

function WidgetNeuroTreeTest()

    clc
    clear variables
    close all

    %% read test image
    fileQuery = '/Users/tushevg/Desktop/imgdb/BatchProcessed/160517_UTRProject_Colocalization-CDS-UTR_Calm3_Channel2UTR_Channel3CDS_Dish01-OME_TIFF-Export-01_s5.ome_maxProjection.tif';
    img = imread(fileQuery);

    %% create figure
    VIEWER_AXES_PADDING = 5;
    screenSize = get(0, 'ScreenSize');
    screenSize = floor(0.8 * min(screenSize(3:4)));
    handle_figure = figure(...
            'Visible', 'on',...
            'Tag', 'hViewerFigureHandle',...
            'Name', '',...
            'MenuBar', 'none',...
            'ToolBar', 'none',...
            'NumberTitle', 'off',...
            'Units', 'pixels',...
            'Position', [1, 1,...
                         screenSize + VIEWER_AXES_PADDING,...
                         screenSize + VIEWER_AXES_PADDING]);
    movegui(handle_figure, 'north');

    handle_layout = uiextras.HBoxFlex(...
            'Parent', handle_figure,...
            'Padding', VIEWER_AXES_PADDING);

    handle_axes = axes(...
            'Parent', handle_layout,...
            'ActivePositionProperty', 'position',...
            'XTick', [],...
            'YTick', [],...
            'Units','pixels',...
            'XColor', 'none',...
            'YColor', 'none');

    handle_image = imshow(...
            zeros(screenSize, screenSize, 'uint8'),...
            [],...
            'Parent', handle_axes,...
            'XData', [0, 1],...
            'YData', [0, 1]);

    clim = [min(img(:)), max(img(:))];    
    set(handle_axes, 'CLim', clim);
    set(handle_axes, 'XLim', [1, size(img,2)]);
    set(handle_axes, 'YLim', [1, size(img,1)]);
    set(handle_image, 'XData', [1, size(img,2)]);
    set(handle_image, 'YData', [1, size(img,1)]);
    set(handle_image, 'CData', img);



    %% test callbacks on figure
    obj = WidgetNeuroTree('Viewer',handle_figure);
    addlistener(obj,'event_treeExport', @assignFileInfo);
    
    function assignFileInfo(obj, ~, ~)

        [filePath, fileName] = fileparts(fileQuery);
        obj.filePath = filePath;
        obj.fileName = fileName;

    end

end


