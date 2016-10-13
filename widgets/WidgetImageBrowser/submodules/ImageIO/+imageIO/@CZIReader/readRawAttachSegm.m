function obj = readRawAttachSegm( obj )
%READATTACHSEGM Summary of this function goes here
%   Extract information from ZISRAWattach segments. 
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  dataSize = int32(fread(obj.cziPtr, 1, 'int32'));
  fread(obj.cziPtr, 3, 'int32'); %spare
  
  attachEntry = CZIAttachmentEntry(obj.cziPtr);
  
  fread(obj.cziPtr, 28, 'int32'); %spare
  
  data = fread(obj.cziPtr, dataSize, 'uint8');
  
end

