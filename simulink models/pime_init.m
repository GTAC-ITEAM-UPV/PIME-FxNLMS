%PIME initialization

fs=2000;
load("paths_2kHz_mic643.mat");


%buffer size
Mp=500;
Ms=500;

%identification filter
L=Mp+Ms;
mu= 0.4; 
Initial=zeros(Mp+Ms,1)';
Initial(Mp+1)=1;

%control filter
L2=400; 
mu2=0.1; 

%gamma
c2=0.12;
alpha=0.999;

k=0.06;

%error mic position change (seconds)
t_mic_change=30;

