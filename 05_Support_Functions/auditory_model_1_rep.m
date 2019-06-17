function [ neurogram ] = auditory_model_1_rep( stimulus, parameters, audiogram )

% This script-file calls the auditory periphery model using
% a single repetition of the stimulus.
%
% Note:  The neurogram returned by this function has the lowest
% characteristic frequency (CF) response indexed at row 1, with consecutive
% CF responses stored in following rows.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Sunday, September 29, 2013
% Modification Date:  Friday, May 30, 2014
%       Change Digest:  See below.
%
%% See Also
% auditory_model


model_sample_period = 1 / parameters.model.sample_frequency;
                                                 
stimulus_duration = ceil( length(stimulus) * model_sample_period * ...
    parameters.model.time_multiplication_factor / parameters.neurogram_processing.envelope_time_window ) * ...
    parameters.neurogram_processing.envelope_time_window;

number_of_characteristic_frequencies_to_process = numel(parameters.model.CFs);

% 50 fibers are simulated with order of:
%	30 - Type "3" or "high" spontaneous spiking fibers.
%   15 - Type "2" or "medium" spontaneous spiking fibers.
%   5 - Type "1" or "low" spontaneous spiking fibers.
%
spontaneous_rate_indices = [ 3*ones(1, 30) 2*ones(1, 15) 1*ones(1, 5) ];
    number_of_SRI = numel( spontaneous_rate_indices );
    
h_inner_hair_cell = str2func( ['model_IHC', parameters.model.model_version] );
h_synapse = str2func( ['model_Synapse', parameters.model.model_version] );
    
% Compute PSTH response length and preallocate memory.
inner_haircell_response = h_inner_hair_cell( stimulus(:).', ...
            parameters.model.CFs(1), 1, ...
            model_sample_period, stimulus_duration, ...
            parameters.model.outer_haircell_control, parameters.model.inner_haircell_control, ...
            parameters.model.species );
        
psth_matrix = NaN(number_of_characteristic_frequencies_to_process, ...
    numel(inner_haircell_response), 'single');


dB_loss = interp1( audiogram.frequencies, audiogram.HL, parameters.model.CFs, ...
    'linear', 'extrap' );

% Impaired (mixed loss;  both COHC and CIHC parameters)
[ cohc, cihc, OHC_Loss ] = fitaudiogram2( parameters.model.CFs, dB_loss, ...
    parameters.model.species );
        clear OHC_Loss;
%    
% Impaired (IHC loss only)
% [ cohc, cihc, OHC_Loss ] = fitaudiogram( parameters.model.CFs, dB_loss, ...
%     zeros( size(parameters.model.CFs) ) );
%    
% Impaired (OHC loss only)
% [ cohc, cihc, OHC_Loss ] = fitaudiogram( parameters.model.CFs, dB_loss, dB_loss );



%% Calculate PSTH Responses

for CF_index = 1:1:number_of_characteristic_frequencies_to_process
    
    working_CF = parameters.model.CFs( CF_index );
    working_cihc = cihc( CF_index );
    working_cohc = cohc( CF_index );
    
    if ( parameters.general.display_text == 1 )
        fprintf( 1, '\n\tCF (Hz):  %5.1f  (%d of %d)  - HSF: %d, MSF: %d, LSF: %d', ...
            parameters.model.CFs( CF_index), CF_index, number_of_characteristic_frequencies_to_process, ...
            30, 15, 5 );
    end;
    
    % Transform middle-ear pressure (Pa) to corresponding inner hair-cell response.
    inner_haircell_response = h_inner_hair_cell( stimulus(:).', ...
        working_CF, 1, ...
        model_sample_period, stimulus_duration, ...
        working_cohc, working_cihc, ...
        parameters.model.species );
    
    accumulated_PSTH = zeros(1, numel(inner_haircell_response), 'single');
    
    for rate_index = 1:1:number_of_SRI
        
        spontaneous_rate = spontaneous_rate_indices( rate_index );
        
        % Transform inner hair-cell responses to corresponding neurological spike-events.
        [ PSTH, mean_rate, variance_rate, synout, trd_vector, trel_vector ] = h_synapse( inner_haircell_response, ...
            working_CF, ...
            1, ...  % Number of stimuli presentations.
            1.0/parameters.model.sample_frequency, ...
            parameters.model.noise_type, ...
            parameters.model.power_law_implementation, ...
            spontaneous_rate, ...
            parameters.model.tabs, ...
            parameters.model.trel );
        
        accumulated_PSTH = accumulated_PSTH + PSTH;    
                                        
    end;  % End:  for rate_index = 1:1:number_of_SRI
    
    psth_matrix( CF_index, : ) = accumulated_PSTH;
    
end;  % End:  for CF_index = 1:1:number_of_characteristic_frequencies_to_process


neurogram.PSTH = psth_matrix;
neurogram.PSTH_time_indices = single(( 1:1:numel(PSTH) ) * model_sample_period);

fprintf( 1, '\n\n' );



%% References



%% Digest

% Friday, May 30, 2014 (prior revision 2466)
%   -Update print statements for clarification.

% Wednesday, January 15, 2014 (prior revision 2286)
%   -Continued review and modification for speech quality work.

% Friday, December 6, 2013
%   -Review and modification for speech quality work.

% Sunday, September 29, 2013
%   -Created (see "generate_neurogram_nsim.m").


