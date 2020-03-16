SuppData.samplingRate = 15;
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
    tempBaseline = mean(tempDescendPixelVals(1:ceil(length(realVals)*0.3)));
    adjustedHeight(nanInds) = tempBaseline;
end
descendPixelVals = sort(adjustedHeight(:),'descend');
baseline = mean(descendPixelVals(1:ceil(length(adjustedHeight)*0.3)));
positiveVals = adjustedHeight <= (baseline - threshHeight);
changes = diff(positiveVals);
rearingEvents = sum(ismember(changes,1));
totalRearingTime = sum(changes)*(1/SuppData.samplingRate);   % seconds
%
prevVal = 0;
b = 1;
rearingDurations{b,1} = [];
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
% 
rearingDurationTimes = zeros(length(rearingDurations),1);
for c = 1:length(rearingDurations)
    rearingDurationTimes(c,1) = sum(rearingDurations{c,1})*(1/SuppData.samplingRate);
end
