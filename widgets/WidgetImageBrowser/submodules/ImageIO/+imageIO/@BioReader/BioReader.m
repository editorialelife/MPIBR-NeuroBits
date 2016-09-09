classdef BioReader < imageIO.ImageIO
%BIOREADER Wrapper for Matlab bioFormat package
% This class acts as a wrapper for the BioFormat package.
% This class uses the bioformat library to open a file and it then tries to
% read all the metadata and store them in the properties defined in the
% ImageIO class.
% Author: Florian.Vollrath@brain.mpg.de
%
% Revision history:
%   25.08.2016 Stefano: testdebug and test with files provided by Stephan
  
  properties
    bfPtr;       % BIOFORMAT reader pointer
  end
  
  methods
    function obj = BioReader(filename)
    %BIOREADER Constructs the BioReader object
    % The constructor calls the superclass constructor and then tries to
    % extract as many metadata as possible
    
      % Must call explictily because we pass one argument
      obj = obj@imageIO.ImageIO(filename);
      
      obj.bfPtr = bfGetReader(obj.fileFullPath);
      obj = obj.readMetadata();
    end
    
    function data = getData(obj, varargin)
    %GETDATA extracts image data
    % This function reads data from the bioformat file. If no parameters
    % are specified for a specific dimension, all the data will be
    % extracted.
    % INPUT
    %   obj: class instance
    %   varargin: Name-Value arguments. Allowed parameters are 'X', 'Y',
    %     'C', 'Z', 'T', 'TileRow', 'TileCol'
    % OUTPUT
    %   data: image data, up to 5 dimension (in this order: XYCZT). If only one
    %   	channel is extracted (or the input is single channel), the singleton
    %   	dimension relative to channel is squeezed.
    % EXAMPLES
    %   myBR = BioReader('testfile.lsm');
    %   data = myBR.getData(); %Reads all the data
    %   data = myBR.getData('X', 1:10) %Reads only the first then rows
    %   data = myBR.getData('X', 1:2:end) %reads only the odd rows
    %   data = myBR.getData('C', 1, 'Z', 4:8) %reads tiles 4 to 8, only 1st channel
    %   data = myBR.getData('TileRow', 1:6, 'TileCol, 2:4) %Reads first six rows of
    %     tiles, and column tiles from 2 to 4
    
      if isempty(varargin) % Read all the data
        data = obj.getAllData();
      elseif 1 == obj.tile
        obj.getDataNoTiles(varargin);
      else
        obj.getTiledData(varargin);
      end
    
%       ome = obj.bfPtr{1,4};
%       %result = result{1}; ????
%       
%       % import data
%       %preallocate data
%       data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, obj.data_type);
%       %fill out data array
%       numPlanes = size(result,1);
%       for k=0:numPlanes-1
%         %extract dimensions out of string
%         try
%           ch = ome.getPlaneTheC(0,k).getValue()+1;
%         catch
%           ch = 1;
%         end
%         try
%           z = ome.getPlaneTheZ(0,k).getValue()+1;
%         catch
%           z = 1;
%         end
%         try
%           t = ome.getPlaneTheT(0,k).getValue()+1;
%         catch
%           t = k+1;
%         end
%         obj.data(:,:,ch,z,t) = result{k+1,1}';
%         %result{i, 1} = [];
%         %result{i, 2} = [];
%       end
    end
    
    function close(obj)
    %CLOSE Close object instances.
    %Close performs the cleanup and release of the instantiated object
      obj.result.close();
    end
    
    function obj = readMetadata(obj)
    %READMETADATA Access the OME metadata and sets the object properties
    %The function accesses the OME metadata. The method takes as input the
    %metadata stored in a Java Hashtable (as they are returned by the 
    %BioFormat package) object and from there accesses all the required 
    %metadata. If the metadata is not available a default value is set
    
      % get OME metadata object
      ome = obj.bfPtr.getMetadataStore();
      
      % get Pixels Physical Size
      try
        obj.pixelSizeX = double(ome.getPixelsPhysicalSizeX(0).value());
      catch
        obj.pixelSizeX = 1;
      end
      try
        obj.pixelSizeY = double(ome.getPixelsPhysicalSizeY(0).value());
      catch
        obj.pixelSizeY = 1;
      end
      try
        obj.pixelSizeZ = double(ome.getPixelsPhysicalSizeZ(0).value());
      catch
        obj.pixelSizeZ = 1;
      end
      
      
      %for tiled data: get total number of tiles and accessory info
      try
        obj.tile = ome.getImageCount();
      catch
        obj.tile = 1;
      end
      obj = obj.setTileProperties(ome);
      
      %dimensions
      try
        obj.height = round(obj.pixPerTileRow * (1 + (obj.numTilesRow - 1) * (1 - obj.tileOverlap)));
      catch
        obj.height = NaN;
      end
      try
        obj.width = round(obj.pixPerTileCol * (1 + (obj.numTilesCol - 1) * (1 - obj.tileOverlap)));
      catch
        obj.width = NaN;
      end
      try
        obj.stacks = double(ome.getPixelsSizeZ(0).getValue());
      catch
        obj.stacks = NaN;
      end
      try
        obj.time = double(ome.getPixelsSizeT(0).getValue());
      catch
        obj.time = NaN;
      end
      try
        obj.channels = double(ome.getPixelsSizeC(0).getValue());
      catch
        obj.channels = NaN;
      end
      try
        obj.data_type = char(ome.getPixelsType(0));
      catch
        obj.data_type = 'uint16';
      end

      %scales
      obj.scale_size = zeros(1,3);
      try
        obj.scale_size(1) = double(ome.getPixelsPhysicalSizeX(0).value());
      catch
        obj.scale_size(1) = NaN;
      end
      try
        obj.scale_size(2) = double(ome.getPixelsPhysicalSizeY(0).value());
      catch
        obj.scale_size(2) = NaN;
      end
      try
        obj.scale_size(3) = double(ome.getPixelsPhysicalSizeZ(0).value());
      catch
        obj.scale_size(3) = NaN;
      end

      %scaling units
      try
        obj.scale_units{1} = char(ome.getPixelsPhysicalSizeY(0).unit().getSymbol());
      catch
        obj.scale_units{1} = 'Unknown';
      end
      try
        obj.scale_units{2} = char(ome.getPixelsPhysicalSizeX(0).unit().getSymbol());
      catch
        obj.scale_units{2} = 'Unknown';
      end
      try
        obj.scale_units{3} = char(ome.getPixelsPhysicalSizeZ(0).unit().getSymbol());
      catch
        obj.scale_units{3} = 'Unknown';
      end

      %objective properties
      try
        obj.refraction_media = char(ome.getObjectiveImmersion(0,0));
      catch
        obj.refraction_media = 'Unknown';
      end
      try
        obj.NA = double(ome.getObjectiveLensNA(0,0));
      catch
        obj.NA = NaN;
      end
      try
        obj.objective_name = char(ome.getObjectiveModel(0,0));
      catch
        obj.objective_name = 'Unknown';
      end
      try
        obj.refraction_media = double(ome.getObjectiveSettingsRefractiveIndex(0));
      catch
        obj.refraction_media = NaN;
      end
      try
        obj.objective_magnification = double(ome.getObjectiveNominalMagnification(0,0));
      catch
        obj.objective_magnification = NaN;
      end

      %acquisition properties
      try
        obj.zoom = double(ome.getDetectorZoom(0, 0));
      catch
        obj.zoom = NaN;
      end
      try
        obj.gain = double(ome.getDetectorGain(0, 0));
      catch
        obj.gain = NaN;
      end

      %laser properties
      %exc and emission wavelengths
      if obj.channels > 1
        for ch = 0:obj.channels-1
          try
            obj.wavelengthExc(ch+1) = double(ome.getChannelExcitationWavelength(0,ch).value());
          catch
            obj.wavelengthExc(ch+1) = NaN;
          end
          try
            obj.wavelengthEm(ch+1) = double(ome.getChannelEmissionWavelength(0,ch).value());
          catch
            obj.wavelengthEm(ch+1) = NaN;
          end
        end
      else
        try
          obj.wavelengthExc = double(ome.getChannelExcitationWavelength(0,0).value());
        catch
          obj.wavelengthExc = NaN;
        end
        try
          obj.wavelengthEm = double(ome.getChannelEmissionWavelength(0,0).value());
        catch
          obj.wavelengthEm = NaN;
        end
      end
    
    end
  end
  
  methods (Access = protected)
    function obj = setTileProperties(obj, ome)
    %SETTILEPROPERTIES Set all properties related to tiles
      
      if 1 == obj.tile
        obj.rowTilePos = 1;
        obj.colTilePos = 1;
        obj.numTilesRow = 1;
        obj.numTilesCol = 1;
        obj.tileOverlap = 0;
        obj.pixPerTileRow = ome.getPixelsSizeX(0).getValue();
        obj.pixPerTileCol = ome.getPixelsSizeY(0).getValue();
      else
        obj.rowTilePos = nan(1, obj.tile);
        obj.colTilePos = nan(1, obj.tile);
        try
          for k = 1:obj.tile
            obj.rowTilePos(k) = double(ome.getPlanePositionX(k-1,0).value());
            obj.colTilePos(k) = double(ome.getPlanePositionY(k-1,0).value());
          end
          obj.numTilesRow = length(unique(obj.rowTilePos));
          obj.numTilesCol = length(unique(obj.colTilePos));
        catch
          obj.rowTilePos = nan(1, obj.tile);
          obj.colTilePos = nan(1, obj.tile);
          obj.numTilesRow = nan;
          obj.numTilesCol = nan;
        end
        try
          obj.pixPerTileRow = double(ome.getPixelsSizeX(0).getValue());
          obj.pixPerTileCol = double(ome.getPixelsSizeY(0).getValue());
        catch
          obj.pixPerTileRow = NaN;
          obj.pixPerTileCol = NaN;
        end
        try
          if obj.numTilesRow > 1
            adjacentDiff = obj.rowTilePos(2) - obj.rowTilePos(1);
            obj.tileOverlap = 1 - adjacentDiff / (obj.pixPerTileRow * obj.pixelSizeX);
          elseif obj.numTilesCol > 1
            adjacentDiff = obj.colTilePos(2) - obj.colTilePos(1);
            obj.tileOverlap = 1 - adjacentDiff / (obj.pixPerTileCol * obj.pixelSizeY);
          else
            obj.tileOverlap = 0;
          end
        catch
          obj.tileOverlap = 0;
        end
        
      end
    end
  end
end