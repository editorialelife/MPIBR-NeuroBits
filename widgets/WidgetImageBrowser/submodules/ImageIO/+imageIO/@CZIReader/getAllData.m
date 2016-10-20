function [ data ] = getAllData( obj )
%GETALLDATA Get all the image data
%   This method extracts all the image data from a CZIReader object
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

 data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, ...
   obj.series, obj.datatype);

% Now go through all the directory entries
for k = 1:length(obj.directoryEntries)
  dirEntry = obj.directoryEntries(k);
  % Get image
  tmpImg = obj.readRawSubblockSegm(dirEntry);
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

