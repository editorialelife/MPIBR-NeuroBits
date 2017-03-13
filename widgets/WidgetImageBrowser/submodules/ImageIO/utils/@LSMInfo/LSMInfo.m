classdef LSMInfo
  %LSMINFO Information included in the CZ_LSM_INFO Directory Entry
  %   The entry TIF_CZ_LSMINFO in the first image directory contains a file
  %   offset to a structure with detailed information of the image generation 
  %   and the states of several editors. Basic information is stored directly
  %   in the structure. For additional information there are file offsets to
  %   further structures.
  
  properties
    structureSize;                  % Number of bytes in the structure
    dimensionX;                     % Number of intensity values in x-direction
    dimensionY;                     % Number of intensity values in y-direction
    dimensionZ;                     % Number of intensity values in z-direction
                                    % or in case of scan mode "Time Series Mean-of-ROIs"
                                    % the Number of ROIs.
    dimensionChannels;              % Number of channels
    dimensionTime;                  % Number of intensity values in time-direction
    dataType;                       % format of intensity values. 1 for uint8,
                                    % 2 for uint12, 5 for float 32bit, 0
                                    % for differente data tyoes for
                                    % different channels
    thumbnailX;                     % Width in pixels of a thumbnail.
    thumbnailY;                     % Height in pixels of a thumbnail.
    voxelSizeX;                     % Distance of the pixels in x-direction in meter
    voxelSizeY;                     % Distance of the pixels in y-direction in meter
    voxelSizeZ;                     % Distance of the pixels in z-direction in meter
    originX;                        % The x-offset of the center of the image in meter.
                                    % relative to the optical axis
    originY;                        % The y-offset of the center of the image in meter.
                                    % relative to the optical axis
    originZ;                        % not used at the moment
    scanType;                       % Scan type:
                                    % 0 - normal x-y-z-scan
                                    % 1 - z-Scan (x-z-plane)
                                    % 2 - line scan
                                    % 3 - time series x-y
                                    % 4 - time series x-z (release 2.0 or later)
                                    % 5 - time series "Mean of ROIs" (release 2.0 or later)
                                    % 6 - time series x-y-z (release 2.3 or later)
                                    % 7 - spline scan (release 2.5 or later)
                                    % 8 - spline plane x-z (release 2.5 or later)
                                    % 9 - time series spline plane x-z (release 2.5 or later)
                                    % 10 - point mode (release 3.0 or later)
    spectralScan;                   % Spectral scan flag (0 = no scan, 1 = spectral scan mode)
    uDataType;                      % 0 = original data, 1 = calculated data, 2 = 3d Recon, 3 = Topograpy height map
    offsetVectorOverlay;            % File offset to the description of the vector overlay
    offsetInputLut;                 % File offset to the channel input LUT with brightness and contrast properties
    offsetOutputLut;                % File offset to the color palette
    offsetChannelColors;            % File offset to the list of channel colors and channel names
    timeInterval;                   % Time interval for time series in "s"
    offsetChannelDatatype;          % File offset to an array with UINT32-values with the
                                    % format of the intensity values for the respective channels 
                                    % (can be 0, if not present). 
                                    % 1 - for 8-bit unsigned integer,
                                    % 2 - for 12-bit unsigned integer and
                                    % 5 - for 32-bit float (for “Time Series Mean-of-ROIs” ).
    offsetScanInformation;          % File offset to a structure with information of the device
                                    % settings used to scan the image
    offsetKsData;                   % File offset to “Zeiss Vision KS-3D” specific data
    offsetTimeStamps;               % File offset to a structure containing the time stamps for the time indexes
    offsetEventList;                % File offset to a structure containing the experimental notations recorded during a time series
    offsetRoi;                      % File offset to a structure containing a list of the ROIs used during the scan operation
    offsetBleachRoi;                % File offset to a structure containing a description of the bleach region used during the scan operation
    offsetNextRecording;            % For "Time Series Mean-of-ROIs" and for "Line scans" it is
                                    % possible that a second image is stored in the file
                                    % (can be 0, if not present). For "Time Series Mean-of-ROIs"
                                    % it is an image with the ROIs. For "Line scans" 
                                    % it is the image with the selected line.
                                    % Currently not implemented in MATLAB!
    displayAspectX;                 % Zoom factor for the image display in x-direction
    displayAspectY;                 % Zoom factor for the image display in y-direction
    displayAspectZ;                 % Zoom factor for the image display in z-direction
    displayAspectTime;              % Zoom factor for the image display in time-direction
    offsetMeanOfRoisOverlay;        % File offset to the description of the vector overlay
                                    % with the ROIs used during a scan in "Mean of ROIs" mode
    offsetTopoIsolineOverlay;       % File offset to the description of the vector overlay for the
                                    % topography–iso–lines and height display with
                                    % the profile selection line
    offsetTopoProfileOverlay;       % File offset to the description of the vector overlay
                                    % for the topography–profile display
    offsetLinescanOverlay;          % File offset to the description of the vector overlay
                                    % for the line scan line selection with the selected
                                    % line or Bezier curve
    offsetChannelWavelength;        % Offset to memory block with the wavelength range
                                    % used during acquisition for the individual channels
    offsetChannelFactors;           % too long to explain ^_^'          
    objectiveSphereCorrection;      % The inverse radius of the spherical error of the
                                    % objective that was used during acquisition
    offsetUnmixParameters;          % File offset to the parameters for linear unmixing
    offsetAcquisitionParameters;    % File offset to a block with acquisition parameters
    offsetCharacteristics;          % File offset to a block with user specified properties
    offsetPalette;                  % File offset to a block with detailed color palette properties
    timeDifferenceX;                % The time difference for the acquisition of adjacent pixels in x-direction in seconds
    timeDifferenceY;                % The time difference for the acquisition of adjacent pixels in y-direction in seconds
    timeDifferenceZ;                % The time difference for the acquisition of adjacent pixels in z-direction in seconds
    dimensionP;                     % Number of intensity values in position-direction
    dimensionM;                     % Number of intensity values in tile (mosaic)-direction
    offsetTilePositions;            % File offset to a block with the positions of the tiles
  end
  
  methods
  end
  
end

