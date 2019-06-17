function [ modified_neurogram, neurogram_time ] = rectangular_window_processing( neurogram, neurogram_time, ...
    model_frequency, window_size, fractional_overlap, repetitions_of_stimulus )

% This script-file applies a rectangular window at a specified
% fractional-overlap to jointly rebin and filter (i.e. "smooth") the given
% neurogram.
%
%
%% See Also
% hamming_window_processing

% Author:  Michael R. Wirtzfeld
% Creation Date:  Wednesday, August 22, 2012
% Modification Date:  Friday, May 24, 2013
%       Change Digest:  See below.
%
%% See Also
% 


% Preallocate Memory
window_set = Window_Analysis(neurogram(1, :), window_size, floor(window_size*fractional_overlap ), 1);
modified_neurogram = zeros(size(neurogram, 1), size(window_set, 1));


for CF_index = 1:1:size(neurogram, 1)
    
    window_set = Window_Analysis(neurogram(CF_index, :), window_size, ...
        floor(window_size*fractional_overlap), 1);
    
    modified_neurogram( CF_index, : ) = (sum( window_set, 2 ))';
    
end;


window_overlap = floor( fractional_overlap * window_size );
    modified_sample_frequency = model_frequency / (window_size - window_overlap);

modified_neurogram = modified_neurogram.*modified_sample_frequency./repetitions_of_stimulus*(1-fractional_overlap);
neurogram_time = neurogram_time(1:window_overlap:(size(window_set, 1)*window_overlap));


end



%% References



%% Digest

% Friday, May 24, 2013 (prior revision 1718)
%   -Remove second normalization of neurogram by stimulus repetitions.

% Monday, December 24, 2012
%   -Review and tidy script-file.


