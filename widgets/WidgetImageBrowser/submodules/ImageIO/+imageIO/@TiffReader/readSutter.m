function [ data ] = readSutter( obj, cols, rows, channels, stacks, timeseries )
%READSUTTER Read data from Tiff files created with Sutter microscope

data = zeros(rows, cols, channels, stacks, timeseries, obj.datatype);
idx = 1;

idxS = 1;
for s = stacks
  idxT = 1;
  for t = timeseries
    idxCh = 1;
    for ch = channels
      
      img = obj.readImage(idx);
      idx = idx + 1;
      data(:, :, idxCh, idxS, idxT) = img(rows, cols);
      
      idxCh = idxCh + 1;
    end
    idxT = idxT + 1;
  end
  idxS = idxS + 1;
end

end

