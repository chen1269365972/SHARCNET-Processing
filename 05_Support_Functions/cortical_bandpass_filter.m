function [ h_scale_filter ] = cortical_bandpass_filter( scale, filter_length, SRF, filter_type )

% This script-file generates a complex-valued filter to process a neurogam
% at a single time bin (i.e. across CFs or columns of the neurogram).
%
% Inputs:
%       scale - Scale Rate (Omega;  cycles per octave)
%       filter_length - Length of complex-valued transfer function.
%       SRF - Sample Rate
%       filter_type - [<value_1> <value_2>] (vector)
%           <value_1> (scalar only) - 1 - Gabor Function (optional)
%           <value_1> (scalar only) - 2 - Gaussian Function (default)
%                   -Negative second-derivative.
%           <value_1> = 1 - Lowpass
%           1 < <value_1> > <value_2> - Bandpass
%           <value_1> = <value_2> - Highpass
%
% *** Filter is complex-valued and non-causal. ***
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Unknown
% Modification Date:  Wednesday, April 3, 2013
%       Change Digest:  See below
%
%% See Also
% 


if ( nargin < 4 )
    filter_type = 2;
end;

if ( length(filter_type) == 1 )
    PASS = [2 3];  % Bandpass
else
    PASS = filter_type;
	filter_type = 2;
end;

R1 = ( 0:1:(filter_length - 1) )' / filter_length * SRF / 2 / abs(scale);

if ( filter_type == 1)  % Gabor Function
    C1 = 1/2/.3/.3;
    h_scale_filter = exp(-C1*(R1-1).^2) + exp(-C1*(R1+1).^2);
else
    R1 = R1 .^ 2;  % Gaussian Function
	h_scale_filter = R1 .* exp(1 - R1);  % Single-sided Filter
end;

if ( PASS(1) == 1 )  % Lowpass
	[maxH, maxi] = max(h_scale_filter);
	sumH = sum(h_scale_filter);
	h_scale_filter(1:1:(maxi - 1) ) = ones( (maxi - 1), 1);
	h_scale_filter = h_scale_filter / sum(h_scale_filter) * sumH;
elseif ( PASS(1) == PASS(2) )  % Highpass
	[maxH, maxi] = max(h_scale_filter);
	sumH = sum(h_scale_filter);
	h_scale_filter(maxi+1:filter_length) = ones(filter_length-maxi, 1);
	h_scale_filter = h_scale_filter / sum(h_scale_filter) * sumH;
end;



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


