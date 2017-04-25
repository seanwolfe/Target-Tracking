classdef Solver
    %Contains all functions relavent to solving the simulation. More
    %specifically, generating observations, fusing via kf, fusing via
    %maximum likelihood, getting the respective target ids and computing
    %global covariance matrices.
    
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
            trans = [cosd(Plane.nhead) sind(Plane.nhead) Plane.ncurrpos(1); -sind(Plane.nhead) cosd(Plane.nhead) Plane.ncurrpos(2)];
            
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
        
        %need to change to a global merge
        function[ellipse] = fuse(~, ell1, ell2, newconf)
            %calculate kalman gain
            k = ell1.cov/(ell1.cov+ell2.cov);
            
            newcov = ell1.cov-k*ell1.cov;
            newmean = ell1.mean+k*(ell2.mean-ell1.mean);
            
            ellipse = Ellipse(newcov, newmean, newconf);
            
        end
        
        function [estimates] = estimates(Solver)
            %This function will produce overall estimates in one
            %calculation
            
            estimates = [];
            
            %iterate through ids
            id_groups = Solver.id_list(1);
                      
            for i=2:1:size(Solver.id_list,2)
                
                %iterate through already seen ids
                for j=1:1:size(id_groups,2)
                    count = 0;
                    %already an existing group of ids
                    if Solver.id_list(:,i) == id_groups(:,j)
                        %it has already seen a target of this type
                        count = 1;                  
                        break;
                    end
                end
                %this type of target has not been seen yet
                if count == 0
                    id_groups = [id_groups Solver.id_list(:,i)];
                end
            end
            
            indice_table = zeros(size(id_groups,2),size(Solver.observations,2));
            Solver.id_list;
            
            %determine which observations belong to which targets based on
            %the id and observation number
            for j=1:1:size(id_groups,2)
                pointer = 1;
                for i=1:1:size(Solver.id_list,2)
                     %if the id already exists 
                     if Solver.id_list(:,i) == id_groups(:,j)
                        indice_table(j, pointer) = i;
                        pointer = pointer+1;
                     end
                end
            end
            size(Solver.observations);
            size(Solver.cvcov);
            indice_table;
            for i=1:1:size(indice_table,1)
                
                inv_cov = zeros(2,2);
                mean_var = zeros(2,1);
                
                %fuse the appropriate observations together based on the
                %indice table
                for j=1:1:size(indice_table,2)
                    if indice_table(i,j) == 0
                        break;
                    else
                        inv_cov = inv_cov + inv(Solver.cvcov(:,:,indice_table(i,j)));
                        mean_var = mean_var + inv(Solver.cvcov(:,:,indice_table(i,j)))*Solver.observations(:,indice_table(i,j));
                    end
                end
                
                estimate_i = inv(inv_cov)*mean_var;
                estimates = [estimates estimate_i];
            end           
        end
        
        function [mean_groups, cov_groups] = multiple_estimates(Solver)
            %This function fuses two ellipses at a time continuously, thus
            %can be done in real time potentially
            
            %iterate through ids
            id_groups = Solver.id_list(1);
            cov_groups = Solver.cvcov(:,:,1);
            mean_groups = Solver.observations(:,1);
            
            for i=2:1:size(Solver.id_list,2)
                
                %iterate through already seen ids
                for j=1:1:size(id_groups,2)
                    
                    count = 0;
                    
                    %already an existing group of ids
                    if Solver.id_list(:,i) == id_groups(:,j)
                        %get mean, cov, conf of group up to now
                        ell1 = Ellipse(cov_groups(:,:,j), mean_groups(:,j), 4);
                        %get mean, cov, conf of id to fuse
                        ell2 = Ellipse(Solver.cvcov(:,:,i), Solver.observations(:,i), 4);
                        %fuse
                        ell3 = Solver.fuse(ell1, ell2, 4);
                        
                        cov_groups(:,:,j) = ell3.cov;
                        mean_groups(:,j) = ell3.mean;
                        
                        %it has already seen a target of this type
                        count = 1;
                        
                        break;
                    end
                end
                %this type of target has not been seen yet
                if count == 0
                    id_groups = [id_groups Solver.id_list(:,i)];
                    cov_groups = cat(3,cov_groups, Solver.cvcov(:,:,i));
                    mean_groups = [mean_groups Solver.observations(:,i)];
                end
            end
        end
        
        function[id_list] = getids(Solver, Search_Area)
            id_list = blanks(size(Solver.target_pixels,2));
            
            %returns the id list observed for the current iteration
            for i=1:1:size(Search_Area.target_indices,2)
                id_list(i) = Search_Area.ids(Search_Area.target_indices(i));
            end
            
            
        end
        
        function[global_cov] = cov_convert(Solver, Plane, Camera, pixel_cov, num_obs)
            %decompose pixel cov into two vectors, since uncorrelated
            %we can go from S = [s_11 s_12; s_21 s_22] to U_1 = [s_11;
            %s_21] and U_2 = [s_12; s_22]
            global_cov = [];
            
            for i=1:1:num_obs
            
            %Get normalized eigenvecs on camera frame, should always be [1,0] and
            %[0,1]
            U_1 = pixel_cov(:,1,i)/pixel_cov(1,1,i);
            U_2 = pixel_cov(:,2,i)/pixel_cov(2,2,i);
            
%              if(Plane.nhead < 0)
%                 angle = Plane.nhead + 2*pi;
%              else
%                  angle = Plane.nhead;
%             end
            
            angle = Plane.nhead;
            
            %Transform to global frame
            trans = [cosd(angle) sind(angle); -sind(angle) cosd(angle)];
            
            %Get new normalized eigenvec
            new_U1 = trans*U_1;
            new_U2 = trans*U_2;
            
            %Convert EigenVals to meters
            new_Lambda1 = pixel_cov(1,1,i)*Camera.fov(1)/Camera.res(1);
            new_Lambda2 = pixel_cov(2,2,i)*Camera.fov(2)/Camera.res(2);
            
            %compute new covariance
            global_cov_i = [new_U1 new_U2]*diag([new_Lambda1 new_Lambda2])*[new_U1 new_U2]';
            
            global_cov = cat(3,global_cov, global_cov_i);
            end 
        end
    end
end


