function [] = countPunctaInNeuroTrees()
% count puncta in neuro trees
clc
clear variables
close all

    %% --- THINGS TO CHANGE BEFORE RUN --- %%
    %% --- input parameters --- %%
    channelPuncta = 2
    dataPath = '/Users/lisakochen/Desktop/331/';
    minPunctaSize = 2;
    minPeakRatio = 0.18;
    nhood = 13; % [pixels] from branch center to closest puncta
    testFileDetection = false; % %false toggle between [true | fato be odnelse] to get first image puncta
    testFileIndex = 54;
    
    %% --- DO NOT CHANGE STUFF AFTER HERE --- %%
    
    se = strel('disk', minPunctaSize);
    COLOR_TABLE = [255, 255, 255;...  % white
                       255,   0,   0;...  % red
                       255, 165,   0;...  % orange
                       255, 255,   0;...  % yellow
                        60, 179, 113;...  % dark green
                         0, 255, 255;...  % cyan
                       100, 149, 237;...  % light blue
                         0,   0, 255;...  % blue
                       128,   0, 128;...  % dark purple
                       255,  20, 147]...  % pink
                       ./255;
    
    %% --- read file names from path --- %%
    [imgFileNames, imgFileCount] = getFilesFromDir(dataPath, '*.tif');
    txtFileNames = getFilesFromDir(dataPath, '*.txt');
    
    %% --- process each image and channel --- %%
    if testFileDetection
        
        if testFileIndex > imgFileCount
            testFileIndex = imgFileCount;
        end
        
        fileIndexStart = testFileIndex;
        fileIndexStop = testFileIndex;
    else
        fileIndexStart = 1;
        fileIndexStop = imgFileCount;
    end
    
    
    for f = fileIndexStart : fileIndexStop
        
        % current image file
        imgFileNow = fullfile(dataPath, imgFileNames{f});
        [~,imgFileTag] = fileparts(imgFileNow);
        fprintf('image :: %s ', imgFileTag);
        
        % find neuro tree file
        idxTxtFile = strncmp(imgFileTag, txtFileNames, length(imgFileTag));
        if ~any(idxTxtFile)
            fprintf('warning :: neuro tree missing.\n');
            continue;
        else
            fprintf('\n');
        end
        
        % current text file
        idxTxtFile = find(idxTxtFile, 1, 'last');
        txtFileNow = fullfile(dataPath, txtFileNames{idxTxtFile});
        
        
        % read image info
        lsm = readLSMInfo(imgFileNow);
        idxStack = (1:lsm.stacks)';
        range = [lsm.height, lsm.width];
        
        % process tree
        neuroTree = loadNeuroTree(txtFileNow);
        neuroTree = maskNeuroTree(neuroTree, range);
        neuroTree = linkNeuroTree(neuroTree);
        
        
        % read puncta channels
        for c = 1 : length(channelPuncta)
            
            % prepare output file
            fileOut = [dataPath,filesep,'punctaStats_',imgFileTag,sprintf('_channel%d.txt',channelPuncta(c))];
            imgOut = [dataPath,filesep,'punctaStats_',imgFileTag,sprintf('_channel%d.png',channelPuncta(c))];
            
            % read current image
            idxChannel = channelPuncta(c);
            
            img = zeros(lsm.width, lsm.height, length(idxStack));
            for i = 1:length(idxStack)
                im = imread(imgFileNow, idxStack(i));
                img(:,:,i) = im(:,:,idxChannel);
            end
            %img = readLSMImage(imgFileNow, lsm, idxStack, idxChannel);
            
            % sum projection
            prj = sum(double(img),3);
            
            % apply spatial filter
            prj = imgaussfilt(prj,0.5,'Padding','symmetric');
            
            % rescale projection
            prj = (prj - min(prj(:))) ./ (max(prj(:)) - min(prj(:)));
            
            % dilate
            dil = imdilate(prj, se);
            bry = (prj == dil) & (prj > minPeakRatio);
            
            % get weighted centroid
            props = regionprops(bry, dil, 'WeightedCentroid');
            weightedCentroids = round(cat(1, props.WeightedCentroid));    

            punctaCount = size(weightedCentroids,1);
            punctaIndex = sub2ind2D(range, weightedCentroids(:,2), weightedCentroids(:,1));
            punctaDistance = neuroTree.bdist(punctaIndex);
            punctaSholl = neuroTree.sholl(punctaIndex);
            punctaToNode = double(neuroTree.bdistIdx(punctaIndex));
            punctaToBranch = neuroTree.remapBranch(punctaToNode);

            punctaResult = punctaDistance <= nhood;
            punctaResultIndex = find(punctaResult);


            
            if testFileDetection
                
                figure('Color','w');
                imshow(prj,[]);
                hold on;
                for b = 1 : neuroTree.branchCount
                    plot(neuroTree.branch(b).sampleNodes(:,1),...
                         neuroTree.branch(b).sampleNodes(:,2),...
                         'Color', COLOR_TABLE(neuroTree.branch(b).depth + 1, :));

                end
                
                plot(weightedCentroids(~punctaResult,1),...
                         weightedCentroids(~punctaResult,2),...
                         'r.','MarkerSize',10);
                     
                plot(weightedCentroids(punctaResult,1),...
                         weightedCentroids(punctaResult,2),...
                         'g.','MarkerSize',10);
                hold off;
                
            else
                
                
                fW = fopen(fileOut, 'w');
                fprintf(fW,'# image\t%s\n', imgFileTag);
                fprintf(fW,'# channel\t%d\n', channelPuncta(c));
                fprintf(fW,'# nhood\t%d\n', nhood);
                fprintf(fW,'# minPunctaSize\t%d\n', minPunctaSize);
                fprintf(fW,'# minPeakRatio\t%.2f\n', minPeakRatio);
                fprintf(fW,'# total puncta\t%d\n', punctaCount);
                fprintf(fW,'# in-range puncta\t%d\n', sum(punctaResult));
                fprintf(fW,'# punctaID\tbranchID\tbranchOrder\tdistPrev\tdistNext\tdistSoma\tdistSholl\n');
                for k = 1 : sum(punctaResult)

                    j = punctaResultIndex(k);
                    posBranch = punctaToBranch(j);
                    posNode = punctaToNode(j);
                    shollDist = punctaSholl(j);
                    unitDist = punctaDistance(j);

                    pixels = neuroTree.branch(posBranch).pixels;
                    nodes = neuroTree.branch(posBranch).sampleNodes;
                    prevNodes = neuroTree.branch(posBranch).prevNodes;
                    branchIndex = neuroTree.branch(posBranch).index;
                    branchOrder = neuroTree.branch(posBranch).depth;
                    [qryY, qryX] = ind2sub2D(range, posNode);

                    idxNode = find(pixels == posNode, 1);
                    if isempty(idxNode)

                        % find closest on perimeter
                        idxPerim = knnsearch(pixels, posNode);
                        [prevY,prevX] = ind2sub2D(range, pixels(idxPerim));

                        % calculate prevDist
                        prevDist = calculateDistance([qryX,qryY;prevX,prevY]);
                        nextDist = calculateDistance([qryX,qryY;neuroTree.center]);
                        somaDist = nextDist;

                    else

                        if branchOrder == 0

                            prevDist = unitDist + calculateDistance([nodes(idxNode,:);neuroTree.center]);
                            nextDist = 0;
                            somaDist = prevDist;

                        else

                            prevDist = unitDist + calculateDistance(nodes(1:idxNode,:));
                            nextDist = unitDist + calculateDistance(nodes(idxNode:end,:));
                            somaDist = unitDist + calculateDistance([prevNodes;nodes(1:idxNode,:)]);

                        end

                    end


                    fprintf(fW,'%d\t%d\t%d\t%.2f\t%.2f\t%.2f\t%.2f\n',...
                            k,branchIndex,branchOrder,prevDist,nextDist,somaDist,shollDist);

                end
                fclose(fW);
                
                %%% --- prepare PNG output --- %%%
                gray = uint8(255.* prj);
                rgb = repmat(gray, 1, 1, 3);

                % draw tree in image
                for b = 1 : neuroTree.branchCount

                    colorNow = COLOR_TABLE(neuroTree.branch(b).depth+1,:);
                    for crgb = 1 : 3
                        tmp = rgb(:,:,crgb);
                        tmp(neuroTree.branch(b).pixels) = uint8(255.*colorNow(crgb));
                        rgb(:,:,crgb) = tmp;
                    end

                    % insert text
                    rgb = insertText(rgb, round(mean(neuroTree.branch(b).sampleNodes)),...
                                     sprintf('%d',neuroTree.branch(b).index),...
                                     'TextColor', 255.*colorNow,...
                                     'BoxOpacity', 0,...
                                     'FontSize', 24);

                end

                % draw missed puncta
                tmp = false(range);
                tmp(punctaIndex(~punctaResult)) = true;
                %tmp = imdilate(tmp, strel('disk', 4)) & ~imdilate(tmp, strel('disk', 3));
                %tmp = imdilate(tmp, strel('disk', 3));
                r = rgb(:,:,1);
                r(tmp) = 255;
                rgb(:,:,1) = r;
                g = rgb(:,:,2);
                g(tmp) = 0;
                rgb(:,:,2) = g;
                b = rgb(:,:,3);
                b(tmp) = 0;
                rgb(:,:,3) = b;

                % draw accepted puncta
                tmp = false(range);
                tmp(punctaIndex(punctaResult)) = true;
                %tmp = imdilate(tmp, strel('disk', 3));
                %tmp = imdilate(tmp, strel('disk', 4)) & ~imdilate(tmp, strel('disk', 3));
                r = rgb(:,:,1);
                r(tmp) = 0;
                rgb(:,:,1) = r;
                g = rgb(:,:,2);
                g(tmp) = 255;
                rgb(:,:,2) = g;
                b = rgb(:,:,3);
                b(tmp) = 0;
                rgb(:,:,3) = b;

                imwrite(rgb, imgOut);
            end

            
        end
        
        % break execution after first image in folder if test case
        if testFileDetection
            break;
        end
        %}
    end

end

%% --- ADDITIONAL FUNCTIONS --- %%

function [fileNames, fileCount] = getFilesFromDir(dataPath, ext)
%GETFILESFROMDIR

    dirInfo = dir([dataPath, filesep, ext]);
    fileNames = {dirInfo.name}';
    fileCount = size(fileNames, 1);
    
end

function [obj] = loadNeuroTree(fileName)
%LOADNEUROTREE

    % open file to read
    fpRead = fopen(fileName, 'r');
    txt = textscan(fpRead, '%s', 'delimiter', '\n');
    fclose(fpRead);
    txt = txt{:};

    % read dilation
    queryTxt = 'dilation[px]=';
    idxTxtDilation = strncmp(queryTxt, txt, length(queryTxt));
    obj.dilation = sscanf(txt{idxTxtDilation},'dilation[px]=%d');

    % read nhood
    queryTxt = 'nhood[px]=';
    idxTxtNhood = strncmp(queryTxt, txt, length(queryTxt));
    obj.nhood = sscanf(txt{idxTxtNhood},'nhood[px]=%d');

    % read branch info
    idxTxtBranch = strncmp('branch', txt, 6);
    idxTxtBranch = cumsum(idxTxtBranch);
    obj.branchCount = max(idxTxtBranch);
    
    for b = 1 : obj.branchCount

        if sum(idxTxtBranch == b) == 10
            
            % set vartext
            vartxt = txt(idxTxtBranch == b);
            
            % parse text 
            obj.branch(b,1).index = sscanf(vartxt{1}, 'branch=%d');
            obj.branch(b,1).depth = sscanf(vartxt{2}, 'depth=%d');
            obj.branch(b,1).tag = sscanf(vartxt{3}, 'tag=%d');
            obj.branch(b,1).parent = sscanf(vartxt{4}, 'partent=%d');
            obj.branch(b,1).children = str2double(regexp(vartxt{5},'[\d]+', 'match'))';
            obj.branch(b,1).span = sscanf(vartxt{6}, 'span=%f');
            obj.branch(b,1).nodeCount = sscanf(vartxt{7}, 'nodes=%d');
            xData = str2double(regexp(vartxt{8}, '[\d]+', 'match'));
            yData = str2double(regexp(vartxt{9}, '[\d]+', 'match'));
            
            % set ui elements
            obj.branch(b,1).nodes = [xData', yData'];
            
            % close polygon
            if obj.branch(b,1).depth == 0
                obj.branch(b,1).nodes = cat(1, obj.branch(b,1).nodes,...
                                               obj.branch(b,1).nodes(1,:));
            end
            
            
        else
            warning('NeuroTreeBranch:load','incomplete branch data.');
        end
        
    end
    
    % clean single nodes in branch
    idx_single = cat(1, obj.branch.nodeCount);
    obj.branch(idx_single == 1)  = [];
    obj.branchCount = sum(idx_single > 1);
    
    % interpolate nodes
    for b = 1 : obj.branchCount
        obj.branch(b,1).sampleNodes = interpolateBranch(obj.branch(b,1).nodes);
    end
    
    % sort by depth
    listDepth = cat(1, obj.branch.depth);
    [~, idxSort] = sort(listDepth);
    obj.branch = obj.branch(idxSort);
    
    
    
    

end


function sampleNodes = interpolateBranch(nodes)
%INTERPOLATEBRANCH

    if size(nodes, 1) == 1
        
        sampleNodes = nodes;
        
    else

        % calculate cumulative pixel distance along line
        dNodes = sqrt(sum(diff(nodes, [], 1).^2, 2));
        csNodes = cat(1, 0, cumsum(dNodes));

        % resample nodes at sub-pixel intervals
        sampleCsNodes = linspace(0, csNodes(end), ceil(csNodes(end)./0.5));
        sampleNodes = interp1(csNodes, nodes, sampleCsNodes, 'pchip');
        sampleNodes = round(sampleNodes);
        
    end

end


function neuroTree = maskNeuroTree(neuroTree, range)

    % associate puncta to each branch
    sholl = false(range);
    neuroTree.mask = false(range);
    neuroTree.remapBranch = zeros(range);
    for b = 1 : neuroTree.branchCount

        % fix constrain around sample nodes
        hAry = neuroTree.branch(b).sampleNodes(:,2);
        hAry(hAry > range(1)) = range(1);
        hAry(hAry < 1) = 1;
        neuroTree.branch(b).sampleNodes(:,2) = hAry;
        
        wAry = neuroTree.branch(b).sampleNodes(:,1);
        wAry(wAry > range(2)) = range(2);
        wAry(wAry < 1) = 1;
        neuroTree.branch(b).sampleNodes(:,1) = wAry;
        
        
        neuroTree.branch(b).pixels = sub2ind2D(range,...
                           neuroTree.branch(b).sampleNodes(:,2),...
                           neuroTree.branch(b).sampleNodes(:,1));

        tmp = false(range);               
        tmp(neuroTree.branch(b).pixels) = true;
        
        if neuroTree.branch(b).depth == 0
            
            tmp = imfill(tmp, 'holes');
            rp = regionprops(tmp, 'Centroid');
            neuroTree.center = round(rp.Centroid);
            sholl(round(rp.Centroid(:,1)), round(rp.Centroid(:,2))) = true;
            neuroTree.sholl = bwdist(sholl);
            
        end
        
        neuroTree.mask(tmp) = true;
        neuroTree.remapBranch(tmp) = b;
        %}
    end
    
    %neuroTree.mask = imfill(neuroTree.mask, 'holes');
    [neuroTree.bdist, neuroTree.bdistIdx] = bwdist(neuroTree.mask);
    

end

function neuroTree = linkNeuroTree(neuroTree)

    listDepth = cat(1, neuroTree.branch.depth);

    % check if two cells are segmented
    if sum(listDepth == 0) ~= 1
        error('Only one cell some expected!');
    end
    
    
    % loop through each branch
    for b = 1 : neuroTree.branchCount
        
        depth = neuroTree.branch(b).depth;
        startPos = neuroTree.branch(b).sampleNodes(1,:);
        
        % check soma closest
        if depth == 0
            
            neuroTree.branch(b).prevNodes = neuroTree.center;
            
        elseif depth == 1
            
            idx = knnsearch(neuroTree.branch(1).sampleNodes, startPos);
            neuroTree.branch(b).prevNodes = [neuroTree.center;...
                                             neuroTree.branch(1).sampleNodes(idx,:)];
            
        else
            
            % loop over previous depth last positions
            prevDepthCount = sum(listDepth == (depth - 1));
            prevDepthLast = zeros(prevDepthCount, 2);
            prevDepthIndex = find(listDepth == (depth - 1));
            for j = 1 : prevDepthCount
                prevDepthLast(j,:) = neuroTree.branch(prevDepthIndex(j)).sampleNodes(end,:);
            end
            
            % get closest one
            idx = knnsearch(prevDepthLast, startPos);
            prevClosestIndex = prevDepthIndex(idx);
            neuroTree.branch(b).prevNodes = [neuroTree.branch(prevClosestIndex).prevNodes;...
                                             neuroTree.branch(prevClosestIndex).sampleNodes];
            
        end
        
    end

    
end



function dist = calculateDistance(nodes)

    if size(nodes, 1) == 1
        dist = 0;
    else
        dNodes = sqrt(sum(diff(nodes, [], 1).^2, 2));
        dist = sum(dNodes);
    end
       
end