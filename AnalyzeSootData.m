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

% Load in ms excel file
disp('Select the Microsoft Excel sheet with the soot experiment information'); disp(' ')
sootDataFile = uigetfile('*DataSheet.xlsx');
[~, ~, allData] = xlsread(sootDataFile);

curDir = cd;
animalIDs = allData(2:end,1);
driveLetters = allData(2:end,7);
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    driveLetter = driveLetters{a,1};
    dataLoc = [driveLetter ':\' animalID];
    disp(['Switching to ' dataLoc]); disp(' ')
    cd(dataLoc)
    
    %    resultsFileDirectory = dir('*_Results.mat');
    %    resultsFiles = {resultsFileDirectory.name}';
    %    resultsFile = char(resultsFiles);
    %    load(resultsFile)
    
    disp('Loading depth stack'); disp(' ')
    trueDepthStackADir = dir('*_TrueDepthStack_A.mat');
    trueDepthStackAFiles = {trueDepthStackADir.name}';
    trueDepthStackAFile = char(trueDepthStackAFiles);
    load(trueDepthStackAFile)
    
    supplementalFileDirectory = dir('*_SupplementalData.mat');
    supplementalFiles = {supplementalFileDirectory.name}';
    supplementalFile = char(supplementalFiles);
    load(supplementalFile)
        
    if ~isfield(SuppData, 'binWidth')
        yString = 'y';
        theInput = 'n';
        while strcmp(yString, theInput) ~= 1
            disp('Draw a line the width of the box'); disp(' ')
            cageImg = figure;
            imagesc(depthStack_A{1,1})
            colormap jet
            caxis([0 1])
            hold on
            p1=[200 1];
            p2=[200 640];
            plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2)
            cageLine = drawline();
            L1 = cageLine.Position(1);
            L2 = cageLine.Position(2);
            close(cageImg)
            
            checkLine = figure;
            imagesc(depthStack_A{1,1})
            colormap jet
            hold on
            p1=[200 L1];
            p2=[200 L2];
            plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2)
            
            binWidth = abs(round(L2)-round(L1));
            disp(['Bin width (pixels): ' num2str(binWidth)]); disp(' ')
            theInput = input('Is the bin width accurate? (y/n): ', 's'); disp(' ')
            try
                close(checkLine)
            catch
            end
            
            disp('Saving updated supplemental file'); disp(' ')
            SuppData.binWidth = binWidth;
            save(supplementalFile, 'SuppData');
        end
    else
        disp(['Bin width already measured for ' animalID '. Continuing...']); disp(' ')
    end
end
                                
