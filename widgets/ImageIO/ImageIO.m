classdef ImageIO < handle
    %IMAGEIO read/write various image formats
    %   use BioFormats
    %   use TIFF lib
    %   metadata
    
    
    %% --- Metadata Properties --- %%%
    properties
        fileName
        data
        
        height
        width
        channels
        stacks
        time
        tile
        
        data_type
        
        scale_size %x,y,z,t
        scale_units
        scale_time
        
        time_pixel
        time_line
        time_frame
        time_stack
        
        zoom
        gain
        
        wavelengthExc
        wavelengthEm
        refraction_media
        NA
        
        microscope_name
        microscope_type
        
        objective_magnification
        objective_name
        
    end
    
    methods
    end
    
end

