% TEST LSM FILES

%% INPUT DATA
if ispc
  lsmFolder = '\\storage.corp.brain.mpg.de\data\Projects\ImageIO\TestDataFormats\ZeissLSM';
else
  lsmFolder = '/Volumes/data/Projects/ImageIO/TestDataFormats/ZeissLSM';
end

%% TEST CZI DATA - READ ALL DATA
lsmFiles = {'2Positions.lsm', '2x2Tiles.lsm', '5Z.lsm', '5Z10T2x2Tiles2Pos.lsm', ...
  '10T.lsm', 'U4_20150328_TileStack_25x_Red_Green_CentralRegion_Z330-360.lsm'};

%% EXAMPLE FILES - READ ALL THE DATA
for k = 1:length(lsmFiles)
  filename = lsmFiles{k};
  fullPath = fullfile(lsmFolder, filename);
  lsmFile = imageIO.BioReader(fullPath);
  lsmData = lsmFile.read();
  if ismatrix(lsmData)
    imshow(imadjust(lsmData))
    pause(0.5)
  elseif 3 == ndims(lsmData)
    for m = 1:size(lsmData, 3)
      imshow(imadjust(lsmData(:,:,m)))
      pause(0.5)
    end
  elseif 4 == ndims(lsmData)
    for m = 1:size(lsmData, 4)
      imshow(imadjust(lsmData(:,:,1,m)))
      pause(0.5)
    end
  elseif 5 == ndims(lsmData)
    for m = 1:size(lsmData, 5)
      imshow(imadjust(lsmData(:,:,1,1,m)))
      pause(0.5)
    end
  else % 6D
    for m = 1:size(lsmData, 6)
      imshow(imadjust(lsmData(:,:,1,1,m)))
      pause(0.5)
    end
  end  
end