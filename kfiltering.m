% user inputs
% true observation noise
sigtrue = 0.1;
% time discretization
dt = 0.002;
printf("dt = %f\n", dt);
t = [0:dt:2];
% observations
f_true = 125
f = [ 1:1:125 ];
printf("time-step must be smaller than %f\n", 0.5/f(end))
beta = 0.8;
y = exp(-beta*t).*cos(2*pi*f_true*t);
y_noisy = y + sigtrue*randn(size(y));

% spectrum estimation by Kalman filtering
% the state has dimension ns
ns = 1+2*size(f,2)
% the process noise is characterized by Z=zI
z = 1000;
% prior on the first state
m0 = zeros(ns,1);
V0 = (10)^2*eye(ns);
% guess of the observation noise
sigma = sigtrue
% Kalman filtering
t_length = size(t,2);
printf("starting Kalman filtering over %d iterations:\n",t_length)
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

w = 600;
h = 600;
fh1 = figure('Position',[150,150,w,h]);

subplot(2,1,1);
hold on;
plot(t,exp(-beta*t), 'linewidth', 3, 'color', 'red');
plot(t,m(end,:), 'linewidth', 2, 'color', 'black');
legend('ground truth','mean prediction for amplitude at f=125Hz')

subplot(2,1,2);
hold on;
for k = 1:ns
	plot(t,m(k,:), 'linewidth', 2, 'color', 'black');
end
axis([0 2 -0.4 1])
legend('Mean predictions for amplitude at all frequencies')

disp(' ')
disp('Press any key to end.')
pause
close(fh1);
clear all;