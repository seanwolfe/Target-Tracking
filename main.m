function [] = main()
% This function creates a simplified simulation environment for the
% AUVSI_SUAS drone competitition

%Sampling Period (in seconds)
t = 1;

%Simlulation Time
end_time = 10;

%Create a plane with:
    %an initial heading of: 0
    %an altitude of: 200ft
    %a velocity of: 100 (m per instance s)
    %and an initial position of: [x, y, z] = [0, 0, 200]
plane1 = Plane(0, 200, 100,[0 0 200]);

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

%Generate Targets Randomly in search area
area1.targets = area1.gen_targets(num_targets);
%Generate Targest with noise
%noisy_targets = gen_t_noise(area1);

grid on



for k = 1:t:end_time
    %If first iteration, set position to the initial position of the plane
    if k == 1
        
        %this position2 variable hold the true positions of the plane
        position2 = plane1.pos;
        noisy_pos2 = gen_p_noise(plane1);
        %calculate the field of view of the camera
        fov = project_image(cam1, plane1);
        
        hold on
        %plot the true target locations
        plot3(area1.targets(1,:),area1.targets(2,:), zeros(num_targets),'x')
        %plot the noisy target locations
        %plot3(noisy_targets(1,:), noisy_targets(2,:), zeros(num_targets),'.')
        %plot the plane position
        plot3(plane1.pos(1),plane1.pos(2),plane1.pos(3), 'o')
        %plot the field of view
        plot3(fov(:,1), fov(:,2), fov(:,3), ':')
        
    end
    
    %Plane velocity
    plane1.vel = 100;
    
    %Otherwise ask for next heading
    plane1.heading = input('What is the next heading in degrees');
    
    %Calculate the next position
    plane1.pos = plane1.translate(plane1.pos);
    position2 = [position2; plane1.pos];
    
    %add noise to the position
    noisy_pos = gen_p_noise(plane1);
    noisy_pos2 = [noisy_pos2; noisy_pos];
    %Calculate field of view
    fov = project_image(cam1, plane1);
    
    hold off
    %plot field of view
    plot3(fov(:,1), fov(:,2), fov(:,3), ':');
    hold on
    grid on
    %plot true (x) and noisy targets (.)   
    plot3(area1.targets(1,:),area1.targets(2,:), zeros(num_targets),'x')
    %plot3(noisy_targets(1,:), noisy_targets(2,:), zeros(num_targets),'.')
    
    %plot position and position with noise
    plot3(position2(:,1), position2(:,2), position2(:,3))
    plot3(noisy_pos2(:,1), noisy_pos2(:,2), noisy_pos2(:,3), 'o')
    
    
    
end

end

