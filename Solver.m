classdef Solver
    %Contains two functions. One for going from target locations to pixel
    %frame coordinates. The other one goes from pixel coordinates from
    %target coordinates.
    
    properties
        states, target_pixels;
    end
    
    methods
        %Solve for targets x and y location using x and y pixel coordinates
        %on a frame
        function [targets] = target_from_pixel(Solver, Camera, Plane)
            %Get field of view
            fov = Camera.fov;
            
            %set camera frame zero
            zerox = Plane.currpos(1) - fov(1)/2;
            zeroy = Plane.currpos(2) + fov(2)/2;
            
            %get pixel coordinates for current frame
            pixels = Solver.target_pixels;
                 
            %Calc x and y distance corresponding to x and y pixel
            %coordinates
            %iterate over all the targets in the frame
           if pixels ~= 0 
            for i = 1:size(pixels,2)
                %If the first iteration, you want to initialize the
                %variable that holds everything
                if i == 1
                    %Calculate distance of target from frame zero
                    x_dis = fov(1)*pixels(1,i)/Camera.res(1);
                    y_dis = fov(2)*pixels(2,i)/Camera.res(2);
                    
                    %Transform to world frame
                    xtarget = x_dis + zerox;
                    ytarget = -y_dis + zeroy;
                    
                    %store target
                    targets = [xtarget; ytarget];
                else
                
                %Calculate distance of target from frame zero
                x_dis = fov(1)*pixels(1,i)/Camera.res(1);
                y_dis = fov(2)*pixels(2,i)/Camera.res(2);
                    
                %Transform to world frame
                xtarget = x_dis + zerox;
                ytarget = -y_dis + zeroy;
                    
                %store target
                target = [xtarget; ytarget];
                targets = [targets target];
                end
            end
           else
               targets = 0;
           end
        end
        
        %solve for target pixel coordinates from target positions
        function [target_pixels] = pixel_from_target(Solver, Camera, Plane, Search_Area)
            %Calc field of view
            fov = Camera.fov;
            
            %camera frame zero
            zerox = Plane.currpos(1) - fov(1)/2;
            zeroy = Plane.currpos(2) + fov(2)/2;
            
            %Calc frame x limits
            leftx = Plane.currpos(1) - fov(1)/2;
            rightx = Plane.currpos(1) + fov(1)/2;
            
            %Calc frame y limits
            bottomy = Plane.currpos(2) - fov(2)/2;
            topy = Plane.currpos(2) + fov(2)/2;
            
            count = 0;
            
                  
            %check to see if any targets within frame limits
            %iterate over the number of targets
            for i = 1:1:size(Search_Area.targets,2)
                %while no targets within frame
                if count == 0
                    %If target is within the x limits of frame
                    if leftx <= Search_Area.targets(1,i) && Search_Area.targets(1,i) <= rightx
                        %If target is within the y limits of frame
                        if bottomy <= Search_Area.targets(2,i) && Search_Area.targets(2,i) <= topy
                            
                            %The x and y distances of the target relative to the zero of the frame
                            x_dis = Search_Area.targets(1,i) - zerox;
                            y_dis = -(Search_Area.targets(2,i) - zeroy);
                            
                            %The corresponding x and y pixels of the target
                            pixel = [x_dis/fov(1)*Camera.res(1); y_dis/fov(2)*Camera.res(2)];
                            
                            %store pixel coordinates
                            target_pixels = pixel;
                            
                            count = 1;
                        end
                    end
                else
                    %If target is within the x limits of frame
                    if leftx <= Search_Area.targets(1,i) && Search_Area.targets(1,i) <= rightx
                        
                        %If target is within the y limits of frame
                        if bottomy <= Search_Area.targets(2,i) && Search_Area.targets(2,i) <= topy
                            
                            %The x and y distances of the target relative to the zero
                            %of the frame
                            x_dis = Search_Area.targets(1,i) - zerox;
                            y_dis = -(Search_Area.targets(2,i) - zeroy);
                            
                            %The corresponding x and y pixels of the target
                            pixel = [x_dis/fov(1)*Camera.res(1); y_dis/fov(2)*Camera.res(2)];
                            
                            %store all pixel coordinates
                            target_pixels = [target_pixels pixel]; 
                        end
                    end
                end
            end
            %if no targets in frame
            if count == 0
                target_pixels = 0;
            end
        end
           
    end
    
end

