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
    
    supplementalFileDirectory = dir('*_SupplementalData.mat');
    supplementalFiles = {supplementalFileDirectory.name}';
    supplementalFile = char(supplementalFiles);
    load(supplementalFile)
    
    RunMotionTrackingPatch(supplementalFile)
    
    resultsFileDirectory = dir('*_Results.mat');
    resultsFiles = {resultsFileDirectory.name}';
    resultsFile = char(resultsFiles);
    load(resultsFile)
    
    supplementalFileDirectory = dir('*_SupplementalData.mat');
    supplementalFiles = {supplementalFileDirectory.name}';
    supplementalFile = char(supplementalFiles);
    load(supplementalFile)
    
    disp(['Extracting ' animalID ' Results.']); disp(' ')
    
%     if ~isfield(Results, 'rearingEvents')
        
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
        changes = diff(positiveVals);
        Results.rearingEvents = sum(ismember(changes,1));
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
%     end
    rearingEvents{a,1} = Results.rearingEvents;
    distancePerPixel = (binWidth_inches/SuppData.binWidth)*2.54*0.01;   % in to cm to m
    distanceTraveled{a,1} = Results.distanceTraveled*distancePerPixel;
end

rearingEvents = vertcat({'rearingEvents'}, rearingEvents);
distanceTraveled = vertcat({'distanceTraveled'}, distanceTraveled);
allData = horzcat(allData, rearingEvents, distanceTraveled);
cd(curDir)

%% Generate figures for comparisons using the allData structure
waterControl = 'H20';
soot = 'Soot2040';
funcSoot = 'Soot2040F';
male = 'Male';
female = 'Female';
twoDay = 2;
tenDay = 10;
thirtyDay = 30;

%% Two day waterControl vs. Two day funcSoot (no gender))
c1 = 1;
c2 = 1;
for a = 2:size(allData,1)
    if strcmp(allData{a,4}, waterControl) == true && allData{a,5} == twoDay
        R1C1_columnOne_rearingEvents(c1,1) = allData{a,8};
        R2C1_columnOne_distanceTraveled(c1,1) = allData{a,9};
        c1 = c1+1;
    elseif strcmp(allData{a,4}, funcSoot) == true && allData{a,5} == twoDay
        R1C1_columnTwo_rearingEvents(c2,1) = allData{a,8};
        R2C1_columnTwo_distanceTraveled(c2,1) = allData{a,9};
        c2 = c2+1;
    end
end

%% Ten day waterControl vs. Ten day funcSoot (no gender))
c1 = 1;
c2 = 1;
for a = 2:size(allData,1)
    if strcmp(allData{a,4}, waterControl) == true && allData{a,5} == tenDay
        R1C2_columnOne_rearingEvents(c1,1) = allData{a,8};
        R2C2_columnOne_distanceTraveled(c1,1) = allData{a,9};
        c1 = c1+1;
    elseif strcmp(allData{a,4}, funcSoot) == true && allData{a,5} == tenDay
        R1C2_columnTwo_rearingEvents(c2,1) = allData{a,8};
        R2C2_columnTwo_distanceTraveled(c2,1) = allData{a,9};
        c2 = c2+1;
    end
end

%% Thirty day waterControl vs. Thirty day funcSoot (no gender))
c1 = 1;
c2 = 1;
for a = 2:size(allData,1)
    if strcmp(allData{a,4}, waterControl) == true && allData{a,5} == thirtyDay
        R1C3_columnOne_rearingEvents(c1,1) = allData{a,8};
        R2C3_columnOne_distanceTraveled(c1,1) = allData{a,9};
        c1 = c1+1;
    elseif strcmp(allData{a,4}, funcSoot) == true && allData{a,5} == thirtyDay
        R1C3_columnTwo_rearingEvents(c2,1) = allData{a,8};
        R2C3_columnTwo_distanceTraveled(c2,1) = allData{a,9};
        c2 = c2+1;
    end
end

%% All waterControl vs. All funcSoot (no gender or treatment duration)
c1 = 1;
c2 = 1;
for a = 2:size(allData,1)
    if strcmp(allData{a,4}, waterControl) == true
        R1C4_columnOne_rearingEvents(c1,1) = allData{a,8};
        R2C4_columnOne_distanceTraveled(c1,1) = allData{a,9};
        c1 = c1+1;
    elseif strcmp(allData{a,4}, funcSoot) == true
        R1C4_columnTwo_rearingEvents(c2,1) = allData{a,8};
        R2C4_columnTwo_distanceTraveled(c2,1) = allData{a,9};
        c2 = c2+1;
    end
end

%%
R1C1_columnOne_rearingEvents_mean = mean(R1C1_columnOne_rearingEvents);
R1C1_columnOne_rearingEvents_std = std(R1C1_columnOne_rearingEvents);
R2C1_columnOne_distanceTraveled_mean = mean(R2C1_columnOne_distanceTraveled);
R2C1_columnOne_distanceTraveled_std = std(R2C1_columnOne_distanceTraveled);
R1C1_columnTwo_rearingEvents_mean = mean(R1C1_columnTwo_rearingEvents);
R1C1_columnTwo_rearingEvents_std = std(R1C1_columnTwo_rearingEvents);
R2C1_columnTwo_distanceTraveled_mean = mean(R2C1_columnTwo_distanceTraveled);
R2C1_columnTwo_distanceTraveled_std = std(R2C1_columnTwo_distanceTraveled);

R1C1_columnOne_rearingEvents_x = ones(length(R1C1_columnOne_rearingEvents),1);
R2C1_columnOne_distanceTraveled_x = ones(length(R2C1_columnOne_distanceTraveled),1);
R1C1_columnTwo_rearingEvents_x = ones(length(R1C1_columnTwo_rearingEvents),1)*2;
R2C1_columnTwo_distanceTraveled_x = ones(length(R2C1_columnTwo_distanceTraveled),1)*2;

%%
R1C2_columnOne_rearingEvents_mean = mean(R1C2_columnOne_rearingEvents);
R1C2_columnOne_rearingEvents_std = std(R1C2_columnOne_rearingEvents);
R2C2_columnOne_distanceTraveled_mean = mean(R2C2_columnOne_distanceTraveled);
R2C2_columnOne_distanceTraveled_std = std(R2C2_columnOne_distanceTraveled);
R1C2_columnTwo_rearingEvents_mean = mean(R1C2_columnTwo_rearingEvents);
R1C2_columnTwo_rearingEvents_std = std(R1C2_columnTwo_rearingEvents);
R2C2_columnTwo_distanceTraveled_mean = mean(R2C2_columnTwo_distanceTraveled);
R2C2_columnTwo_distanceTraveled_std = std(R2C2_columnTwo_distanceTraveled);

R1C2_columnOne_rearingEvents_x = ones(length(R1C2_columnOne_rearingEvents),1);
R2C2_columnOne_distanceTraveled_x = ones(length(R2C2_columnOne_distanceTraveled),1);
R1C2_columnTwo_rearingEvents_x = ones(length(R1C2_columnTwo_rearingEvents),1)*2;
R2C2_columnTwo_distanceTraveled_x = ones(length(R2C2_columnTwo_distanceTraveled),1)*2;

%%
R1C3_columnOne_rearingEvents_mean = mean(R1C3_columnOne_rearingEvents);
R1C3_columnOne_rearingEvents_std = std(R1C3_columnOne_rearingEvents);
R2C3_columnOne_distanceTraveled_mean = mean(R2C3_columnOne_distanceTraveled);
R2C3_columnOne_distanceTraveled_std = std(R2C3_columnOne_distanceTraveled);
R1C3_columnTwo_rearingEvents_mean = mean(R1C3_columnTwo_rearingEvents);
R1C3_columnTwo_rearingEvents_std = std(R1C3_columnTwo_rearingEvents);
R2C3_columnTwo_distanceTraveled_mean = mean(R2C3_columnTwo_distanceTraveled);
R2C3_columnTwo_distanceTraveled_std = std(R2C3_columnTwo_distanceTraveled);

R1C3_columnOne_rearingEvents_x = ones(length(R1C3_columnOne_rearingEvents),1);
R2C3_columnOne_distanceTraveled_x = ones(length(R2C3_columnOne_distanceTraveled),1);
R1C3_columnTwo_rearingEvents_x = ones(length(R1C3_columnTwo_rearingEvents),1)*2;
R2C3_columnTwo_distanceTraveled_x = ones(length(R2C3_columnTwo_distanceTraveled),1)*2;

%%
R1C4_columnOne_rearingEvents_mean = mean(R1C4_columnOne_rearingEvents);
R1C4_columnOne_rearingEvents_std = std(R1C4_columnOne_rearingEvents);
R2C4_columnOne_distanceTraveled_mean = mean(R2C4_columnOne_distanceTraveled);
R2C4_columnOne_distanceTraveled_std = std(R2C4_columnOne_distanceTraveled);
R1C4_columnTwo_rearingEvents_mean = mean(R1C4_columnTwo_rearingEvents);
R1C4_columnTwo_rearingEvents_std = std(R1C4_columnTwo_rearingEvents);
R2C4_columnTwo_distanceTraveled_mean = mean(R2C4_columnTwo_distanceTraveled);
R2C4_columnTwo_distanceTraveled_std = std(R2C4_columnTwo_distanceTraveled);

R1C4_columnOne_rearingEvents_x = ones(length(R1C4_columnOne_rearingEvents),1);
R2C4_columnOne_distanceTraveled_x = ones(length(R2C4_columnOne_distanceTraveled),1);
R1C4_columnTwo_rearingEvents_x = ones(length(R1C4_columnTwo_rearingEvents),1)*2;
R2C4_columnTwo_distanceTraveled_x = ones(length(R2C4_columnTwo_distanceTraveled),1)*2;

%%
figure;
ax1 = subplot(2,4,1);
scatter(R1C1_columnOne_rearingEvents_x, R1C1_columnOne_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R1C1_columnOne_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R1C1_columnOne_rearingEvents_mean + R1C1_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R1C1_columnOne_rearingEvents_mean - R1C1_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R1C1_columnTwo_rearingEvents_x, R1C1_columnTwo_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R1C1_columnTwo_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R1C1_columnTwo_rearingEvents_mean + R1C1_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R1C1_columnTwo_rearingEvents_mean - R1C1_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Two day rearing events ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax2 = subplot(2,4,2);
scatter(R1C2_columnOne_rearingEvents_x, R1C2_columnOne_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R1C2_columnOne_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R1C2_columnOne_rearingEvents_mean + R1C2_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R1C2_columnOne_rearingEvents_mean - R1C2_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R1C2_columnTwo_rearingEvents_x, R1C2_columnTwo_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R1C2_columnTwo_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R1C2_columnTwo_rearingEvents_mean + R1C2_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R1C2_columnTwo_rearingEvents_mean - R1C2_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Ten day rearing events ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax3 = subplot(2,4,3);
scatter(R1C3_columnOne_rearingEvents_x, R1C3_columnOne_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R1C3_columnOne_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R1C3_columnOne_rearingEvents_mean + R1C3_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R1C3_columnOne_rearingEvents_mean - R1C3_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R1C3_columnTwo_rearingEvents_x, R1C3_columnTwo_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R1C3_columnTwo_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R1C3_columnTwo_rearingEvents_mean + R1C3_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R1C3_columnTwo_rearingEvents_mean - R1C3_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Thirty day rearing events ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax4 = subplot(2,4,4);
scatter(R1C4_columnOne_rearingEvents_x, R1C4_columnOne_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R1C4_columnOne_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R1C4_columnOne_rearingEvents_mean + R1C4_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R1C4_columnOne_rearingEvents_mean - R1C4_columnOne_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R1C4_columnTwo_rearingEvents_x, R1C4_columnTwo_rearingEvents, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R1C4_columnTwo_rearingEvents_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R1C4_columnTwo_rearingEvents_mean + R1C4_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R1C4_columnTwo_rearingEvents_mean - R1C4_columnTwo_rearingEvents_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['All rearing events ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])
linkaxes([ax1 ax2 ax3 ax4], 'y')

ax5 = subplot(2,4,5);
scatter(R2C1_columnOne_distanceTraveled_x, R2C1_columnOne_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R2C1_columnOne_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R2C1_columnOne_distanceTraveled_mean + R2C1_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R2C1_columnOne_distanceTraveled_mean - R2C1_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R2C1_columnTwo_distanceTraveled_x, R2C1_columnTwo_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R2C1_columnTwo_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R2C1_columnTwo_distanceTraveled_mean + R2C1_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R2C1_columnTwo_distanceTraveled_mean - R2C1_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Two day distance traveled ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax6 = subplot(2,4,6);
scatter(R2C2_columnOne_distanceTraveled_x, R2C2_columnOne_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R2C2_columnOne_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R2C2_columnOne_distanceTraveled_mean + R2C2_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R2C2_columnOne_distanceTraveled_mean - R2C2_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R2C2_columnTwo_distanceTraveled_x, R2C2_columnTwo_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R2C2_columnTwo_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R2C2_columnTwo_distanceTraveled_mean + R2C2_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R2C2_columnTwo_distanceTraveled_mean - R2C2_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Ten day distance traveled ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax7 = subplot(2,4,7);
scatter(R2C3_columnOne_distanceTraveled_x, R2C3_columnOne_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R2C3_columnOne_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R2C3_columnOne_distanceTraveled_mean + R2C3_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R2C3_columnOne_distanceTraveled_mean - R2C3_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R2C3_columnTwo_distanceTraveled_x, R2C3_columnTwo_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R2C3_columnTwo_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R2C3_columnTwo_distanceTraveled_mean + R2C3_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R2C3_columnTwo_distanceTraveled_mean - R2C3_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['Thirty day distance traveled ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])

ax8 = subplot(2,4,8);
scatter(R2C4_columnOne_distanceTraveled_x, R2C4_columnOne_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
hold on
scatter(1, R2C4_columnOne_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(1, R2C4_columnOne_distanceTraveled_mean + R2C4_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(1, R2C4_columnOne_distanceTraveled_mean - R2C4_columnOne_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(R2C4_columnTwo_distanceTraveled_x, R2C4_columnTwo_distanceTraveled, 'MarkerEdgeColor', 'k', 'jitter', 'on', 'jitterAmount', 0.25);
scatter(2, R2C4_columnTwo_distanceTraveled_mean, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b')
scatter(2, R2C4_columnTwo_distanceTraveled_mean + R2C4_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
scatter(2, R2C4_columnTwo_distanceTraveled_mean - R2C4_columnTwo_distanceTraveled_std, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'g')
title(['All distance traveled ' waterControl ' (L) vs. ' funcSoot ' (R)'])
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0 3])
linkaxes([ax5 ax6 ax7 ax8], 'y')
