% spectrum estimation by Kalman filtering:

% Inputs
%% t: time discretization
%% y_noisy: true signal, possibly contaminated by (Gaussian) noise
%% the process noise is characterized by Z=zI
%% m0, V0: prior on the first (hidden) state
%% sigma: standard deviation of the observation noise

% Outputs
%% Mean m and covariance matrix V of the state at each time-step 
%% Mean is of size ns-x-ns-t_lentgh
%% where ns is the dimension of the state and t_length the number of time-steps

function [ m, V ] = kfiltering(t,y_noisy,f,z,m0,V0,sigma,verbose)

cputime0 = cputime;

% dimension of the state
ns = 1+2*size(f,2);
% Kalman filtering
t_length = size(t,2);
if verbose
	printf("starting Kalman filtering over %d iterations:\n",t_length)
	printf("time-step must be smaller than %f\n", 0.5/f(end))
end
% mean and variance of the state
V = zeros(ns,ns,t_length);
m = zeros(ns,t_length);
% start of the recursion, t=1
c = [ 1 sin(2*pi*f*t(1)) cos(2*pi*f*t(1)) ];
K = V0*c'*inv(c*V0*c'+sigma^2);
V(:,:,1) = (eye(ns)-K*c)*V0;
m(:,1) = m0 + K*(y_noisy(1)-c*m0);
% Kalman filtering, from (t-1) to t
for k = 2:t_length
	t_prev = t(k-1);
	t_now = t(k);
	c = [ 1 sin(2*pi*f*t_now) cos(2*pi*f*t_now) ];
	G = (t_now-t_prev)*z*eye(ns);
	P = reshape( V(:,:,k-1), [ns ns ]) + G;
	K = P*c'*inv(c*P*c'+sigma^2);
	V(:,:,k) = (eye(ns)-K*c)*P;
	m(:,k) = m(:,k-1) + K*(y_noisy(k)-c*m(:,k-1));
end

if verbose
	printf("cputime: %.1fs.\n",cputime-cputime0)
end