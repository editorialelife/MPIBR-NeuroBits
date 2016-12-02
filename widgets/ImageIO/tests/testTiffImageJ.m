% TEST TIFF SAVED IN IMAGEJ NON STANDARD FORMAT

%% INPUT DATA
if ispc
  imageJFolder = '\\storage.corp.brain.mpg.de\data\Projects\ImageIO\TestDataFormats\tiffImageJ';
else
  imageJFolder = 'smb://storage.corp.brain.mpg.de/data/Projects/ImageIO/TestDataFormats/tiffImageJ';
end

filename = 'stitched_shadowCorrection_bin221.tif';
fullPath = fullfile(imageJFolder, filename);

%% CREATE READER
reader = imageIO.TiffReader(fullPath);

%% READ PART OF THE DATA
dataImageJ = reader.read('Cols', 1:4:reader.width, 'rows', 1:4:reader.height, 'Z', 1:300);

%% SHOW DATA
disp(['Showing file ' filename])
for m = 1:size(dataImageJ, 4)
  imshow(imadjust(dataImageJ(:,:,:,m)))
  pause(0.05)
end