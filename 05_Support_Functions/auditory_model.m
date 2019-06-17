function [ model_response ] = auditory_model( stimulus, parameters )


% This script-file calls the auditory periphery model.
%
%
%% See Also

% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Thursday, October 27, 2011
% Modification Date:  Thursday, December 27, 2012
%       Change Digest:  See below.
%
%% See Also
% 



%% Model Transforms

model_sample_period = 1 / parameters.model.sample_frequency;
                                                 
stimulus_duration=length(stimulus) * ...
    model_sample_period * parameters.model.time_multiplication_factor;

number_of_characteristic_frequencies_to_process = numel(parameters.model.CFs);
number_of_spontaneous_spiking_rates_to_process = numel(parameters.model.spontaneous_rate);

h_inner_hair_cell = str2func( ['model_IHC', parameters.model.model_version] );
h_synapse = str2func( ['model_Synapse', parameters.model.model_version] );

    
% Compute PSTH response length and PREALLOCATE MEMORY.
inner_haircell_response = h_inner_hair_cell( stimulus(:).', ...
            parameters.model.CFs(1), 1, ...
            model_sample_period, stimulus_duration, ...
            parameters.model.outer_haircell_control, parameters.model.inner_haircell_control, ...
            parameters.model.species );
%
[ PSTH, mean_rate, variance_rate, synout, trd_vector, trel_vector ] = h_synapse( inner_haircell_response, ...
            parameters.model.CFs(1), ...
            1, ...  % Number of stimuli presentations.
            model_sample_period, ...
            parameters.model.noise_type, ...
            parameters.model.power_law_implementation, ...
            parameters.model.spontaneous_rate(1), ...
            parameters.model.tabs, ...
            parameters.model.trel );
        
psth_matrix = NaN(number_of_characteristic_frequencies_to_process, numel(PSTH) );


for characteristic_frequency_index = 1:1:number_of_characteristic_frequencies_to_process
    
    accumulated_post_stimulus_time_histogram = zeros(1, numel(PSTH));
    
    for spontaneous_spiking_rate_index = 1:1:number_of_spontaneous_spiking_rates_to_process
    
        number_of_realizations = ceil( parameters.model.number_of_realizations * ...
            parameters.model.fraction_of_spontaneous_rate( spontaneous_spiking_rate_index ) );
                
    
        % Transform middle-ear pressure (Pascals - Pa) sequence to respective inner hair-cell responses.
        inner_haircell_response = h_inner_hair_cell( stimulus(:).', ...
            parameters.model.CFs( characteristic_frequency_index ), ...
            number_of_realizations, ...
            model_sample_period, ...
            stimulus_duration, ...
            parameters.model.outer_haircell_control, parameters.model.inner_haircell_control, ...
            parameters.model.species );


        if ( parameters.general.display_text == 1 )
            fprintf( 1, '\n\tCF (Hz):  %5.1f  (%d of %d) - SR Index %d  (%d realizations)', ...
                parameters.model.CFs( characteristic_frequency_index), ...
                characteristic_frequency_index, number_of_characteristic_frequencies_to_process, ...
                spontaneous_spiking_rate_index, number_of_realizations );
        end;
        
        
        % Transform inner hair-cell responses to respective neurological spike-timings.
        [ PSTH, mean_rate, variance_rate, synout, trd_vector, trel_vector ] = h_synapse( inner_haircell_response, ...
            parameters.model.CFs( characteristic_frequency_index ), ...
            number_of_realizations, ...
            model_sample_period, ...
            parameters.model.noise_type, ...
            parameters.model.power_law_implementation, ...
            parameters.model.spontaneous_rate( spontaneous_spiking_rate_index ), ...
            parameters.model.tabs, ...
            parameters.model.trel );
        
        accumulated_post_stimulus_time_histogram = accumulated_post_stimulus_time_histogram + PSTH;    
                                        
    end;  % End:  for spontaneous_spiking_rate_index = 1:1:number_of_spontaneous_spiking_rates_to_process
    
    psth_matrix( characteristic_frequency_index, : ) = accumulated_post_stimulus_time_histogram;
    
    if ( parameters.general.display_text == 1 )
        fprintf( 1, '\n' );
    end;
    
end;  % End:  for characteristic_frequency_index = number_of_characteristic_frequencies_to_process:-1:1


model_response.PSTH = psth_matrix;
model_response.PSTH_time_indices = ( 1:1:numel(PSTH) ) * model_sample_period;
model_response.inner_haircell_response = inner_haircell_response;
model_response.mean_rate = mean_rate;
model_response.variance_rate = variance_rate;



%% References



%% Digest

% Thursday, December 27, 2012
%   -Update characteristic frequency field-name in the model parameter
%       structure.


% Tuesday, December 25, 2012
%   -Incorporate combined cat/human auditory model. 


% Sunday, December 9, 2012
%   -Call either cat or humanized version of the 2009 (power adaptation)
%   auditory model.


% Saturday, July 28, 2012
%   -Modify code to handle both NSIM and STMI characteristic frequency sets
%       along with the respective neurogram processing.


% Friday, July 20, 2012
%   -Incorporate percentage of presentations associated with the three
%   types of spontaneous rate.


