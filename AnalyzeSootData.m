%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpse:
%________________________________________________________________________________________________________________________
%
%   Inputs:
%
%   Outputs:
%
%   Last Revised: 
%________________________________________________________________________________________________________________________

clear
clc

disp('Select the Microsoft Excel sheet with the soot experiment information'); disp(' ') 
sootDataFile = uigetfile('*DataSheet.xlsx');
[~, ~, alldata] = xlsread(sootDataFile);

