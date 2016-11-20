classdef Plane
    %Defines the properties of the plane
    
    properties
        %Defined heading (in degrees), altitude, velocity and initial
        %position [x y z].
        heading, alt, vel, prevpos, currpos; nprevpos, ncurrpos
        
    end
    
    methods
        function obj = Plane(heading, altitude, velocity, position)
            %Constructor
            obj.heading = heading;
            obj.alt = altitude;
            obj.vel = velocity;
            obj.currpos = position;
        end
        
        function [curr_pos, prev_pos] = translate(Plane, curr_pos)
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
            
            %update the current position with the calculated translation
            prev_pos = curr_pos;
            curr_pos = prev_pos + pos;
            
        end
        
        function [curr_noisy_pos, prev_noisy_pos] = gen_p_noise(Plane, curr_noisy_pos)
            %generates the noisy position of the plane at a certain
            %iteration with respect to the true positon
            
            %noise vector, using randn
            noise = 4*[randn(size(Plane.currpos(1))) randn(size(Plane.currpos(2))) randn(size(Plane.currpos(3)))];
            
            %add the noise to the true position
            prev_noisy_pos = curr_noisy_pos;
            curr_noisy_pos = Plane.currpos + noise;
        end
        
    end 
end








