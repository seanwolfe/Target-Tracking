function [] = erroranalysis()
%this fucntions runs the main a specified number of times and calculates
%the overall covariance matrix associated with error

clear
estimates_x = [];
estimates_y =[];
targets_x = [];
targets_y = [];

%specify the number of iterations
for i=1:1:50
    
    %run the main and gather the final estimates and target positions
    %associated with that iteration
    [targets_i,estimates_i] = main();
    
    %concatenate everything
    estimates_x= [estimates_x, estimates_i(1,:)];
    estimates_y= [estimates_y, estimates_i(2,:)];
    targets_x= [targets_x, targets_i(1,:)];
    targets_y= [targets_y, targets_i(2,:)];
end

%compute the error
error_x = estimates_x - targets_x;
error_y = estimates_y - targets_y;

%compute the covariance matrix
error_cov = cov(error_x, error_y);
end

