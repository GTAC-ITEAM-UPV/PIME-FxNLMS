
function [e_signal, e_internal, e_identif, d_signal, y_signal, P, S, E0_hist, gamma_hist] = pime_fxnlms_online_estimation(x, Pri, h, Pri2, h2, params)
% pime_fxnlms_online_estimation 
%
% Inputs:
% x - reference signal
% Pri, h - primary and secondary path before change
% Pri2, h2 - primary and secondary path after change
% params - configuration parameters
%
% Outputs:
% e_signal - error signal captured by the microphone
% e_internal - internal control model error signal (ei)
% e_identif - online path identification error signal (e2)
% P, S - primary and secondary path estimations
% E0_hist - internal error envelope over time (E0)
% gamma_hist - blending weight between e_signal and e_internal


% Configuration parameters

Ite = params.Ite;     % total number of samples in the simulation
Ite2 = params.Ite2;   % sample in which paths change         
L = params.L;         % adaptative control filter length
Mp = params.Mp;       % primary path identifier length
Ms = params.Ms;       % secondary path identifier length
mu = params.mu;       % control filter convergence step size
mu2 = params.mu2;     % identification filter convergence step size
beta = params.beta;   % forgetting factor for E0
k = params.k;         % Scaling factor that balances the primary and secondary path energies in the identification regression vector (k*buf_x).         
c2 = params.c2;       % Tuning constant that sets how quickly gamma transitions from 0 to 1 as the internal model error decreases.
eps = params.eps;     % small positive constant that overcomes the potential numerical instability in the update of weights 

% Variables to store results:
e_signal = zeros(Ite,1); 
e_internal = zeros(Ite,1);
e_identif = zeros(Ite,1);
d_signal = zeros(Ite,1);
E0_hist = zeros(Ite,1);
gamma_hist = zeros(Ite,1);
y_signal = zeros(Ite,1);
 
% Initial states
S = zeros(Ms,1);
S(1) = 1;
wout = zeros(L,1);              % control filter
buff_w = zeros(L,1);
wr_state = zeros(L-1,1);
xs_state = zeros(Ms-1,1);
buf_x = zeros(Mp,1);
buf_y = zeros(Ms,1);
T = zeros(Mp+Ms,1);             % identification filter 
bufxP = zeros(length(Pri),1);   % sliding window of x to convolve with the real primary path (Pri) -> d
bufyS = zeros(length(h),1);     % sliding window of y to convolve with the real secondary path (h) -> ys
D0 = sum(abs(Pri));
E0 = 0.01*D0;
e = 0; 

% loop

for n = 1:Ite

    bufxP = [x(n); bufxP(1:end-1)];
    if n < Ite2   
        d_signal(n) = Pri'*bufxP;
    else
        d_signal(n) = Pri2'*bufxP;
    end
 
    % Signal emmited by the control speaker
    [y, wr_state] = filter(wout, 1, x(n), wr_state);    % control filter output y(n)
    y_signal(n) = y;
       
    % Filtered-x with the secondary path estimation
    [xf,xs_state] = filter(S, 1, x(n), xs_state);       % reference signal filtered through the S estimate

    % Online primary and secondary path estimation
    Buff_xy = [k*buf_x; buf_y];
    etilde = T'*Buff_xy;
    e2 = e-etilde;
    T = T+ mu2/(Buff_xy'*Buff_xy+eps)*Buff_xy*e2;     % update the identification filter
    S = [T(Mp+1:end)];                                % extract the secondary path estimate
    P = k*[T(1:Mp)];                                  % extract the primary path estimate
    e_identif(n) = e2;                                % store the identification error history
    
    % Internal control model:
    ei = buf_x'*P + buf_y'*S;
    buf_x = [x(n); buf_x(1:end-1)];
    buf_y = [y; buf_y(1:end-1)];
    e_internal(n) = ei;

    % Blend the real error and the internal model error 
    E0 = max(abs(ei), beta*E0 + (1-beta)*abs(ei));  
    E0_hist(n) = E0;
    gamma = E0/(E0+c2); 
    gamma_hist(n) = gamma;

    % Control filter update
    wout = wout-0.7*mu/(buff_w'*buff_w+eps)*buff_w*((1-gamma)*e+gamma*ei);
    buff_w = [xf;buff_w(1:end-1)];
    
    % Propagation through the real secondary path
    bufyS = [y;bufyS(1:end-1)];
    if n<Ite2
    
       ys = h'*bufyS; 
    else
    
      ys = h2'*bufyS;
    
    end
    e = d_signal(n)+ys; % Signal captured by the error microphone
    e_signal(n) = e;

end


