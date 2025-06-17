clc; clear; clear all; close all;

% =============================
% Parameters
% =============================

sampling_rate = 48000;             % Sampling rate in Hz
window_length = 4096;              % Length of each window segment
step_size = window_length;         % Step size for non-overlapping windows
epsilon = 1e-6;                    % Small value to prevent division by zero during normalization

% File containing merged raw DE signal (preprocessed earlier)
outerracefault_data_file = '48kball188_testdata.mat';
outerracefault_signal_variable = 'merged_data';             % Variable name inside the .mat file

% Output file names
output_mat_file = '48kball188_testrawdata.mat';             % Output for windowed data (MAT)
output_csv_file = '48kball188_testrawdata.csv';             % Output for windowed data (CSV)

% =============================
% Load Raw DE Signal from .mat File
% =============================

try
    mat_data = load(outerracefault_data_file);

    % Check if the signal variable exists in the file
    if ~isfield(mat_data, outerracefault_signal_variable)
        error('Variable "%s" not found in file "%s". Please check the variable name.', ...
              outerracefault_signal_variable, outerracefault_data_file);
    end

    % Extract the DE signal
    de_signal = mat_data.(outerracefault_signal_variable);

    % Ensure signal is a column vector
    if size(de_signal, 2) > 1
        de_signal = de_signal'; % Transpose if needed
    end

catch ME
    error('Failed to load or process %s: %s', outerracefault_data_file, ME.message);
end

% =============================
% Validate Signal Data
% =============================

% Check for invalid values in the signal
if any(isnan(de_signal)) || any(isinf(de_signal))
    error('Data contains NaN or Inf values. Check input file: %s', outerracefault_data_file);
end

% Print signal length for verification
fprintf('Loaded data with %d samples.\n', length(de_signal));

% =============================
% Normalize Signal (Zero mean, unit variance)
% =============================

de_signal = (de_signal - mean(de_signal)) / (std(de_signal) + epsilon);

% =============================
% Segment Signal into Fixed-Length Windows
% =============================

num_samples = length(de_signal);
total_windows = floor((num_samples - window_length) / step_size) + 1;

% Ensure there's enough data to create at least one full window
if total_windows < 1
    error('Data length (%d) is too short for window size (%d).', num_samples, window_length);
end

fprintf('Processing %d windows of size %d...\n', total_windows, window_length);

% Preallocate arrays for efficiency
all_data = zeros(total_windows, window_length);   % Matrix to store windowed DE signals
all_labels = cell(total_windows, 1);              % Cell array for labels

% =============================
% Sliding Window Loop
% =============================

window_idx = 1;
for i = 1:total_windows
    start_idx = (i-1)*step_size + 1;
    end_idx = start_idx + window_length - 1;

    % Extract signal window and store as a row
    all_data(window_idx, :) = de_signal(start_idx:end_idx)';

    % Assign label for each window (since this example is "Ball" fault only)
    all_labels{window_idx} = 'Ball';

    window_idx = window_idx + 1;
end

% =============================
% Convert Labels to Categorical Type
% =============================

all_labels = categorical(all_labels);

% =============================
% Save Data to .mat File
% =============================

save(output_mat_file, 'all_data', 'all_labels', 'sampling_rate', 'window_length', '-v7.3');
fprintf('MAT-file saved as %s\n', output_mat_file);

% =============================
% Save Data to .csv File
% =============================

% Create header names for CSV: DE_0001, DE_0002, ..., DE_4096 + "Label"
header = [compose('DE_%04d', 1:window_length), {'Label'}];

% Convert categorical labels to cell array of strings for CSV export
labels_for_csv = cellstr(all_labels);

% Create a table: numerical data + label column
csv_table = array2table(all_data);
csv_table.Properties.VariableNames = compose('DE_%04d', 1:window_length);  % Assign column names
csv_table.Label = labels_for_csv;                                          % Add label column

% Write the table to CSV
writetable(csv_table, output_csv_file);
fprintf('CSV file saved as %s\n', output_csv_file);

disp('Processing complete.');
