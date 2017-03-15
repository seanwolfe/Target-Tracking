classdef Solver
    %Contains two functions. One for going from target locations to pixel
    %frame coordinates. The other one goes from pixel coordinates from
    %target coordinates.
    
    properties
        states, target_pixels, cvcov, observations, id_list;
    end
    
    methods
        
        function obj = Solver(observations, cv_covariance, id_list)
            obj.observations = observations;
            obj.cvcov = cv_covariance;
            obj.id_list = id_list;
        end
        
        %Solve for targets x and y location using x and y pixel coordinates
        %on a frame
        function [targets] = target_from_pixel(Solver, Camera, Plane)
            %Get field of view
            fov = Camera.nfov;
            
            %set camera frame zero
            zerox = - fov(1)/2;
            zeroy = fov(2)/2;
            
            %get noisy pixel coordinates for current frame
            pixels = Solver.target_pixels;
            
            %Transformation Matrix based on noisy heading and position
            trans = [cosd(-Plane.nhead) -sind(-Plane.nhead) Plane.ncurrpos(1); sind(-Plane.nhead) cosd(-Plane.nhead) Plane.ncurrpos(2)];
            
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
                        
                        %Transform to plane frame
                        xtarget = x_dis + zerox;
                        ytarget = -y_dis + zeroy;
                        
                        %transform from plane frame to world frame
                        target = [xtarget; ytarget; 1];
                        target  = trans*target;
                        target = target(1:2);
                        targets = target;
                    else
                        
                        %Calculate distance of target from frame zero
                        x_dis = fov(1)*pixels(1,i)/Camera.res(1);
                        y_dis = fov(2)*pixels(2,i)/Camera.res(2);
                        
                        %Transform to plane frame
                        xtarget = x_dis + zerox;
                        ytarget = -y_dis + zeroy;
                        
                        
                        %transform from plane frame to world frame
                        target = [xtarget; ytarget; 1];
                        target  = trans*target;
                        target = target(1:2);
                        targets = [targets target];
                    end
                end
            else
                targets = [];
            end
        end
        
        function[ellipse] = fuse(~, ell1, ell2, newconf)
            %calculate kalman gain
            k = ell1.cov/(ell1.cov+ell2.cov);
            
            newcov = ell1.cov-k*ell1.cov;
            newmean = ell1.mean'+k*(ell2.mean-ell1.mean)';
            
            ellipse = Ellipse(newcov, newmean, newconf);
            
        end
    end
end


