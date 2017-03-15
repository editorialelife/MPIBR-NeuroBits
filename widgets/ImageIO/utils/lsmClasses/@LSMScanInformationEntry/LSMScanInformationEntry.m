classdef LSMScanInformationEntry
  %LSMSCANINFORMATIONENTRY Defines an entry in the scan information field
  %of the lsm file
  %   In LSM files, the Scan information part of the metadata is nothing
  %   but an array of entries. Each entry is represented by an instance of
  %   this class
  
  properties
    entry;          % A value that specifies which data are stored. Refer to 
                    % the constant properties of LSMScanInformation to get 
                    % a list of available entries
    type;           % A value that specifies the type of the data stored in the
                    % "Variable length data" field.
                    % TYPE_SUBBLOCK - start or end of a sub block
                    % TYPE_LONG - 32 bit signed integer
                    % TYPE_RATIONAL - 64 bit floating point
                    % TYPE_ASCII - zero terminated string.
    size;           % Size in bytes of the "Variable length data" field
    data;           % Data contained in the "Variable length data" field
  end
  
  methods
  end
  
end

