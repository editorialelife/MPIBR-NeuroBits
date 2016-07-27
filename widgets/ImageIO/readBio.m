classdef readBio < ImageIO
    methods
        function obj = getMetaData(obj)
            %get everything.. loads complete data too
            result = bfopen(obj.fileName);
            ome = result{1,4};
            
            %dimensions
            try obj.height = double(ome.getPixelsSizeX(0).getValue()); catch obj.height = NaN; end
            try obj.width = double(ome.getPixelsSizeY(0).getValue()); catch obj.width = NaN; end
            try obj.stacks = double(ome.getPixelsSizeZ(0).getValue()); catch obj.stacks = NaN; end
            try obj.time = double(ome.getPixelsSizeT(0).getValue()); catch obj.time = NaN; end
            try obj.channels = double(ome.getPixelsSizeC(0).getValue()); catch obj.channels = NaN; end
            try obj.data_type = char(ome.getPixelsType(0)); catch obj.data_type = 'uint16'; end;
            
            %scales
            obj.scale_size = zeros(1,4);
            try obj.scale_size(1) = double(ome.getPixelsPhysicalSizeX(0).value()); catch obj.scale_size(1) = NaN; end
            try obj.scale_size(2) = double(ome.getPixelsPhysicalSizeY(0).value()); catch obj.scale_size(2) = NaN; end
            try obj.scale_size(3) = double(ome.getPixelsPhysicalSizeZ(0).value()); catch obj.scale_size(3) = NaN; end
            
            %scaling units
            try obj.scale_units{1} = char(ome.getPixelsPhysicalSizeY(0).unit().getSymbol()); catch obj.scale_units{1} = 'Unknown'; end
            try obj.scale_units{2} = char(ome.getPixelsPhysicalSizeX(0).unit().getSymbol()); catch obj.scale_units{2} = 'Unknown'; end
            try obj.scale_units{3} = char(ome.getPixelsPhysicalSizeZ(0).unit().getSymbol()); catch obj.scale_units{3} = 'Unknown'; end
            
            %objective properties
            try obj.refraction_media = char(ome.getObjectiveImmersion(0,0)); catch obj.refraction_media = 'Unknown'; end
            try obj.NA = double(ome.getObjectiveLensNA(0,0)); catch obj.NA = NaN; end
            try obj.objective_name = char(ome.getObjectiveModel(0,0)); catch obj.objective_name = 'Unknown'; end
            try obj.refraction_media = double(ome.getObjectiveSettingsRefractiveIndex(0)); catch obj.refraction_media = NaN; end
            try obj.objective_magnification = double(ome.getObjectiveNominalMagnification(0,0)); catch obj.objective_magnification = NaN; end
            
            %acquisition properties
            try obj.zoom = double(ome.getDetectorZoom(0, 0)); catch obj.zoom = NaN; end
            try obj.gain = double(ome.getDetectorGain(0, 0)); catch obj.gain = NaN; end
            
            %laser properties
            %exc and emission wavelengths
            if obj.channels > 1
                for ch = 0:obj.channels-1
                    try obj.wavelengthExc(ch+1) = double(ome.getChannelExcitationWavelength(0,ch).value()); catch obj.wavelengthExc(ch+1) = NaN; end
                    try obj.wavelengthEm(ch+1) = double(ome.getChannelEmissionWavelength(0,ch).value()); catch obj.wavelengthEm(ch+1) = NaN; end
                end
            else
                try obj.wavelengthExc = double(ome.getChannelExcitationWavelength(0,0).value()); catch obj.wavelengthExc = NaN; end
                try obj.wavelengthEm = double(ome.getChannelEmissionWavelength(0,0).value()); catch obj.wavelengthEm = NaN; end
            end
            result = result{1};
            %% import data
            %preallocate data
            obj.data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, obj.data_type);
            %fill out data array
            numPlanes = size(result,1);
            for k=0:numPlanes-1
                %extract dimensions out of string
                try ch = ome.getPlaneTheC(0,k).getValue()+1; catch ch = 1; end
                try z = ome.getPlaneTheZ(0,k).getValue()+1; catch z = 1; end
                try t = ome.getPlaneTheT(0,k).getValue()+1; catch t = k+1; end
                obj.data(:,:,ch,z,t) = result{k+1,1}';
                %result{i, 1} = [];
                %result{i, 2} = [];
            end
        end
    end
end