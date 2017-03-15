classdef Plotter
    %Takes care of the plotting for the simulation
    
    properties
        %The x and y dimensions of the grid, the x and y target vectors
        fov, ell_x, ell_y, observations, position, noisy_position;
    end
    
    methods
        
        function obj = Plotter(fov, ell_x, ell_y, position, noisy_position)
            obj.fov = fov;
            obj.ell_x = ell_x;
            obj.ell_y = ell_y;
            obj.position = position;
            obj.noisy_position = noisy_position;
        end
        
        function [] = simulation(Plotter, Search_Area, Solver, total_obs)
            %Plots the simulation for this iteration
            hold off
            
            %plot field of view
            plot3(Plotter.fov(:,1), Plotter.fov(:,2), Plotter.fov(:,3), ':');
            
            hold on
            grid on
            
            if total_obs ~= 0
                %plot ellipses
                plot3(Plotter.ell_x, Plotter.ell_y, zeros(size(Plotter.ell_y)));
                
                %plot state estimates
                plot3(Solver.observations(1,:), Solver.observations(2,:), zeros(size(Solver.observations,2)), '.');
                
            end
            
            %plot true (x) and noisy targets (.)
            plot3(Search_Area.targets(1,:),Search_Area.targets(2,:), zeros(size(Search_Area.targets,2)),'x')
                        
            %plot position and position with noise
            plot3(Plotter.position(:,1), Plotter.position(:,2), Plotter.position(:,3))
            plot3(Plotter.noisy_position(:,1), Plotter.noisy_position(:,2), Plotter.noisy_position(:,3), 'o')
            
        end
    end
    
end

