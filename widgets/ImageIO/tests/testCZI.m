% TEST CZI FILES

%% INPUT DATA
if ispc
  cziFolder = '\\storage.corp.brain.mpg.de\data\Projects\ImageIO\TestDataFormats\ZeissCZI';
else
  cziFolder = '/Volumes/data/Projects/ImageIO/TestDataFormats/ZeissCZI';
end

%% TEST CZI DATA - READ ALL DATA
cziFiles = {'2Positions.czi', '2x2Tiles.czi', '5Z.czi', '5Z10T2x2Tiles2Pos.czi', ...
  '10T.czi', 'Slide02_10x_RGT_Shading Correction.czi', ...
  'Slide03_10x_RGT_Shading Correction_StitchZenBlue.czi', ...
  ['ProblematicFiles' filesep() 'GreenSlide_Stack_1p-405_2p-720_exc561.czi']};

%% EXAMPLE FILES - READ ALL THE DATA
for k = 1:5
  filename = cziFiles{k};
  fullPath = fullfile(cziFolder, filename);
  cziFile = imageIO.CZIReader(fullPath);
  cziData = cziFile.read();
  if ismatrix(cziData)
    imshow(imadjust(cziData))
    pause(0.5)
  elseif 3 == ndims(cziData)
    for m = 1:size(cziData, 3)
      imshow(imadjust(cziData(:,:,m)))
      pause(0.5)
    end
  elseif 4 == ndims(cziData)
    for m = 1:size(cziData, 4)
      imshow(imadjust(cziData(:,:,1,m)))
      pause(0.5)
    end
  elseif 5 == ndims(cziData)
    for m = 1:size(cziData, 5)
      imshow(imadjust(cziData(:,:,1,1,m)))
      pause(0.5)
    end
  else % 6D
    for m = 1:size(cziData, 6)
      imshow(imadjust(cziData(:,:,1,1,m)))
      pause(0.5)
    end
  end
    
end

%% OTHER FILES - GET A SUBSET OF THE DATA
for k = 6:length(cziFiles)
  filename = cziFiles{k};
  fullPath = fullfile(cziFolder, filename);
  cziFile = imageIO.CZIReader(fullPath);
  if 6 == k
    %extract only one channel, subsample by a factor 2
    cziData = cziFile.read('Rows', 1:2:cziFile.pixPerTileRow, 'Cols', 1:2:cziFile.pixPerTileCol, 'C', 1);
    for m = 1:size(cziData, 3)
      imshow(imadjust(cziData(:,:,m)))
      pause(0.5)
    end
  elseif 7 == k
    cziData = cziFile.read();  % read all, cannot read only partially if wrongMetadata is true
    for m = 1:size(cziData, 3) % display three channels, second series
      imshow(imadjust(cziData(:,:,m, 1, 1, 2)))
      pause(0.5)
    end
  else
    %extract only 20 slices
    cziData = cziFile.read('Z', 1:20);
    for m = 1:size(cziData, 3)
      imshow(imadjust(cziData(:,:,m)))
      pause(0.2)
    end
  end
end