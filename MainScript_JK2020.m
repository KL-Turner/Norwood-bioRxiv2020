function [] = MainScript_JK2020()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
% Purpose: Generates KLT's main and supplemental figs for the 2020 soot paper.
%
% Scripts used to acquire and pre-process the original data are located in the folders RealSenseD435-Camera-Streaming
%         and RealSenseD435-Data-Analysis. 
%________________________________________________________________________________________________________________________

clear; clc;
%% Make sure the current directory is 'Norwood_Turner_Drew_JK2020' and that the code repository is present.
currentFolder = pwd;
addpath(genpath(currentFolder));
fileparts = strsplit(currentFolder,filesep);
if ismac
    rootFolder = fullfile(filesep,fileparts{1:end});
else
    rootFolder = fullfile(fileparts{1:end});
end
% Add root folder to Matlab's working directory.
addpath(genpath(rootFolder))

%% Run the data analysis. The progress bars will show the analysis progress.
dataSummary = dir('AnalnysisResults.mat');
runFromStart = 'n';
% If the analysis structure has already been created, load it and skip the analysis.
if ~isempty(dataSummary) && strcmp(runFromStart,'n') == true
    load(dataSummary.name);
    disp('Loading analysis results and generating figures...'); disp(' ')
else
    multiWaitbar_Manuscript2020('Tracking animal rearing',0,'Color','K'); pause(0.25);
    multiWaitbar_Manuscript2020('Tracking animal motion',0,'Color','K'); pause(0.25);
    multiWaitbar_Manuscript2020('Creating presentation video',0,'Color','K'); pause(0.25);
    % Run analysis and output a structure containing all the analyzed data.
    [AnalysisResults] = AnalyzeData_JK2020(rootFolder);
    multiWaitbar_Manuscript2020('CloseAll');
end

%% Individual figures can be re-run after the analysis has completed.
SootSummaryFigure_JK2020(AnalysisResults)
disp('MainScript Analysis - Complete'); disp(' ')

end

function [AnalysisResults] = AnalyzeData_JK2020(rootFolder)
sootDataFile = 'SootExperimentDataSheet.xlsx';
[~,~,allData] = xlsread(sootDataFile);
animalIDs = allData(2:end,1);
saveFigs = 'y';
if exist('AnalysisResults.mat') == 2
    load('AnalysisResults.mat')
else
    AnalysisResults = [];
end

%% Block [1] Track the rearing events of each animal
runFromStart = 'n';
for a = 1:length(animalIDs)
    if isfield(AnalysisResults,(animalIDs{a,1})) == false || isfield(AnalysisResults.(animalIDs{a,1}),'Rearing') == false || strcmp(runFromStart,'y') == true 
        [AnalysisResults] = TrackAnimalHeight_JK2020(animalIDs{a,1},saveFigs,rootFolder,AnalysisResults);
    end
    multiWaitbar_Manuscript2020('Tracking animal rearing','Value',a/length(animalIDs));
end

%% Block [2] Track the rearing events of each animal
runFromStart = 'n';
for b = 1:length(animalIDs)
    if isfield(AnalysisResults,(animalIDs{b,1})) == false || isfield(AnalysisResults.(animalIDs{b,1}),'Distance') == false || strcmp(runFromStart,'y') == true 
        [AnalysisResults] = TrackAnimalMotion_JK2020(animalIDs{b,1},saveFigs,rootFolder,AnalysisResults);
    end
    multiWaitbar_Manuscript2020('Tracking animal motion','Value',b/length(animalIDs));
end

end
