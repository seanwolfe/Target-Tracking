classdef Camera
    %The camera class is meant to model the parameters of the camera and 
    %lens combinations thatwill be used in the competition: 
    %Camera: FL3-U3-88S2C-C (PointGrey)
    %Lens: Tamron model 23FM25SP
    %Characteristics:
        %an horizontal sensor width of: 5.76mm
        %a vertical sensor width of: 4.29mm
        %a resolution of: 4096 x 2160
        %a focal length of 25mm
        
    
    properties
        %sensor_x is horizontal, sensor_y is vertical
        sensor_x, sensor_y, f, res;
    end
    
    methods
        %constructor
        function obj = Camera(sensor_x, sensor_y, resolution, focal_length)
            obj.sensor_x = sensor_x;
            obj.sensor_y = sensor_y;
            obj.f = focal_length;
            obj.res = resolution;
        end
        
        %project_image, determines the field of view for a certain camera
        %and lens combination, along with the plane's altitude
        %It returns the image projected onto the ground. It uses the fact
        %that image_width/height = Distance from Ground *
        %                          horizontal/vertical sensor length/focal length
        function [image] = project_image(Camera, Plane)
            image_x_width = Plane.alt*Camera.sensor_x/Camera.f;
            image_y_height = Plane.alt*Camera.sensor_y/Camera.f;
        end
    end
    
end

