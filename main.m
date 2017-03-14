function [] = main()
% This function creates a simplified simulation environment for the
% AUVSI_SUAS drone competitition

%Sampling Period (in seconds)
t = 1;

%Simlulation Time
end_time = 100;

%Create a plane with:
    %an initial heading of: 0
    %an altitude of: 200ft
    %a velocity of: 100 (m per instance s)
    %and an initial position of: [x, y, z] = [0, 0, 200]
plane1 = Plane(0, 200, 0,[0 0 200]);
plane1.ncurrpos = [0 0 200];
noisy_pos2 = [];
position2 = [];


%Create a camera with:
    %an horizontal sensor width of: 5.76mm
    %a vertical sensor width of: 4.29mm
    %a resolution of: 4096 x 2160
        %Camera: FL3-U3-88S2C-C
    %a focal length of 8mm
        %lens: Tamron model
cam1 = Camera(5.76, 4.29,[4096 2160], 8);

%create a search ares with:
    %Dimensions x,y: 1000m,1000m
area1 = Search_Area(1000, 1000);


%Enter number of targets
num_targets = input('Number of Targets:');
%num_targets = 3;
%area1.targets = [50 50 150; 50 100 50];
%Generate Targets Randomly in search area
area1.targets = area1.gen_targets(num_targets);
area1.obs_cov = [];
area1.id = gen_target_ids(num_targets);
area1.targets;


%Generate Targest with noise
%noisy_targets = gen_t_noise(area1);

%Create a solver to solve the simulation
solv1 = Solver();

%this variable stores all observations
observations = [];

%the following hold all ellipse values to plot
ell_x = [];
ell_y = [];

grid on



for k = 1:t:end_time
       
    %Plane velocity(m/s)
    plane1.vel = 20;
    
    %Otherwise ask for next heading
    plane1.heading = input('What is the next heading in degrees');
    %add noise to heading
    plane1.nhead = gen_h_noise(plane1);
    %plane1.nhead;
    
    %Calculate the next position
    [plane1.currpos, plane1.prevpos] = plane1.translate(plane1.currpos);
    position2 = [position2; plane1.currpos];
    
    %add noise to the position
    [plane1.ncurrpos, plane1.nprevpos] = gen_p_noise(plane1, plane1.ncurrpos);
    noisy_pos2 = [noisy_pos2; plane1.ncurrpos];
        
    %Calculate field of view
    [fov, cam1.fov] = project_image(cam1, plane1);
    
    %Calculate noisy field of view
    [nfov, cam1.nfov] = project_image_noisy(cam1, plane1);
   
    %solve the pixel coordinates of the targets in the camera frame
    solv1.target_pixels = pixel_from_target(solv1, cam1, plane1, area1);
    solv1.target_pixels;
    
    %Solve for the target locations from pixel coordinates
    solv1.states = target_from_pixel(solv1, cam1, plane1);
    solv1.states;
    
    %append all observations
    observations = [observations solv1.states];
    
    %number of observations for this iteration and total number
    num_obs = size(solv1.states, 2);
    total_obs = size(observations,2);
    
    hold off
    
    %plot field of view
    plot3(fov(:,1), fov(:,2), fov(:,3), ':');
    
    hold on
    grid on
    
    %if there are observations to plot
    if num_obs ~= 0
        
        %generate simulated covariances for these observations
        obs_cov_i = area1.gen_obs_cov(num_obs);
        area1.obs_cov = cat(3, area1.obs_cov, obs_cov_i);
        
        %generate ellipse points
        [ell_ix, ell_iy] = solv1.gen_ellipse_points(area1, num_obs, total_obs);
        ell_x = [ell_x ell_ix];
        ell_y = [ell_y, ell_iy];
        
        
    end
    
    if total_obs ~= 0
        %plot ellipses
        plot3(ell_x, ell_y, zeros(size(ell_y)));
        
        %plot state estimates
        plot3(observations(1,:), observations(2,:), zeros(size(observations,2)), '.');
        
    end
    
    %plot true (x) and noisy targets (.)   
    plot3(area1.targets(1,:),area1.targets(2,:), zeros(num_targets),'x')
    %plot3(noisy_targets(1,:), noisy_targets(2,:), zeros(num_targets),'.')
    
    %plot position and position with noise
    plot3(position2(:,1), position2(:,2), position2(:,3))
    plot3(noisy_pos2(:,1), noisy_pos2(:,2), noisy_pos2(:,3), 'o')
    
    end
end

 %If first iteration, set position to the initial position of the plane
    %if k == 1
        
        %this position2 variable hold the true positions of the plane
        %position2 = plane1.currpos;
        %[noisy_pos2, plane1.ncurrpos] = gen_p_noise(plane1, plane1.currpos);
                
        %calculate the true field of view of the camera
        %[fov, cam1.fov] = project_image(cam1, plane1);
        
        %calculate the noisy field of view the camera
        %plane1.nhead = plane1.heading;
        %[nfov, cam1.nfov] = project_image_noisy(cam1, plane1);
        
        %solve for the pixel coordinates of the targets in the camera frame
        %solv1.target_pixels = pixel_from_target(solv1, cam1, plane1, area1);
        %solv1.target_pixels;
        
        %Solve for the target locations from pixel coordinates
        %solv1.states = target_from_pixel(solv1, cam1, plane1);
        %solv1.states;
        
        %number of observations for this iteration and total number
        %num_obs = size(solv1.states, 2);
        %total_obs = size(observations,2);
        
           
        %store the observations for the iteration
        %observations = [observations solv1.states];
       
        
        %hold on
        
        %if there are observations to plot
        %if num_obs ~= 0
            
            %plot state estimates
            %plot3(observations(1,:), observations(2,:), zeros(size(observations,2)), '.')
            
            %generate simulated covariances for these observations
            %obs_cov_i = area1.gen_obs_cov(num_obs);
            %area1.obs_cov = cat(3, area1.obs_cov, obs_cov_i);
            
            %generate ellipse points
            %[ell_ix, ell_iy] = solv1.gen_ellipse_points(area1, num_obs, total_obs);
            %ell_x = [ell_x ell_ix];
            %ell_y = [ell_y, ell_iy];
            
            %plot ellipses
            %plot3(ell_x, ell_y, zeros(size(ell_x)));
        %end
        
        %plot the true target locations
        %plot3(area1.targets(1,:),area1.targets(2,:), zeros(num_targets),'x')
        
        %plot the noisy target locations
        %plot3(noisy_targets(1,:), noisy_targets(2,:), zeros(num_targets),'.')
        
        %plot the plane position
        %plot3(plane1.currpos(1),plane1.currpos(2),plane1.currpos(3), 'o')
        
        %plot the field of view
        %plot3(fov(:,1), fov(:,2), fov(:,3), ':')
        
    %else
