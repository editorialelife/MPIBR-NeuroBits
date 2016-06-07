function [lsm, iTIFF, iLSM] = readLSMInfo(filename)

    % read TIFF info
    iTIFF = imfinfo(filename);
    
    % set dimensions
    lsm.width = iTIFF(1).Width;
    lsm.height = iTIFF(1).Height;
    lsm.channels = iTIFF(1).SamplesPerPixel;
    ifdCount = size(iTIFF,1);
    lsm.ifdIndex = (1:ifdCount)';
    iconIndex = cat(1, iTIFF.NewSubFileType);
    lsm.ifdIndex(iconIndex == 1) = [];
    lsm.stacks = size(lsm.ifdIndex, 1);
    
    % set image offset
    lsm.stripOffset = cat(1,iTIFF.StripOffsets);
    lsm.stripOffset(iconIndex == 1, :) = [];
    
    % set output type
    lsm.stripByteCount = iTIFF(1).StripByteCounts(1);
    lsm.bitsPerSample = iTIFF(1).BitsPerSample(1);
    switch lsm.bitsPerSample
        case 8
            lsm.readByte = 1;
            lsm.readType = 'uint8';
        case 16
            lsm.readByte = 2;
            lsm.readType = 'uint16';
        case 32
            lsm.readByte = 4;
            lsm.readType='single';
    end
    lsm.readSize = lsm.stripByteCount / lsm.readByte;
    
    % set byteOrder
    lsm.byteOrder = 'ieee-le';
    if strcmp('big-endian', iTIFF(1).ByteOrder)
        lsm.byteOrder = 'ieee-be';
    end
    
    % parse LSM Tag
    if iTIFF(1).UnknownTags.ID ~= 34412
        error('readLSMInfo::LSM tag 34412 missing.');
    end
    
    lsmTagOffset = iTIFF(1).UnknownTags.Offset;
    fid = fopen(filename, 'r');
    fseek(fid, lsmTagOffset, 'bof');
    iLSM = parseLSMTag(fid, lsm.byteOrder);
    fclose(fid);
    
    lsm.xResolution = iLSM.VoxelSizeX * 1e6;
    lsm.yResolution = iLSM.VoxelSizeY * 1e6;
    lsm.unitResolution = 'um';
end


function [iLSM] = parseLSMTag(fid, byteOrder)
        
        % Read part of the LSM info table version 2
        % this provides only very partial information, since the offset indicate that
        % additional data is stored in the file
        
        iLSM.MagicNumber          = fread(fid, 1, 'uint32', byteOrder);
        iLSM.StructureSize        = fread(fid, 1, 'uint32', byteOrder);
        iLSM.DimensionX           = fread(fid, 1, 'uint32', byteOrder);
        iLSM.DimensionY           = fread(fid, 1, 'uint32', byteOrder);
        iLSM.DimensionZ           = fread(fid, 1, 'uint32', byteOrder);
        iLSM.DimensionChannels    = fread(fid, 1, 'uint32', byteOrder);
        iLSM.DimensionTime        = fread(fid, 1, 'uint32', byteOrder);
        iLSM.IntensityDataType    = fread(fid, 1, 'uint32', byteOrder);
        iLSM.ThumbnailX           = fread(fid, 1, 'uint32', byteOrder);
        iLSM.ThumbnailY           = fread(fid, 1, 'uint32', byteOrder);
        iLSM.VoxelSizeX           = fread(fid, 1, 'float64', byteOrder);
        iLSM.VoxelSizeY           = fread(fid, 1, 'float64', byteOrder);
        iLSM.VoxelSizeZ           = fread(fid, 1, 'float64', byteOrder);
        iLSM.OriginX              = fread(fid, 1, 'float64', byteOrder);
        iLSM.OriginY              = fread(fid, 1, 'float64', byteOrder);
        iLSM.OriginZ              = fread(fid, 1, 'float64', byteOrder);
        iLSM.ScanType             = fread(fid, 1, 'uint16', byteOrder);
        iLSM.SpectralScan         = fread(fid, 1, 'uint16', byteOrder);
        iLSM.DataType             = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetVectorOverlay  = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetInputLut       = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetOutputLut      = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetChannelColors  = fread(fid, 1, 'uint32', byteOrder);
        iLSM.TimeInterval         = fread(fid, 1, 'float64', byteOrder);
        iLSM.OffsetChannelDataTypes = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetScanInformatio = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetKsData         = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetTimeStamps     = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetEventList      = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetRoi            = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetBleachRoi      = fread(fid, 1, 'uint32', byteOrder);
        iLSM.OffsetNextRecording  = fread(fid, 1, 'uint32', byteOrder);
        
        % There is more information stored in this table, which is skipped here
        
        %read real acquisition times:
        if ( iLSM.OffsetTimeStamps > 0 )
            
            status =  fseek(fid, iLSM.OffsetTimeStamps, -1);
            if status == -1
                warning('tiffread:TimeStamps', 'Could not locate LSM TimeStamps');
                return;
            end
            
            iLSM.StructureSize          = fread(fid, 1, 'int32', byteOrder);
            NumberTimeStamps       = fread(fid, 1, 'int32', byteOrder);
            for i=1:NumberTimeStamps
                iLSM.TimeStamp(i)     = fread(fid, 1, 'float64', byteOrder);
            end
            
            %calculate elapsed time from first acquisition:
            iLSM.TimeOffset = iLSM.TimeStamp - iLSM.TimeStamp(1);
            
        end
        
        % anything else assigned to S is discarded

  end