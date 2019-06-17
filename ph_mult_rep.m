

% This script-file generates raw neurograms for the chimaera acoustic
% stimuli corpus using the multiple realizations version of the auditory
% periphery model.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Thursday, February 19, 2015
% Creation Date:  Thursday, July 5, 2011
%       Change Digest:  See below.
%
%% See Also
% 


%% Matlab or Octave Computing Environment

if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
    
    fprintf(1, '\n\nVersion: %s\n\n', version);
    
    pkg load signal;
    pkg load image;  % Required for MEAN2 function call in "nsim.m".
    
    if ( exist('rms') < 1 )
        fprintf(1, '\n\n*** Defining anonymous function RMS. ***\n\n');
        rms = @(x) sqrt(mean(x.^2));
    else
        fprintf(1, '\n\n*** RMS is ALREADY defined. ***\n\n');
    end
    
else
    fprintf(1, '\n\nVersion: %s\n\n', version);  
end



%% Environment

close all;  clear;  clc;
addpath( genpath(pwd), '-begin' ); pause(1);



%% Sun GRID Engine (SGE) Processing

selected_column = getenv( 'SGE_TASK_ID' );

if ( isempty(selected_column) || strcmp( selected_column, 'undefined' ) )  % Local Processing
    columns_to_process = 1;
    
    start_index=1;  step_index=1;  end_index=1;
        word_set = start_index:step_index:end_index;
else    
    columns_to_process = str2double(selected_column);  % Cluster Processing
    
    start_index = getenv('START');
        start_index = str2double(start_index);
    step_index = getenv('STEP');
        step_index = str2double(step_index);
    end_index = getenv('END');
        end_index = str2double(end_index);
    
    word_set = start_index:step_index:end_index;
end;



%% Set Chimaera Reference Structures

load( 'PC_SI_Working_Chimaera_List' );
    working_directory = '40_Local_Results';

% Eliminates Code Analyzer comments suggesting memory preallocation.
temp_variable = working_chimaera_data_set;
    clear working_chimaera_data_set;
        working_chimaera_data_set = temp_variable;
            clear temp_variable;

cd( working_directory );



%% Load and Set Processing Parameters

parameters = processing_parameters();
    parameters.model.time_multiplication_factor = 1.2;
    parameters.model.number_of_realizations = 50;
    parameters.general.calculate_metrics=1;



%% Set Chimaera Types to Process and Number of Target-words

CASES_TO_PROCESS = columns_to_process;

% Chimaera type index (column-index of structure):
%
%   1.)  Envelope:  Speech                       Time Fine Structure:  Weighted Gaussian Noise
%   2.)  Envelope:  White Gaussian Noise   Time Fine Structure:  Speech
%   3.)  Envelope:  Speech                       Time Fine Structure:  Matched Noise
%   4.)  Envelope:  Matched Noise             Time Fine Structure:  Speech
%   5.)  Envelope:  Constant                     Time Fine Structure:  Speech



%% Directories

TIME_STAMP = datestr( now, 'mmmm_dd_yyyy_HH_MM' );

target_directory=[ 'rep_mult_Case' parameters.model.model_version '_' num2str(columns_to_process) '_Words_' num2str(start_index) ...
    '_' num2str(step_index) '_' num2str(end_index) '_' TIME_STAMP ];
    %
    mkdir( target_directory );
    cd( target_directory );
    

Results_Textfile( target_directory, parameters, parameters.general.calculate_metrics );
%
% if parameters.general.calculate_metrics is set to 0, only raw neurograms
% are computed and saved.  If this variable is set to 1, the STMI and NSIM
% metrics are also computed.
    
    
    
%% Process Chimaera Speech Corpus

start_time_chimaera_set = tic;

for chimaera_index = CASES_TO_PROCESS
    
    file_handle = fopen(sprintf('chimaera_%d_status.txt', chimaera_index), 'w');
        output_description = sprintf( '\n\nWords %d to %d, step-size of %d.', start_index, end_index, step_index);
        
    fprintf(file_handle, '%s', output_description);
    
    
    for case_index = word_set
        
        fprintf(1, '\nChimaera: %d,  Row: %d  (%d To Process)', chimaera_index, case_index, numel(word_set));
                        
        start_time_individual_chimaera = tic;
        
        
        % Compute Neurogram - UNPROCESSED SENTENCE
        load( working_chimaera_data_set(case_index, chimaera_index).full_pathname_original_sentence );
        %
        original_neurograms = sentence_processing( x(:), parameters, ...
            working_chimaera_data_set(case_index, chimaera_index).placement_index, ...
            working_chimaera_data_set(case_index, chimaera_index).length );
        
        
        % Compute Neurogram - CHIMAERA SENTENCE
        load( working_chimaera_data_set(case_index, chimaera_index).full_pathname_chimaera_sentence );
        %
        chimaera_neurograms = sentence_processing( added_filter_bands(:), parameters, ...
            working_chimaera_data_set(case_index, chimaera_index).placement_index, ...
            working_chimaera_data_set(case_index, chimaera_index).length );
        
        
        save_raw_neurograms( original_neurograms, 'original', chimaera_index, case_index, ...
            working_chimaera_data_set(case_index, chimaera_index).word_string, 'multiple_rep', parameters );
        %
        save_raw_neurograms( chimaera_neurograms, 'chimaera', chimaera_index, case_index, ...
            working_chimaera_data_set(case_index, chimaera_index).word_string, 'multiple_rep', parameters );
        
        
        % Compute Metrics
        if ( parameters.general.calculate_metrics == 1 )
            
            % STMI
            neurograms.stmi.original = neurogram_processing(original_neurograms.original.target_word, 'stmi', parameters);
                neurograms.stmi.original_mn = neurogram_processing(original_neurograms.matched_noise.target_word, 'stmi', parameters);
            %
            neurograms.stmi.chimaera = neurogram_processing(chimaera_neurograms.original.target_word, 'stmi', parameters);
                neurograms.stmi.chimaera_mn = neurogram_processing(chimaera_neurograms.matched_noise.target_word, 'stmi', parameters);
            
            stmi_value = stmi_metric( neurograms.stmi, parameters );
                working_chimaera_data_set( case_index, chimaera_index ).stmi = stmi_value;
                
                
            % NSIM
            neurograms.nsim.original = neurogram_processing(original_neurograms.original.target_word, 'nsim', parameters);
            neurograms.nsim.chimaera = neurogram_processing(chimaera_neurograms.original.target_word, 'nsim', parameters);
            
            nsim_values.env = nsim(  neurograms.nsim.original.nsim_env.PSTH, neurograms.nsim.chimaera.nsim_env.PSTH, parameters, 'env' );
            nsim_values.tfs = nsim( neurograms.nsim.original.nsim_tfs.PSTH, neurograms.nsim.chimaera.nsim_tfs.PSTH, parameters, 'tfs' );
            
            working_chimaera_data_set( case_index, chimaera_index ).nsim = nsim_values;
            
            
            % Compute ALSR (STMI-based formulation)
            %
            % The ALSR function called in this cell has a fixed number of
            % overlap samples.  The spectrogram of the PSTH is computed
            % using the following parameters:
            %
            % a.) PSTH is sampled at and effective frequency of 10 kHz ( 1/time_bin ).
            % b.) 256-point Hamming window using "perfect periodic extension".
            %       With respect to the term "perfect periodic extension", the
            %       Hamming window is created so that the end-point of a
            %       preceding Hamming window is contiguous with the start-point
            %       of the following Hamming window.
            % c.) Use 64-point overlap (effects temporal resolution of frequency analysis).
            % d.) FFT size of 256.
            % e.) Sample frequency of 10 kHz.
            
%             neurogram.PSTH = original_neurograms.original.target_word.PSTH;
%                 alsr_set.original = ALSR( neurogram, parameters, 0.1e-3 );
%             %
%             neurogram.PSTH = original_neurograms.matched_noise.target_word.PSTH;
%                 alsr_set.original_mn = ALSR( neurogram, parameters, 0.1e-3 );
%             %
%             neurogram.PSTH = chimaera_neurograms.original.target_word.PSTH;
%                 alsr_set.chimaera = ALSR( neurogram, parameters, 0.1e-3 );
%             %
%             neurogram.PSTH = chimaera_neurograms.matched_noise.target_word.PSTH;
%                 alsr_set.chimaera_mn = ALSR( neurogram, parameters, 0.1e-3 );
%                 
%             % Without base-spectrum subtraction.
%             alsr.CF_128 = 1 - norm( alsr_set.original - alsr_set.chimaera )^2 / norm( alsr_set.original )^2;
%             %
%             % With base-spectrum subtraction.
%             alsr.CF_128_bss = 1 - norm( alsr_set.original_mn - alsr_set.chimaera_mn )^2 / norm( alsr_set.original_mn )^2;
%             
%             working_chimaera_data_set( case_index, chimaera_index ).alsr = alsr;

        else
            working_chimaera_data_set( case_index, chimaera_index ).stmi = nan;
            working_chimaera_data_set( case_index, chimaera_index ).nsim = nan;
            working_chimaera_data_set( case_index, chimaera_index ).alsr = nan;
        end;
        
        
        fprintf( file_handle, '%s', sprintf('\nWord:  %d', case_index) );
        
        working_chimaera_data_set( case_index, chimaera_index ).processing_time = toc( start_time_individual_chimaera ) / 60;
        
    end;  % End:  for case_index = word_set
    
    
    fprintf( file_handle, '\n' );
    
    filename_modifier = [ '_multple_rep' parameters.model.model_version ];
        target_structure_name = [ sprintf( 'Chimaera_%d_Words_%d_%d_%d', ...
            chimaera_index, start_index, step_index, end_index ) filename_modifier ];
    %
    if ( exist ('OCTAVE_VERSION', 'builtin') ~= 0 )
        save( '-V7', target_structure_name, 'working_chimaera_data_set' );
    else
        save( target_structure_name, 'working_chimaera_data_set' );
    end;
    
end;  % End:  for chimaera_index = CASES_TO_PROCESS


if ( parameters.general.display_text == 1 )
    fprintf( 1, '\n\n' );
end;

fprintf( file_handle, '\nChimaera set processing time: %5.1f minute(s)\n\n', toc(start_time_chimaera_set)/60 );
    fclose( file_handle );

cd( fullfile( '..', '..' ) );



%% Clean-up

fprintf(1, '\n\n*** Processing Complete ***\n\n');



%% References
%
%   "Speech Intelligibility from Image Processing", Andrew Hines and Naomi Harte, 
% Speech Communication, Volume 52, pages 736-752, 2010
%
%   "Evaluating Sensorineural Hearing Loss with an Auditory Nerve Model
% using a Mean Structure Similarity Measure", Andrew Hines and Naomi Harte,
% 18th European Signal Processing Conference (EUSIPCO-2010), Aalborg,
% Denmark, August 23 - 27, 2010
%
%   "Image Quality Assessment:  From Error Visibility to Structural
% Similarity", Zhow Wang, Alan C. Black, Hamid R. Sheikh and Eero P.
% Simoncelli, IEEE Transactions on Image Processing, Volume 13, Issue 4,
% April 2004



%% Digest

% Thursday, February 19, 2015 (prior revision 3062)
%   -Review
%       a.) "processing_parameters.m"
%               -Add field (parameters.general.calculate_metrics = 0).
%               -Add field (parameters.model.model_version = '_V52').
%       b.) Make calculation of metrics optional.  If they are not
%       computed, set the following fields in the structure to "nan":
%               working_chimaera_data_set(case_index, chimaera_index).stmi
%               working_chimaera_data_set(case_index, chimaera_index).nsim
%               working_chimaera_data_set(case_index, chimaera_index).alsr
%       c.) Comment out section of code that computes the ALSR metric.
%       d.) Always save computed neurograms (was conditional before).
%       e.) Modify filenames and directories to reflect how the auditory
%       model was called (i.e. single or multiple realization) and version
%       of the model.

% Friday, July 25, 2014 (prior revision 2220)
%   -Review and set-up to use both the single realization and the multiple
%   realizations (50) of the auditory periphery model.

% Friday, November 11, 2013 (prior revison 2213)
%   -Comment statements used to calculate NSIM and STMI metrics.

% Friday, May 24, 2013 (prior revision 1718)
%   -Addition of ALSR metric using the STMI formulation.

% Wednesday, March 6, 2013
%   -Review

% Tuesday, January 15, 2013
%   -Addition of raw PSTH scaling values for NSIM metric.

% Monday, December 31, 2012
%   -Verification of STMI calculation.

% Saturday, December 29, 2012
%   -Continued code factorization.

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.

% Tuesday, December 25, 2012
%   -Incorporate combined cat/human auditory model.
%   -Review processing script-file.

% Wednesday, October 17, 2012
%   -Add flag to control scaling of PSTH to spikes per second.
%   -Convert PSTH data fields in structure to minimize file size.

% Friday, September 7, 2012
%   -Addition of text-file status update.

% Thursday, September 6, 2012
%   -Verification and validation.

% Wednesday, September 5, 2012
%   -Modify script-file to properly process data-set.

% Monday, August 20, 2012
%   -Review script-file execution in effort to reproduce Rasha's results.

% Tuesday, July 31, 2012
%   -Finalization of environment variable modifications.

% Monday, July 30, 2012
%   -Modify script-file to handle environment variables when job is
%       submitted to GRID.

% Saturday, July 28, 2012
%   -Modify script-file to handle both NSIM and STMI characteristic
%       frequency sets and neurogram processing requirements.

% Friday, July 27, 2012
%   -Modify script-file to support processing 2 sets of characteristic
%       frequencies, one based on Zilany/Ibrahim, the other from Hines &
%       Harte, 2012.
%   -Change script-file to function script-file to support a word-list
%       argument.

% Saturday, July 21, 2012
%   -Validate operation of script-file.

% Friday, July 20, 2012
%   -Memory preallocation for the considered metric set, stored in the
%   structure "working_chimaera_data_set", is done during the creation of
%   the structure.  In order to remove Code Analyzer comments suggesting
%   this be done for this structure, the loaded variable from the MAT-file
%   is stored to a local temporary variable and then the loaded variable is
%   deleted.  A final assignment of the temporary variable to the original
%   variable name is then completed.  This removes the Code Analyzer
%   messages.

% Thursday, July 19, 2012
%   -Memory preallocation for structure fields.
%   -Save target-word neurograms to MAT-file;  no longer in results structure.
%   -Save computer cat model PSTH responses to MAT-file.
%   -IF-ELSEIF-ELSE statement for chimaera set.


