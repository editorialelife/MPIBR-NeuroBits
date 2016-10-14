function obj = readMetadata( obj )
%READMETADATA Read the metadata information and stores it in the object
%properties
%   This function parses the file according to the CZI file specifications,
%   and stores header and segment information that is hten used to fill all
%   the metadata fields of the object.
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  %open file for reading
  [obj.cziPtr, errmsg] = fopen(obj.fileFullPath);
  if obj.cziPtr < 0
    error(errmsg)
  end

  %Read file metadata
  keepGoing = true; %Stop once we reach the end of file
  currOffset = 32;
  while keepGoing
    % Read segment header: ID, AllocatedSize, UsedSize
    ID = fread(obj.cziPtr, 16, '*char')';
    if ~isempty(ID)
      obj.segmentTypes = [obj.segmentTypes, setSegmenType(ID)];

      if obj.segmentTypes(end) == CZISegments.ZISRAWSUBBLOCK
        obj.imageSubblocks = obj.imageSubblocks + 1;
      end
      % Check size of segment, set the offset
      obj.offsetToSegments = [obj.offsetToSegments, currOffset];
      AllocSize = int64(fread(obj.cziPtr, 1, 'int64'));
      
      if obj.segmentTypes(end) == CZISegments.ZISRAWDIRECTORY
        if 0 == obj.offsetDirectorySegm
          obj.offsetDirectorySegm = obj.offsetToSegments(end);
        else
          error('CZIReader.readMetadata: obj.offsetDirectorySegm already set!')
        end
      elseif obj.segmentTypes(end) == CZISegments.ZISRAWMETADATA
        if 0 == obj.offsetMetadataSegm
          obj.offsetMetadataSegm = obj.offsetToSegments(end);
        else
          error('CZIReader.readMetadata: obj.offsetMetadataSegm already set!')
        end
      elseif obj.segmentTypes(end) == CZISegments.ZISRAWATTDIR
        if 0 == obj.offsetAttachDirSegm
          obj.offsetAttachDirSegm = obj.offsetToSegments(end);
        else
          error('CZIReader.readMetadata: obj.offsetAttachDirSegm already set!')
        end
      end
      
      currOffset = currOffset + AllocSize + 32; % + 32 to include header
      
      %Check how much of the segment is actually used
      UsedSize = fread(obj.cziPtr, 1, 'int64');

      try
        fseek(obj.cziPtr, AllocSize, 'cof');
      catch
        keepGoing = false;
      end
    else
      keepGoing = false;
    end
  end

  % Now go through all the segments and extract the information we need
  for k = 1:length(obj.segmentTypes)
    fseek(obj.cziPtr, obj.offsetToSegments(k), 'bof');
    switch obj.segmentTypes(k)
      case CZISegments.ZISRAWFILE
        obj = obj.readRawFileSegm();
      case CZISegments.ZISRAWDIRECTORY
        obj = obj.readRawDirSegm(); % Summary of subblock metadata
      case CZISegments.ZISRAWSUBBLOCK
        % Don't do anything at the moment. We have specific methods to read data
      case CZISegments.ZISRAWMETADATA
        obj = obj.readRawMetadataSegm(); % Main method accessing all metadata 
      case CZISegments.ZISRAWATTACH
        obj = obj.readRawAttachSegm(); % Maybe remove? we are not using this info
      case CZISegments.ZISRAWATTDIR
        % Don't do anything, the information is redundant!
      case CZISegments.DELETED
        % Don't do anything, the specification says to ignore this segment
      otherwise
        error('Unrecognized Segment type')
    end
  end
end

function segmType = setSegmenType(ID)
  ID = deblank(ID);
  switch ID
    case 'ZISRAWFILE'
      segmType = CZISegments(1); return;
    case 'ZISRAWDIRECTORY'
      segmType = CZISegments(2); return;
    case 'ZISRAWSUBBLOCK'
      segmType = CZISegments(3); return;
    case 'ZISRAWMETADATA'
      segmType = CZISegments(4); return;
    case 'ZISRAWATTACH'
      segmType = CZISegments(5); return;
    case 'ZISRAWATTDIR'
      segmType = CZISegments(6); return;
    case 'DELETED'
      segmType = CZISegments(7); return;
    otherwise
      error('Unrecognized Segment type')
  end
end
