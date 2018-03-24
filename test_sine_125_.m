% true signal
% true observation noise
sigtrue = 0.1;
% time discretization
dt = 0.002;
printf("dt = %f\n", dt);
t = [0:dt:2];
% observations
f_true = 125;
printf("true frequency: %f\n", f_true)
beta = 0.8;
y = exp(-beta*t).*cos(2*pi*f_true*t);
y_noisy = y + sigtrue*randn(size(y));

% user input
verbose = true
% frequencies to test
f = [ 1 125 ];
% the process noise is characterized by Z=zI
z = 1;
% dimension of the state
ns = 1+2*size(f,2);
% prior on the first state
m0 = zeros(ns,1);
V0 = (10)^2*eye(ns);
% guess of the observation noise
sigma = sigtrue;

% Kalman filtering
[ mf, Vf ] = kfiltering(t,y_noisy,f,z,m0,V0,sigma,verbose);
% Kalman smoothing
[ ms, Vs ] = ksmoothing(t,z,mf,Vf,verbose);

% plotting
w = 450;
h = 450;

fh1 = figure('Position',[150,150,w,h]);

subplot(2,1,1);
hold on;
plot(t,exp(-beta*t), 'linewidth', 3, 'color', 'red');
m_pred = mf(end,:);
s_pred = sqrt(reshape(Vf(end,end,:),size(t)));
plot(t,m_pred, 'linewidth', 2, 'color', 'black');
X = [ t, fliplr(t) ]; # transpose the vectors: They must be 1-x-n (and not the other way round!)
Y = [ m_pred+s_pred, fliplr(m_pred-s_pred) ];
f = fill(X, Y, 'r');
set(f,"FaceAlpha",0.5); # set alpha value 
%legend('ground truth','mean prediction for amplitude at f=125Hz')
ylim([0,2])

subplot(2,1,2);
hold on;
for k = 1:ns
	plot(t,mf(k,:), 'linewidth', 2, 'color', 'black');
end
ylim([-1,2])
%legend('Mean predictions for amplitude at all frequencies')

fh2 = figure('Position',[250,250,w,h]);

subplot(2,1,1);
hold on;
plot(t,exp(-beta*t), 'linewidth', 3, 'color', 'red');
m_pred = ms(end,:);
s_pred = sqrt(reshape(Vs(end,end,:),size(t)));
plot(t,m_pred, 'linewidth', 2, 'color', 'black');
X = [ t, fliplr(t) ]; # transpose the vectors: They must be 1-x-n (and not the other way round!)
Y = [ m_pred+s_pred, fliplr(m_pred-s_pred) ];
f = fill(X, Y, 'r');
set(f,"FaceAlpha",0.5); # set alpha value 
%legend('ground truth','mean prediction for amplitude at f=125Hz')
ylim([0,2])

subplot(2,1,2);
hold on;
for k = 1:ns
	plot(t,ms(k,:), 'linewidth', 2, 'color', 'black');
end
ylim([-1,2])
%legend('Mean predictions for amplitude at all frequencies')


disp(' ')
disp('Press any key to end.')
pause
close(fh1);
close(fh2);
clear all;