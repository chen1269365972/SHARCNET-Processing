function [ shaped_speech_sequence ] = Envelope_Shaping( speech_sequence, envelope_type )


% This script-file applies a smoothing function to the beginning and end of
% a given vector to remove unwanted transients.
%
%
% Input(s):
%
% speech_sequence - Vector to process.
% envelope_type - Type of smoothing function to apply (1 - Linear; 2 - Logistic; 3 - Hyperbolic-tangent)
%
%
% Output(s):
%
% shaped_speech_sequence - Modified speech sequence.
%
%
% Research - Fall 2011
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Date:  Tuesday, October 11, 2011



%% Set Processing Variables

number_of_samples_to_consider = 50;
working_domain = linspace( -20, 40, number_of_samples_to_consider );

constant_a = 0.5;
constant_b = 0.5;


%% Apply Selected Smoothing Function

switch lower( envelope_type )
    
    case { 'logistic' }
        shaping_vector = 1 ./ ( 1 + exp( -0.5 * working_domain) );
        
    case { 'hyperbolic' }
        shaping_vector = 0.5 * tanh( 0.5 * working_domain ) + 0.5;
        
    otherwise
        shaping_vector = linspace( 0, 1, number_of_samples_to_consider );
      
end;  % End:  switch lower(method)



%% Smooth Speech Sequence

shaped_speech_sequence = speech_sequence;

% Start of Sequence
shaped_speech_sequence(1:number_of_samples_to_consider) = shaped_speech_sequence(1:number_of_samples_to_consider) .* shaping_vector';


% End of Sequence
shaped_speech_sequence( ( length(shaped_speech_sequence) - number_of_samples_to_consider + 1 ):end ) = ...
    shaped_speech_sequence( ( length(shaped_speech_sequence) - number_of_samples_to_consider + 1 ):end ) .* flipud( shaping_vector' );



%% Reference(s)


