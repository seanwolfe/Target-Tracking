function [Your_Targets, Your_Estimates] = main()
% This function creates a simplified simulation environment for the
% AUVSI_SUAS drone competitition

clear

%Sampling Period (in seconds)
t = 1;

%Create a plane with:
    %an initial heading of: 0
    %an altitude of: 50m
    %a velocity of: 16 (m per instance s)
    %and an initial position of: [x, y, z] = [0, 0, 200]
plane1 = Plane(0, 50, 16,[0 0 50]);
plane1.ncurrpos = [0 0 50];



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

generate = Generator();

%Enter number of targets
%num_targets = input('Number of Targets:');
num_targets = 5;

%Generate Targets Randomly in search area
area1.targets = generate.targets(area1, num_targets);
%area1.targets = [20 60 60; 20 20 60];

%Generate target ids
area1.ids = generate.target_ids(num_targets);

%Create a solver to solve the simulation
    %First holds the observation means
    %Second holds the observation covariances
    %Third holds the observation ids
solv1 = Solver([],[],[]);

%This objects adds simulated noise to certain parameters
    %The first input is the heading variance
    %The second input is the position covariance matrix in x,y,z
addnoiseto = Noisemachine(0.5, [2.5 0 0; 0 2.5 0; 0 0 5]);

%Create a Plotter, initialize all properties to be empty.
    %The first variable is the field of view
    %The second variable is the x values used to plot error ellipses
    %The third variable is the y values used to plot error ellipses
    %The fourth variable is used to store the plane positions to plot
    %The fifth variable is used to store the noisy plane positions to plot
plot = Plotter([],[],[],[],[]);

%Simlulation Time
end_time = max(area1.y_length)/(plane1.vel*t)^2*max(area1.x_width)+2*max(area1.y_length)/(plane1.vel*t)+50;
%end_time = 30;

for k = 1:t:end_time
    
    %Otherwise ask for next heading
    %plane1.heading = input('What is the next heading in degrees');
    %plane1.currpos = plane1.translate();
    %Calculate the next position
    [plane1.currpos, plane1.heading] = plane1.fly(area1);
    
    %add noise to heading
    plane1.nhead = addnoiseto.heading(plane1);
    plot.position = [plot.position; plane1.currpos];
    
    %add noise to the position
    plane1.ncurrpos = addnoiseto.planeposition(plane1);
    plot.noisy_position = [plot.noisy_position; plane1.ncurrpos];
        
    %Calculate field of view
    [plot.fov, cam1.fov] = cam1.project_image(plane1);
    cam1.fov;
    
    %Add noise to field of view
    [~, cam1.nfov] = addnoiseto.fov(cam1, plane1);
   
    %generate the pixel coordinates of the targets in the camera frame
    %also returns the target indices for that iteration
    [solv1.target_pixels, area1.target_indices] = generate.pixel_coordinates(cam1, plane1, area1);
    
    %number of observations (points of interest) for this iteration
    num_obs = size(solv1.target_pixels, 2);
    
      
    %if there are observations to plot
    if num_obs ~= 0
        
        %get the ids for this iteration
        ids_i = solv1.getids(area1);
        solv1.id_list = [solv1.id_list ids_i];
        
        %generate simulated covariances for these observations
        obs_cov_i = generate.observation_covariance(num_obs);
        
        %convert the coviance to meters in the global frame
        obs_cov_m = solv1.cov_convert(plane1, cam1, obs_cov_i, num_obs);
        solv1.cvcov = cat(3, solv1.cvcov, obs_cov_m);
        
           
        %use that to add noise to the target pixels
        solv1.target_pixels = addnoiseto.pixels(solv1, obs_cov_i, num_obs);
        solv1.target_pixels;
    
        %Solve for the target locations from pixel coordinates
        solv1.states = solv1.target_from_pixel(cam1, plane1);
        solv1.states;
        
        %append all observations
        solv1.observations = [solv1.observations solv1.states];
        
        %generate ellipse points for this iteration
        [ell_ix, ell_iy] = generate.ellipse_points(solv1, obs_cov_m, num_obs);
        plot.ell_x = [plot.ell_x ell_ix];
        plot.ell_y = [plot.ell_y, ell_iy];
                     
    end     
    
    %total number of observations up to now
    total_obs = size(solv1.observations,2);
    
    %plot the simulation
    plot.simulation(area1, solv1, total_obs);
    
    %plot true targets(x)
    plot3(area1.targets(1,:),area1.targets(2,:), zeros(size(area1.targets,2)),'x', 'LineWidth', 1);
   
     
end

if total_obs ~= 0

    %Compute final estimates
    solv1.states = solv1.estimates();
    [kf, final_cov] = solv1.multiple_estimates;
    
    
    %generate ellipse points for this iteration
    [ell_ix, ell_iy] = generate.ellipse_points(solv1, final_cov, 2);
    size(ell_ix)
    plot3(ell_ix, ell_iy, zeros(size(ell_ix,1),1), '--');
    
    %Sort Targets
    [~, J] = sort(kf(1,:));
    kf = kf(:,J);
    Your_KF = kf
    
    %Sort Targets
    [~, J] = sort(area1.targets(1,:));
    area1.targets = area1.targets(:,J);
    Your_Targets = area1.targets
    
    %Sort Estimates
    [~, I] = sort(solv1.states(1,:));
    solv1.states = solv1.states(:,I);
    Your_Estimates = solv1.states
    
    grid on
    hold on
    
    %plot the final estimates
    plot3(solv1.states(1,:), solv1.states(2,:), zeros(size(solv1.states,2)), '.', 'MarkerSize', 12);
end

end

