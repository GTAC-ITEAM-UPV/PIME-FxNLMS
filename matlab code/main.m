% main
% configure parameters and run this file to start the simulation
%% gen acoustic paths
[Pri, h, Pri2, h2] = acoustic_paths_gen();

%% simulation and algorithm configuration
params.Ite = 200000;    % total number of samples in the simulation
params.Ite2 = 100000;   % sample in which paths change
params.L = 400;         % adaptative control filter length
params.Mp = 300;        % primary path identifier length
params.Ms = 300;        % secondary path identifier length  
 
%Div = 2;
params.mu = 0.25;       % control filter convergence step size
params.mu2 = 0.45;      % identification filter convergence step size

params.beta = 0.99;     % forgetting factor for E0
params.k = 0.06;        % scaling factor that balances the primary and secondary path energies in the identification regression vector (k*buf_x).
params.c2 = 0.01;       % tuning constant that sets how quickly gamma transitions from 0 to 1 as the internal model error decreases.
params.eps = 1e-10;     % small positive constant that overcomes the potential numerical instability in the update of weights 

%% reference signal
rng(0);

x = randn(params.Ite,1);
x = filter(fir1(500, 0.5), 1, x);
x = x - mean(x);

%% RUN PIME-FxNLMS
[e_signal, e_internal, e_identif, d_signal, y_signal, P, S, E0_hist, gamma_hist] = ...
    pime_fxnlms_online_estimation(x, Pri, h, Pri2, h2, params);

%% Plots

% Error signals over the whole simulation
figure
plot([d_signal e_internal e_identif e_signal])
legend('d (primary noise)', 'e_i (internal model)', ...
       '\epsilon (identification error)', 'e (error microphone)')
ylim([-0.25 0.25])
xlabel('Samples'); ylabel('Amplitude')
title('Error signals over time')

% Secondary/primary path estimation vs true paths 
% (compares against the path segment active at the end of the run)
if params.Ite2 < params.Ite
    true_sec = h2;
    true_pri = Pri2;
else
    true_sec = h;
    true_pri = Pri;
end

figure
plot([S(1:length(true_sec)) true_sec])
legend('Estimated', 'True')
xlabel('Taps'); ylabel('Amplitude')
title('Secondary path estimation (S)')

figure
plot([P(1:length(true_pri)) true_pri])
legend('Estimated', 'True')
xlabel('Taps'); ylabel('Amplitude')
title('Primary path estimation (P)')

