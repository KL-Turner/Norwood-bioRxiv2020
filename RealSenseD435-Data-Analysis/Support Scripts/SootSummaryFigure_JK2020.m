function [] = SootSummaryFigure_JK2020(AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpose: create a summary figure (3) showing differences in rearing and distance traveled between treatment conditions
%________________________________________________________________________________________________________________________

%% get file animal treament information
sootDataFile = 'SootExperimentDataSheet.xlsx';
[~,~,allData] = xlsread(sootDataFile);
animalIDs = allData(2:end,1);
colorA = [(51/256),(160/256),(44/256)];   % H2O color
colorB = [(192/256),(0/256),(256/256)];   % Soot2040 color
colorC = [(255/256),(140/256),(0/256)];   % Soot2040F color
%% extract relevant data from results structure
rearingEvents = cell(length(animalIDs),1);
rearingTime = cell(length(animalIDs),1);
rearingDurations = cell(length(animalIDs),1);
distanceTraveled = cell(length(animalIDs),1);
distancePath = cell(length(animalIDs),1);
for aa = 1:length(animalIDs)
    animalID = animalIDs{aa,1};
    rearingEvents{aa,1} = AnalysisResults.(animalID).Rearing.rearingEvents;
    rearingTime{aa,1} = AnalysisResults.(animalID).Rearing.totalRearingTime;
    rearingDurations{aa,1} = AnalysisResults.(animalID).Rearing.rearingDurations;
    distanceTraveled{aa,1} = AnalysisResults.(animalID).Distance.distanceTraveled;
    distancePath{aa,1} = AnalysisResults.(animalID).Distance.distancePath;
end
%% separate data by each condition
cc1 = 1; cc2 = 1; cc3 = 1;
for bb = 1:length(rearingEvents)
    if strcmp(allData{bb + 1,4},'H2O') == true
        waterMice{cc1,1} = allData{bb + 1,1};
        waterRearingEvents(cc1,1) = rearingEvents{bb,1}; %#ok<*AGROW>
        waterRearingTime(cc1,1) = rearingTime{bb,1};
        waterRearingDurations{cc1,1} = rearingDurations{bb,1};
        waterDistance(cc1,1) = distanceTraveled{bb,1};
%         waterDistancePath{cc1,1} = distancePath{bb,1}; 
        waterSex{cc1,1} = allData{bb + 1,3};
        waterTreatments{cc1,1} = 'H2O';
        cc1 = cc1 + 1 ;
    elseif strcmp(allData{bb + 1,4},'Soot2040') == true
        sootMice{cc2,1} = allData{bb + 1,1};
        sootRearingEvents(cc2,1) = rearingEvents{bb,1};
        sootRearingTime(cc2,1) = rearingTime{bb,1};
        sootRearingDurations{cc2,1} = rearingDurations{bb,1};
        sootDistance(cc2,1) = distanceTraveled{bb,1};
%         sootDistancePath{cc2,1} = distancePath{bb,1}; 
        sootSex{cc2,1} = allData{bb + 1,3};
        sootTreatments{cc2,1} = 'Soot2040';
        cc2 = cc2 + 1;
    elseif strcmp(allData{bb + 1,4},'Soot2040F') == true
        funcSootMice{cc3,1} = allData{bb + 1,1};
        funcSootRearingEvents(cc3,1) = rearingEvents{bb,1};
        funcSootRearingTime(cc3,1) = rearingTime{bb,1};
        funcSootRearingDurations{cc3,1} = rearingDurations{bb,1};
        funcSootDistance(cc3,1) = distanceTraveled{bb,1};
%         funcSootDistancePath{cc3,1} = distancePath{bb,1}; 
        funcSootSex{cc3,1} = allData{bb + 1,3};
        funcSootTreatments{cc3,1} = 'Soot2040F';
        cc3 = cc3 + 1;
    end
end
%% calculate mean and standard error
% water control
waterRearingEvents_mean = mean(waterRearingEvents);
waterRearingEvents_StErr = std(waterRearingEvents)/sqrt(length(waterRearingEvents));
waterRearingTime_mean = mean(waterRearingTime);
waterRearingTime_StErr = std(waterRearingTime)/sqrt(length(waterRearingTime));
waterAllRearingDurations = cell2mat(waterRearingDurations);
waterDistance_mean = mean(waterDistance);
waterDistance_StErr = std(waterDistance)/sqrt(length(waterDistance));
% waterDistancePath_mean = mean(cell2mat(waterDistancePath),1);
waterXinds = ones(length(waterRearingEvents),1);
% soot
sootRearingEvents_mean = mean(sootRearingEvents);
sootRearingEvents_StErr = std(sootRearingEvents)/sqrt(length(sootRearingEvents));
sootRearingTime_mean = mean(sootRearingTime);
sootRearingTime_StErr = std(sootRearingTime)/sqrt(length(sootRearingTime));
sootAllRearingDurations = cell2mat(sootRearingDurations);
sootDistance_mean = mean(sootDistance);
sootDistance_StErr = std(sootDistance)/sqrt(length(sootDistance));
% sootDistancePath_mean = mean(cell2mat(sootDistancePath),1);
sootXinds = ones(length(sootRearingEvents),1);
% functionalized soot
funcSootRearingEvents_mean = mean(funcSootRearingEvents);
funcSootRearingEvents_StErr = std(funcSootRearingEvents)/sqrt(length(funcSootRearingEvents));
funcSootRearingTime_mean = mean(funcSootRearingTime);
funcSootRearingTime_StErr = std(funcSootRearingTime)/sqrt(length(funcSootRearingTime));
funcSootAllRearingDurations = cell2mat(funcSootRearingDurations);
funcSootDistance_mean = mean(funcSootDistance);
funcSootDistance_StErr = std(funcSootDistance)/sqrt(length(funcSootDistance));
% funcSootDistancePath_mean = mean(cell2mat(funcSootDistancePath),1);
funcSootXinds = ones(length(funcSootRearingEvents),1);
%% statistics - linear mixed effects model
% rearing event stats
rearingEventTable = table('Size',[length(animalIDs),4],'VariableTypes',{'string','double','string','string'},'VariableNames',{'Mouse','Events','Treatment','Sex'});
rearingEventTable.Mouse = cat(1,waterMice,sootMice,funcSootMice);
rearingEventTable.Events = cat(1,waterRearingEvents,sootRearingEvents,funcSootRearingEvents);
rearingEventTable.Treatment = cat(1,waterTreatments,sootTreatments,funcSootTreatments);
rearingEventTable.Sex = cat(1,waterSex,sootSex,funcSootSex);
rearingFitFormula = 'Events ~ 1 + Treatment + (1|Mouse) + (1|Sex)';
rearingStats = fitglme(rearingEventTable,rearingFitFormula);
rearingCI = coefCI(rearingStats,'Alpha',.025);
% rearing duration stats
rearingDurationTable = table('Size',[length(animalIDs),4],'VariableTypes',{'string','double','string','string'},'VariableNames',{'Mouse','Duration','Treatment','Sex'});
rearingDurationTable.Mouse = cat(1,waterMice,sootMice,funcSootMice);
rearingDurationTable.Duration = cat(1,waterRearingTime,sootRearingTime,funcSootRearingTime);
rearingDurationTable.Treatment = cat(1,waterTreatments,sootTreatments,funcSootTreatments);
rearingDurationTable.Sex = cat(1,waterSex,sootSex,funcSootSex);
durationFitFormula = 'Duration ~ 1 + Treatment + (1|Mouse) + (1|Sex)';
durationStats = fitglme(rearingDurationTable,durationFitFormula);
durationCI = coefCI(durationStats,'Alpha',.025);
% distance traveled stats
distanceTraveledTable = table('Size',[length(animalIDs),4],'VariableTypes',{'string','double','string','string'},'VariableNames',{'Mouse','Distance','Treatment','Sex'});
distanceTraveledTable.Mouse = cat(1,waterMice,sootMice,funcSootMice);
distanceTraveledTable.Distance = cat(1,waterDistance,sootDistance,funcSootDistance);
distanceTraveledTable.Treatment = cat(1,waterTreatments,sootTreatments,funcSootTreatments);
distanceTraveledTable.Sex = cat(1,waterSex,sootSex,funcSootSex);
distanceFitFormula = 'Distance ~ 1 + Treatment + (1|Mouse) + (1|Sex)';
distanceStats = fitglme(distanceTraveledTable,distanceFitFormula);
distanceCI = coefCI(distanceStats,'Alpha',.025);
%% summary figure
% rearing events
summaryFigure = figure;
subplot(2,2,1);
for dd = 1:length(waterRearingEvents)
    if strcmp(waterSex{dd,1},'Male') == true
        scatter(waterXinds(dd,1).*1,waterRearingEvents(dd,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    elseif strcmp(waterSex{dd,1},'Female') == true
        scatter(waterXinds(dd,1).*1,waterRearingEvents(dd,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e1 = errorbar(1,waterRearingEvents_mean,waterRearingEvents_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
e1.Color = 'black';
for ee = 1:length(sootRearingEvents)
    if strcmp(sootSex{ee,1},'Male') == true
        scatter(sootXinds(ee,1).*2,sootRearingEvents(ee,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    elseif strcmp(sootSex{ee,1},'Female') == true
        scatter(sootXinds(ee,1).*2,sootRearingEvents(ee,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e2 = errorbar(2,sootRearingEvents_mean,sootRearingEvents_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
e2.Color = 'black';
for ff = 1:length(funcSootRearingEvents)
    if strcmp(funcSootSex{ff,1},'Male') == true
        scatter(funcSootXinds(ff,1).*3,funcSootRearingEvents(ff,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    elseif strcmp(funcSootSex{ff,1},'Female') == true
        scatter(funcSootXinds(ff,1).*3,funcSootRearingEvents(ff,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e3 = errorbar(3,funcSootRearingEvents_mean,funcSootRearingEvents_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
e3.Color = 'black';
maleScatter = scatter(0,NaN,'s','MarkerEdgeColor','k','MarkerFaceColor','w');
femaleScatter = scatter(0,NaN,'c','MarkerEdgeColor','k','MarkerFaceColor','w');
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'box','off')
xlim([0,4])
ylabel('Linked rearing events')
title('[3a] rearing events')
ylim([0,350])
legend([e1,e2,e3,maleScatter,femaleScatter],'H2O','Soot2040','Soot2040F','Male','Female')
% rearing time
subplot(2,2,2);
for gg = 1:length(waterRearingTime)
    if strcmp(waterSex{gg,1},'Male') == true
        scatter(waterXinds(gg,1).*1,waterRearingTime(gg,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    elseif strcmp(waterSex{gg,1},'Female') == true
        scatter(waterXinds(gg,1).*1,waterRearingTime(gg,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e1 = errorbar(1,waterRearingTime_mean,waterRearingTime_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
e1.Color = 'black';
for hh = 1:length(sootRearingTime)
    if strcmp(sootSex{hh,1},'Male') == true
        scatter(sootXinds(hh,1).*2,sootRearingTime(hh,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    elseif strcmp(sootSex{hh,1},'Female') == true
        scatter(sootXinds(hh,1).*2,sootRearingTime(hh,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e2 = errorbar(2,sootRearingTime_mean,sootRearingTime_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
e2.Color = 'black';
for ii = 1:length(funcSootRearingTime)
    if strcmp(funcSootSex{ii,1},'Male') == true
        scatter(funcSootXinds(ii,1).*3,funcSootRearingTime(ii,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    elseif strcmp(funcSootSex{ii,1},'Female') == true
        scatter(funcSootXinds(ii,1).*3,funcSootRearingTime(ii,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e3 = errorbar(3,funcSootRearingTime_mean,funcSootRearingTime_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
e3.Color = 'black';
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'box','off')
xlim([0,4])
ylabel('Total rearing time (s)')
title('[3b] rearing duration')
ylim([0,450])
% rearing event durations
subplot(2,2,3)
edges = 0:0.5:3;
[curve1] = SmoothHistogramBins_Manuscript2020(waterAllRearingDurations,edges);
[curve2] = SmoothHistogramBins_Manuscript2020(sootAllRearingDurations,edges);
[curve3] = SmoothHistogramBins_Manuscript2020(funcSootAllRearingDurations,edges);
before = findall(gca);
fnplt(curve1);
added = setdiff(findall(gca),before);
set(added,'Color',colorA)
hold on
before = findall(gca);
fnplt(curve2);
added = setdiff(findall(gca),before);
set(added,'Color',colorB)
before = findall(gca);
fnplt(curve3);
added = setdiff(findall(gca),before);
set(added,'Color',colorC)
xlabel('Rearing duration (s)')
ylabel('Probability')
title('[3c] rearing events duration')
axis square
set(gca,'box','off')
axis tight
% distance traveled
subplot(2,2,4);
for dd = 1:length(waterDistance)
    if strcmp(waterSex{dd,1},'Male') == true
        scatter(waterXinds(dd,1).*1,waterDistance(dd,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    elseif strcmp(waterSex{dd,1},'Female') == true
        scatter(waterXinds(dd,1).*1,waterDistance(dd,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorA,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e1 = errorbar(1,waterDistance_mean,waterDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorA);
e1.Color = 'black';
for ee = 1:length(sootDistance)
    if strcmp(sootSex{ee,1},'Male') == true
        scatter(sootXinds(ee,1).*2,sootDistance(ee,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    elseif strcmp(sootSex{ee,1},'Female') == true
        scatter(sootXinds(ee,1).*2,sootDistance(ee,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorB,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e2 = errorbar(2,sootDistance_mean,sootDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorB);
e2.Color = 'black';
for ff = 1:length(funcSootDistance)
    if strcmp(funcSootSex{ff,1},'Male') == true
        scatter(funcSootXinds(ff,1).*3,funcSootDistance(ff,1),100,'s','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    elseif strcmp(funcSootSex{ff,1},'Female') == true
        scatter(funcSootXinds(ff,1).*3,funcSootDistance(ff,1),100,'c','MarkerEdgeColor','k','MarkerFaceColor',colorC,'jitter','on','jitterAmount',0.25);
    end
    hold on
end
e3 = errorbar(3,funcSootDistance_mean,funcSootDistance_StErr,'d','MarkerSize',10,'MarkerEdgeColor','k','MarkerFaceColor',colorC);
e3.Color = 'black';
axis square
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'box','off')
xlim([0,4])
ylabel('Distance traveled (m)')
title('[3d] distance traveled')
ylim([0,55])
%% save figure(s)
savefig(summaryFigure,'Fig3_Norwood2020');
set(summaryFigure,'PaperPositionMode','auto');
print('-painters','-dpdf','-fillpage','Fig3_Norwood2020')
%% statistical diary
diaryFile = 'Fig3_Stats_Norwood2020.txt';
if exist(diaryFile,'file') == 2
    delete(diaryFile)
end
diary(diaryFile)
diary on
% HbT statistical diary
disp('======================================================================================================================')
disp('[3a] Generalized linear mixed-effects model statistics for rearing events following soot treatment')
disp('======================================================================================================================')
disp(rearingStats)
disp('----------------------------------------------------------------------------------------------------------------------')
disp('Alpha = 0.001 confidence interval with 3 comparisons to ''Rest'' (Intercept): ')
disp(['Water: ' num2str(rearingCI(1,:))])
disp(['Soot2040: ' num2str(rearingCI(2,:))])
disp(['Soot2040F: ' num2str(rearingCI(3,:))])
% gamma statistical diary
disp('======================================================================================================================')
disp('[3b] Generalized linear mixed-effects model statistics for rearing duration following soot treatment')
disp('======================================================================================================================')
disp(durationStats)
disp('----------------------------------------------------------------------------------------------------------------------')
disp('Alpha = 0.05 confidence interval with 3 comparisons to ''Rest'' (Intercept): ')
disp(['Water: ' num2str(durationCI(1,:))])
disp(['Soot2040: ' num2str(durationCI(2,:))])
disp(['Soot2040F: ' num2str(durationCI(3,:))])
disp('======================================================================================================================')
% gamma statistical diary
disp('======================================================================================================================')
disp('[3d] Generalized linear mixed-effects model statistics for distance traveled following soot treatment')
disp('======================================================================================================================')
disp(distanceStats)
disp('----------------------------------------------------------------------------------------------------------------------')
disp('Alpha = 0.05 confidence interval with 2 comparisons to ''Untreated'' (Intercept): ')
disp(['Water: ' num2str(distanceCI(1,:))])
disp(['Soot2040: ' num2str(distanceCI(2,:))])
disp(['Soot2040F: ' num2str(distanceCI(3,:))])
disp('======================================================================================================================')
diary off

end
