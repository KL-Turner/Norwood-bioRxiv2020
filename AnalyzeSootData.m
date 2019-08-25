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
binWidth_inches = 14;

for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    driveLetter = driveLetters{a,1};
    dataLoc = [driveLetter ':\' animalID];
    disp(['Switching to ' dataLoc]); disp(' ')
    cd(dataLoc)
    
    resultsFileDirectory = dir('*_Results.mat');
    resultsFiles = {resultsFileDirectory.name}';
    resultsFile = char(resultsFiles);
    load(resultsFile)
    
    supplementalFileDirectory = dir('*_SupplementalData.mat');
    supplementalFiles = {supplementalFileDirectory.name}';
    supplementalFile = char(supplementalFiles);
    load(supplementalFile)
    
    disp(['Extracting ' animalID ' Results.']); disp(' ')
    
    if ~isfield(Results, 'rearingEvents')
        
        threshHeight = 3;   % cm
        mouseHeight = Results.avg20Height';
        X = ~isnan(mouseHeight);
        Y = cumsum(X-diff([1,X])/2);
        adjustedHeight = interp1(1:nnz(X),mouseHeight(X),Y);
        if sum(isnan(adjustedHeight)) > 0
            nanInds = isnan(adjustedHeight);
            nonnanInds = ~isnan(adjustedHeight);
            realVals = adjustedHeight(nonnanInds);
            tempDescendPixelVals = sort(realVals(:),'descend');
            tempBaseline = mean(descendPixelVals(1:ceil(length(realVals)*0.3)));
            adjustedHeight(nanInds) = tempBaseline;
        end
        
        descendPixelVals = sort(adjustedHeight(:),'descend');
        baseline = mean(descendPixelVals(1:ceil(length(adjustedHeight)*0.3)));
        
        positiveVals = adjustedHeight <= (baseline-threshHeight);
        Results.rearingEvents = sum(positiveVals);
        negativeVals = adjustedHeight > (baseline-threshHeight);
        yVals = zeros(length(positiveVals),1);
        yVals(positiveVals) = min(Results.avg20Height) - 1;
        yVals(negativeVals) = NaN;
        p1=[baseline 1];
        p2=[baseline 1200];
        p3=[baseline-threshHeight 1];
        p4=[baseline-threshHeight 1200];
        
        checkThresh = figure;
        plot((1:length(adjustedHeight))/SuppData.samplingRate, adjustedHeight, 'k')
        hold on
        scatter((1:length(yVals))/SuppData.samplingRate, yVals, 'MarkerEdgeColor', colors_IOS('Vegas Gold'))
        plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','b','LineWidth',2)
        plot([p3(2),p4(2)],[p3(1),p4(1)],'Color','g','LineWidth',2)
        title([animalID ' rearing events'])
        set(gca, 'YDir','reverse')
        ylabel('Distance (cm)')
        xlabel('~Time (sec)')
        legend('Min of bottom 20% of valid pixels', 'Positive events')
        
        disp(['Total rearing events: ' num2str(Results.rearingEvents)]); disp(' ')
        
        save(resultsFile, 'Results')
    end
    rearingEvents{a,1} = Results.rearingEvents;
    distancePerPixel = (binWidth_inches/SuppData.binWidth)*2.54;
    distanceTraveled{a,1} = Results.distanceTraveled*distancePerPixel;
end

cd(curDir)
