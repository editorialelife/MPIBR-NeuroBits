function [ data ] = getTiledData( obj, varargin )
%GETTILEDDATA Retrieves image data when the input is tiled
%   This method retrieves the image data (or a subset of it) in the case of
%   images that contain multiple tiles. The user can specify subset
%   of the images by specifying the dimension and the interval of interest
%   as a Name-Value pair. If no arguments are given, all the data is
%   extracted. For the Cols and Rows argument, the interval is intented
%   per-tile. For example, if the user wants to keep only the top left tile,
%   he won't specify any subset for Rows and Cols (that is, take them all),
%   but will specify the subset TileRow = 1 and TileCol = 1. On the other
%   hand, if the user wants to extract an image subsampled of a factor 2
%   compared to the original, he will specify a subset Rows = 1:2:obj.pixPerTileRow
%   and Cols = 1:2:obj.pixPerTileCol, and no subset for the tiles (i.e. use
%   all tiles).
% INPUT:
%   obj: the TiffDirReader instance
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
%   data = obj.getTiledData('Rows', 1:2:obj.pixPerTileCol, 'Cols', 1:2:obj.pixPerTileRow); %
%     extract data subsampled by a factor 2 in rows and cols
%   data = obj.getTiledData('TileRow', 1:6, 'TileCol, 2:4) %Reads first six rows of
%     tiles, and column tiles from 2 to 4

%parse input
p = inputParser();
p.KeepUnmatched = true;
p.addParameter('Cols', 1:obj.pixPerTileCol, @(x) isvector(x) && all(x > 0) && max(x) <= obj.pixPerTileCol);
p.addParameter('Rows', 1:obj.pixPerTileRow, @(x) isvector(x) && all(x > 0) && max(x) <= obj.pixPerTileRow);
p.addParameter('C', 1:obj.channels, @(x) isvector(x) && all(x > 0) && max(x) <= obj.channels);
p.addParameter('Z', 1:obj.stacks, @(x) isvector(x) && all(x > 0) && max(x) <= obj.stacks);
p.addParameter('T', 1:obj.time, @(x) isvector(x) && all(x > 0) && max(x) <= obj.time);
p.addParameter('TileCols', 1:obj.numTilesCol, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesCol);
p.addParameter('TileRows', 1:obj.numTilesRow, @(x) isvector(x) && all(x > 0) && max(x) <= obj.numTilesRow);

p.parse(varargin{:});
rows = p.Results.Rows;
cols = p.Results.Cols;
channels = p.Results.C;
stacks = p.Results.Z;
timeseries = p.Results.T;
tileCol = p.Results.TileCols;
tileRow = p.Results.TileRows;

sizeRows = round(length(rows) * (1 + (max(tileRow) - 1) * (1 - obj.tileOverlap)));
sizeCols = round(length(cols) * (1 + (max(tileCol) - 1) * (1 - obj.tileOverlap)));
data = zeros(sizeRows, sizeCols, length(channels), length(stacks), ...
  length(timeseries), obj.datatype);

end

