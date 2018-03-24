% spectrum estimation by Kalman smoothing:

% Intputs
%% Mean mf and covariance matrix Vf of the state at each time-step
%% obtained by Kalman filtering 

function [ ms, Vs ] = ksmoothing(t,z,mf,Vf,verbose)

cputime0 = cputime;

% dimension of the state
ns = size(mf,1);
% number of time-steps
t_length = size(mf,2);
% Kalman smoothing
if verbose
	printf("starting Kalman smoothing over %d iterations:\n",t_length)
end
% mean and variance of the state
Vs = zeros(ns,ns,t_length);
ms = zeros(ns,t_length);
% start of the recursion, t=t_length
ms(:,t_length)   = mf(:,t_length);
Vs(:,:,t_length) = Vf(:,:,t_length);
% Kalman filtering, from t to (t-1)
for k = t_length-1:-1:1
	t_now = t(k);
	t_next = t(k+1);
	G = (t_next-t_now)*z*eye(ns);
	V = reshape( Vf(:,:,k), [ns ns ]);
	P = V + G;
	J = Vf(:,:,k)*inv(P);
	Vs(:,:,k) = V + J*(Vs(:,:,k+1)-P)*J';
	ms(:,k) = mf(:,k) + J*(ms(:,k+1) - mf(:,k));
end

if verbose
	printf("cputime: %.1fs.\n",cputime-cputime0)
end