%% WidgetNeuroTreeTest
% test script and example usage
%
% Aug 2017
% 
    


%{
clc
clear variables
close all

%% read test image
fileQuery = '/Users/tushevg/Desktop/imgdb/BatchProcessed/160517_UTRProject_Colocalization-CDS-UTR_Calm3_Channel2UTR_Channel3CDS_Dish01-OME_TIFF-Export-01_s5.ome_maxProjection.tif';
img = imread(fileQuery);

imgdbl = double(img);
img_max = max(imgdbl(:));
img_min = min(imgdbl(:));
imgnrm = (imgdbl - img_min)./ (img_max - img_min);


%% test mask
fileTree = '/Users/tushevg/Desktop/imgdb/BatchProcessed/160517_UTRProject_Colocalization-CDS-UTR_Calm3_Channel2UTR_Channel3CDS_Dish01-OME_TIFF-Export-01_s5.ome_maxProjection_neuroTree_10Nov2017.txt';
fr = fopen(fileTree,'r');
txt = textscan(fr,'%s','delimiter','\n');
fclose(fr);
txt = txt{:};

% read branch info
idxTxtBranch = strncmp('branch', txt, 6);
idxTxtBranch = cumsum(idxTxtBranch);
branchCount = max(idxTxtBranch);

width = 2048;
height = 2048;
mask = zeros(height, width);
%figure('color','w');
%hold on;
for b = 1 : branchCount

    txtNow = txt(idxTxtBranch == b);
    
    depth = sscanf(txtNow{2}, 'depth=%d');
    
    xNodes = regexp(txtNow(strncmp('x=',txtNow,2)),'\d+\.?\d*','match');
    xNodes = str2double(xNodes{:});
    
    yNodes = regexp(txtNow(strncmp('y=',txtNow,2)),'\d+\.?\d*','match');
    yNodes = str2double(yNodes{:});
    
    
    % interpolate
    nodes = [xNodes', yNodes'];
    if depth == 0
        nodes = cat(1,nodes, nodes(1,:));
    end
    
    % calculate cumulative pixel distance along line
    dNodes = sqrt(sum(diff(nodes, [], 1).^2, 2));
    csNodes = cat(1, 0, cumsum(dNodes));

    % resample nodes at sub-pixel intervals
    sampleCsNodes = linspace(0, csNodes(end), ceil(csNodes(end)/0.5))';
    sampleNodes = interp1(csNodes, nodes, sampleCsNodes,'pchip');
    
    
    %plot(nodes(:,1),nodes(:,2),'r.');
    %plot(sampleNodes(:,1), sampleNodes(:,2),'k');
    
    
    % filter nodes
    sampleNodes = round(sampleNodes);
    idxFilter = any(sampleNodes < 1, 2) | ...
                (sampleNodes(:,1) > width) | ...
                (sampleNodes(:,2) > height);
    sampleNodes(idxFilter,:) = [];
    sampleNodes = unique(sampleNodes, 'rows');
    pixels = sub2ind([height, width], sampleNodes(:,2), sampleNodes(:,1));
    
    mask_tmp = false(height, width);
    mask_tmp(pixels) = true;
    if depth == 0
        mask_tmp = imfill(mask_tmp,'holes');
    end
    
    %% calculate distance mask
    mask_dist = bwdist(mask_tmp);
    
    
    %{
    mask_dist_max = max(mask_dist(:));
    mask_dist_min = min(mask_dist(:));
    
    %% calculate intensity thresh
    mask_thresh = prctile(imgnrm(mask==2),20);
    
    mask_dist = (mask_dist - mask_dist_min) ./ (mask_dist_max - mask_dist_min);
    mask_dist = abs(mask_dist - 1);
    %}
    mask(mask_tmp) = b;
    
end

tmp = (imgnrm > 0.2) & (mask_dist < 100);
se = strel('disk', 3);
tmp = imclose(tmp, se);
tmp = bwareafilt(tmp, 1, 'largest');
figure(),imshow(tmp,[]);
%}

%hold off;
%{
set(gca,'Box','on',...
        'XTick',[],...
        'YTick',[],...
        'XLim',[1,2048],...
        'YLim',[1,2048],...
        'YDir','reverse');
%}
    
    
    

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

    
    %% test mask
    %tree = obj.engine.tree;


end
%}

