function [obj, XPos, YPos] = analyzeDirEntry( obj, k, XPos, YPos )
%ANALYZEDIRENTRY Check the directoryEntry and set all its properties

if k < 1 || k > length(obj.directoryEntries)
  error('CZIReader.analyzeDirEntry: directoryEntry index out of bounds')
end

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

