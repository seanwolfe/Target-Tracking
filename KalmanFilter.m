classdef KalmanFilter
    %Basic Kalman filter to filter out noise from computer vision estimates
    %and plane position. This is for a system with only one target
    %in this class: the initial state estimate(s_ini), the
    %covariance matrix (p), measurement noise (mnoise), proces noise
    %(pnoise), the apriori covariance matrix (p_ap), the Kalman Gain
    %(k_gain), the measurement matrix h
    
    properties
        s, pnoise, mnoise, p_ap, p, k_gain, h
    end
    
    methods
        %constructor
        function obj = KalmanFilter(initial_target_location, initial_covariance_matrix, process_noise, measurement_noise)
            obj.s = initial_target_location;
            obj.p = initial_covariance_matrix;
            obj.pnoise = process_noise;
            obj.mnoise = measurement_noise;
        end
      
        function[p_ap] = calc_apriori_cov(KalmanFilter)
            %Calculates the apriori covariance matrix from the old one and the
            %measurement noise
            p_ap = KalmanFilter.p + KalmanFilter.pnoise;        
        end
        
        function [ h ] = create_h( num_states, Camera, Plane )
        %this function creates the corresponding h matrix according to the number
        %of states (twice the number of targets). Assuming that the vector is
        %arraged as [x_target1 y_target1 x_target2 y_target2...]
            
            %these are the respective x and y transforms to go from x and y
            %relative to the projection frame to x and y relative to the
            %world(ie longitude and latitude)
            x_trans = Camera.res(1)/Camera.fov(1)*(-Plane.currpos(1)+Camera.fov(1)/2);
            y_trans = Camera.res(2)/Camera.fov(2)*(Plane.currpos(2)+Camera.fov(2)/2);
            x = Camera.res(1)/Camera.fov(1);
            y = Camera.res(2)/Camera.fov(2);
            
            even = 1;
            
            %the h matrix is initialized to a square matrix of size equal
            %to the number of states, so is the trans vector, which is
            %concantenated at the end of the h matrix to take into
            %consideration any necessary transformations.
            h = zeros(num_states);
            trans = zeros(num_states, 1);
            
            %diagonal entries alternate between x and y ratios for going
            %between meters and pixels
            for i = 1:(num_states)
                if even == 1
                    h(i,i) = x;
                    trans(i) = x_trans;
                elseif even == -1
                    h(i,i) = -y;
                    trans(i) = y_trans;
                end
                even  = -even;
            end

            h = [h trans];
        end
  
        function[g] = calc_k_gain(KalmanFilter)
            %Calculate the Kalman Gain
            g = KalmanFilter.p_ap*KalmanFilter.h'/(KalmanFilter.h*KalmanFilter.p_ap*KalmanFilget.h'+KalmanFilter.mnoise);
        end
    end
    
end

