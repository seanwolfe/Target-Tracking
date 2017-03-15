classdef Search_Area
    %Creates a search area with a length and width, partitioned as desired.
    %Also randomly places a desired number of targets
    
    properties
        %The x and y dimensions of the grid, the x and y target vectors
        x_width, y_length, targets, ids;
    end
    
    methods
        function obj = Search_Area(x_width, y_length)
            %Constructor. 
            obj.x_width = 1:1:x_width;
            obj.y_length =  1:1:y_length;          
        end    
    end
end

