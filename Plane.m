classdef Plane
    %Defines the properties of the plane
    
    properties
        %Defined heading (in degrees), altitude, velocity and initial
        %position [x y z].
        heading, alt, vel, ini_pos;
        
    end
    
    methods
        function obj = Plane(heading, altitude, velocity, initial_position)
            %Constructor
            obj.heading = heading;
            obj.alt = altitude;
            obj.vel = velocity;
            obj.ini_pos = initial_position;
        end
        
        function [current_position] = translate(Plane, curr_pos)
            %Models Linear motion with possible change in direction
            %Creates a translation vector. Since altitude is assumed to be
            %constant, dz = 0. dy and dx correspond to the translation in x
            %and y respectively
            
            dz = 0;
            %Distance in y = velocity in y * time elapsed (in our case, one
            %iteration
            dy = Plane.vel*sind(Plane.heading);
            %Distance in y = velocity in y * time elapsed (in our case, one
            %iteration
            dx = Plane.vel*cosd(Plane.heading);
            pos = [dx dy dz];
            %update the currnt position with the calculated translation
            curr_pos = curr_pos + pos;
            current_position = curr_pos;
        end
    end 
end







