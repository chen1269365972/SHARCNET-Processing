function [ h_rate_filter ] = cortical_temporal_filter( rate, filter_length, STF, filter_type )

% This script-file generates a complex-valued filter to process a
% neurogram at a single CF (i.e. across time bins or rows of the
% neurogram).
%
% Inputs:
%       rate - Ripple Rate (omega;  w;  Hertz)
%       filter_length - Length of complex-valued transfer function.
%       STF - Sample Rate (bins per second)
%       filter_type - [<value_1> <value_2>] (vector)
%           <value_1> = 1 - Lowpass
%           1 < <value_1> > <value_2> - Bandpass
%           <value_1> = <value_2> - Highpass
%
%  *** Filter is complex-valued and non-causal. ***
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Unknown
% Modification Date:  Wednesday, April 3, 2013
%       Change Digest:  See below
%
%% See Also
% 


t = ( 0:1:(filter_length - 1) )' / STF * rate;

h = sin(2*pi*t) .*t.^2.* exp(-3.5*t) * rate;  % Gamma-tone Filter
    h = h - mean(h);
    
H0 = fft( h, (2 * filter_length) );
    A = angle( H0(1:filter_length) );
    
h_rate_filter = abs( H0(1:filter_length) );
    [maximum_value, maxi] = max(h_rate_filter);
h_rate_filter = h_rate_filter / max(h_rate_filter);
    
if ( filter_type(1) == 1 )  % Lowpass    
    h_rate_filter( 1:1:(maxi - 1) ) = ones( (maxi - 1), 1 );
elseif ( filter_type(1) == filter_type(2) )  % Highpass	
	h_rate_filter( (maxi + 1):1:filter_length ) = ones( (filter_length - maxi), 1 );	
end;

h_rate_filter = h_rate_filter .* exp(1i*A);  % Bandpass



%% References

% http://en.wikipedia.org/wiki/Gammatone_filter

% T. Chi et al., "Spectro-temporal modulation transfer functions and speech
% intelligibility," Journal of the Acoustical Society of America, Vol. 106,
% No. 5, November 1999

% M. Elhilali, T. Chi and S. A. Shamma, "A spectro-temporal modulation
% index (STMI) for assessment of speech intelligibility," Speech
% Communication, Volume 41, pages 331-348, 2003



%% Digest

% Wednesday, April 3, 2013
%   -Review and refactoring to clarify script-file.
%       -Removal of commented lines.


