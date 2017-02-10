function [ data ] = getAllData( obj )
%GETALLDATA Get all the image data
%   This method extracts all the image data from an LSMReader object
%
% AUTHOR: Stefano Masneri
% Date: 08.02.2017


progBar = TextProgressBar('LSMReader --> Extracting data: ', 30);

data = zeros(obj.height, obj.width, obj.channels, obj.stacks, obj.time, obj.datatype);

numSteps = obj.channels * obj.stacks * obj.time * obj.numTilesRow * obj.numTilesCol;
incr = 1;
typeOut = str2func(obj.datatype);

for indT = 1:obj.time
  for indZ = 1:obj.stacks
    for row = 1:obj.numTilesRow
      for col = 1:obj.numTilesCol

        %seek to beginning of current tile
        tilePos = indT + (indZ-1)*(obj.time) + (col-1)*obj.stacks*obj.time + ...
          (row-1)*obj.stacks*obj.time*obj.numTilesCol;
        fseek(obj.lsmPtr, obj.offsets(tilePos), 'bof');

        %read data
        for indC = 1:obj.channels
          
          progBar.update(incr/numSteps * 100);
          incr = incr + 1;
          
          tmpImg = reshape(typeOut(fread(obj.lsmPtr, obj.pixPerTileRow * obj.pixPerTileCol, ...
            obj.datatypeInput, obj.byteOrder)), obj.pixPerTileCol, obj.pixPerTileRow)';
          
          % Manage overlap
          if 1 ~= row
            ovDiffRow = round(obj.tileOverlap * obj.pixPerTileRow);
          else
            ovDiffRow = 0;
          end
          if 1 ~= col
            ovDiffCol = round(obj.tileOverlap * obj.pixPerTileCol);
          else
            ovDiffCol = 0;
          end
          startR = 1 + (row - 1) * (obj.pixPerTileRow - ovDiffRow);
          startC = 1 + (col - 1) * (obj.pixPerTileCol - ovDiffCol);
          endR   = startR + obj.pixPerTileRow - 1;
          endC   = startC + obj.pixPerTileCol - 1;
          data(startR:endR, startC:endC, indC, indZ, indT) = tmpImg;
        end
      end
    end
  end
end

%squeeze data, to remove singleton dimensions
data = squeeze(data);

end

