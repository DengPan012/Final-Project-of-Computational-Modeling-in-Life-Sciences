function [t,v,r1,r2] = Model(c_dot,stimulus)
% input two parameter: coherence level and whether have stimulus
% output: solution of the equations, inluding t is time, v contains S1, S2,
% I_noise1, I_noise2, r1 is firing rate of neural population 1, and r2 is
% neural population 2
%
tmin = 0;
tmax = 2;
tspan = [tmin tmax];
v0 = [0.1 0.1 0 0];

% initial parameter used in the model
a = 270;
b = 108;
d = 0.154;
gama = 0.641;
taoS = 0.1;
JN11 = 0.2609;
JN22 = JN11;
JN12 = 0.0497;
JN21 = JN12;

% parameter for noise and injections
JAext = 5.2*10^(-4);
I0 = 0.3255;
miu0 = 30*stimulus;
taoAMPA = 0.002;
sigmanoise = 0.02;

% parameter of noise
tstep=0.01;% the time step of noise
tup=tmin+tstep:tstep:tmax;
Noise1=ones(size(tup)).*NaN;
Noise2=ones(size(tup)).*NaN;
noisescale=3;
for i=1:length(tup)
    Noise1(i)=randn*noisescale;
    Noise2(i)=randn*noisescale;
end

% outer injection
I1=JAext * miu0 * (1+c_dot);
I2=JAext * miu0 * (1-c_dot);

% formula used to calculate firing rate
x1 = @(S1,S2,I_noise1,I_noise2) JN11.*S1-JN12.*S2+I0+I1+I_noise1;
x2 = @(S1,S2,I_noise1,I_noise2) JN22.*S2-JN21.*S1+I0+I2+I_noise2;
H= @(x)(a.*x-b) ./ (1-exp(-d.*(a.*x-b)));
H1=@(S1,S2,I_noise1,I_noise2)H(x1(S1,S2,I_noise1,I_noise2));
H2=@(S1,S2,I_noise1,I_noise2)H(x2(S1,S2,I_noise1,I_noise2));

% four ode waiting to be solved
dS1 = @(S1,S2,I_noise1,I_noise2) -S1./taoS + (1-S1).*gama.*H1(S1,S2,I_noise1,I_noise2);
dS2 = @(S1,S2,I_noise1,I_noise2) -S2./taoS + (1-S2).*gama.*H2(S1,S2,I_noise1,I_noise2);
dInoise1 = @(I_noise1,time)-I_noise1./taoAMPA + eta(time,tup,Noise1).*sigmanoise./sqrt(taoAMPA);
dInoise2 = @(I_noise2,time)-I_noise2./taoAMPA + eta(time,tup,Noise2).*sigmanoise./sqrt(taoAMPA);

f = @(t,v) [dS1(v(1),v(2),v(3),v(4));...
    dS2(v(1),v(2),v(3),v(4));...
    dInoise1(v(3),t);...
    dInoise2(v(4),t)];

% using ode45 to calculate the solution
[t,v] = ode45(f,tspan,v0);

% calculate firing rate
r1=H1(v(:,1),v(:,2),v(:,3),v(:,4));
r2=H2(v(:,1),v(:,2),v(:,3),v(:,4));
end

