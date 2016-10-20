function obj = readRawDirSegm( obj )
%READRAWDIRSEGM Read metadata for segment of type ZISRAWDIRECTORY
%   Extract information from ZISRAWDIRECTORY segments. 
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Get entry info
  entryCount = int32(fread(obj.cziPtr, 1, 'int32'));
  fread(obj.cziPtr, 31, 'int32');  % reserved

  % Now read all entries. Each item is a copy of the DirectoryEntry in the referenced
  % SubBlock segment.
  obj.directoryEntries = repmat(CZIDirectoryEntry(), 1, entryCount);
  for k = 1:entryCount
    obj.directoryEntries(k) = obj.directoryEntries(k).init(obj.cziPtr);
  end
  
  % Analyze directory entries to get info about tiling, timeseries etc.
  XPos = zeros(1, entryCount);
  YPos = zeros(1, entryCount);
  for k = 1:entryCount    
    for m = 1:obj.directoryEntries(k).dimensionCount
      dimEntry = obj.directoryEntries(k).dimensionEntries(m);
      switch dimEntry.dimension
        case 'X' % Pixel index / offset in the X direction. Used for tiled images
          XPos(k) = dimEntry.startCoordinate;
          obj.directoryEntries(k).XPos = XPos(k);
        case 'Y' % Pixel index / offset in the Y direction. Used for tiled images
          YPos(k) = dimEntry.startCoordinate;
          obj.directoryEntries(k).YPos = YPos(k);
        case 'C' % Channel in a Multi-Channel data set
          obj.directoryEntries(k).C = dimEntry.startCoordinate;
          if dimEntry.size > 1
            disp('Size of C > 1 for this block')
          end
        case 'Z' % Slice index (Z – direction).
          obj.directoryEntries(k).Z = dimEntry.startCoordinate;
          if dimEntry.size > 1
            disp('Size of Z > 1 for this block')
          end
        case 'T' % Time point in a sequentially acquired series of data.
          obj.directoryEntries(k).T = dimEntry.startCoordinate;
        case 'R' % Rotation – used in acquisition modes where the data is recorded
                 %  from various angles.
          disp('Dimension R currently not supported')
        case 'S' % Scene – for clustering items in X/Y direction (data belonging to
                 %  contiguous regions of interests in a mosaic image).
          obj.directoryEntries(k).S = dimEntry.startCoordinate;
        case 'I' % Illumination - illumination direction index (e.g. from left=0, from
                 %   right=1).
          disp('Dimension I currently not supported')
        case 'B' % (Acquisition) Block index in segmented experiments
        	%disp('Dimension B currently not supported and dropped by the file specification')
          %BPos = [BPos dimEntry.startCoordinate];
        case 'M' % Mosaic tile index – this index uniquely identifies all tiles in a
                 %   specific plane
          obj.directoryEntries(k).M = dimEntry.startCoordinate;
          if dimEntry.size > 1
            disp('Size of M > 1 for this block')
          end
        case 'H' % Phase index – for specific acquisition methods.
          disp('Dimension H currently not supported')
        case 'V' % View index (for multi – view images, e.g. SPIM)
          disp('Dimension V currently not supported')
        otherwise
          error('CZIReader.readRawDirSegm: Unrecognized dimension');
      end
    end
  end
  
  % Check correspondences between values obtained here and metadata info
  if length(unique(XPos)) == obj.numTilesCol
    warning('CZIReader.readRawDirSegm: inaccurate metadata information for number of horizontal tiles.')
    obj.numTilesCol = length(unique(XPos));
  end
  if length(unique(YPos)) == obj.numTilesRow
    warning('CZIReader.readRawDirSegm: inaccurate metadata information for number of vertical tiles.')
    obj.numTilesRow = length(unique(YPos));
  end
  
  % Now from here extract the positions of the tiles
  obj.rowTilePos = unique(YPos);
  obj.colTilePos = unique(XPos);
  obj.rowIndex = containers.Map(sort(unique(YPos), 'ascend'), 1:obj.numTilesRow);
  obj.colIndex = containers.Map(sort(unique(XPos), 'ascend'), 1:obj.numTilesCol);
  
  %now sort the directory entries according to their M field, so that tiles
  %with higher M are read later and will overwrite overlapping pixels
  [~, idx] = sort([obj.directoryEntries.M]);
  obj.directoryEntries = obj.directoryEntries(idx);
end

