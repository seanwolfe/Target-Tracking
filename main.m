function [] = main()
% This function creates a simplified simulation environment for the
% AUVSI_SUAS drone competitition

%Create a plane with:
    %an initial heading of: 0
    %an altitude of: 200ft
    %a velocity of: 1 (ft per instance k)
    %and an initial position of: [x, y, z] = [0, 0, 200]
plane1 = Plane(0, 200, 1,[0 0 200]);

%Create a camera with:
    %an horizontal sensor width of: 5.76mm
    %a vertical sensor width of: 4.29mm
    %a resolution of: 4096 x 2160
        %Camera: FL3-U3-88S2C-C
    %a focal length of 25mm
        %lens: Tamron model 23FM25SP
cam1 = Camera(5.76, 4.29,[4096 2160], 25);

%create a search ares with:
    %Dimensions x,y: 10ft,10ft
    %Increments of 1ft
area1 = Search_Area(10, 10, 1);

%Enter number of targets
num_targets = input('Number of Targets:');

%Generate Targets Randomly in search area
[targets_x, targets_y] = area1.gen_targets(num_targets);
plot3(targets_x,targets_y, zeros(num_targets),'x')
hold on


for k = 1:10
    %If first iteration, set position to the initial position of the plane
    if k == 1
        position = plane1.ini_pos;
        plot3(position(1),position(2),position(3),'o')
    end
    %Otherwise ask for next heading
    plane1.heading = input('What is the next heading in degrees');
    %Calculate the next position
    position = plane1.translate(position);
    grid on
    plot3(position(1),position(2),position(3),'o')
    hold on
end


end

