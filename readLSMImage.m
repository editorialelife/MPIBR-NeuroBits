function img = readLSMImage( filename, lsm, idxStack, idxChannel)
% read LSM image
    iH = lsm.height;
    iW = lsm.width;
    iC = size(idxChannel, 1);
    iZ = size(idxStack, 1);
    img = zeros(iH,iW,iZ,iC, 1, lsm.readType);
    fid = tifflib('open', filename, 'r');
    for z = 1 : iZ
        tifflib('setDirectory',fid, lsm.ifdIndex(idxStack(z))-1);
        for c = 1 : iC
            img(:,:,z,c) = tifflib('readEncodedStrip',fid,idxChannel(c)-1);
        end
    end
    tifflib('close', fid);
end

