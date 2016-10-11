function obj = readMetadataSegm( obj )
%READMETADATASEGM Read metadata for segment of type ZISRAWMETADATA
%   Extract information from ZISRAWMETADATA segments. The first part of the
%   segment contains the header, namely the size of the XML and the size of
%   the Attachment. After that there is the xml field and the optional
%   attachment field
  
  xmlSize = int32(fread(obj.cziPtr, 1, 'int32'));
  attSize = int32(fread(obj.cziPtr, 1, 'int32'));  % currently unused
  empty   = int32(fread(obj.cziPtr, 62, 'int32')); % spare space

  xmlData = fread(obj.cziPtr, xmlSize, '*char')';
  disp(xmlData);
end