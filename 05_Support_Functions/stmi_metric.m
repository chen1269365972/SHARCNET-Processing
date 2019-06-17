function [ stmi_metric ] = stmi_metric( neurograms, parameters )

% This script-file calculates the spectro-temporal modulation index (STMI)
% given a neurogram-set based on the orignal and chimaera sentences and
% their respective matched-noise spectral magnitudes.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Tuesday, June 26, 2012
% Modification Date:  Friday, March 29, 2013
%       Change Digest:  See below.
%
%% See Also
%


%% Parameters

rate = parameters.stmi_processing.rate;  % omega (Hertz)
scale = parameters.stmi_processing.scale;  % Omega (cycles per octave)



%% Calculate STMI Metric

frame_length = parameters.neurogram_processing.stmi_time_window * ...
    parameters.neurogram_processing.fractional_window_overlap;


% Original Sentence
original_sentence_cortex = abs( neurogram_to_cortex( neurograms.original.stmi.PSTH.', ...
    frame_length, rate, scale ) );
%
original_sentence_match_noise_cortex = abs( neurogram_to_cortex( neurograms.original_mn.stmi.PSTH.', ...
    frame_length, rate, scale ) );

T = max( ( original_sentence_cortex - original_sentence_match_noise_cortex ), 0 );
    %
    if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
        TT = sumsq( T(:) );
    else
        TT = sumsqr( T(:) );
    end;


% Chimaera Sentence
chimaera_sentence_cortex = abs( neurogram_to_cortex( neurograms.chimaera.stmi.PSTH.', ...
    frame_length, rate, scale ) );
%
chimaera_sentence_match_noise_cortex = abs( neurogram_to_cortex( neurograms.chimaera_mn.stmi.PSTH.', ...
    frame_length, rate, scale ) );

N = max( ( chimaera_sentence_cortex - chimaera_sentence_match_noise_cortex ), 0 );
    %
    if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
        NN = sumsq( max( ( T(:) - N(:) ), 0 ) );
    else
        NN = sumsqr( max( ( T(:) - N(:) ), 0 ) );
    end;
    
    
stmi_metric = 1 - NN/TT;



%% Reference(s)

% https://octave.sourceforge.io/octave/function/sumsq.html

% M. Elhilali, T. Chi and S. A. Shamma, "A spectro-temporal modulation
% index (STMI) for assessment of speech intelligibility," Speech
% Communication, Volume 41, pages 331-348, 2003



%% Digest

% Friday, March 29, 2013
%   -Review and clarify comments.

% Sunday, December 30, 2012
%   -Update code to handle different neurogram structure.

% Monday, August 27, 2012
%   -Compute only one STMI metric value.

% Saturday, July 28, 2012
%   -Modify script-file to handle both NSIM and STMI characteristic
%       frequency sets and neurogram processing requirements.


