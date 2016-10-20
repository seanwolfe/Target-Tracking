classdef Search_Area
    %Creates a search area with a length and width, partitioned as desired.
    %Also randomly places a desired number of targets
    
    properties
        %The x and y dimensions of the grid
        x_width, y_length;
    end
    
    methods
        function obj = Search_Area(x_width, y_length, spacing)
            %Constructor. Spacing variable is the increment by which the
            %grid is partitioned
            obj.x_width = 1:spacing:x_width;
            obj.y_length =  1:spacing:y_length;
        end
        
       function [targets] = gen_targets(Search_Area, num_targets)
            %The function uses the number of targets input (num_targets) 
            %to randomly create the desired number of x coordinates and y
            %coordinates. The coordinates lie within the grid.
            
            %for i = 1:num_targets
             %   if i == 1
              %      target
               %     targets
               % end
                
                %targets = [targets 
                %targets_x = datasample(Search_Area.x_width, num_targets)
                %targets_y = datasample(Search_Area.y_length,num_targets)
            size_y = size(Search_Area.y_length);
            size_x = size(Search_Area.x_width);
            ymax = Search_Area.y_length(size_y(1), size_y(2));
            xmax = Search_Area.x_width(size_x(1), size_x(2));
            
            for i = 1:num_targets
                
                if i == 1
                    targets = [rand(1).*xmax; rand(1,1)*ymax];
                else
                   target = [rand(1).*xmax; rand(1,1)*ymax];
                    for j=1:size(targets,2)
                        size(targets,2)
                        if target == targets(:,j)
                            i = i-1;
                        end
                    end
                    targets = [targets target];
                end
            end
            %targets = [(rand(1,num_targets).*xmax); (rand(1,num_targets).*ymax)]
       end
    end
end

