classdef Noisemachine
    %Handles the noise simulation, so anything associated with the heading
    %variance or position covariance
    
    properties
        hvar, poscov
    end
    
    methods
        %constructor
        function obj = Noisemachine(heading_variance, position_covariance)
            obj.hvar = heading_variance;
            obj.poscov = position_covariance;
        end
        
        function [noisy_heading] = heading(Noisemachine, Plane)
            %generates the noisy heading for the current iteration
            
            %determine noise
            noise = randn(1)*sqrt(Noisemachine.hvar);
            
            %add noise
            noisy_heading = Plane.heading + noise;
            
        end
        
        function [curr_noisy_pos] = planeposition(Noisemachine, Plane)
            %generates the noisy position of the plane at a certain
            %iteration with respect to the true positon
            
            %just to ensure the matrix is pos def, but in real
            %implementation it is assumed
            pos_cov = Noisemachine.poscov*Noisemachine.poscov';
            %generate relevant samples from cov
            L = chol(pos_cov);
            noise = randn(1,3)*L;
            
            %add the noise to the true position
            curr_noisy_pos = Plane.currpos + noise;
        end
        function [rect, fov] = fov(~, Camera, Plane)
            %this function is the same as in the camera function, expcept
            %it uses noisy measurements instead
            
            %projection of the camera frame onto the search area
            fov = [Plane.ncurrpos(3)*Camera.sensor_x/Camera.f; Plane.ncurrpos(3)*Camera.sensor_y/Camera.f];
            halfx = fov(1)/2;
            halfy = fov(2)/2;
            
            %if the plane is at the center of the rectangle (i.e camera poiting straight down),
            %p1,p2,p3,p4 are the vertices of the rectangle
            
            %Transformation Matrix using noisy readings
            trans = [cosd(Plane.nhead) sind(Plane.nhead) Plane.ncurrpos(1); -sind(Plane.nhead) cosd(Plane.nhead) Plane.ncurrpos(2); 0 0 1];
            
            %Generate camera frame relative to plane
            p1 = [-halfx halfy 1];
            p2 = [halfx halfy 1];
            p3 = [halfx -halfy 1];
            p4 = [-halfx -halfy 1];
            
            %noisy plane position
            p5 = [Plane.ncurrpos(1) Plane.ncurrpos(2) Plane.ncurrpos(3)];
            
            %Transform camera frame to world
            p1t = trans*p1';
            p2t = trans*p2';
            p3t = trans*p3';
            p4t = trans*p4';
            
            rect = [p5; p1t'; p2t'; p5; p3t'; p2t'; p5; p4t'; p1t'; p4t'; p3t'];
            
        end
        
        function [target_pixels] = pixels(~, Solver, obs_cov_i, num_obs)
            %obs_cov_i represents the covariance matrices for the current
            %iteration. So just the pixels within the current frame. The
            %function adds noise to the true pixel coordinates
            
            %initialize noise vector
            noise = [];
            
            %draws samples from the associated covariance matrix for each observation       
            for i=1:1:num_obs
                L = chol(obs_cov_i(:,:,i));
                noise_i = L*randn(2,1);
                noise = [noise noise_i];
            end
            
            %add noise to true pixel coordinates
            target_pixels = round(Solver.target_pixels + noise,0);
        
        end
    end
end

