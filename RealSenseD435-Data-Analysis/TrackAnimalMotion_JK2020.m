function [AnalysisResults] = TrackAnimalMotion_JK2020(animalID,saveFigs,rootFolder,AnalysisResults)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: track centroid of mouse to determine distance traveled
%________________________________________________________________________________________________________________________

dataLocation = [rootFolder '/' animalID '/'];
cd(dataLocation)
% find and load SupplementalData.mat struct
suppDataFileStruct = dir('*_SupplementalData.mat');
suppDataFile = {suppDataFileStruct.name}';
suppDataFileID = char(suppDataFile);
load(suppDataFileID,'-mat');
% find and load BinDepthStack.mat struct
binStackFileStruct = dir('*_BinDepthStack.mat');
binStackDataFile = {binStackFileStruct.name}';
binStackDataFileID = char(binStackDataFile);
load(binStackDataFileID,'-mat');
% go through each frame and track the centroid of the mouse
binWidth = 14;   % inches
distanceTraveled = 0;
distancePath = zeros(1,length(binDepthStack));
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
distancePerPixel = (binWidth/SuppData.binWidth)*2.54*0.01;   % in to cm to m
AnalysisResults.(animalID).Distance.distanceTraveled = distanceTraveled*distancePerPixel;
AnalysisResults.(animalID).Distance.distancePath = distancePath.*distancePerPixel;
% show summary figure
if strcmp(saveFigs,'y') == true
    animalDistance = figure;
    animalIDrep = strrep(animalID,'_',' ');
    plot((1:length(distancePath))/SuppData.samplingRate,distancePath.*distancePerPixel,'color','k','LineWidth',2)
    title([animalIDrep ' distance path'])
    ylabel('Distance traveled (m)')
    xlabel('~Time (sec)')
    set(gca,'box','off')
    % save figure
    [pathstr,~,~] = fileparts(cd);
    dirpath = [pathstr '/' animalID '/Figures/'];
    if ~exist(dirpath,'dir')
        mkdir(dirpath);
    end
    savefig(animalDistance,[dirpath animalID '_DistanceTraveled']);
    close(animalDistance)
end
% save results
cd(rootFolder)
save('AnalysisResults.mat','AnalysisResults')

end
