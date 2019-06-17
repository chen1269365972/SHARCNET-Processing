function [ modified_neurogram, neurogram_time ] = hamming_window_processing( neurogram, neurogram_time, ...
    model_frequency, window_size, fractional_overlap, repetitions_of_stimulus, spike_rate_scaling )

% This script-file applies a user-defined Hamming window at a specified
% overlap to jointly rebin and filter (i.e. "smooth") the given neurogram.
%
%
%% See Also
% rectangular_window_processing 

% Author:  Michael R. Wirtzfeld
% Creation Date:  Wednesday, February 15, 2012
% Modification Date:  Friday, May 24, 2013
%       Change Digest:  See below.
%
%% See Also
% rectangular_window_processing


% Preallocate Memory
window_set = Window_Analysis(neurogram(1, :), window_size, floor(window_size*fractional_overlap), 1);
modified_neurogram = zeros(size(neurogram, 1), size(window_set, 1));

neurogram = neurogram ./ repetitions_of_stimulus;


for CF_index = 1:1:size(neurogram, 1)
    
    window_set = Window_Analysis(neurogram(CF_index, :), window_size, ...
        floor(window_size*fractional_overlap), 1);

    hamming_window_set = repmat(hamming(window_size)', size(window_set, 1), 1);
        windowed_a_cf_psth = window_set.*hamming_window_set;
        
    modified_neurogram(CF_index, :) = (sum(windowed_a_cf_psth, 2))';
    
end;


window_overlap = floor(fractional_overlap*window_size);
    modified_sample_frequency = model_frequency / (window_size - window_overlap);

if ( spike_rate_scaling == 1 )
    modified_neurogram = modified_neurogram .* modified_sample_frequency;
end;

neurogram_time = neurogram_time(1:window_overlap:(size(window_set, 1) * window_overlap));


end



%% References



%% Digest

% Friday, May 24, 2013 (prior revision 1270)
%   -Addition of logical-flag to set raw spike count or spikes-per-second.

% Friday, December 21, 2012
%   -Review and tidy script-file.
%       b.)  Remove "repetitions_of_stimulus" variable.
%       a.)  Remove "spike_rate_scaling" variable;  only use NET spike-count.

% Wednesday, October 17, 2012
%   -Add flag to control scaling of PSTH to spikes per second.


