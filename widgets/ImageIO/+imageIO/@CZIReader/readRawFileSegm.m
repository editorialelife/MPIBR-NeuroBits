function obj = readRawFileSegm( obj )
%READRAWFILESEGM Read metadata for segment of type ZISRAWFILE
%   Extract information from ZISRAWFILE segments. For the moment, read all
%   fields, even the unnecessary ones, and use them for sanity check.

  Major = int32(fread(obj.cziPtr, 1, 'int32')); % Should be always one
  Minor = int32(fread(obj.cziPtr, 1, 'int32')); % Should be always zero
  
  if (Major ~= 1 || Minor ~= 0)
    error('CZIReader.readRawFileSegm: Major and Minor fields are not correct')
  end
  
  Reserved = fread(obj.cziPtr, 2, 'int32');
  PrimaryFileGuid = fread(obj.cziPtr, 4, 'int32'); % Unique Guid of Master file (FilePart 0)
  FileGuid = fread(obj.cziPtr, 4, 'int32'); % Unique per file
  
  if ~isequal(PrimaryFileGuid, FileGuid)
    warning('CZIReader.readRawFileSegm: multifile dataset. Currently unsupported')
  end
  
  FilePart = int32(fread(obj.cziPtr, 1, 'int32')); % Part number in multi-file scenarios
  DirectoryPosition = int64(fread(obj.cziPtr, 1, 'int64')); % File position of the SubBlockDirectory Segment
  
  if DirectoryPosition ~= obj.offsetDirectorySegm - 32 %32 is the ehader size
    error('CZIReader.readRawFileSegm: Inconsistent offset for Directory segment')
  end
  
  MetadataPosition = int64(fread(obj.cziPtr, 1, 'int64')); % File position of the Metadata Segment
  
  if MetadataPosition ~= obj.offsetMetadataSegm - 32 %32 is the ehader size
    error('CZIReader.readRawFileSegm: Inconsistent offset for Metadata segment')
  end
  
  UpdatePending = int32(fread(obj.cziPtr, 1, 'int32')); % either 0 or 0xffff
                                                 % This flag indicates a currently inconsistent
                                                 % situation (e.g. updating Index, Directory or
                                                 % Metadata segment).
                                                 % Readers should either wait until this flag is
                                                 % reset (in case that a writer is still accessing the
                                                 % file), or try a recovery procedure by scanning
                                                 % all segments.
  if 0 ~= UpdatePending
    error('CZIReader.readRawFileSegm: UpdatePending field set')
  end
                                                 
  AttachmentDirectoryPosition = int64(fread(obj.cziPtr, 1, 'int64')); % File position of the
                                                               % AttachmentDirectory Segment
                                                               
  if AttachmentDirectoryPosition ~= obj.offsetAttachDirSegm - 32 %32 is the ehader size
    error('CZIReader.readRawFileSegm: Inconsistent offset for AttachDirectory segment')
  end                                               
end

