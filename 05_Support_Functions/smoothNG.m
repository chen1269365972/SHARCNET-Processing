function [modified_neurogram, neurogram_time]=smoothNG(neurogram, neurogram_time, ...
    model_frequency, new_bin_width, h_window)

% This script-file rebins and convolves a given neurogram.  Convolution can
% be processed in two ways, using a pre-determined block-size or
% convolution by the FILTER function and extracting the desired values and
% respective time indicies.

% The basis of this script-file is work done by Timothy Zeyl.  This
% script-file is a modified version of his work.
%
%
%% See Also

% Author:  Michael R. Wirtzfeld
% Creation Date:  Wednesday, February 8, 2012
% Modification Date:  Monday, December 24, 2012
%       Change Digest:  See below.
%
%% See Also
%


%% Processing Conditions

if (nargin > 4)
    convolution_flag = 1;
else
    convolution_flag = 0;
end;

bins_to_collapse = floor(model_frequency*new_bin_width);



%% Processing

%----------------------------------------------------------------------------------------------------------------------------------
if (bins_to_collapse > 1)  % Rebinning Required

    if (convolution_flag == 1)
        
        new_total_bins = floor(size(neurogram, 2) / bins_to_collapse);
        neurogram_convolved=zeros(size(neurogram, 1), new_total_bins);
        neurogram = neurogram(:, 1:1:(new_total_bins * bins_to_collapse));
        
        for CF_index = 1:1:size(neurogram, 1)
            neurogram_convolved(CF_index, :) = filter(h_window, 1, ...
                sum(reshape(neurogram(CF_index, :), bins_to_collapse, new_total_bins)));
        end;
        
        window_length=numel(h_window);
        
        modified_neurogram = neurogram_convolved(:, 1:(window_length/2):(new_total_bins - numel(h_window)));
        
        neurogram_time = neurogram_time(1:(new_total_bins * bins_to_collapse));
        neurogram_time = neurogram_time(1:(window_length/2*bins_to_collapse):(new_total_bins - numel(h_window))*bins_to_collapse);
    
    else
        
        new_total_bins = floor(size(neurogram, 2) / bins_to_collapse);
        neurogram = neurogram(:, 1:1:(new_total_bins * bins_to_collapse));
        
        modified_neurogram = zeros(size(neurogram, 1), new_total_bins);
        
        for CF_index = 1:1:size(neurogram, 1)            
            modified_neurogram(CF_index, :) = sum(reshape(neurogram(CF_index, :), bins_to_collapse, new_total_bins));
        end;

        neurogram_time = neurogram_time(1:bins_to_collapse:(new_total_bins * bins_to_collapse));
    
    end;
    
    
%----------------------------------------------------------------------------------------------------------------------------------      
elseif (bins_to_collapse == 1)  % No Rebinning
    
    if (convolution_flag == 1)
        
       neurogram_convolved = zeros(size(neurogram));
       
       for CF_index = 1:1:size(neurogram, 1)            
           neurogram_convolved(CF_index, :) = filter(h_window, 1, neurogram(CF_index, :));
       end;
       
       window_length=numel(h_window);
       
       modified_neurogram = neurogram_convolved(:, 1:(window_length/2*bins_to_collapse):(size(neurogram, 2) - numel(h_window)));
       neurogram_time = neurogram_time(1:(window_length/2*bins_to_collapse):(size(neurogram, 2) - numel(h_window)));    
   
    else
        
        modified_neurogram=neurogram;
    
    end;
  
   
%----------------------------------------------------------------------------------------------------------------------------------
else
    
    fprintf( 1, '\n\n *** Desired bin-width is Too Small ***\n\n' );    
    modified_neurogram = [];
    neurogram_time = [];

end;



%% References



%% Digest

% Monday, December 24, 2012
%   -Results verification using FILTER to perform convolution operation.


% Friday, December 21, 2012
%   -Review and clean-up script-file.
%       b.)  Remove "repetitions_of_stimulus" variable.
%       a.)  Remove "spike_rate_scaling" variable;  only use NET spike-count.


% Wednesday, October 17, 2012
%   -Add flag to control scalling of PSTH to spikes per second.


% Saturday, July 21, 2012
%   -Add IF-END statement for conditional printing.


