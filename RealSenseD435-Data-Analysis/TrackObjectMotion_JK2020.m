function [] = TrackObjectMotion(binDepthStackFile,supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: track centroid of mouse to determine distance traveled
%________________________________________________________________________________________________________________________

disp('Tracking object motion...'); disp(' ')
resultsFile = [supplementalFile(1:end - 20) 'Results.mat'];
load(binDepthStackFile)
load(supplementalFile)
load(resultsFile)
distanceTraveled = 0;
distancePath = zeros(1,length(binDepthStack)); %#ok<*USENS>
for x = 1:length(binDepthStack)
    if x == length(binDepthStack)
        distancePath(1,x) = distanceTraveled;
    else
        imageA = binDepthStack(:,:,x);
        [yA,xA] = ndgrid(1:size(imageA,1),1:size(imageA,2));
        centroidA = mean([xA(logical(imageA)),yA(logical(imageA))]);       
        imageB = binDepthStack(:,:,x + 1);
        [yB,xB] = ndgrid(1:size(imageB,1),1:size(imageB,2));
        centroidB = mean([xB(logical(imageB)),yB(logical(imageB))]);       
        centroidCoord = [centroidB;centroidA];
        distance = pdist(centroidCoord,'euclidean');
        if isnan(distance) == true
            distance = 0;
        end
        distanceTraveled = distanceTraveled + distance;
        distancePath(1,x) = distanceTraveled;
    end
end
% show summary figure
figure;
plot((1:length(distancePath))/SuppData.samplingRate,distancePath)
title('Distance traveled')
ylabel('Pixels')
xlabel('~Time (sec)')
% save results
Results.distanceTraveled = distanceTraveled;
Results.distancePath = distancePath;
save(resultsFile,'Results')

end
