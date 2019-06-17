function [] = Results_Textfile( filename, parameters, CALCULATE_METRICS )

% This script-file writes the processing parameters held in the given
% structure to a text-file in the results target-directory.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Wednesday, June 13, 2012
% Modification Date:  Friday, July 25, 2014
%       Change Digest:  See below
%
%% See Also
% 

file_handle = fopen( [ filename '.txt' ], 'wt' );

if ( CALCULATE_METRICS == 1 )
    
    % Sentence Processing Parameters
    fprintf( file_handle, '\n\nSentence Processing Parameters\n--------------------------------------\n' );
    fprintf( file_handle, 'HRTF:  %d\n', parameters.sentence_processing.apply_HRTF );
    fprintf( file_handle, 'Envelope Conditioning:  %d\n', parameters.sentence_processing.ramping );
    fprintf( file_handle, 'Presentation Level (SPL):  %d\n', parameters.sentence_processing.dB_SPL_level );
    fprintf( file_handle, 'Sample Frequency:  %d\n', parameters.sentence_processing.sample_frequency );
    fprintf( file_handle, '\n\n' );
    
    
    % Model Parameters
    fprintf( file_handle, 'Model Parameters\n--------------------------\n' );
    fprintf( file_handle, 'Sample Frequency:  %d Hz\n', parameters.model.sample_frequency );
    fprintf( file_handle, 'Spontaneous Rates:  %s\n', num2str(parameters.model.spontaneous_rate) );
    fprintf( file_handle, 'Spontaneous Rates Fractions (respectively):  %s\n', num2str(parameters.model.fraction_of_spontaneous_rate) );
    fprintf( file_handle, 'Time Multiplication Factor:  %4.2f\n', parameters.model.time_multiplication_factor );
    frequencies = parameters.model.CFs;
    fprintf( file_handle, 'Characteristic Frequencies (Legacy) - Min:  %6.4f Hz, Max:  %6.4f Hz, Total: %d:\n', ...
        min(frequencies), max(frequencies), numel(frequencies) );
    %
    frequencies = parameters.model.CFs(parameters.model.CFs_extracted_indices);
    fprintf( file_handle, 'Characteristic Frequencies (Hines & Harte, 2012) - Min:  %6.4f Hz, Max:  %6.4f Hz, Total: %d:\n', ...
        min(frequencies), max(frequencies), numel(frequencies) );
    fprintf( file_handle, 'Outer Hair-cell Control:  %d\n', parameters.model.outer_haircell_control );
    fprintf( file_handle, 'Inner Hair-cell Control:  %d\n', parameters.model.inner_haircell_control );
    fprintf( file_handle, 'Power-law Implementation:  %d\n', parameters.model.power_law_implementation );
    fprintf( file_handle, 'Realizations:  %d\n', parameters.model.number_of_realizations );
    %
    if (parameters.model.species==2)
        species_string = 'Human';
    else
        species_string = 'Cat';
    end;
    fprintf( file_handle, 'Species:  %s\n', species_string);
    fprintf( file_handle, '\n\n' );
    
    
    % Neurogram Processing Parameters
    fprintf( file_handle, 'Neurogram Processing Parameters\n----------------------------------------\n' );
    fprintf( file_handle, 'ENV Window:  %.3e seconds\n', parameters.neurogram_processing.envelope_time_window );
    fprintf( file_handle, 'ENV Samples:  %d\n', parameters.neurogram_processing.envelope_samples );
    fprintf( file_handle, 'TFS Window:  %.3e seconds\n', parameters.neurogram_processing.tfs_time_window );
    fprintf( file_handle, 'TFS Samples:  %d\n', parameters.neurogram_processing.tfs_samples );
    fprintf( file_handle, 'STMI Window:  %s\n', parameters.neurogram_processing.stmi_window_type );
    fprintf( file_handle, 'STMI Window:  %5.3f\n', parameters.neurogram_processing.stmi_time_window );
    fprintf( file_handle, 'Fractional Overlap:  %5.3f\n', parameters.neurogram_processing.fractional_window_overlap );
    fprintf( file_handle, '\n\n' );
    
    
    % STMI Processing Parameters
    rates = parameters.stmi_processing.rate;
    fprintf( file_handle, 'STMI Rate - Min: %5.3f, Max: %5.3f, Total: %d\n', ...
        min(rates), max(rates), numel(rates) );
    rates = parameters.stmi_processing.scale;
    fprintf( file_handle, 'STMI Scale - Min: %5.3f, Max: %5.3f, Total: %d\n', ...
        min(rates), max(rates), numel(rates) );
    fprintf( file_handle, '\n\n' );
    
    
    % NSIM Processing Parameters
    fprintf( file_handle, 'NSIM Weight - ALPHA:  %5.2f\n', parameters.nsim_processing.weights.alpha );
    fprintf( file_handle, 'NSIM Weight - BETA:  %5.2f\n', parameters.nsim_processing.weights.beta );
    fprintf( file_handle, 'NSIM Weight - GAMMA:  %5.2f\n', parameters.nsim_processing.weights.gamma );
    fprintf( file_handle, 'NSIM Kernel-size (rows):  %d, (columns): %d', size( parameters.nsim_processing.kernel, 1 ), ...
        size( parameters.nsim_processing.kernel, 2 ) );
    
    fprintf( file_handle, '\n\n\n' );
    
else
    
    fprintf( file_handle, '\n\n\n*** ONLY RAW NEUROGRAMS ***\n\n\n' );

end;


fclose( file_handle );



%% References



%% Digest

% Friday, July 25, 2014 (prior revision 1435)
%   -Add logic-flag to function arugments to print message indicating only
%   raw neurograms are produced.

% Wednesday, March 6, 2013
%   -Addtion of print-statement for model species (i.e. cat or human).

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.

% Friday, July 27, 2012
%   -Update fields to reflect new structure organization.


