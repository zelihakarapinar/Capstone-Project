clc; clear; clear all; close all;

% =============================
% Configuration
% =============================

% List of .mat files containing preprocessed raw DE signal windows
input_files = {
    '48khealty_trainingrawdata.mat',     % Healthy condition
    '48kinner_trainingrawdata.mat',      % Inner race fault
    '48kball_trainingrawdata.mat',       % Ball fault
    '48kouter_trainingrawdata.mat'       % Outer race fault
};

% Output filenames for merged data
output_mat_file = '48kcombined_trainingrawdata.mat';   % .mat output
output_csv_file = '48kcombined_trainingrawdata.csv';   % .csv output (optional)

% =============================
% Initialization
% =============================

all_data_list = {};         % Will store all data arrays from different files
all_labels_list = {};       % Will store corresponding labels
window_length = -1;         % Will be determined dynamically based on first file

fprintf('Starting merging process...\n');

% =============================
% Loop through input files and load their content
% =============================

for i = 1:length(input_files)
    current_file = input_files{i};
    fprintf('Loading %s...\n', current_file);

    try
        loaded_data = load(current_file);

        % Validate presence of expected variables
        if ~isfield(loaded_data, 'all_data')
            warning('Variable "all_data" not found in %s. Skipping file.', current_file);
            continue;
        end
        if ~isfield(loaded_data, 'all_labels')
            warning('Variable "all_labels" not found in %s. Skipping file.', current_file);
            continue;
        end

        % Determine window length from data size
        current_wl = size(loaded_data.all_data, 2);

        % First file: use it to establish window length
        if i == 1
            if isfield(loaded_data, 'window_length')
                 window_length = loaded_data.window_length;
                 fprintf('Determined window length from variable in %s: %d\n', current_file, window_length);

                 % Check if saved value matches actual data dimensions
                 if window_length ~= current_wl
                     warning('Saved window_length (%d) in %s does not match data dimension (%d). Using data dimension.', ...
                         window_length, current_file, current_wl);
                     window_length = current_wl;
                 end
            else
                 % Fallback: infer from data dimensions
                 window_length = current_wl;
                 fprintf('Inferred window length from data dimensions in %s: %d\n', current_file, window_length);
            end

            if window_length <= 0
                 error('Invalid window length detected in first file: %s', current_file);
            end

        % Other files: check if window length is consistent
        elseif current_wl ~= window_length
             warning('Inconsistent window length in %s. Expected %d, found %d. Skipping file.', ...
                     current_file, window_length, current_wl);
             continue; % Skip this file
        end

        % Store data and labels
        all_data_list{end+1} = loaded_data.all_data;
        all_labels_list{end+1} = loaded_data.all_labels;

    catch ME
        warning('Failed to load or process %s: %s. Skipping file.', current_file, ME.message);
    end
end

% =============================
% Concatenate all collected data
% =============================

% Combine all windowed signals vertically
combined_data = vertcat(all_data_list{:});

% Combine all corresponding labels
combined_labels = vertcat(all_labels_list{:});

fprintf('Merging complete. Total windows: %d\n', size(combined_data, 1));

% =============================
% Save merged result to .mat file
% =============================

fprintf('Saving merged data to %s...\n', output_mat_file);

if window_length > 0
    save(output_mat_file, 'combined_data', 'combined_labels', 'window_length', '-v7.3');
else
    save(output_mat_file, 'combined_data', 'combined_labels', '-v7.3');
end

fprintf('MAT-file saved.\n');

% =============================
% Optional: Export merged data to CSV
% =============================

if window_length <= 0
     warning('Cannot save CSV because window length is invalid.');
else
    fprintf('Saving merged data to %s...\n', output_csv_file);

    try
        % Create header names for each DE signal value (e.g., DE_0001, ..., DE_4096)
        header = [compose('DE_%04d', 1:window_length), {'Label'}];

        % Convert categorical labels to strings
        labels_for_csv = cellstr(combined_labels);

        % Create a table with signal data
        csv_table = array2table(combined_data);
        csv_table.Properties.VariableNames = compose('DE_%04d', 1:window_length);

        % Add label column
        csv_table.Label = labels_for_csv;

        % Write the table to CSV file
        writetable(csv_table, output_csv_file);
        fprintf('CSV file saved as %s\n', output_csv_file);

    catch ME
        warning('Failed to save CSV file: %s', ME.message);
    end
end

fprintf('Script finished.\n');
