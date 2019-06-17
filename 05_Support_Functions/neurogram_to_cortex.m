function [ cortical_respresentation ] = neurogram_to_cortex( neurogram, frame_length, rates, scales )

% This script-file is a modified version of the original found in the
% neural tool set developed by Powen Ru at the Neural System
% laboratory in 2001.
%
% It produces a 4-dimensional cortical representation of a neurogram
% along the dimensions of time (bins), characteristic frequency (CF),
% rate, and scale.
%
%       4D -> scale, rate (up and down; 2X), time, and frequency
%
% Inputs:
%       neurogram - Neurogram, N-by-M  (from cochlear model)
%               N: time bins, M: number of CFs
%       frame_length - Nominally 2^[natural_number]
%               Units:  milliseconds
%       rates - Upward / Downward Rates of Ripple Propagation
%               Units:  cycles per second;  omega
%       scales - Cycle Densities
%               Units:  cycles per octave;  Omega%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Unknown
% Modification Date:  Wednesday, April 3, 2013
%       Change Digest:  See below
%
%% See Also
% 


%% Parameters

STF = 1.0 / frame_length;  % Frames per second
SRF = 24;  % Cycles per octave (fixed;  based on CF set)

number_of_rates = numel(rates);
number_of_scales = numel(scales);

[number_of_bins, number_of_CFs]	= size(neurogram);

% Zero-padding for scale and rate FFT analysis.
N1 = 2^nextpow2(number_of_bins);  N2 = N1*2;  % Rows
M1 = 2^nextpow2(number_of_CFs);  M2 = M1*2;  % Columns



%% Fourier Transform No. 1 - Across CFs (rows;  single time bin)

Y = zeros(N2, M1);

for bin_index = 1:1:number_of_bins
    R1 = fft( neurogram(bin_index, :), M2 );
        Y(bin_index, :) = R1(1:M1);
end;



%% Fourier Transform No. 2 - Across Time Bins (columns;  single CF)

for m = 1:1:M1
    R1 = fft( Y(1:number_of_bins, m), N2 );
        Y(:, m) = R1;
end;



%% Spectro-temporal Response Fields (STRF) Processing

mdx1 = 1:1:number_of_CFs;
ndx = 1:1:number_of_bins;
    ndx1 = ndx;

z  = zeros( number_of_bins, number_of_CFs );
cortical_respresentation = zeros( number_of_scales, (number_of_rates * 2), size(z, 1), size(z, 2) );


for rate_index = 1:1:number_of_rates
    
    h_rate_filter = cortical_temporal_filter( rates(rate_index), N1, STF, [rate_index number_of_rates] );
    
    for rate_sign = [1 -1]  % Upward and downward, respectively.
        
        if ( rate_sign > 0 )
            h_rate_filter = [ h_rate_filter; zeros(N1, 1) ];
            ix = 0;
        else
            h_rate_filter = [ h_rate_filter(1); conj( flipud(h_rate_filter(2:N2) ) ) ];
            h_rate_filter(N1+1) = abs( h_rate_filter(N1+2) );
            ix = 1;
        end;
        
        
        % First Frequency-domain Filtering - Across Time Bins (rows;  single CF)
        z1 = zeros(N2, M1);
        
        for m = 1:1:M1
            z1(:, m) = h_rate_filter .* Y(:, m);
        end;
        
        z1 = ifft(z1);
        z1 = z1(ndx1, :);
        
        
        for scale_index = 1:1:number_of_scales
            
            h_scale_filter = cortical_bandpass_filter( scales(scale_index), M1, SRF, [ scale_index number_of_scales ] );
            
            % Second Frequency-domain Filtering - Across CFs (columns;  single time bin)
            for n = ndx
                R1 = ifft( (z1(n, :) .* h_scale_filter' ), M2 ); 
                z(n, :) = R1(mdx1);
            end;	
            
            cortical_respresentation(scale_index, rate_index*rate_sign+number_of_rates+ix, :, :) = z;
            
        end;  % End:  for scale_index = 1:1:number_of_scales
        
    end;  % End:  for rate_sign = [1 -1]  % Upward and downward, respectively.
    
end;  % End:  for rate_index = 1:1:number_of_rates



%% References

% T. Chi et al., "Spectro-temporal modulation transfer functions and speech
% intelligibility," Journal of the Acoustical Society of America, Vol. 106,
% No. 5, November 1999

% M. Elhilali, T. Chi and S. A. Shamma, "A spectro-temporal modulation
% index (STMI) for assessment of speech intelligibility," Speech
% Communication, Volume 41, pages 331-348, 2003



%% Digest

% Wednesday, April 3, 2013
%   -Review and Finalization

% Tuesday, April 2, 2013
%   -Review and refactoring to clarify script-file.

% Thursday, March 28, 2013 (starting revision:  1459)
%   -Review and refactoring to clarify script-file.


