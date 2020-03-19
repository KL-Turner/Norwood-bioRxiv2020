%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: track height of the mouse using the depth stack
%________________________________________________________________________________________________________________________

SuppData.samplingRate = 15;
sootDataFile = 'SootExperimentDataSheet.xlsx';
[~,~,allData] = xlsread(sootDataFile);
animalIDs = allData(2:end,1);
for q = 1:length(animalIDs)
    animalID = animalIDs{q,1};
    if strcmp(animalID,'JK_soot107')
        keyboard
    end
    threshHeight = 3;   % cm
    mouseHeight = AnalysisResults.(animalID).Rearing.avg20Height';
    X = ~isnan(mouseHeight);
    Y = cumsum(X - diff([1,X])/2);
    adjustedHeight = interp1(1:nnz(X),mouseHeight(X),Y);
    if sum(isnan(adjustedHeight)) > 0
        nanInds = isnan(adjustedHeight);
        nonnanInds = ~isnan(adjustedHeight);
        realVals = adjustedHeight(nonnanInds);
        tempDescendPixelVals = sort(realVals(:),'descend');
        tempBaseline = mean(tempDescendPixelVals(1:ceil(length(realVals)*0.3)));
        adjustedHeight(nanInds) = tempBaseline;
    end
    descendPixelVals = sort(adjustedHeight(:),'descend');
    baseline = mean(descendPixelVals(1:ceil(length(adjustedHeight)*0.3)));
    positiveVals = adjustedHeight <= (baseline - threshHeight);
    changes = diff(positiveVals);
    AnalysisResults.(animalID).Rearing.rearingEvents = sum(ismember(changes,1));
    AnalysisResults.(animalID).Rearing.totalRearingTime = sum(positiveVals)*(1/SuppData.samplingRate);   % seconds
    % determine duration of each rearing event
    prevVal = 0;
    b = 1;
    rearingDurations = [];
    for a = 1:length(positiveVals)
        curVal = positiveVals(1,a);
        if curVal == 0 && prevVal == 1
            b = b + 1;
            prevVal = 0;
        elseif curVal == 1 && prevVal == 1
            rearingDurations{b,1} = horzcat(rearingDurations{b,1},curVal);
            prevVal = 1;
        elseif curVal == 1
            rearingDurations{b,1} = 1;
            prevVal = 1;
        elseif curVal == 0
            prevVal = 0;
        end
    end
    % sum up each event
    rearingDurationTimes = zeros(length(rearingDurations),1);
    for c = 1:length(rearingDurations)
        rearingDurationTimes(c,1) = sum(rearingDurations{c,1})*(1/SuppData.samplingRate);
    end
    AnalysisResults.(animalID).Rearing.rearingDurations = rearingDurationTimes;
end
% save results
save('AnalysisResults.mat','AnalysisResults')

