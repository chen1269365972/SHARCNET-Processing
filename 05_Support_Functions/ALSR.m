function [ ALSR_matrix, synchronous_rate] = ALSR( neurogram, parameters, time_bin, ALSR_display ) 

% This script-file deterimines synchronous rate profiles using a
% short-term Fourier transform (STFT) of each characteristic frequency (CF)
% post-stimulus time histogram (PSTH) and its corresponding averaged
% localized synchronous rate (ALSR) matrix using 1 octave binning.
%
%
% Author:  Michael R. Wirtzfeld ( michael.wirtzfeld [at] gmail.com )
% Modification Date:  Sunday, December 12, 2015
% Creation Date:  Tuesday, May 14, 2013
%       Change Digest:  See below.
%
%% See Also
% octave_binning, display_ALSR


%% Processing Conditions

if ( nargin < 4 )
    ALSR_display.show = 0;
    ALSR_display.figure_name = '';
    ALSR_display.max_time = 0;
elseif ( nargin == 4 )        
else
    error( '*** ALSR - Invalid Number of Arguments ***' );
end;



%% Synchronous Rate Profile

model_period = 1 / parameters.model.sample_frequency;  % Seconds

psth_bin_size = time_bin / model_period;  % 10 to 1 Rebinning

for CF_index = 1:1:size(neurogram.PSTH, 1)
    
    psth_100k_CF = neurogram.PSTH( CF_index, 1:1:(psth_bin_size * floor(numel(neurogram.PSTH(CF_index, :)) / psth_bin_size)) );
    
    psth_100k_rebinned = sum( reshape(psth_100k_CF, psth_bin_size, length(psth_100k_CF) / psth_bin_size) ) / ...
        parameters.model.number_of_realizations;
    
    psth_100k_spikes = psth_100k_rebinned / time_bin;  % Units of spikes per second.
    
    
    w = hamming( 256, 'periodic' );
    
    [ stft.spectra, stft.frequencies, stft.time_indices ] = spectrogram( psth_100k_spikes, w, 64, 256, (1 / time_bin) );
    %
    % Compute spectrogram of auditory nerve fiber (ANF) response with the following parameters:
    %
    %   a.) ANF response sampled at 10 kHz ( 1/time_bin ).
    %   b.) 256-point Hamming window using "perfect periodic extension".
    %       With respect to the term "perfect periodic extension", the
    %       Hamming window is created so that the end-point of a preceding
    %       Hamming window is contiguous with the start-point of the
    %       following Hamming window.
    %   c.) Use 64-point overlap (effects temporal resolution of frequency analysis).
    %   b.) FFT size of 256.
    %   c.) Sample frequency of 10 kHz.
    %
%     figure( 'Color', 'w' ); ...
%         imagesc( stft.time_indices, stft.frequencies./1e3, 20*log10( abs(stft.spectra) ) );
%         axis xy;
%         colormap(jet);  colorbar;
%         title( sprintf( 'CF = %5.1f', parameters.model.CFs(CF_index) ) );
%         xlabel( 'Time (seconds)' );  ylabel( 'Frequency (kHz)' );
        
	synchronous_rate(CF_index, :, :) = abs(stft.spectra) / sqrt( 256*sum(w.^2) );

end;



%% Average Localized Synchronized Rate (ALSR)

ALSR_matrix = zeros( size(synchronous_rate, 3), size(synchronous_rate, 2) );

for time_index = 1:1:size(synchronous_rate, 3)
    
    ALSR_matrix( time_index, : ) = octave_binning( stft.frequencies, parameters.model.CFs, ...
            squeeze(synchronous_rate(:, :, time_index)) );
        
end;

if ( ALSR_display.show == 1 )
    display_ALSR( ALSR_matrix, ALSR_display, stft );
end;



%% Octave Binning

function [ averaged_sr ] = octave_binning( frequency_set, best_frequencies, synchronous_rates )

averaged_sr = zeros( size(frequency_set) );

for stft_frequencies_index = 2:1:numel(frequency_set)  % DC not included.
    
    working_frequency = frequency_set( stft_frequencies_index );
        lower_limit = working_frequency / sqrt(2);
        upper_limit = working_frequency * sqrt(2);
        
    indices = find( (lower_limit < best_frequencies) & (best_frequencies < upper_limit) );
        if ( isempty(indices) )
            continue;
        end;
    
    averaged_sr(stft_frequencies_index) = mean( synchronous_rates(indices, stft_frequencies_index) );
    
end;



%% Display ALSR

function [] = display_ALSR( ALSR_matrix, ALSR_display, stft )

figure( 'Name', ALSR_display.figure_name ); ...
    set( gcf, 'Color', [1 1 1] );
    set( gca, 'Box', 'off' );
    imagesc( stft.time_indices, stft.frequencies./1e3, ALSR_matrix' );
    set( gca,'YDir','normal' );
    xlabel('Time (seconds)');  ylabel('Frequency (kHz)');
    title( ALSR_display.figure_name );
    xlim([min(stft.time_indices) ALSR_display.max_time]);
    colorbar;
    colormap('Jet');
    
figure( 'Name', ALSR_display.figure_name ); ...
    set( gcf, 'Color', [1 1 1] );
    set( gca, 'Box', 'off' );
    surf( stft.time_indices, stft.frequencies./1e3, ALSR_matrix' );
        view( [62 75] );
    set( gca,'YDir','normal' );
    xlabel('Time (seconds)');  ylabel('Frequency (kHz)');  zlabel('Average Localized Syncrhonized Rate (spikes per second)');
    title( ALSR_display.figure_name );
    colorbar;
    colormap('Jet');
    
sr_size = size(ALSR_matrix);
    fprintf(1, '\n\nALSR Matrix Size:  %d x %d\n\n', sr_size(1), sr_size(2) );



%% References
%
%   "Physiological assessment of contrast-enhancing frequency shaping and
%   multiband compression in hearing aids," Ian C. Bruce, Physiological
%   Measurement, Volume 25, pages 945-956, 2004
%
%   "Representation of steady-state vowels in the temporal aspects
% of the discharge patterns of populations of auditory nerve fibers,"
% Eric D. Young and Murray B. Sachs, Journal of the Acoustical Society of
% America, Volume 66, Number 5, November 1979
%
%   "Effects of acoustic trauma on the representation of the vowel /eh/ in
% cat auditory nerve fibers," Roger L. Miller, John R. Schilling, Kevin R.
% Franck, Eric D. Young, Journal of the Acoustical Society of
% America, Volume 101, Number 6, June 1977



%% Digest

% Sunday, December 12, 2015 (prior revision 3659)
%   -Review and minor layout changes;  no funcational changes.

% Tuesday, March 24, 2015 (prior revision 3054)
%   -Review and grammatical corrections.

% Thursday, July 24, 2014 (prior revision 3028)
%   -Remove FPRINTF statements.

% Wednesday, July 16, 2014 (prior revision 1720)
%   -Add additional comments regarding short-term Fourier transform
%   calculation.
%   -Correct minor errors (spacing, spelling, etc.).

% Friday, May 24, 2013 (prior revision 1696)
%   -Incorporate ALSR_display structure as an optional argument.

% Tuesday, May 14, 2013 (initial commit revision 1666)
%   -Created


