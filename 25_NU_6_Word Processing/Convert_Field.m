


%% Environment

close all; clear all; clc;

addpath( genpath( fullfile('..', '..') ), '-begin' );



%% Load Original Data-set

load( 'PC_SI_Working_Chimaera_List.mat' );



%% Convert Structure to Cell-array

a = working_chimaera_data_set;
    clear working_chimaera_data_set;
%
b = a(1,1);

c = struct2cell(a);
    c_fieldnames = fieldnames(a);
    
    
    
%% Convert Fieldnames for File Pathnames

old_substring = '../../00_Dataset/10_MAT_Files/';
new_substring = '../../00_Dataset/10_MAT_Files/';

% Rename pathname for chimaera files (index 9 from extracted fieldnames).
c_paths  = strrep( c(9, :, :), old_substring, new_substring);
    c(9, :, :) = regexprep(c_paths(:,:,:), '\', '/');

% Rename pathname for original files (index 10 from extracted fieldnames).
o_paths  = strrep( c(10, :, :), old_substring, new_substring);
    c(10, :, :) = regexprep(o_paths(:,:,:), '\', '/');

%% Reconstitute Structure

working_chimaera_data_set = cell2struct(c, c_fieldnames, 1);



%% Save

save( 'PC_SI_Working_Chimaera_List', 'working_chimaera_data_set' );


