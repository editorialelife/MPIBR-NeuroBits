classdef ChannelInfo
  %CHANNELINFO Specify info about image channels (dye, color, ...)
  %   This class contains basic information about the color channels of an
  %   image. It is mostly used to display info, as well as to plot the
  %   image using the same colors used by ZEN or other visualization tools.
  %
  % Author: Stefano.Masneri@brain.mpg.de
  % Date: 12.10.2016
  
  properties
    dyeName = '';         % name of the dye used
    color = nan;          % RGB triplet representing the color used
    gamma = 1;            % transparency level (1 = fully opaque)
  end
  
  methods
    function obj = ChannelInfo(data, whereFrom)
    % CHANNELINFO Constructor f the class
    % The constructor takes as input a data structure, as well as a string
    % specifying the input file format or reader used. This is because
    % different file formats have different way of storing information
    % about the channels.
    % Currently supported Image Formats:
    %   CZI
    %   
      if strcmpi('CZI', wherefrom)
      else
        warning('ChannelInfo.ChannelInfo: Unsupported input filetype'
        obj = [];
      end
    end
  end
  
end

