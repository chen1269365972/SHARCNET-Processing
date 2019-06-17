function [ windows ] = target_word_windowing( placement_index, net_length )

% This script-file generates an exponentially-weighted vector that is used
% to extract both the keying sentence and the target-word from a given NU 6
% sentence of arbitrary length.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Thursday, June 28, 2012
% Modification Date:  Friday, May 24, 2013
%       Change Digest:  See below.
%
%% See Also
%


% Generate Window
working_domain = linspace( -20, 20, 80 );
    shaping_vector = interp( 1 ./ ( 1 + exp( -0.5 * working_domain ) ), 10 );
    
    
% Position at Target-index
change_factor = ( numel(shaping_vector) - 1) / 2 + 1;
    prepend_indices = 1:1:(placement_index - change_factor);
    postend_indices = ( placement_index + change_factor ):1:net_length +1;

target_word_vector = [ zeros(1, numel(prepend_indices) ) ...
    shaping_vector ones(1, numel(postend_indices) ) ];
%
keying_sentence_vector = ones(1, numel(target_word_vector) ) - ...
    target_word_vector;

windows.index = numel(prepend_indices);
windows.target_word = target_word_vector(:);
windows.keying_sentence_vector = keying_sentence_vector(:);
        
        
        
%% References



%% Digest

% Friday, May 24, 2013
%   -Change interpolation factor from 100 to 10 (line 18).


