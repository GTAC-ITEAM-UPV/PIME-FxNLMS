
function [Pri, h, Pri2, h2] = acoustic_paths_gen()
% acoustic_paths_gen generates the primary and secondary paths impulse responses before and after changing.   
%
% Pri, h - primary and secondary paths initial position
% Pri2, h2 - primary and secondary paths after change


room = [9.13 4.48 2.64];    % Room dimensions [x y z] (m)
c = 340;                    % Sound speed (m/s)
fs = 2000;                  % Sample frequency (samples/s)
reverb = 0.2;               % Reverberation time (s)
n = 300;                    % Number of samples


% Initial primary and secondary paths
primary_source_pos = [1 1 1];
secondary_source_pos = [7 2 1.5];
mic_pos = [7.5  2 1.4];

Pri = rir_generator(c, fs, mic_pos, primary_source_pos, room, reverb, n)';
h = rir_generator(c, fs, mic_pos, secondary_source_pos, room, reverb, n)';
            

% MICROPHONE POSITION CHANGE 

% Primary and secondary paths after mic change
primary_source_pos = [1 1 1];
secondary_source_pos = [7 2 1.5];
mic_pos = [7.5  2 1.5];

Pri2 = rir_generator(c, fs, mic_pos, primary_source_pos, room, reverb, n)';
h2 = rir_generator(c, fs, mic_pos, secondary_source_pos, room, reverb, n)';