classdef LSMChannelColors
  %LSMCHANNELCOLORS Simple class representing the Channel Colors part of LSM metadata
  %
  
  properties
    blockSize     = 0;
    numberColors  = 0;
    numberNames   = 0;
    colorsOffset  = 0;
    namesOffset   = 0;
    mono          = 0;
    colors        = {};
    names         = {};
  end
  
  properties (Constant = true)
    FIELDS = 6;
    FIELDS_SIZE = 6*4; %They are all int32
  end
  
  methods
    function obj = LSMChannelColors(fid, offsetChannelColors)
      if 0 == offsetChannelColors
        return
      else
        if fseek(fid, offsetChannelColors, 'bof')
          error(['Received error on file seek to offsetChannelColors(' offsetChannelColors '): ' ferror(fid)]); 
        end
        % Get file length
        pos = ftell(fid);
        fseek(fid, 0,'eof');
        flen = ftell(fid);
        if fseek(fid, pos, 'bof') == -1
          error(['Received error on file seek: ' ferror(fid)]);
        end
        fleft = flen - pos;
        if obj.FIELDS_SIZE > fleft
          error('Not enough bytes left in file to read ChannelColors info');
        end
        
        dataread = zeros(obj.FIELDS, 1);
        for i = 1:obj.FIELDS
          [val, readNum] = fread(fid, 1, 'int32');
          if readNum ~= 1
            error(['Failed to read more than ' num2str(readNum) ' values']);
          end
          dataread(i) = val;
        end
        obj.blockSize    = dataread(1);
        obj.numberColors = dataread(2);
        obj.numberNames  = dataread(3);
        obj.colorsOffset = dataread(4);
        obj.namesOffset  = dataread(5);
        obj.mono         = dataread(6);
      end
      
      %now read Channel RGB values
      fseek(fid, offsetChannelColors + obj.colorsOffset, 'bof');
      for i = 1:obj.numberColors
        R = fread(fid, 1, 'uint8');
        G = fread(fid, 1, 'uint8');
        B = fread(fid, 1, 'uint8');
        obj.colors{i} = [R G B];
      end
      
      %and finally channel names
      fseek(fid, offsetChannelColors + obj.namesOffset, 'bof');
      for i = 1:obj.numberNames
        namelength = fread(fid, 1, 'uint32');
        name = char(fread(fid, namelength, 'char')');
        if uint8(name(end)) == 0
            name = name(1:end-1);
        end
        obj.names{i} = name;
      end
    end
  end
  
end

