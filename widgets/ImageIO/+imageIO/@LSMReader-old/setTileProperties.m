function [ obj ] = setTileProperties( obj, ome )
%SETTILEPROPERTIES Summary of this function goes here

if 1 == obj.tile
  obj.rowTilePos = 1;
  obj.colTilePos = 1;
  obj.numTilesRow = 1;
  obj.numTilesCol = 1;
  obj.tileOverlap = 0;
  obj.pixPerTileRow = ome.getPixelsSizeY(0).getValue();
  obj.pixPerTileCol = ome.getPixelsSizeX(0).getValue();
else
  obj.rowTilePos = nan(1, obj.tile);
  obj.colTilePos = nan(1, obj.tile);
  try
    for k = 1:obj.tile
      obj.rowTilePos(k) = double(ome.getPlanePositionY(k-1,0).value());
      obj.colTilePos(k) = double(ome.getPlanePositionX(k-1,0).value());
    end
    obj.numTilesRow = length(unique(obj.rowTilePos));
    obj.numTilesCol = length(unique(obj.colTilePos));
  catch
    obj.rowTilePos = nan(1, obj.tile);
    obj.colTilePos = nan(1, obj.tile);
    obj.numTilesRow = nan;
    obj.numTilesCol = nan;
  end
  try
    obj.pixPerTileRow = double(ome.getPixelsSizeY(0).getValue());
    obj.pixPerTileCol = double(ome.getPixelsSizeX(0).getValue());
  catch
    obj.pixPerTileRow = NaN;
    obj.pixPerTileCol = NaN;
  end
  try
    if obj.numTilesRow > 1
      %get the minimum value above zero
      rowDiffs = diff(obj.rowTilePos);
      rowDiffs(rowDiffs <= 0) = Inf;
      adjacentDiff = min(rowDiffs);
      obj.tileOverlap = 1 - adjacentDiff / (obj.pixPerTileRow *  ...
        double(ome.getPixelsPhysicalSizeY(0).value()));
    elseif obj.numTilesCol > 1
      colDiffs = diff(obj.colTilePos);
      colDiffs(colDiffs == 0) = Inf;
      adjacentDiff = min(colDiffs);
      obj.tileOverlap = 1 - adjacentDiff / (obj.pixPerTileCol * ...
        double(ome.getPixelsPhysicalSizeX(0).value()));
    else
      obj.tileOverlap = 0;
    end
  catch
    obj.tileOverlap = 0;
  end
  
end
end

