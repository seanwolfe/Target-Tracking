function [] = main()
% This function creates a simplified simulation environment for the
% AUVSI_SUAS drone competitition

%Create a plane with:
    %an initial heading of: 0
    %an altitude of: 200ft
    %a velocity of: 1 (ft per instance k)
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
    %Dimensions x,y: 10ft,10ft
    %Increments of 1ft
area1 = Search_Area(1000, 1000, 1);

%Enter number of targets
num_targets = input('Number of Targets:');

%Generate Targets Randomly in search area
[targets] = area1.gen_targets(num_targets);
grid on



for k = 1:10
    %If first iteration, set position to the initial position of the plane
    if k == 1
        position2 = plane1.pos;
        fov = project_image(cam1, plane1);
        
        hold on
        plot3(plane1.pos(1),plane1.pos(2),plane1.pos(3), 'o')
        plot3(fov(:,1), fov(:,2), fov(:,3), ':');
        plot3(targets(1,:),targets(2,:), zeros(num_targets),'x')
    end
    %Otherwise ask for next heading
    plane1.heading = input('What is the next heading in degrees');
    %Calculate the next position
    
    temp = plane1.translate(plane1.pos);
    position2 = [position2; temp];
    plane1.pos = temp;
    fov = project_image(cam1, plane1);
    
    plot3(targets(1,:),targets(2,:), zeros(num_targets),'x')
    plot3(plane1.pos(1),plane1.pos(2),plane1.pos(3), 'o')
    plot3(position2(:,1), position2(:,2), position2(:,3))
    plot3(fov(:,1), fov(:,2), fov(:,3), ':');
    
    
end



end

