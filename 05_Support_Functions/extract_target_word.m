function [ extracted_target_word_neurograms ] = extract_target_word( model_response_original, ...
    windows, parameters )

% This script-file determines the appropriate separation index for a given
% NU 6 sentence based on a short-term energy values and its respective
% slow, time-varying amplitude.  See the first reference below.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Friday, June 29, 2012
% Modification Date:  Thursday, December 27, 2012
%
%% See Also
% target_word_harness, target_word_windowing


windowed_PSTH = model_response_original.PSTH( :, 1:numel( windows.target_word ) ) .* ...
    repmat( windows.target_word', numel(parameters.model.CFs), 1 );
windowed_PSTH = windowed_PSTH( :, windows.index:size(windowed_PSTH, 2) );

sample_period = 1 / parameters.model.sample_frequency;
    windowed_time_indices = sample_period:sample_period:(sample_period * size(windowed_PSTH, 2) );
    
extracted_target_word_neurograms.PSTH = windowed_PSTH;
extracted_target_word_neurograms.PSTH_time_indices = windowed_time_indices;



%% References



%% Digest

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.


% Saturday, July 28, 2012
%   - Modify code to handle both NSIM and STMI characteristic frequency
%       sets.


