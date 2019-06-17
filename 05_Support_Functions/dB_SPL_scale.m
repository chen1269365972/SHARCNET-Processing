function [ sequence_scaled ] = dB_SPL_scale( sequence, target_dB_SPL_level, display_flag, scale_flag )


% This script-file rescales a sequence to a given target dB SPL value.
%
% Inputs:
%
% sequence - Discrete-time sequence data-values.
%
% target_dB_SPL_level - dB SPL target level.
%
% display_flag - If this logical-flag is set to 1, statistics for the sequence will
%       be displayed to the console.  If this logical-flag is set to 0, no statistics
%       will be displayed.
%
% scale_flag - If this logical-flag is set to 1, the given sequence will be scaled to
%       the desired dB SPL target-level.  If this logical-flag is set to 0, no
%       scaling will take place (i.e. the returned sequence will be the one handed to
%       this function as a argument).
%
%
% Outputs:
%
% sequence_scaled - Rescaled sequence.
%
%
%% See Also
% dB_SPL_Pascal_Conversion

% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Friday, September 13, 2013
% Creation Date:  Thursday, June 21, 2012


if ( scale_flag == 1 )    
    average_power = norm( sequence )^2 / length( sequence );
    
    input_stimulus_raw_normalized_to_1_RMS = sequence / sqrt( average_power );
    %
    scale_factor = 20e-6 * 10^( target_dB_SPL_level / 20 );
    sequence_scaled =  scale_factor  * input_stimulus_raw_normalized_to_1_RMS;    
else    
    sequence_scaled = sequence;    
end  % End:  if ( scale_flag == 1)
    

if ( display_flag == 1 )
    
    if ( scale_flag == 0 )    
        statistics( 'Raw', sequence );
        sequence_scaled = sequence;
    else        
        statistics( 'Raw - Pre-normalization', sequence );
        statistics( 'Raw - Post-normalization', input_stimulus_raw_normalized_to_1_RMS );
        statistics( 'Scaled', sequence_scaled );    
    end  % End:  if ( display_flag == 1 )
    
end  % End:  if ( display_flag == 1 )

end  % End:  function [ sequence_scaled ] = dB_SPL_scale( sequence, target_dB_SPL_level, display_flag, scale_flag )



%% Support Functions

function [] = statistics( text, sequence )

    raw_RMS = sqrt( mean( sequence.^2 ) );
    raw_variance = var( sequence );
    raw_minimum = min( sequence );
    raw_maximum = max( sequence );
    
    rms_raw_power = sqrt( norm( sequence )^2 / length( sequence ) );
    dB_SPL_level = 20.0 * log10( rms_raw_power / 20.0e-6 );
    
    to_display = sprintf( [ '\n\n%s Sequence:\n-----------------------------------\n', ...
        'RMS:  %6.3f\nVariance:  %6.3f\nMinimum:  %6.3f\nMaximum:  %6.3f\nRMS Power (Pascals):  %e\ndB SPL:  %6.3f', ...
        '\n-----------------------------------' ], ...
        text, raw_RMS, raw_variance, raw_minimum, raw_maximum, rms_raw_power, dB_SPL_level );
    %
    disp( to_display );
    
end



%% References



%% Digest

% Friday, September 13, 2013 (prior revision 580)
%   -Remove double-line print statement.


