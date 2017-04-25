% solv1 = Solver();
% 
% cov = [0.5 0.1; 0.1 0.3];
% mean = [5 5];
% conf = 2.4477;
% ell1 = Ellipse(cov, mean, conf);
% [x,y] = ell1.errorellipse();
% 
% cov2 = [1.2 0.7; 0.7 2.3];
% mean2 = [4.5 4.5];
% conf2 = 2.4477;
% ell2 = Ellipse(cov2, mean2, conf2);
% [x2,y2] = ell2.errorellipse();
% 
% newconf = 2.4477;
% newell = solv1.fuse(ell1, ell2, newconf);
% 
% [x3, y3] = newell.errorellipse();
% 
% 
% num_targets = 10;
% 
% area2 = Search_Area(100,100);
% area2.targets = area2.gen_targets(num_targets);
% area2.t_cov = area2.gen_target_cov(num_targets);
% area2.t_cov;
% 
% 
% for i=1:1:num_obs
%     sp = total_obs + i;
%     ell_i = Ellipse(area2.obs_cov(:,:,sp), area2.targets(:,i), 2.554);
%     [ell_ix, ell_iy] = ell_i.errorellipse();
%     ell_x = [ell_x ell_ix];
%     ell_y = [ell_y ell_iy];
%     %plot(ell_ix, ell_iy);
%     %hold on;
% end
% 
% plot(ellx, elly);
% 
% 
% 
% %plot(x,y);
% %hold on;
% %plot(x2,y2);
% %plot(x3,y3,'.');
%ids = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
%datasample(ids, 5)

% plane = Plane(0,[],[],[]);
% plane.nhead = 45;
% pixel_cov = [45 0; 0 10];
% 
% solver = Solver([],[],[]);
% 
% new = solver.cov_convert(plane, pixel_cov);





