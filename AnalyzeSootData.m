%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: Analyze average rearing and movement of mouse behavior after intranasal administration of environmental toxins
%________________________________________________________________________________________________________________________

clear; clc
% load in ms excel file
disp('Select the Microsoft Excel sheet with the soot experiment information'); disp(' ')

% go through each animal and load the rearing/movement results
for a = 1:length(animalIDs)
    animalID = animalIDs{a,1};
    driveLetter = driveLetters{a,1};
    dataLoc = [driveLetter ':\' animalID];
    disp(['Gathering data from ' dataLoc]); disp(' ')
    cd(dataLoc)
    % load supplemental file
    supplementalFileDirectory = dir('*_SupplementalData.mat');
    supplementalFiles = {supplementalFileDirectory.name}';
    supplementalFile = char(supplementalFiles);
    load(supplementalFile)
    % load results file
    resultsFileDirectory = dir('*_Results.mat');
    resultsFiles = {resultsFileDirectory.name}';
    resultsFile = char(resultsFiles);
    load(resultsFile)
    % determine number of rearing events
    threshHeight = 3;   % cm
    mouseHeight = Results.avg20Height';
    X = ~isnan(mouseHeight);
    Y = cumsum(X - diff([1,X])/2);
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
    positiveVals = adjustedHeight <= (baseline - threshHeight);
    changes = diff(positiveVals);
    Results.rearingEvents = sum(ismember(changes,1));
    % summary figure of rearinge events
    %     negativeVals = adjustedHeight > (baseline-threshHeight);
    %     yVals = zeros(length(positiveVals),1);
    %     yVals(positiveVals) = min(Results.avg20Height) - 1;
    %     yVals(negativeVals) = NaN;
    %     p1 = [baseline,1];
    %     p2 = [baseline,1200];
    %     p3 = [baseline - threshHeight,1];
    %     p4 = [baseline - threshHeight,1200];
    %     checkThresh = figure;
    %     plot((1:length(adjustedHeight))/SuppData.samplingRate,adjustedHeight,'k')
    %     hold on
    %     scatter((1:length(yVals))/SuppData.samplingRate,yVals,'MarkerEdgeColor',colors_Manuscript2020('Vegas Gold'))
    %     plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','b','LineWidth',2)
    %     plot([p3(2),p4(2)],[p3(1),p4(1)],'Color','g','LineWidth',2)
    %     title([animalID ' rearing events'])
    %     set(gca, 'YDir','reverse')
    %     ylabel('Distance (cm)')
    %     xlabel('~Time (sec)')
    %     legend('Min of bottom 20% of valid pixels','Positive events')
    rearingEvents{a,1} = Results.rearingEvents; %#ok<*SAGROW>
%     try
        distancePerPixel = (binWidth/SuppData.binWidth)*2.54*0.01;   % in to cm to m
%     catch
%         distancePerPixel = (binWidth/617)*2.54*0.01;   % in to cm to m
%     end
    distanceTraveled{a,1} = Results.distanceTraveled*distancePerPixel;
end
rearingEvents = vertcat({'rearingEvents'},rearingEvents);
distanceTraveled = vertcat({'distanceTraveled'},distanceTraveled);
allData = horzcat(allData,rearingEvents,distanceTraveled);
cd(curDir)

% separate data by each condition
c1 = 1; c2 = 1; c3 = 1;
for b = 2:size(allData,1)
    if strcmp(allData{b,4},'H2O') == true
        waterRearing(c1,1) = allData{b,8};
        waterDistance(c1,1) = allData{b,9};
        waterSex{c1,1} = allData{b,3};
        c1 = c1 + 1 ;
    elseif strcmp(allData{b,4},'Soot2040') == true
        sootRearing(c2,1) = allData{b,8};
        sootDistance(c2,1) = allData{b,9};
        sootSex{c2,1} = allData{b,3};
        c2 = c2 + 1;
    elseif strcmp(allData{b,4},'Soot2040F') == true
        funcSootRearing(c3,1) = allData{b,8};
        funcSootDistance(c3,1) = allData{b,9};
        funcSootSex{c3,1} = allData{b,3};
        c3 = c3 + 1;
    end
end

% calculate mean and standard error
% water control
waterRearing_mean = mean(waterRearing);
waterRearing_StErr = std(waterRearing)/sqrt(length(waterRearing));
waterDistance_mean = mean(waterDistance);
waterDistance_StErr = std(waterDistance)/sqrt(length(waterDistance));
waterXinds = ones(length(waterRearing),1);
% soot
sootRearing_mean = mean(sootRearing);
sootRearing_StErr = std(sootRearing)/sqrt(length(sootRearing));
sootDistance_mean = mean(sootDistance);
sootDistance_StErr = std(sootDistance)/sqrt(length(sootDistance));
sootXinds = ones(length(sootRearing),1);
% functionalized soot
funcSootRearing_mean = mean(funcSootRearing);
funcSootRearing_StErr = std(funcSootRearing)/sqrt(length(funcSootRearing));
funcSootDistance_mean = mean(funcSootDistance);
funcSootDistance_StErr = std(funcSootDistance)/sqrt(length(funcSootDistance));
funcSootXinds = ones(length(funcSootRearing),1);

% figure
% rearing
figure;
ax1 = subplot(1,2,1);
for d = 1:length(waterRearing)
    if strcmp(waterSex{d,1},'Male') == true
        scatter(waterXinds(d,1).*1,waterRearing(d,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    elseif strcmp(waterSex{d,1},'Female') == true
        scatter(waterXinds(d,1).*1,waterRearing(d,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e1 = errorbar(1,waterRearing_mean,waterRearing_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
e1.Color = 'black';
for e = 1:length(sootRearing)
    if strcmp(sootSex{e,1},'Male') == true
        scatter(sootXinds(e,1).*2,sootRearing(e,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    elseif strcmp(sootSex{e,1},'Female') == true
        scatter(sootXinds(e,1).*2,sootRearing(e,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e2 = errorbar(2,sootRearing_mean,sootRearing_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
e2.Color = 'black';
for f = 1:length(funcSootRearing)
    if strcmp(funcSootSex{f,1},'Male') == true
        scatter(funcSootXinds(f,1).*3,funcSootRearing(f,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    elseif strcmp(funcSootSex{f,1},'Female') == true
        scatter(funcSootXinds(f,1).*3,funcSootRearing(f,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e3 = errorbar(3,funcSootRearing_mean,funcSootRearing_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
e3.Color = 'black';
maleScatter = scatter(0,NaN,'s','MarkerEdgeColor','k','MarkerFaceColor','w');
femaleScatter = scatter(0,NaN,'c','MarkerEdgeColor','k','MarkerFaceColor','w');
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0,4])
ylabel('Linked rearing events')
ylim([0,350])
legend([e1,e2,e3,maleScatter,femaleScatter],'H2O','Soot2040','Soot2040F','Male','Female')
% distance traveled
ax2 = subplot(1,2,2);
for d = 1:length(waterDistance)
    if strcmp(waterSex{d,1},'Male') == true
        scatter(waterXinds(d,1).*1,waterDistance(d,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    elseif strcmp(waterSex{d,1},'Female') == true
        scatter(waterXinds(d,1).*1,waterDistance(d,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e1 = errorbar(1,waterDistance_mean,waterDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
e1.Color = 'black';
for e = 1:length(sootDistance)
    if strcmp(sootSex{e,1},'Male') == true
        scatter(sootXinds(e,1).*2,sootDistance(e,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    elseif strcmp(sootSex{e,1},'Female') == true
        scatter(sootXinds(e,1).*2,sootDistance(e,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e2 = errorbar(2,sootDistance_mean,sootDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
e2.Color = 'black';
for f = 1:length(funcSootDistance)
    if strcmp(funcSootSex{f,1},'Male') == true
        scatter(funcSootXinds(f,1).*3,funcSootDistance(f,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    elseif strcmp(funcSootSex{f,1},'Female') == true
        scatter(funcSootXinds(f,1).*3,funcSootDistance(f,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e3 = errorbar(3,funcSootDistance_mean,funcSootDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
e3.Color = 'black';
maleScatter = scatter(0,NaN,'s','MarkerEdgeColor','k','MarkerFaceColor','w');
femaleScatter = scatter(0,NaN,'c','MarkerEdgeColor','k','MarkerFaceColor','w');
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
xlim([0,4])
ylabel('Distance traveled (m)')
ylim([0,55])
legend([e1,e2,e3,maleScatter,femaleScatter],'H2O','Soot2040','Soot2040F','Male','Female')
