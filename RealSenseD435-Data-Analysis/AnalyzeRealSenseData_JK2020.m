%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: apply an assortment of image processing techniques to the depth stack in order to track animal height/motion
%________________________________________________________________________________________________________________________

clear; clc;
%% draw ROIs for motion tracking
disp('Verifying that ROIs exist for each day...'); disp(' ')
depthStackDirectory = dir('*_DepthStack.mat');
depthStackFiles = {depthStackDirectory.name}';
depthStackFile = char(depthStackFiles);
supplementalFile = [depthStackFile(1:end - 15) '_SupplementalData.mat'];
if ~exist([depthStackFile(1:end - 15) '_TrueDepthStack_A.mat'],'file')
    DrawAnalysisROIs_JK2020(depthStackFile,supplementalFile);
end
depthStackA = [depthStackFile(1:end - 15) '_TrueDepthStack_A.mat'];
depthStackB = [depthStackFile(1:end - 15) '_TrueDepthStack_B.mat'];
depthStackC = [depthStackFile(1:end - 15) '_TrueDepthStack_C.mat'];
depthStacks = {depthStackA,depthStackB,depthStackC};
%% Process the depth stack frames
for b = 1:size(depthStacks,2)
    depthStackFile = depthStacks{1,b};
    if ~exist([depthStackFile(1:end - 21) '_ProcDepthStack_' depthStackFile(end - 4:end)],'file')
        disp(['Processing TrueDepthStack file... (' num2str(b) '/' num2str(size(depthStacks,2)) ')']); disp(' ')
        CorrectRealSenseFrames_PatchHoles_JK2020(depthStackFile,supplementalFile)
        CorrectRealSenseFrames_ImageMask_JK2020(depthStackFile,supplementalFile)
        CorrectRealSenseFrames_KalmanFilter_JK2020(depthStackFile)
        CorrectRealSenseFrames_MeanSub_JK2020(depthStackFile)
        CorrectRealSenseFrames_Theshold_JK2020(depthStackFile)
        CorrectRealSenseFrames_Binarize_JK2020(depthStackFile)
        CorrectRealSenseFrames_BinOverlay_JK2020(depthStackFile)
    end
end
%% Load the RGB stack camera frames, create .avi movies from data
RGBStackDirectory = dir('*RGBStack.mat');
RGBStackFiles = {RGBStackDirectory.name}';
RGBStackFile = char(RGBStackFiles);
ConvertRealSenseToAVI_JK2020(RGBStackFile,supplementalFile,'RGBStack');
CorrectColorScale_JK2020(supplementalFile)
for c = 1:size(depthStacks,2)
    depthStackFile = depthStacks{1,c};
    CorrectRealSenseFrames_ResetDepth_JK2020(depthStackFile,supplementalFile)
end
%% Skip combining the split files into one if they already exist
if ~exist([depthStackFile(1:end - 21) '_ProcDepthStack.mat'],'file')
    JoinProcessedFiles_JK2020(depthStacks,'processed')
end
%% Skip combining the split files into one if they already exist
if ~exist([depthStackFile(1:end - 21) '_BinDepthStack.mat'],'file')
    JoinProcessedFiles_JK2020(depthStacks,'binary')
end
%% Load the RGB stack camera frames, create .avi movies from data
procStackDirectory = dir('*ProcDepthStack.mat');
procStackFiles = {procStackDirectory.name}';
procStackFile = char(procStackFiles);
ConvertRealSenseToAVI_JK2020(procStackFile,supplementalFile,'FullyProcDepthStack');
%% Track object height
TrackObjectHeight_JK2020(procStackFile,supplementalFile);
%% Track object motion in video
binStackDirectory = dir('*BinDepthStack.mat');
binStackFiles = {binStackDirectory.name}';
binStackFile = char(binStackFiles);
TrackObjectMotion_JK2020(binStackFile,supplementalFile);

disp('RealSense movie analysis - complete'); disp(' ')
