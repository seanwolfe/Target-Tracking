classdef Generator
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [ell_x, ell_y] = ellipse_points(~, Solver, obs_cov_i, num_obs, Camera)
            %this function produces points that can be plotted as an error
            %ellipse
            
            %these hold the points
            ell_x = [];
            ell_y = [];
                        
            %generate an ellipse for each target observed this iteration
            for i=1:1:num_obs
               
                %create an ellipse, with covariance, mean, and confidence
                ell_i = Ellipse(obs_cov_i(:,:,i), Solver.states(:,i), 2.554);
                
                %generate the ellipse in pixels
                [ell_ix_p, ell_iy_p] = ell_i.errorellipse();
                
                %Convert to meters
                ell_ix = ell_ix_p*Camera.fov(1)/Camera.res(1);
                ell_iy = ell_iy_p*Camera.fov(2)/Camera.res(2);
                
                %center ellipse
                ell_ix = ell_ix + ell_i.mean(1);
                ell_iy = ell_iy + ell_i.mean(2);
                
                %append all the ellipses together
                ell_x = [ell_x ell_ix];
                ell_y = [ell_y ell_iy];
                
            end
            
        end
        
        function[observation_covs] = observation_covariance(~, num_obs)
            
            observation_covs = [];
            
            %assign a covariance to each target
            for i=1:1:num_obs
                
                %generate a random (ie value between 0 and 1) 2x2 covariance
                %matrix with variance 5
                temp = 5*rand(2,2);
                %temporary to make pose def
                cov = temp*temp';
                observation_covs = cat(3, observation_covs, cov);
                
            end
        end
        
        function[ids] = target_ids(~, num_targets)
            
            id_list = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'];
            
            index = randperm(size(id_list,2), num_targets);
            
            ids = blanks(num_targets);
            
            for i=1:1:num_targets
                ids(i) = id_list(index(i));
            end
        end
        
        function [targets] = targets(~, Search_Area, num_targets)
            %The function uses the number of targets input (num_targets)
            %to randomly create the desired number of x coordinates and y
            %coordinates. The coordinates lie within the grid.
            
            %y vector of search area
            size_y = size(Search_Area.y_length);
            %x vector of search area
            size_x = size(Search_Area.x_width);
            %highest value of y in the search area
            ymax = Search_Area.y_length(size_y(1), size_y(2));
            %highest value of x in the search area
            xmax = Search_Area.x_width(size_x(1), size_x(2));
            
            targets = zeros(2, num_targets);
            
            %make num_targets targets
            for i = 1:1:num_targets
                %if first target
                if i == 1
                    %store a random target direcly
                    targets(:,i) = [rand(1).*xmax; rand(1).*ymax];
                else
                    %otherwise generate a target
                    target = [rand(1).*xmax; rand(1,1)*ymax];
                    
                    %check if this target exists already
                    for j=1:1:size(targets,2)
                        %if it does, redo
                        if target == targets(:,j)
                            i = i-1;
                        end
                    end
                    %add to list of targets
                    targets(:,i) = target;
                end
            end
        end
        
        %solve for target pixel coordinates from target positions
        function [target_pixels, target_indices] = pixel_coordinates(~, Camera, Plane, Search_Area)
            
            target_indices = [];
            
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
                            
                            target_indices = [target_indices i];
                            
                            %store pixel coordinates
                            target_pixels = pixel;
                            
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
                            
                            target_indices = [target_indices i];
                            
                            %store all pixel coordinates
                            %remove noise if you want to see true pixel
                            %coordinates
                            target_pixels = [target_pixels pixel];
                        end
                    end
                end
            end
            %if no targets in frame
            if count == 0
                target_pixels = [];
            end
        end
    end
end

