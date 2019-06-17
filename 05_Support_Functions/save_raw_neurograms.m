function [] = save_raw_neurograms( neurograms, type_flag, case_index, word_index, target_word, implementation, parameters )

% This script-file saves raw post-stimulus time histograms.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Thursday, February 19, 2015
% Creation Date:  Friday, December 28, 2012
%       Change Digest:  See below.
%
%% See Also
% 

if ( strcmp(implementation, 'multiple_rep') || strcmp(implementation, 'single_rep') )
    filename_modifier = [ '_' implementation parameters.model.model_version '_' ];
else
    error( '*** Invalid filename modifier - save_raw_neurograms ***' );
end;    


if ( strcmp(type_flag, 'original' ) )
    
    filename = [ sprintf( 'Type_%d_Row_%d_%s_Original', case_index, word_index, ...
        upper(target_word) ) filename_modifier ];
    
    raw_original.stimulus = struct_field_2_single( neurograms.upsampled_stimulus );
    raw_original.time_indices = struct_field_2_single( neurograms.upsampled_time_indices );
    raw_original.original = struct_field_2_single( neurograms.original );
    raw_original.matched_noise = struct_field_2_single( neurograms.matched_noise );
    
    if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
        save ('-V7', filename, 'raw_original' );
    else
        save( filename, 'raw_original' );
    end;
        
else
    
    filename = [ sprintf( 'Type_%d_Row_%d_%s_Chimaera', case_index, word_index, ...
        upper(target_word) ) filename_modifier ];
    
    raw_chimaera.stimulus = struct_field_2_single( neurograms.upsampled_stimulus );
    raw_chimaera.time_indices = struct_field_2_single( neurograms.upsampled_time_indices );
    raw_chimaera.original = struct_field_2_single( neurograms.original );
    raw_chimaera.matched_noise = struct_field_2_single( neurograms.matched_noise );
    
    if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
        save ('-V7', filename, 'raw_chimaera' );
    else
        save( filename, 'raw_chimaera' );
    end;
    
end;



%% References



%% Digest

% Thursday, February 19, 2015 (prior revision 1300)
%   -Add filename-modifier to denote version of auditory model used
%   (multiple realization or single realization) and version of the
%   auditory model.

% Friday, December 28, 2012
%   -Creation of this script-file.


