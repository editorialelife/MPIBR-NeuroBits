classdef WidgetImageBrowserModel < handle
    
    properties (Access = public)
        
        stack
        channel
        
    end
    
    properties (SetObservable = true)
        
        cdata
        
    end
    
    properties (Access = private)
        
        imgptr
        
    end
    
    
    %% --- constructor/update methods --- %%
    methods
        
        function obj = WidgetImageBrowserModel()
            
            % defaults
            obj.imgptr = [];
            obj.cdata = [];
            obj.stack = 1;
            obj.channel = 1;
            
        end
        
        
        function obj = updateFile(obj, varfilename)
            
            obj.imgptr = imageIOPtr(varfilename);
            obj.stack = 1;
            obj.channel = 1;
            
        end
        
        function obj = updateCData(obj)
            
            obj.cdata = obj.imgptr.read('C', obj.channel, 'Z', obj.stack);
            
        end
        
        function obj = updateProjection(obj, vartext)
            
            img = obj.imgptr.read('C', obj.channel);
            switch vartext
                
                case 'max'
                    obj.cdata = max(img, [], 3);
                    
                case 'mean'
                    obj.cdata = mean(img, 3);
                    
                case 'std'
                    obj.cdata = std(double(img), [], 3);
                    
            end
            
            
        end
        
        
        function obj = updateIndexStack(obj, varstep)
            
            % varstep value
            if varstep > obj.requestSizeStack
                
                varstep = sign(varstep);
                
            end
            
            % increment stack counter
            obj.stack = obj.stack + varstep;
            
            % floor
            if obj.stack < 1
                
                obj.stack = obj.requestSizeStack;
                
            end
            
            % ceil
            if obj.stack > obj.requestSizeStack
                
                obj.stack = 1;
                
            end
            
        end
        
        function obj = updateIndexChannel(obj, varstep)
            
            % varstep value
            if varstep > obj.requestSizeChannel
                
                varstep = sign(varstep);
                
            end
            
            % increment channel counter
            obj.channel = obj.channel + varstep;
            
            % floor
            if obj.channel < 1
                
                obj.channel = obj.requestSizeChannel;
                
            end
            
            % ceil
            if obj.channel > obj.requestSizeChannel
                
                obj.channel = 1;
                
            end
            
        end
        
        
    end
    
    %% --- request methods --- %%
    methods 
        
        function varnum = requestSizeStack(obj)
            
            varnum = obj.imgptr.stacks;
            
        end
        
        function varnum = requestSizeChannel(obj)
            
            varnum = obj.imgptr.channels;
            
        end
        
        function varnum = requestResolution(obj, vartext)
            
            xres = obj.imgptr.XResolution;
            if isempty(xres)
                xres = 1;
            end
            yres = obj.imgptr.YResolution;
            if isempty(yres)
                yres = 1;
            end
            
            switch lower(vartext)
                case 'pixels'
                    varnum = size(obj.cdata);
                case 'units'
                    varnum = size(obj.cdata) ./[yres, xres];
            end
            
        end
        
        function varnum = requestCLimit(obj)
            
            varnum = [min(obj.cdata(:)), max(obj.cdata(:))];
        end
        
        function vartype = requestBitDepth(obj)
            
            vartype = obj.imgptr.datatype;
            
        end
    end
    
end