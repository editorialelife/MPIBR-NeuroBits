function obj = readRawMetadataSegm( obj )
%READMETADATASEGM Read metadata for segment of type ZISRAWMETADATA
%   Extract information from ZISRAWMETADATA segments. The first part of the
%   segment contains the header, namely the size of the XML and the size of
%   the Attachment. After that there is the xml field and the optional
%   attachment field
%
% AUTHOR: Stefano Masneri
% Date: 13.10.2016

  % Get xml info
  xmlSize = int32(fread(obj.cziPtr, 1, 'int32'));
  attSize = int32(fread(obj.cziPtr, 1, 'int32'));  % currently unused
  empty   = int32(fread(obj.cziPtr, 62, 'int32')); % spare space

  % Read xml
  xmlData = fread(obj.cziPtr, xmlSize, '*char')';
  
  % Convert to struct
  metadataStruct = xml2struct(xmlData);
  
  % Now we have an incredibly nested structure. go through all the fields
  % and try to extract all the metadata info from it
  top = metadataStruct.ImageDocument.Metadata;
  
  % The field "Version" is not of interest, it will be ignored for the
  % moment
  
  %% The field "Information" contains several important metadata 
  
  % Microscope Info
  microscopeInfo = top.Information.Instrument;
  try
    obj.microscopeName = microscopeInfo.Microscopes.Microscope.System.Text;
  catch
    disp('Microscope name not available')
  end
  
  try
    obj.NA = str2double(microscopeInfo.Objectives.Objective.LensNA.Text);
  catch
    disp('Numerical aperture info not available')
  end

  try
    obj.refractionMedia = microscopeInfo.Objectives.Objective.Immersion.Text;
  catch
    disp('Refraction media info not available')
  end

  try
    % we don't know which light source is used... so we don't know the name
    % of the structure either!
    obj.wavelengthExc = [];
    lightSrc = microscopeInfo.LightSources.LightSource;
    for k = 1:length(lightSrc)
    	lst = lightSrc{k}.LightSourceType;
      fn = fieldnames(lst);
      obj.wavelengthExc = [obj.wavelengthExc, str2double(lst.(fn{1}).Wavelength.Text)];
    end
  catch
    disp('Excitation wavelength info not available')
  end

  try
    % info stored in Instrument.Detectors.Detector ???
  catch
    disp('Zoom and Gain info not available')
  end
  
  % Image info
  imgInfo = top.Information.Image;
  pixType = imgInfo.PixelType.Text;
  switch pixType
    case 'Gray8'
      obj.datatype = 'uint8';
    case 'Gray16'
      obj.datatype = 'uint16';
    case 'Gray32Float'
      obj.datatype = 'double';
    case 'Bgr24'
      obj.datatype = 'uint8';
    case 'Bgr48'
      obj.datatype = 'uint16';
    case 'Bgr96Float'
      obj.datatype = 'float';
    case 'Bgra32'
      obj.datatype = 'uint8';
    otherwise
      % one of Gray64ComplexFloat or Bgr192ComplexFloat
      warning('CZIReader.readMetadataSegm: Pixel type not supported')
  end
  % now the dimensions
  try
    obj.channels = str2double(imgInfo.SizeC.Text);
  catch
    obj.channels = 1;
  end
  try
    obj.stacks = str2double(imgInfo.SizeZ.Text);
  catch
    obj.stacks = 1;
  end
  try
    obj.series = str2double(imgInfo.SizeS.Text);
  catch
    obj.series = 1;
  end
  try
    obj.time = str2double(imgInfo.SizeT.Text);
  catch
    obj.time = 1;
  end
  try
    obj.tile = str2double(imgInfo.SizeM.Text);
  catch
    obj.tile = 1;
  end
  obj.pixPerTileRow = str2double(imgInfo.SizeY.Text); % mandatory
  obj.pixPerTileCol = str2double(imgInfo.SizeX.Text); % mandatory
  
  %% The field "Experiment" contains information about the tiles
  try
    tileInfo = top.Experiment.ExperimentBlocks.AcquisitionBlock.TilesSetup.PositionGroups.PositionGroup;
    obj.numTilesRow = str2double(tileInfo.TilesY.Text);
    obj.numTilesCol = str2double(tileInfo.TilesX.Text);
    obj.tileOverlap = str2double(tileInfo.TileAcquisitionOverlap.Text);
    obj.width = round((obj.numTilesCol - 1) * (1 - obj.tileOverlap) * obj.pixPerTileCol + ...
      obj.pixPerTileCol);
    obj.height = round((obj.numTilesRow - 1) * (1 - obj.tileOverlap) * obj.pixPerTileRow + ...
      obj.pixPerTileRow);
  catch
    disp('CZIReader.readMetadataSegm: field Experiment not available')
    % assume single tile
    obj.height = obj.pixPerTileRow;
    obj.width = obj.pixPerTileCol;
  end
  
  %% The field "DisplaySetting" has info related to the Channels
  ch = top.DisplaySetting.Channels.Channel;
  for k = 1:length(ch) %check all channels
    obj.channelInfo = [obj.channelInfo, ChannelInfo(ch{k}, 'CZI')];
  end
  
  % The field "Scaling" contain info about the pixels physical size
  scale = top.Scaling.Items.Distance;
  obj.scaleSize = ones(1,3);
  for k = 1:length(scale)
    switch scale{k}.Attributes.Id
      case 'X'
        obj.scaleSize(1) = str2double(scale{k}.Value.Text);
      case 'Y'
        obj.scaleSize(2) = str2double(scale{k}.Value.Text);
      case 'Z'
        obj.scaleSize(3) = str2double(scale{k}.Value.Text);
      otherwise
        warning('CZIReader.readRawMetadataSegm: unrecognized dimension for scale')
    end
  end
end