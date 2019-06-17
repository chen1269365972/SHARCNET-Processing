function y = hrtffilt( x, Fs, ZERO_PHASE_FILTERING )

% Human HRTF filter based on Wiener and Ross, 1946.
%
% Note: The sampling frequency should be around 20-40 kHz
% for the bilinear transform to be accurate.  Resample the
% input to be within this range if necessary.

if ( nargin < 3 )
    ZERO_PHASE_FILTERING = 0;
end;


FH1 = 2.5e3;
FH2 = 4.2e3;
BH1 = 0.9e3;
BH2 = 2.1e3;
FHLP = 8.0e3;
Hmult = 3.0;

PH1 = 1/(2*pi*FH1)^2;
QH1 = 2*pi*BH1*PH1;

PH2 = 1/(2*pi*FH2)^2;
QH2 = 2*pi*BH2*PH2;

PHLP = 1/(2*pi*FHLP);

[ b1, a1 ] = bilinear( 1, [ PH1 QH1 1 ], Fs );
[ b2, a2 ] = bilinear( 1, [ PH2 QH2 1 ], Fs );
[ blp, alp ] = bilinear( 1, [ PHLP 1 ], Fs );


if ( ZERO_PHASE_FILTERING == 1 )    
    x1 = filtfilt( b1, a1, x );
    x2 = filtfilt( b2, a2, x );
    x3 = filtfilt( blp, alp, x );
else
    x1 = filter( b1, a1, x );
    x2 = filter( b2, a2, x );
    x3 = filter( blp, alp, x );
end;


y = Hmult * (x1 - x2) + x3;



%% References


