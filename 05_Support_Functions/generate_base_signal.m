function [ base_signal ] = generate_base_signal( signal )

% This script-file produces a "base-signal" for the spectro-temporal
% modulation index (STMI) calculation by randomizing the phase of the given
% signal while keeping its long-term spectrum.
%
%
% Author:  Ian C. Bruce ( ibruce [at] ieee.org )
% Modified by:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Creation Date:  Tuesday, May 14, 2013
% Modification Date:  Thursday, August 28, 2014
%       Change Digest:  See below.
%
%% See Also
%


%% Input Verification

D = size(signal);

if ( prod(D) > length(signal) )
    error( '\n\n\n*** Input signal must be a vector (i.e., one-dimensional array) *** \n\n\n' );
end;



%% Processing

Xk = fft( signal );
    Xk = Xk( : );  % Ensure Xk is a column vector.

n = length( signal );


if ( mod(n, 2) == 0 )  % EVEN Length
    
    positive_frequencies = ( 1:1:(n/2 - 1) )';
    p = 2 * pi * rand( size(positive_frequencies) );  % Uniformly Distributed Phase (units of radians)
    yc = Xk(2:(n/2)) .* exp( 1i .* p.* positive_frequencies );
    spectrum = [ Xk(1); yc; Xk(n/2+1); conj(flipud(yc)) ];
    
else  % ODD Length
    
    positive_frequencies = ( 1:1:(n-1)/2 )';
    p = 2 * pi * rand( size(positive_frequencies) );  % Uniformly Distributed Phase (units of radians)
    yc = Xk(2:((n-1)/2+1)) .* exp( 1i .* p.* positive_frequencies );
    spectrum = [ Xk(1); yc; conj(flipud(yc)) ];
    
end;


base_signal = real( ifft(spectrum) );

if ( D(2)>1 )
    base_signal = base_signal.';
end;

end



%% References



%% Digest

% Thursday, August 28, 2014 (prior revision 1662)
%   -Review "generate_base_signal.m" to better describe the
%   base-subtraction method for my paper.

% Tuesday, May 14, 2013
%   -Review


