function [ mean_ssim, ssim_map ] = nsim( image_1, image_2, parameters, type_flag )

% This script-file calculates the neural similarity index metric (NSIM).
%
%
%% See Also
%

% Author:  Michael R. Wirtzfeld
% Creation Date:  Monday, April 25, 2012
% Modification Date:  Monday, April 21, 2014
%       Change Digest:  See below.
%
%% See Also
% 


%% Raw Scaling

if ( parameters.nsim_processing.scaling == 1 )

    if ( strcmpi(type_flag, 'env') )
        image_1 = image_1 .* parameters.nsim_processing.raw_env_factor;
        image_2 = image_2 .* parameters.nsim_processing.raw_env_factor;
    else
        image_1 = image_1 .* parameters.nsim_processing.raw_tfs_factor;
        image_2 = image_2 .* parameters.nsim_processing.raw_tfs_factor;
    end;

end;



%% Base Metrics

if ( parameters.nsim_processing.kernel_type == 1 )
    window = parameters.nsim_processing.kernel ./ ...
        sum( parameters.nsim_processing.kernel(:) );    
else
    hsize = size( parameters.nsim_processing.kernel );
    standard_deviation = 0.5;
    %
    % Both of these parameter values are default for the FSPECIAL function.
    
    window = fspecial( 'gaussian', hsize, standard_deviation );   
    window = window ./ sum( window(:) );
end;


mu_1 = filter2( window, image_1, 'valid' );
    mu_1_sq = mu_1.^2;
mu_2 = filter2( window, image_2, 'valid' );
    mu_2_sq = mu_2.^2;
    
sigma_1_sq = filter2( window, image_1.*image_1, 'valid' ) - mu_1_sq;
%     sigma_1 = abs( sigma_1_sq.^(0.5) );
    sigma_1 = sign(sigma_1_sq) .* sqrt( abs(sigma_1_sq) );
sigma_2_sq = filter2( window, image_2.*image_2, 'valid' ) - mu_2_sq;
%     sigma_2 = abs( sigma_2_sq.^(0.5) );
    sigma_2 = sign(sigma_2_sq) .* sqrt( abs(sigma_2_sq) );
    
sigma_12 = filter2( window, image_1.*image_2, 'valid' ) - mu_1.*mu_2;



%% Metric Dimensions

if ( parameters.nsim_processing.dynamic_range == 1 )
    maximum_value = max( image_1(:) );
        scale_factors = ( [ 0.01 0.05 0.05 ] .* maximum_value ).^2;
else
    scale_factors = ( [ 0.01 0.05 0.05 ] .* 255 ).^2;
end;

luminance = ( 2 * mu_1 .* mu_2 + scale_factors(1) ) ./ ( mu_1_sq + mu_2_sq + scale_factors(1) );
%     luminance = luminance .^ parameters.nsim_processing.weights.alpha;
    luminance = sign(luminance) .* ( abs(luminance).^parameters.nsim_processing.weights.alpha );

contrast = ( 2 * sigma_1 .* sigma_2 + scale_factors(2) ) ./ ( sigma_1_sq + sigma_2_sq + scale_factors(2) );
%     contrast = contrast .^  parameters.nsim_processing.weights.beta;
    contrast = sign(contrast) .* ( abs(contrast).^parameters.nsim_processing.weights.beta );

structure = ( sigma_12 + scale_factors(3) ) ./ ( sigma_1 .* sigma_2 + scale_factors(3) );
%     structure = structure .^ parameters.nsim_processing.weights.gamma;
    structure = sign(structure) .* ( abs(structure).^parameters.nsim_processing.weights.gamma );

    
ssim_map = luminance .* contrast .* structure;
mean_ssim = mean2( ssim_map );



%% References

% http://www.mathworks.com/help/toolbox/images/ref/blockproc.html
% http://www.mathworks.com/help/toolbox/images/f7-12726.html
% http://stackoverflow.com/questions/1637000/how-to-divide-an-image-into-blocks-in-matlab



%% Digest

% Monday, April 21, 2014 (prio revision 1532)
%   -Modify script-file to handle negative values with fractional powers
%   (i.e. complex-number results);  produces a scalar value for the mean
%   NSIM result.

% Friday, April 19, 2013 (prior revision 1336)
%   -Add logic-flag to control scaling of raw ENV and TFS neurograms into
%       original dynamic range of 255.
%   -Add logic-flag to set kernel-type.
%   -Add logic-flag to dynamically set the original 255 gray-scale limit to
%       the maximum bin-count of the original neurogram.

% Tuesday, January 15, 2013
%   -Raw PSTH scaling.
%       -Chimaera 1, Sentence 1 ("Lid")
%           a.)  ENV Pre-scaling:  0.69649, post-scaling:  0.39741
%           b.)  TFS Pre-scaling:  0.92103, post-scaling:  0.41006

% Tuesday, December 25, 2012
%   -Review and tidy script-file.

% Thursday, November 29, 2012
%   -Replace scaling and investigate scaline options.

% Tuesday, November 20, 2012
%   -Remove scaling for luminance, contrast and structure dimensions.


