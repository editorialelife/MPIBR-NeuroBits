function [ data ] = getAllData( obj )
%GETALLDATA Get all the image data
%   This method extracts all the image data from a CZIReader object
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

if obj.wrongMetadata
  % Cannot assume that data is arranged on a grid. Must first read all the
  % X and Y position in the directory entry and estimate the image size
  gridPos = zeros(length(obj.directoryEntries), 3); %row, col, S
  for k = 1:length(obj.directoryEntries)
    dirEntry = obj.directoryEntries(k);
    col = 1 + dirEntry.XPos;
    row = 1 + dirEntry.YPos;
    S = 1 + dirEntry.S;
    gridPos(k, :) = [row, col, S];
    if 1 == k % get tile size
      tileH = dirEntry.dimensionEntries(1).size;
      tileW = dirEntry.dimensionEntries(2).size;
    end
  end
  offsets = min(gridPos);
  offsets(3) = 0;
  
  % add offset to get index starting from 0
  gridPos = bsxfun(@minus, gridPos, offsets);
  obj.height = max(gridPos(:,1)) + tileH;
  obj.width = max(gridPos(:,2)) + tileW;
  
  % Sanity check
  assert(obj.height == obj.pixPerTileRow);
  assert(obj.width == obj.pixPerTileCol);
  
  % Fix size of single tile
  obj.pixPerTileRow = tileH;
  obj.pixPerTileCol = tileW;
  
  %initialize data
  data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, ...
   obj.series, obj.datatype);
 
  %now browse through directory entries again, and extract the subblocks
  % Now go through all the directory entries
  for k = 1:length(obj.directoryEntries)
    dirEntry = obj.directoryEntries(k);
    % Get image
    tmpImg = obj.readRawSubblockSegm('dirEntry', dirEntry);
    % Get positions (all zero based)
    C = 1 + dirEntry.C; 
    Z = 1 + dirEntry.Z;
    T = 1 + dirEntry.T;
    S = 1 + dirEntry.S;
    start = gridPos(k, :) + 1;
    endR   = start(1) + size(tmpImg, 1) - 1;
    endC   = start(2) + size(tmpImg, 2) - 1;
    data(start(1):endR, start(2):endC, C, Z, T, S) = tmpImg;
  end
 else
  
 data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, ...
   obj.series, obj.datatype);

  % Now go through all the directory entries
  for k = 1:length(obj.directoryEntries)
    dirEntry = obj.directoryEntries(k);
    % Get image
    tmpImg = obj.readRawSubblockSegm('dirEntry', dirEntry);
    % Get positions (all zero based)
    C = 1 + dirEntry.C; 
    Z = 1 + dirEntry.Z;
    T = 1 + dirEntry.T;
    S = 1 + dirEntry.S;
    row = obj.rowIndex(dirEntry.YPos);
    col = obj.colIndex(dirEntry.XPos);
    % Manage overlap
    if 1 ~= row
      ovDiffRow = round(obj.tileOverlap * obj.pixPerTileRow);
    else
      ovDiffRow = 0;
    end
    if 1 ~= col
      ovDiffCol = round(obj.tileOverlap * obj.pixPerTileCol);
    else
      ovDiffCol = 0;
    end
    startR = 1 + (row - 1) * (obj.pixPerTileRow - ovDiffRow);
    startC = 1 + (col - 1) * (obj.pixPerTileCol - ovDiffCol);
    endR   = startR + obj.pixPerTileRow - 1;
    endC   = startC + obj.pixPerTileCol - 1;
    data(startR:endR, startC:endC, C, Z, T, S) = tmpImg;
  end
end

end

