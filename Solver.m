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
            newmean = ell1.mean+k*(ell2.mean-ell1.mean);
            
            ellipse = Ellipse(newcov, newmean, newconf);
            
        end
        
        function [mean_groups] = estimates(Solver)
   
            %iterate through ids
            id_groups = Solver.id_list(1);
            cov_groups = Solver.cvcov(:,:,1);
            mean_groups = Solver.observations(:,1);
            
            Solver.id_list
            for i=2:1:size(Solver.id_list,2)
                
                %iterate through already seen ids
                for j=1:1:size(id_groups,2)
                    
                    count = 0;
                    
                    %already an existing group of ids
                    if Solver.id_list(:,i) == id_groups(:,j)
                        %get mean, cov, conf of group up to now
                        ell1 = Ellipse(cov_groups(:,:,j), mean_groups(:,j), 2.554);
                        %get mean, cov, conf of id to fuse
                        ell2 = Ellipse(Solver.cvcov(:,:,i), Solver.observations(:,i), 2.554);
                        %fuse
                        ell3 = Solver.fuse(ell1, ell2, 2.554);
                        
                        cov_groups(:,:,j) = ell3.cov;
                        mean_groups(:,j) = ell3.mean;
                        
                        %it has already seen a target of this type
                        count = 1;
                        
                        break;
                    end
                end
                %this type of target has not been seen yet
                if count == 0
                    id_groups = [id_groups Solver.id_list(:,i)]
                    cov_groups = cat(3,cov_groups, Solver.cvcov(:,:,i));
                    mean_groups = [mean_groups Solver.observations(:,i)];
                end
            end
        end
        
        function[id_list] = getids(Solver, Search_Area)
            id_list = blanks(size(Solver.target_pixels,2));
            
            for i=1:1:size(Search_Area.target_indices,2)
                id_list(i) = Search_Area.ids(Search_Area.target_indices(i));
            end
            
            
        end
    end
end


