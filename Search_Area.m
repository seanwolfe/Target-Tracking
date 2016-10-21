classdef Search_Area
    %Creates a search area with a length and width, partitioned as desired.
    %Also randomly places a desired number of targets
    
    properties
        %The x and y dimensions of the grid, the x and y target vectors
        x_width, y_length, targets;
    end
    
    methods
        function obj = Search_Area(x_width, y_length)
            %Constructor. 
            obj.x_width = 1:1:x_width;
            obj.y_length =  1:1:y_length;
        end
        
       function [targets] = gen_targets(Search_Area, num_targets)
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
            
            %make num_targets targets
            for i = 1:num_targets
                %if first target
                if i == 1
                    %store a random target direcly
                    targets = [rand(1).*xmax; rand(1).*ymax];
                else
                   %otherwise generate a target 
                   target = [rand(1).*xmax; rand(1,1)*ymax];
                   
                   %check if this target exists already
                   for j=1:size(targets,2)
                        %if it does, redo
                        if target == targets(:,j)
                            i = i-1;
                        end
                   end
                   %add to list of targets 
                   targets = [targets target];
                end
            end
       end
       
       function [noisy_targets] = gen_t_noise(Search_Area)
            %this function generates noisy targets from the true ones
            
            %noise in x
            noise_tx = 10/3*randn(size(Search_Area.targets(1,:)));
            
            %noise in y
            noise_ty = 10/3*randn(size(Search_Area.targets(2,:)));
            
            %add noise to existing targets
            noisy_targets = [(Search_Area.targets(1,:) + noise_tx); (Search_Area.targets(2,:) + noise_ty)]
       end
    end
end

