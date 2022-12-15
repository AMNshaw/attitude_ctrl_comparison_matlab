clear;clc;close all;
delta_t = 0.01;
iteration = 1000;

% x:45 y:45 z:45
q_init = [0.7774628, 0.3631123, 0.3631123, 0.3631123];

q = q_init;
q_record = zeros(1, 4,iteration);
q_dot = zeros(4, 1);
R = eye(3, 3);
R_dot = eye(3, 3);

eB_z = zeros(3, 1);
eB_z_des = [0 0 1];
n = zeros(3, 1);
n_B = zeros(3, 1);
q_e_rp = zeros(1, 4,iteration);

omega_rp_des = zeros(1, 2);
omega_y_des = zeros(1, 1);
omega_des = zeros(1, 3, 1000);

yaw_des = 0;

k_rp = 0.5;
k_y = 1;



for i = 1:iteration

    % Align roll, pitch
    eB_z = quatrotate(q, [0 0 1]);
    alpha = acos(dot(eB_z, eB_z_des));
    alpha_degree = alpha*180/pi;
    n = cross(eB_z, eB_z_des)/norm(cross(eB_z, eB_z_des))
    n_B = quatrotate(quatinv(q), n);
    q_e_rp(1, :, i) = [cos(alpha/2) sin(alpha/2)*n_B];
        
%     % Align yaw
%     eC_x = [cos(yaw_des); sin(yaw_des); 0];
%     eC_y = [-sin(yaw_des); cos(yaw_des); 0];
%     eB_x_des = cross(eC_y, eB_z_des)/norm(cross(eC_y, eB_z_des));
%     eB_y_des = cross(eB_z_des, eB_x_des)/norm(cross(eB_z_des, eB_x_des));
%     q_des = rotm2quat([eB_x_des', eB_y_des', eB_z_des']);
%     q_e_y = quatmultiply(quatinv(quatmultiply(q, q_e_rp)), q_des);
    
    % Find omega_des
    if q_e_rp(1) >= 0
        omega_rp_des = 2*k_rp*q_e_rp(2:3);
    else
        omega_rp_des = -2*k_rp*q_e_rp(2:3);
    end
    
%     if q_e_y(1) >= 0
%         omega_y_des = 2*k_y*q_e_y(4);
%     else
%         omega_y_des = -2*k_y*q_e_y(4);
%     end
    %omega_des(1, :, i) = [omega_rp_des omega_y_des];
    omega_des(1, :, i) = [omega_rp_des 0];

    % Calculate rotation
    R = quat2rotm(q);
    R_dot = R*hat(omega_des);
    R = R + R_dot*delta_t;
    [U,S,V] = svd(R);
    R=U*V';
    q = rotm2quat(R);

    q_record(1, :, i) = q;
    %e_R = 1/2 * vee(R_d'*R - R'*R_d);    
end

plot(1:iteration, omega_des(1:iteration));