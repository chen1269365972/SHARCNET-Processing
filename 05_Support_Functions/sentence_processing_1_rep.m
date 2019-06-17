function [ raw_neurograms ] = sentence_processing_1_rep( stimulus, parameters, placement_index, end_index )

% This script-file prepares a given sentence for processing by the cat
% auditory periphery model.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Thursday, June 14, 2012
% Modification Date:  Friday, July 25, 2014 (copy of "sentence_processing.m")
%       Change Digest:  See below.
%
%% See Also
%


%% Stimulus Preprocessing

% Head-related Transfer Function (HRTF)
if ( parameters.sentence_processing.apply_HRTF == 1 )
    processed_stimulus = HRTF_Processing( stimulus, ...
        parameters.sentence_processing.sample_frequency );
else
    processed_stimulus = stimulus;
end;


% Envelope Conditioning
if ( parameters.sentence_processing.ramping == 1 )
    processed_stimulus = Envelope_Shaping( processed_stimulus, 'logistic' );
end;


% dB SPL Scaling
processed_stimulus = dB_SPL_scale( processed_stimulus, ...
    parameters.sentence_processing.dB_SPL_level, 0, 1 );


% Interpolation to Model Frequency
processed_stimulus = resample( processed_stimulus, ...
    parameters.model.sample_frequency, parameters.sentence_processing.sample_frequency );
    time_indices = ( 1:1:numel(processed_stimulus) ) ./ parameters.model.sample_frequency;

raw_neurograms.upsampled_stimulus = processed_stimulus';
raw_neurograms.upsampled_time_indices = time_indices;


% Modified Indices for Target-word Extraction
upsampled_placement_index = floor( placement_index * parameters.model.sample_frequency / ...
    parameters.sentence_processing.sample_frequency );

upsampled_end_index = floor( end_index * parameters.model.sample_frequency / ...
    parameters.sentence_processing.sample_frequency );

windows = target_word_windowing( upsampled_placement_index, upsampled_end_index );



%% Original/Chimaera Sentences

audiogram.frequencies = [ 250, 500, 1e3, 2e3, 3e3, 4e3, 6e3 ];
audiogram.HL = [ 0, 0, 0, 0, 0, 0, 0 ];

model_response_original = auditory_model_1_rep( processed_stimulus, parameters, audiogram );

model_response_original.target_word = ...
    extract_target_word( model_response_original, windows, parameters );

model_response_original.target_word.PSTH_subset = ...
    model_response_original.target_word.PSTH(parameters.model.CFs_extracted_indices, :);

raw_neurograms.original = model_response_original;



%% Matched Noise Sentences

matched_noise_sequence = generate_base_signal(processed_stimulus);

matched_noise = dB_SPL_scale( matched_noise_sequence, ...
    parameters.sentence_processing.dB_SPL_level, 0, 1 );
 
model_response_matched_noise = auditory_model_1_rep( matched_noise, parameters, audiogram );

model_response_matched_noise.target_word = ...
    extract_target_word( model_response_matched_noise, windows, parameters );

model_response_matched_noise.target_word.PSTH_subset = ...
    model_response_matched_noise.target_word.PSTH(parameters.model.CFs_extracted_indices, :);

raw_neurograms.matched_noise = model_response_matched_noise;
    
    
    
%% References



%% Digest

% Friday, July 25, 2014
%   -Rename "auditory_model" to "auditory_model_1_rep".
%   -Copy of "sentence_processing.m" at revision 1438.

% Wednesday, March 6, 2013
%   -Change code to calculate STMI base-signal (post: 1437, pre: 1436)

% Friday, December 28, 2012
%   -Further script-file consolidation.

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.

% Wednesday, September 5, 2012
%   -Consolidate changes made to "sentence_processing_verification.m".

% Monday, August 27, 2012
%   -Check saving of target-word and full-sentence neurograms.
%   -Check figure generation.
%   -Move figure generation code to new script-file, "display_neurograms".

% Saturday, July 28, 2012
%   -Incorporate code to handle both NSIM and STMI characterisitic
%   frequency sets.

% Saturday, July 21, 2012
%   -Validate operation.

% Friday, July 20, 2012
%   -Correct calulation of neurograms.

% Thursday, July 19, 2012
%   -Add flag to save target-word neurograms.


