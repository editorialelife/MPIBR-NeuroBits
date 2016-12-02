function [ data ] = getTiledData( obj, varargin )
%GETTILEDDATA Retrieves image data when the input is not tiled
%   This method retrieves the image data (or a subset of it) in the case of
%   images that multiple tiles. The user can specify subset
%   of the images by specifying the dimension and the interval of interest
%   as a Name-Value pair. If no arguments are given, all the data is
%   extracted.
% INPUT:
%   obj: the CZIReader instance
% NAME-VALUE ARGUMENTS
%   'Cols': Specify which columns to extract
%   'Rows': Specify which rows to extract
%   'C': Specify which channels to extract
%   'Z': Specify which planes to extract
%   'T': Specify which timeseries to extract
%   'S': Specify which series/position to extract
%   'TileRows': Specify which row tiles to read.
%   'TileCols': Specify which col tiles to read.
% OUTPUT:
%   data: image data, up to 6 dimension (in this order: XYCZTS). If only one
%   	channel is extracted (or the input is single channel), the singleton
%   	dimension relative to channel is squeezed.
% EXAMPLES:
%   data = obj.getTiledData(); %extract all data
%   data = obj.getTiledData('C', 1:2); %extract data only from the first
%     2 channels
%   data = obj.getTiledData('Rows', 1:2:obj.pixPerTileCol, 'Cols', 1:2:obj.pixPerTileRow); %
%     extract data subsampled by a factor 2 in rows and cols
%   data = obj.getTiledData('TileRows', 1:6, 'TileCols, 2:4) %Reads first six rows of
%     tiles, and column tiles from 2 to 4

%parse input
p = inputParser();
p.KeepUnmatched = true;
p.addParameter('Cols', 1:obj.width, @(x) isvector(x) && all(x > 0) && max(x) <= obj.width);
p.addParameter('Rows', 1:obj.height, @(x) isvector(x) && all(x > 0) && max(x) <= obj.height);
p.addParameter('C', 1:obj.channels, @(x) isvector(x) && all(x > 0) && max(x) <= obj.channels);
p.addParameter('Z', 1:obj.stacks, @(x) isvector(x) && all(x > 0) && max(x) <= obj.stacks);
p.addParameter('T', 1:obj.time, @(x) isvector(x) && all(x > 0) && max(x) <= obj.time);
p.addParameter('S', 1:obj.time, @(x) isvector(x) && all(x > 0) && max(x) <= obj.series);
p.addParameter('TileCols', 1:obj.numTilesCol, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesCol);
p.addParameter('TileRows', 1:obj.numTilesRow, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesRow);

p.parse(varargin{:});

rows = p.Results.Rows;
cols = p.Results.Cols;
channels = p.Results.C;
stacks = p.Results.Z;
timeseries = p.Results.T;
series = p.Results.S;
tileCols = p.Results.TileCols;
tileRows = p.Results.TileRows;

if obj.wrongMetadata % deal with messy indices
  
else % normal case
  sizeRows = round(length(rows) * (1 + (max(tileRows) - 1) * (1 - obj.tileOverlap)));
  sizeCols = round(length(cols) * (1 + (max(tileCols) - 1) * (1 - obj.tileOverlap)));
  
  data = zeros(sizeRows, sizeCols, length(channels), length(stacks), ...
    length(timeseries), length(series), obj.datatype);
  
  %get index of start of each new tile
  pixelStartTileRow = 1 + round((0:max(tileRows)-1) * (1 - obj.tileOverlap) * length(rows));
  pixelStartTileCol = 1 + round((0:max(tileCols)-1) * (1 - obj.tileOverlap) * length(cols));
  
  idxZ = 1;
  for z = stacks;
    idxCh = 1;
    for ch = channels
      idxT = 1;
      for t = timeseries
        idxS = 1;
        for s = series
          %get directory entry
          dirEntries = obj.directoryEntries(obj.dirEntryIndices{ch, z, t, s});
          for k = 1:length(dirEntries)
            
            currTileRow = obj.rowIndex(dirEntries(k).YPos);
            currTileCol = obj.colIndex(dirEntries(k).XPos);
            
            if any(currTileRow == tileRows) && any(currTileCol == tileCols)
              % this tile is required!
              tmpImg = obj.readRawSubblockSegm('dirEntry', dirEntries(k));
              [rr, cc] = size(tmpImg(rows, cols));
              data(pixelStartTileRow(currTileRow) : pixelStartTileRow(currTileRow) + rr - 1, ...
               pixelStartTileCol(currTileCol) : pixelStartTileCol(currTileCol) + cc - 1, ...
               idxCh, idxZ, idxT, idxS) = tmpImg(rows, cols);
            end
          end
          idxS = idxS + 1;
        end
        idxT = idxT + 1;
      end
      idxCh = idxCh + 1;
    end
    idxZ = idxZ + 1;
  end
  
end


%squeeze data, to remove singleton dimensions
data = squeeze(data);
end