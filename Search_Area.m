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
        
       function [targets_x, targets_y] = gen_targets(Search_Area, num_targets)
            %The function uses the number of targets input (num_targets) 
            %to randomly create the desired number of x coordinates and y
            %coordinates. The coordinates lie within the grid. 
            targets_x = datasample(Search_Area.x_width, num_targets);
            targets_y = datasample(Search_Area.y_length,num_targets);
       end 
    end
end

