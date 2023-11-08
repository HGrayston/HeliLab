% FOR HELICOPTER NR 3-10
% This file contains the initialization for the helicopter assignment in
% the course TTK4115. Run this file before you execute QuaRC_ -> Build 
% to build the file heli_q8.mdl.

% Oppdatert høsten 2006 av Jostein Bakkeheim
% Oppdatert høsten 2008 av Arnfinn Aas Eielsen
% Oppdatert høsten 2009 av Jonathan Ronen
% Updated fall 2010, Dominik Breu
% Updated fall 2013, Mark Haring
% Updated spring 2015, Mark Haring


%%%%%%%%%%% Calibration of the encoder and the hardware for the specific
%%%%%%%%%%% helicopter
Joystick_gain_x = 1;
Joystick_gain_y = -1;
PORT = 4;
%rød er X
%blå er y
%gul er Z

%%%%%%%%%%% Physical constants
g = 9.81; % gravitational constant [m/s^2]
l_c = 0.46; % distance elevation axis to counterweight [m]
l_h = 0.66; % distance elevation axis to helicopter head [m]
l_p = 0.175; % distance pitch axis to motor [m]
m_c = 1.92; % Counterweight mass [kg]
m_p = 0.72; % Motor mass [kg]


K_1= (K_f)/(2*m_p*l_p);
K_2 = (l_h*K_f)/(m_c*(l_c).^2+2*m_p*(l_h).^2);
K_3 = (l_h*K_f)/(m_c*(l_c).^2+2*m_p*((l_h).^2+(l_p).^2));

eig_1 =  -1 ;
eig_2 = -1 ;

K_pp = (eig_1*eig_2)/K_1;

K_pd = -(eig_1+eig_2)/K_1;

%Fra task 1:
A = [0 1 0; 0 0 0; 0 0 0];
B = [0 0;0 K_1;K_2 0];
Q = [80 0 0;0 40 0;0 0 100]';
R = [1 0;
    0 1]';

%Fra Task 2:
% Q = [80 0 0 0 0;0 40 0 0 0;0 0 100 0 0; 0 0 0 15 0; 0 0 0 0 6]';
% A = [0 1 0 0 0;0 0 0 0 0;0 0 0 0 0;-1 0 0 0 0;0 0 -1 0 0];
% B = [0 0;0 K_1;K_2 0;0 0;0 0];


K = lqr(A,B,Q,R);
F = [K(1,1),K(1,3);K(2,1),K(2,3)];


%dag 3
A_est = [0 1 0 0 0;
         0 0 0 0 0;
         0 0 0 1 0;
         0 0 0 0 0;
         K_3 0 0 0 0];
 
B_est = [0 0;
         0 K_1;
         0 0;
         K_2 0;
         0 0];

%Sondre C
C_est = [0 0 1 0 0;
         0 0 0 0 1];
     
C = eye(5);
Q_est = diag([100 30 100 20 50]);

R_est = [1 0;
        0 1];
    
K_est = lqr(A_est, B_est, Q_est, R_est);

system_poles = eig(A_est-B_est*K_est);
fast_pole = max(abs(system_poles));

Pole_Gain = 50;
pole_length = fast_pole*Pole_Gain;
max_angle = pi/8;
angles = -max_angle : max_angle/2 : max_angle;
new_poles = -pole_length*exp(1i*angles);

L = place(A_est',   C', new_poles).';


