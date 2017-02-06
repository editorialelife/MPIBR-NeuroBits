classdef LSMTimeStamps
  %TIMESTAMPS Simple class representing the Timestamps part of LSM metadata
  %
  
  properties
    size             = 0;
    numberTimeStamps = 0;
    stamps           = 0;
    timeStamps       = 0;
    timeSteps        = [];
    avgStep          = nan;
  end
  
  properties (Constant = true)
    FIELDS = 2;
    FIELDS_SIZE = 2*4; %They are all int32
  end
  
  methods
    function obj = TimeStamps(fid, offsetTimeStamps)
      if 0 == offsetTimeStamps
        return
      else
        if fseek(fid, offsetTimeStamps, 'bof')
          error(['Received error on file seek to offsetTimeStamps(' offsetTimeStamps '): ' ferror(fid)]); 
        end
      	dataread = zeros(obj.FIELDS, 1);
        for i = 1:obj.FIELDS
          [val, readNum] = fread(fid, 1, 'int32');
          if readNum ~= 1
            error(['Failed to read more than ' num2str(readNum) ' values']);
          end
          dataread(i) = val;
        end
        obj.size = dataread(1);
        obj.numberTimeStamps = dataread(2);
        obj.stamps = fread(fid, obj.numberTimeStamps, 'float64');
        obj.timeStamps = obj.stamps - obj.stamps(1);
        obj.timeSteps = diff(obj.stamps);
        obj.avgStep = mean(obj.timeSteps);
      end
    end
  end
  
end

