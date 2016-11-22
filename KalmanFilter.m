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
            x_trans = Camera.res(1)/Camera.fov(1)*(Plane.currpos(2)*sind(Plane.heading)-Plane.currpos(1)*cosd(Plane.heading)+Camera.fov(1)/2);
            y_trans = Camera.res(2)/Camera.fov(2)*(-Plane.currpos(1)*sind(Plane.heading)+Plane.currpos(2)*cosd(Plane.heading)+Camera.fov(2)/2);
            h_00 = Camera.res(1)/Camera.fov(1)*cosd(Plane.heading);
            h_01 = -Camera.res(1)/Camera.fov(1)*sind(Plane.heading);
            h_10 = -Camera.res(2)/Camera.fov(2)*sind(Plane.heading);
            h_11 = -Camera.res(2)/Camera.fov(2)*cosd(Plane.heading);
            
            %the h matrix is initialized to a square matrix of size equal
            %to the number of states, so is the trans vector, which is
            %concantenated at the end of the h matrix to take into
            %consideration any necessary transformations.
            h_0 = [h_00 h_01; h_10 h_11];
            trans_0 = [x_trans; y_trans];
            
            %diagonal entries alternate between x and y ratios for going
            %between meters and pixels
            for i = 1:(num_states/2)
                if i == 1
                    h = h_0;
                    trans = trans_0;
                else
                    h = [h zeros((i-1)*2, 2); zeros(2, (i-1)*2) h_0];
                    trans = [trans; trans_0];
                end
                
            end

            h = [h trans];
        end
        
        function[g] = calc_k_gain(KalmanFilter)
            %Calculate the Kalman Gain
            g = KalmanFilter.p_ap*KalmanFilter.h'/(KalmanFilter.h*KalmanFilter.p_ap*KalmanFilget.h'+KalmanFilter.mnoise);
        end
    end
    
end

