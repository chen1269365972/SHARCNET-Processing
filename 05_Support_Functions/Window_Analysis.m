function [ window_set, column_sums, row_sums ] = Window_Analysis( sequence, ...
    window_size, number_of_overlapping_samples, averaging_term )


% This script-file takes a vector, either a column or a row vector, and creates an
% equivalent matrix where each row of this matrix corresponds to a window of samples 
% from the original sequence.
%
%
% Input(s):
%
% sequence - A column or row vector sequence.
% window_size - The length of the analysis window.  The value of this variable will
%       form the number of columns in the "window_set" matrix.
% number_of_overlapping_samples - The number of overlapping samples between adjacent
%       analysis windows.
% averaging_term - In the event that the given sequence is a collection of several
%       observations, this terms allows the average or mean of the sequence to be
%       determined.
%
%
% Output(s):
%
% window_set - An m-by-n matrix where each row corresponds to one analysis window and
%       the number of rows is determined by the length of the sequence, the analysis
%       window length and the number of overlapping samples between adjacent analysis
%       windows.
%
%
% Note(s):
%
%
%% See Also

% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Monday, November 7, 2011
% Creation Date:  Monday, November 7, 2011


sequence = sequence(:) / averaging_term;  % Convert to column and average each element.
    sequence_length = length(sequence);

window_indices = (1+(0:(fix((sequence_length-number_of_overlapping_samples)/(window_size-number_of_overlapping_samples))-1))*(window_size-number_of_overlapping_samples));

number_of_windows = length(window_indices);

window_set = zeros( number_of_windows, window_size );

row_index = 1;


for index = 1:1:length(window_indices)
    
    start_index = window_indices( index );
    end_index = start_index + window_size - 1;
    
    window_set( row_index, : ) = sequence( start_index:end_index );
        row_index = row_index + 1;
    
end


column_sums = sum( window_set, 1 );
row_sums = sum( window_set, 2 );



%% References
%
% a.)  http://stackoverflow.com/questions/2202463/sliding-window-algorithm-for-activiting-recognition-matlab


