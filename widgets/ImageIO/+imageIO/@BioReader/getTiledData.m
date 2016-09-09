function [ data ] = getTiledData( obj, varargin )
%GETTILEDDATA Retrieves image data when the input is tiled
%   This method retrieves the image data (or a subset of it) in the case of
%   images that contain multiple tiles. The user can specify subset
%   of the images by specifying the dimension and the interval of interest
%   as a Name-Value pair. If no arguments are given, all the data is
%   extracted.
% INPUT:
%   obj: the BioReader instance
% NAME-VALUE ARGUMENTS
%   'Cols': Specify which columns to extract
%   'Rows': Specify which rows to extract
%   'C': Specify which channels to extract
%   'Z': Specify which planes to extract
%   'T': Specify which timeseries to extract
%   'TileRow': Specify which row tiles to read.
%   'TileCol': Specify which col tiles to read.
% OUTPUT:
%   data: image data, up to 5 dimension (in this order: XYCZT). If only one
%   	channel is extracted (or the input is single channel), the singleton
%   	dimension relative to channel is squeezed.
% EXAMPLES:
%   data = obj.getTiledData(); %extract all data
%   data = obj.getTiledData('C', 1:2); %extract data only from the first
%     2 channels
%   data = obj.getTiledData('X', 1:2:obj.width, 'Y', 1:2:obj.height); %
%     extract data subsampled by a factor 2 in rows and cols
%   data = obj.getTiledData('TileRow', 1:6, 'TileCol, 2:4) %Reads first six rows of
%     tiles, and column tiles from 2 to 4

%parse input
p = inputParser();
p.KeepUnmatched = true;
p.addParameter('Cols', 1:obj.width, @(x) isvector(x) && all(x > 0) && max(x) <= obj.width);
p.addParameter('Rows', 1:obj.height, @(x) isvector(x) && all(x > 0) && max(x) <= obj.height);
p.addParameter('C', 1:obj.channels, @(x) isvector(x) && all(x > 0) && max(x) <= obj.channels);
p.addParameter('Z', 1:obj.stacks, @(x) isvector(x) && all(x > 0) && max(x) <= obj.stacks);
p.addParameter('T', 1:obj.time, @(x) isvector(x) && all(x > 0) && max(x) <= obj.time);
p.addParameter('TileCol', 1:obj.numTilesCol, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesCol);
p.addParameter('TileRow', 1:obj.numTilesRow, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesRow);

p.parse(varargin{:});
rows = p.Results.Rows;
cols = p.Results.Cols;
channels = p.Results.C;
stacks = p.Results.Z;
timeseries = p.Results.T;
tileCol = p.Results.TileCol;
tileRow = p.Results.TileRow;

data = zeros(length(rows), length(cols), length(channels), length(stacks), ...
  length(time), obj.data_type);

% For every combination of Time, Z, Channel
idxS = 0;
for s = stacks;
  idxCh = 0;
  for ch = channels
    idxT = 0;
    for t = timeseries
      
      %Create the whole 2D image
      tmpData = zeros(obj.height, obj.width);
      for row = tileRow
        for col = tileCol
          %set series
          obj.bfPtr.setSeries((col-1) * obj.numTilesCol + row - 1);
          %set index
          tileIdx = obj.bfPtr.getIndex(s-1, ch-1, t-1) + 1;
          %get plane
          tmpTile = bfGetPlane(obj.bfPtr, tileIdx)';
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
          startR = 1 + (row - 1) * obj.pixPerTileRow - ovDiffRow;
          startC = 1 + (col - 1) * obj.pixPerTileCol - ovDiffCol;
          endR   = startR + length(rows);
          endC   = startC + length(cols);
          tmpData(startR:endR, startC:endC) = tmpTile(rows, cols);
        end
      end
      %Subset the 2D image and set it in output data
      data(:, :, idxCh, idxS, idxT) = tmpData(rows, cols);
      
      idxT = idxT + 1;
    end
    idxCh = idxCh + 1;
  end
  idxS = idxS + 1;
end

end

