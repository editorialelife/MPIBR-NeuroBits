classdef LSMScanInformation
  %LSMSCANINFORMATION Class representation of ScanInformation in LSM files
  % The field u32OffsetScanInformation of the "CZ-Private tag" contains the
  % file offset to the start of a block with information of the device settings
  % used during acquisition. Note that the image size, channel number and pixel
  % distance of the image stored in the file can be different form the settings
  % used during acquisition because the image could have been modified by offline
  % operations. Information about the image size, channel number and pixel distance
  % of the image contents stored in the file can be found in the fields of the "CZ-Private tag"
  %
  % AUTHOR: Stefano Masneri
  % Date: 14.3.2017
  
  
  properties
    entry;          % A value that specifies which data are stored. Refer to 
                    % the constant properties of LSMScanInformation to get 
                    % a list of available entries. For the root element, it
                    % should be always "SUBBLOCK_RECORDING"
    type;           % A value that specifies the type of the data stored in the
                    % "Variable length data" field.
                    % TYPE_SUBBLOCK - start or end of a sub block
                    % TYPE_LONG - 32 bit signed integer
                    % TYPE_RATIONAL - 64 bit floating point
                    % TYPE_ASCII - zero terminated string.
    size;           % Size in bytes of the "Variable length data" field
    data;           % Data contained in the "Variable length data" field. It 
                    % is an array of LSMScanInformation objects
  end
  
  properties (Constant = true)
  SUBBLOCK_RECORDING = 268435456;               % 0x010000000
  SUBBLOCK_LASERS = 805306368                   % 0x030000000
  SUBBLOCK_LASER = 1342177280;                  % 0x050000000
  SUBBLOCK_TRACKS = 536870912;                  % 0x020000000
  SUBBLOCK_TRACK = 1073741824;                  % 0x040000000
  SUBBLOCK_DETECTION_CHANNELS = 1610612736;     % 0x060000000
  SUBBLOCK_DETECTION_CHANNEL = 1879048192;      % 0x070000000
  SUBBLOCK_ILLUMINATION_CHANNELS = 2147483648;  % 0x080000000
  SUBBLOCK_ILLUMINATION_CHANNEL = 2415919104;   % 0x090000000
  SUBBLOCK_BEAM_SPLITTERS = 2684354560;         % 0x0A0000000
  SUBBLOCK_BEAM_SPLITTER = 2952790016;          % 0x0B0000000
  SUBBLOCK_DATA_CHANNELS = 3221225472;          % 0x0C0000000
  SUBBLOCK_DATA_CHANNEL = 3489660928;           % 0x0D0000000
  SUBBLOCK_TIMERS = 285212672;                  % 0x011000000
  SUBBLOCK_TIMER = 301989888;                   % 0x012000000
  SUBBLOCK_MARKERS = 318767104;                 % 0x013000000
  SUBBLOCK_MARKER = 335544320;                  % 0x014000000
  SUBBLOCK_END = 4294967295;                    % 0x0FFFFFFFF
  end
  
  methods
    function obj = LSMScanInformation()
      obj.entry = fread(lsmPtr, 1, 'uint32', byteOrder);
      obj.type = fread(lsmPtr, 1, 'uint32', byteOrder);
      obj.size = fread(lsmPtr, 1, 'uint32', byteOrder);
      
      % SUPER BORING - SOMEBODY WILL IMPLEMENT IT IN THE FUTURE
    end
  end
  
end

