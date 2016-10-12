function obj = readMetadataSegm( obj )
%READMETADATASEGM Read metadata for segment of type ZISRAWMETADATA
%   Extract information from ZISRAWMETADATA segments. The first part of the
%   segment contains the header, namely the size of the XML and the size of
%   the Attachment. After that there is the xml field and the optional
%   attachment field
  
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
  
  %% The field "DisplaySetting" has info related to the Channels
  ch = top.DisplaySetting.Channels.Channel;
  for k = 1:length(ch) %check all channels
    obj.channelInfo = [obj.channelInfo, ChannelInfo(ch{k})];
  end
  
  % The field "Scaling" 
end