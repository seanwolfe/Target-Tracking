classdef Camera
    %The camera class is meant to model the parameters of the camera and 
    %lens combinations thatwill be used in the competition: 
    %Camera: FL3-U3-88S2C-C (PointGrey)
    %Lens: Tamron model 
    %Characteristics:
        %an horizontal sensor width of: 5.76mm
        %a vertical sensor width of: 4.29mm
        %a resolution of: 4096 x 2160
        %a focal length of 8mm
        
    
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
        function [rect] = project_image(Camera, Plane)
            
            %projection of the camera frame onto the search area
            image = [Plane.alt*Camera.sensor_x/Camera.f; Plane.alt*Camera.sensor_y/Camera.f];
            halfx = image(1)/2;
            halfy = image(2)/2;
            
            %if the plane is at the center of the rectangle (i.e camera poiting straight down), 
            %p1,p2,p3,p4 are the vertices of the rectangle 
            
            %Transformation Matrix
            trans = [cosd(Plane.heading) -sind(Plane.heading) Plane.pos(1); sind(Plane.heading) cosd(Plane.heading) Plane.pos(2); 0 0 1];
            
            %Generate camera frame relative to plane
            p1 = [-halfx halfy 1];
            p2 = [halfx halfy 1];
            p3 = [halfx -halfy 1];
            p4 = [-halfx -halfy 1];
            p5 = [Plane.pos(1) Plane.pos(2) Plane.pos(3)];
            
            %Transform camera frame to world
            p1t = trans*p1';
            p2t = trans*p2';
            p3t = trans*p3';
            p4t = trans*p4';
            
            
            
            rect = [p5; p1t'; p2t'; p5; p3t'; p2t'; p5; p4t'; p1t'; p4t'; p3t'];
            
        
        end
    end
    
end

