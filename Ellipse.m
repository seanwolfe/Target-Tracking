classdef Ellipse
    %This class contains a function for visualizing the error ellipse
    %also, contains algo for merging multivariate gaussians given
    %covariance and mean
    
    properties
        cov, mean, conf
    end
    
    methods
        function obj = Ellipse(covariance, mean, confidence)
            obj.cov = covariance;
            obj.mean = mean;
            obj.conf = confidence;
        end
        
        function[x,y]= errorellipse(Ellipse)
            
            % Calculate the eigenvectors and eigenvalues
            [eigenvec, eigenval ] = eig(Ellipse.cov);

            % Get the index of the largest eigenvector
            [largest_eigenvec_ind_c, ~] = find(eigenval == max(max(eigenval)));
            largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);
            
            % Get the largest eigenvalue
            largest_eigenval = max(max(eigenval));
            
            % Get the smallest eigenvector and eigenvalue
            if(largest_eigenvec_ind_c == 1)
                smallest_eigenval = max(eigenval(:,2));
                %smallest_eigenvec = eigenvec(:,2);
            else
                smallest_eigenval = max(eigenval(:,1));
                %smallest_eigenvec = eigenvec(1,:);
            end
            
            % Calculate the angle between the x-axis and the largest eigenvector
            angle = atan2(largest_eigenvec(2), largest_eigenvec(1));
            
            % This angle is between -pi and pi.
            % Let's shift it such that the angle is between 0 and 2pi
            if(angle < 0)
                angle = angle + 2*pi;
            end
            
            % Get the confidence interval error ellipse
            theta_grid = linspace(0,2*pi);
            phi = angle;
            X0=Ellipse.mean(1);
            Y0=Ellipse.mean(2);
            a=Ellipse.conf*sqrt(largest_eigenval);
            b=Ellipse.conf*sqrt(smallest_eigenval);
            
            % the ellipse in x and y coordinates
            ellipse_x_r  = a*cos( theta_grid );
            ellipse_y_r  = b*sin( theta_grid );
            
            %Define a rotation matrix
            R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];
            
            %let's rotate the ellipse to some angle phi
            r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;
            
            % Draw the error ellipse
            x = r_ellipse(:,1); 
            y = r_ellipse(:,2);
            %plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
            %hold on;
        end
                
    end
    
end

