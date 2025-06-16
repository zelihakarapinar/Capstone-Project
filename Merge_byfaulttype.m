clc; clear; clear all; close all;

% Sampling rate of the vibration signal (in Hz)
sampling_rate = 48000;

% Initialize an empty array to store the merged vibration signal
merged_data = [];

% ================================
% Dataset Description:
% This section defines the .mat file to be loaded.
% Each entry contains:
%   1. File name (.mat)
%   2. Variable name inside the file (DE - Drive End sensor)
%   3. Rotational speed (not used in this script)
%   4. Fault type (e.g., Ball fault)
% Only DE (Drive End) signals are used in this script.
% ================================
datasets = {
    {'188.mat',  'X188_DE_time', 1730, 'Ball'},
};

% Loop through each dataset and concatenate the signal
for i = 1:length(datasets)
    file_name = datasets{i}{1};      % .mat file name
    signal_name = datasets{i}{2};    % Variable name inside the .mat file

    % Load .mat file
    mat_data = load(file_name);

    % Extract the signal from the loaded struct
    signal = mat_data.(signal_name);

    % Merge the extracted signal into a single array
    merged_data = [merged_data; signal];
end

% Display the size of the final merged signal
size(merged_data)

% ================================
% Save the merged signal for further use
% ================================

% Save as .mat file
save('48kball188_testdata.mat', 'merged_data')

% Save as .csv file for easier access in other tools
csvwrite('48kball188_testdata.csv', merged_data);

% ================================
% Plot a short segment of the signal for visualization
% ================================

% Create a time vector corresponding to the signal length (in milliseconds)
time = (0:length(merged_data)-1) / sampling_rate; % in seconds
time = time * 1e3; % convert to milliseconds

% Plot the first 1/25th second of data (approx. 40 ms)
plot(time(1:sampling_rate/25), merged_data(1:sampling_rate/25));
title('Raw Vibration Signal for Ball Fault (DE)');
xlabel('Time (ms)');
ylabel('Amplitude');
ylim([-3 3]);  % Adjust y-axis limits for better visualization
