function obj = readRawFileSegm( obj )
%READRAWFILESEGM Read metadata for segment of type ZISRAWFILE
%   Extract information from ZISRAWFILE segments. For the moment, read all
%   fields, even the ones we do not care about, just for safety check

  Major = fread(obj.cziPtr, 1, 'int32'); % Should be always one
  Minor = fread(obj.cziPtr, 1, 'int32'); % Should be always zero
  Reserved = fread(obj.cziPtr, 2, 'int32');
  PrimaryFileGuid = fread(obj.cziPtr, 4, 'int32'); % Unique Guid of Master file (FilePart 0)
  FileGuid = fread(obj.cziPtr, 4, 'int32'); % Unique per file
  FilePart = fread(obj.cziPtr, 1, 'int32'); % Part number in multi-file scenarios
  DirectoryPosition = fread(obj.cziPtr, 1, 'int64'); % File position of the SubBlockDirectory Segment
  MetadataPosition = fread(obj.cziPtr, 1, 'int64'); % File position of the Metadata Segment
  UpdatePending = fread(obj.cziPtr, 1, 'int32'); % either 0 or 0xffff
                                                 % This flag indicates a currently inconsistent
                                                 % situation (e.g. updating Index, Directory or
                                                 % Metadata segment).
                                                 % Readers should either wait until this flag is
                                                 % reset (in case that a writer is still accessing the
                                                 % file), or try a recovery procedure by scanning
                                                 % all segments.
  AttachmentDirectoryPosition = fread(obj.cziPtr, 1, 'int64'); % File position of the
                                                               % AttachmentDirectory Segment
  
	% NOTE
  % Single file: PrimaryFileGuid and the FileGuid are identical. The FilePart is 0.
  % Multi file: In the master file, the PrimaryFileGuid and the FileGuid are identical. In file Parts, the
  %   PrimaryFileGuid is the Guid of the master file and FileParts are > 0.
  
end

