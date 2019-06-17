function [ parameters ] = processing_parameters()

% This script-file creates a structure with associated fields to
% manage processing parameters associated with the speech intelligibility
% chimaera data-set.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Thursday, February 19, 2015
% Creation Date:  Thursday, July 8, 2011
%       Change Digest:  See below
%
%% See Also
% 


sentence_processing = struct( 'sample_frequency', 44.1e3, ...
    'apply_HRTF', 1, ...  % Head-related Transfer Function
    'ramping', 1, ...  % Linear Ramping to Eliminate or Reduce Processing Artefacts
    'dB_SPL_level', 65, ...  % Conversational Speech
    'display_pre_post_dB_SPL_levels', 0 );

    sentence_processing = orderfields( sentence_processing, { 'sample_frequency', ...
        'apply_HRTF', 'ramping', 'dB_SPL_level', 'display_pre_post_dB_SPL_levels' } );
    

CFs = logspace(log10(180), log10(7040), 128);  % Hertz
CFs_extracted_indices = [12 17 21 25 29 33 37 41 45 50 54 58 62 66 70 74 79 83 87 91 95 99 103 108 112 116 120 124 128];
%
model = struct( 'model_version', '_BEZ2018', ...
    'sample_frequency', 100e3, ...  % Hertz
    'spontaneous_rate', [ 1 2 3 ], ...  % Spontaneous Neural Spiking-Rate Fibre Type (Low, Medium and High)
    'fraction_of_spontaneous_rate', [ 0.10 0.30 0.60 ], ...
    'power_law_implementation', 0.0, ...  % Approximate Implementation
    'noise_type', 1.0, ...
    'time_multiplication_factor', 1.5, ...
    'tabs', 0.6e-3, ...
    'trel', 0.6e-3, ...
    'number_of_realizations', 50, ...
    'CFs', CFs, ...
    'CFs_extracted_indices', CFs_extracted_indices, ...
    'CF_flag', 'nsim', ...
    'outer_haircell_control', 1.0, ...  % Normal
    'inner_haircell_control', 1.0, ...  % Normal
    'species', 2 );  % Cat - 1, Human -2

    model = orderfields( model, { 'model_version', 'sample_frequency', 'spontaneous_rate', ...
        'fraction_of_spontaneous_rate', 'power_law_implementation', ...
        'time_multiplication_factor', 'noise_type', 'tabs', 'trel', ...
        'number_of_realizations', ...
        'CFs', 'CFs_extracted_indices', ...
        'CF_flag', 'outer_haircell_control', 'inner_haircell_control', 'species' } );


neurogram_processing = struct( ...
    'envelope_time_window', 100e-6, ...  % Seconds - Hines & Harte, BSA Conference 2010
    'envelope_samples', 128, ...  % Dimensionless - Hamming Window
    'tfs_time_window', 10e-6, ...  % Seconds - Hine & Harte, BSA Conference 2010
    'tfs_samples', 32, ...  % Dimensionless - Hamming Window
    'stmi_window_type', 'rectangular', ...
    'stmi_time_window', 16e-3, ...  % Seconds
    'fractional_window_overlap', 0.50,  ...% Dimensionless
    'prune_time', 0.0, ...  % Seconds
    'save_raw_neurograms', 1, ...
    'display_figures', 0 );

    neurogram_processing=orderfields( neurogram_processing, { ...
        'envelope_time_window', 'envelope_samples', 'tfs_time_window', 'tfs_samples', ...
        'stmi_window_type', 'stmi_time_window', 'fractional_window_overlap', 'prune_time', ...
        'save_raw_neurograms', 'display_figures' });
    
    
stmi_processing = struct( 'rate', 2.^(1:0.5:5), ...  % Rate Vector (Hertz)
    'scale', 2.^(-2:0.5:3) );  % Scale Vector (Cycles per Octave)
    stmi_processing = orderfields( stmi_processing, { 'rate', 'scale' } );
    
    
nsim_weights = struct( 'alpha', 1.0, 'beta', 0.0, 'gamma', 1.0 );
%
nsim_processing = struct( 'weights', nsim_weights, ...
    'scaling_raw_sps_nsim', 1, ...  % 0 - Raw;  1 - spikes per second
    'kernel_type', 1, ...  % 1 - Normalized;  Other - Gaussian
    'kernel', ones(3, 3), ...
    'scaling', 0, ...  % 0 - Unscaled;  1 - Scaled
    'raw_env_factor', 2.5, 'raw_tfs_factor', 12, ...
    'dynamic_range', 0 );  % 0 - No;  1 - Yes (Hines method for setting scale factors)
    
    
general = struct( 'display_text', 1, 'calculate_metrics', 0 );
    
    
    
parameters.model = model;
parameters.sentence_processing = sentence_processing;
parameters.neurogram_processing = neurogram_processing;
parameters.stmi_processing = stmi_processing;
parameters.nsim_processing = nsim_processing;
parameters.general = general;

parameters = orderfields( parameters, { 'sentence_processing', 'model', ...
    'neurogram_processing', 'stmi_processing', 'nsim_processing', 'general' } );
    
    
    
%% References

%   "Speech Intelligibility prediction using a Neurogram Similarity Index
%   Measure", Andrew Hines and Naomi Harte, Speech Communication, Volume
%   54, pages 306-320, 2012



%% Digest

% Thursday, February 19, 2015 (prior revision 2140)
%   -Add field to structure for model version.

% Friday, May 24, 2013 (prior revision 1531)
%   -Include logical-flag for NSIM raw spike count or spikes-per-second.
%   -Set "nsim_processing.dynamic_range" to 1 (A. Hines, dynamic range
%       scaled using maximum value of unprocessed neurogram.

% Friday, April 19, 2013  (prior revision 1467)
%   -Addition of three fields to 'nsim_processing'.
%       -'kernel_type' - Normalized (1) or Guassian (other)
%       -'scaling' - Unscaled (0) or Scaled (1)
%       -'dynamic_range' - No (0) or Yes (1) - Using first image argument.

% Tuesday, January 15, 2013
%   -Addition of fields for raw PSTH scaling values for NSIM normalization.

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.

% Thursday, August 16, 2012
%   -Change "tfs_samples" from 64 to 32.

% Friday, July 27, 2012
%   -Update parameters to account for:
%       a.)  Use Rasha's characteristic frequencies (180 to 7,040 Hz; 128 in total).
%           Use 16 ms rectangular window with 50% overlap
%       b.)  Use Hines & Harte (2012) characteristic frequencies (250 to 8 kHz;  30 in total)
%           Use noted time-rebinning and Hamming windows sizes for ENV and
%           TFS, respectively.


