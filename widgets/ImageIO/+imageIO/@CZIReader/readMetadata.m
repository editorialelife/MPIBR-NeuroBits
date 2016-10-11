function obj = readMetadata( obj )
%READMETADATA Read the metadata information and stores it in the object
%properties
%   This function parses the file according to the CZI file specifications,
%   and stores header and segment information that is hten used to fill all
%   the metadata fields of the object.

%open file for reading
[obj.cziPtr, errmsg] = fopen(obj.fileFullPath);
if obj.cziPtr < 0
  error(errmsg)
end

%Read file metadata
keepGoing = true; %Stop once we reach the end of file
currOffset = 0;
while keepGoing
  % Read segment header - ID, AllocatedSize, UsedSize
  ID = fread(obj.cziPtr, 16, '*char')';
  if ~isempty(ID)
    obj.segmentTypes = [obj.segmentTypes, setSegmenType(ID)];

    % Check siz of segment, set the offset
    obj.offsetToSegments = [obj.offsetToSegments, currOffset];
    AllocSize = fread(obj.cziPtr, 1, 'int64');
    currOffset = currOffset + AllocSize;

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

end

function segmType = setSegmenType(ID)
  ID = deblank(ID);
  switch ID
    case 'ZISRAWFILE'
      segmType = 1; return;
    case 'ZISRAWDIRECTORY'
      segmType = 2; return;
    case 'ZISRAWSUBBLOCK'
      segmType = 3; return;
    case 'ZISRAWMETADATA'
      segmType = 4; return;
    case 'ZISRAWATTACH'
      segmType = 5; return;
    case 'ZISRAWATTDIR'
      segmType = 6; return;
    case 'DELETED'
      segmType = 7; return;
    otherwise
      ID
      error('Unrecognized Segment type')
  end
end
