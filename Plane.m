classdef Plane
    %Defines the properties of the plane
    
    properties
        %Defined heading (in degrees), altitude, velocity and initial
        %position [x y z].
        heading, alt, vel, currpos; nprevpos, ncurrpos, nhead
        
    end
    
    methods
        function obj = Plane(heading, altitude, velocity, position)
            %Constructor
            obj.heading = heading;
            obj.alt = altitude;
            obj.vel = velocity;
            obj.currpos = position;
        end
        
        function [curr_pos] = translate(Plane)
            %Models Linear motion with possible change in direction
            %Creates a translation vector. Since altitude is assumed to be
            %constant, dz = 0. dy and dx correspond to the translation in x
            %and y respectively
            
            dz = 0;
            %Distance in y = velocity in y * time elapsed (in our case, one
            %iteration
            dy = Plane.vel*sind(90-Plane.heading);
            %Distance in y = velocity in y * time elapsed (in our case, one
            %iteration
            dx = Plane.vel*cosd(90-Plane.heading);
            pos = [dx dy dz];
            
            %update the current position with the calculated translation
            curr_pos = Plane.currpos + pos;
            
        end
        
        function[currpos, heading] = fly(Plane, Search_Area)
            dz = 0;
           
                heading = Plane.heading;
            %if moving along y axis
            if (heading == 0 || heading == 180) 
                %if outside the search area bounds
                 if (Plane.currpos(2) > max(Search_Area.y_length) || Plane.currpos(2) < 0)
                    %turn east
                    heading = 90;
                    dy = 0;
                    dx = Plane.vel*cosd(90-heading);
                 else
                    %go straight
                    dy = Plane.vel*sind(90-heading);
                    dx = 0;
                 end 
            else
                %turn back into search area
                if Plane.currpos(2) > max(Search_Area.y_length)
                    heading = 180;
                    dy = Plane.vel*sind(90-heading);
                    dx = 0;
                %turn back into search area
                elseif Plane.currpos(2) < 0
                    heading = 0;
                    dy = Plane.vel*sind(90-heading);
                    dx = 0;
                end
            end
            
            %move accordingly
            pos = [dx dy dz];
            currpos = Plane.currpos + pos;
        end
                
    end 
end








