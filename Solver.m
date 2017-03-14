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
        
        %solve for target pixel coordinates from target positions
        function [target_pixels] = pixel_from_target(Solver, Camera, Plane, Search_Area)
            %Calc field of view
            fov = Camera.fov;
             
            %Transformation Matrix
            trans = inv([cosd(-Plane.heading) -sind(-Plane.heading) Plane.currpos(1); sind(-Plane.heading) cosd(-Plane.heading) Plane.currpos(2); 0 0 1]); 
                        
            %camera frame zero
            zerox = -fov(1)/2;
            zeroy = fov(2)/2;
            
            %Calc frame x limits
            rightx =  fov(1);
            
            %Calc frame y limits
            bottomy = fov(2);
            
            count = 0;
                              
            %check to see if any targets within frame limits
            %iterate over the number of targets
            for i = 1:1:size(Search_Area.targets,2)
                %while no targets within frame
                
                %Find x and y relative to plane
                xy_plane = trans*[Search_Area.targets(1,i); Search_Area.targets(2,i); 1];
                
                %The x and y distances of the target relative to the zero of the frame
                x_dis = xy_plane(1) - zerox;
                y_dis = -(xy_plane(2) - zeroy);
                
                if count == 0
                    %If target is within the x limits of frame
                    if 0 <= x_dis && x_dis <= rightx
                        %If target is within the y limits of frame
                        if 0 <= y_dis && y_dis <= bottomy
                                                        
                            %The corresponding x and y pixels of the target
                            pixel = [x_dis/fov(1)*Camera.res(1); y_dis/fov(2)*Camera.res(2)];
                            
                            %covariance assosiated with CV algo
                            temp = 50*rand(4,1);
                            r = [temp(1) temp(2); temp(3)  temp(4)];
                            %just to ensure the matrix is pos def, but in real
                            %implementation it is assumed
                            cv_cov = r*r';
                            %generate relevant samples from cov
                            L = chol(cv_cov);
                            noise = L*randn(2,1);
                            
                            %store pixel coordinates                            
                            target_pixels = pixel + noise;
                            
                            count = 1;
                        end
                    end
                else
                    %If target is within the x limits of frame
                    if 0 <= x_dis && x_dis <= rightx
                        
                        %If target is within the y limits of frame
                        if 0 <= y_dis && y_dis <= bottomy
                            
                            %The corresponding x and y pixels of the target
                            pixel = [x_dis/fov(1)*Camera.res(1); y_dis/fov(2)*Camera.res(2)];
                            
                            %covariance assosiated with CV algo
                            r = [44 35; 60  20];
                            %just to ensure the matrix is pos def, but in real
                            %implementation it is assumed
                            cv_cov = r*r';
                            %generate relevant samples from cov
                            L = chol(cv_cov);
                            noise = L*randn(2,1);
                                                        
                            %store all pixel coordinates
                            %remove noise if you want to see true pixel
                            %coordinates
                            target_pixels = [target_pixels pixel+noise]; 
                        end
                    end
                end
            end
            %if no targets in frame
            if count == 0
                target_pixels = 0;
            end
        end
        
        function[ellipse] = fuse(Solver, ell1, ell2, newconf)
            %calculate kalman gain
            k = ell1.cov/(ell1.cov+ell2.cov);
            
            newcov = ell1.cov-k*ell1.cov;
            newmean = ell1.mean'+k*(ell2.mean-ell1.mean)';
            
            ellipse = Ellipse(newcov, newmean, newconf);
        
        end
        %this function aids in plotting the ellipses
        function [ell_x, ell_y] = gen_ellipse_points(Solver, Search_Area, num_obs, total_obs)
            ell_x = [];
            ell_y = [];
                       
            for i=total_obs-num_obs+1:1:total_obs       
                ell_i = Ellipse(Search_Area.obs_cov(:,:,i), Solver.states(:,i-total_obs+num_obs), 2.554);
                [ell_ix, ell_iy] = ell_i.errorellipse();
                ell_x = [ell_x ell_ix];
                ell_y = [ell_y ell_iy];
           end
        end   
    end
    
end

