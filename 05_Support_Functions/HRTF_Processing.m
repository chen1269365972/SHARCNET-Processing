function [ hrtf_filtered_sequence ] = HRTF_Processing( speech_sequence, ...
    sample_frequency, ZERO_PHASE_FILTERING )


% This script-file modifies the spectral content of a given speech 
% sequence in such a manner as to realize its spectral representation
% at the eardrum.  It acts as a wrapper for the "hrtffilt.m" script-file.
%
% In order to apply the transfer function faithfully, the sample frequency
% of the speech sequence must be between 20 to 40 kHz to minimize the
% nonlinear warping effects of the applied bilinear transformation.  To
% meet this requirement, the sequence is resample to 35 kHz.  The original
% sample frequency is restored by the function prior to returning the new
% sequence to the calling function.
%
% If the ZERO_PHASE_FILTERING logic-flag is set to unity, the zero phase
% delay function FILTFILT is used.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Wednesday, September 28, 2011
% Modification Date:  Wednesday, June 13, 2012


if ( nargin < 3 )
    ZERO_PHASE_FILTERING = 0;
end;

if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
    
    resampled_speech_sequence = resample( speech_sequence, 5, 6 );
        new_sample_frequency = sample_frequency * 5 / 6;
        
    hrtf_filtered_resampled_speech_sequence = hrtffilt( resampled_speech_sequence, ...
        new_sample_frequency, ZERO_PHASE_FILTERING );

    hrtf_filtered_sequence = resample( hrtf_filtered_resampled_speech_sequence, 6, 5 );
        hrtf_filtered_sequence = hrtf_filtered_sequence(1:1:length(speech_sequence) );
        
else
    
    resampled_speech_sequence = resample( speech_sequence, 5, 6, 10, 5 );
        new_sample_frequency = sample_frequency * 5 / 6;
        
    hrtf_filtered_resampled_speech_sequence = hrtffilt( resampled_speech_sequence, ...
        new_sample_frequency, ZERO_PHASE_FILTERING );

    hrtf_filtered_sequence = resample( hrtf_filtered_resampled_speech_sequence, 6, 5, 10, 5 );
        hrtf_filtered_sequence = hrtf_filtered_sequence(1:1:length(speech_sequence) );
    
end    
    




%% References

% F. M. Wiener and D. A. Ross, "The Pressure Distribution in the Auditory
% Canal in a Progressive Sound Field," The Journal of the Acoustical
% Society of America, Volume 18, Number 2, pages 401-408, October, 1946


