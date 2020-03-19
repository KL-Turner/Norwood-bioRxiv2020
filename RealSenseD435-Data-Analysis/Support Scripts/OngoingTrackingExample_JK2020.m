%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: create avi movies of data showing original RGB/Depth streams compared to processed data with a tracking example
%________________________________________________________________________________________________________________________

clear; clc;
%% load eample data from animal JK_soot098
load('JK_soot098_20_Feb_2020_13_16_30_Binarize_C.mat')
binStack = binImgStack(:,:,1:1000);
load('JK_soot098_20_Feb_2020_13_16_30_ProcDepthStack_C.mat')
procStack = procImgStack(:,:,1:1000);
load('JK_soot098_20_Feb_2020_13_16_30_RGBStack.mat')
rgbStack = RGBStack(12001:13000,1);
% load('JK_soot098_20_Feb_2020_13_16_30_TrueDepthStack_C.mat')
% originalStack = depthStack_C(1:1000,1);
load('JK_soot098_20_Feb_2020_13_16_30_SupplementalData.mat')
% %% movie file comparing rgb with original data
% outputVideo = VideoWriter('RGBvsOriginalDepth.avi');
% fps = 15;   % default fps from video acquisition
% speedUp = 2;   % speed up by factor of
% outputVideo.FrameRate = fps*speedUp;
% open(outputVideo);
% fig = figure('Position',get(0,'Screensize'));
% for a = 1:size(rgbStack,1)
%     subplot(1,2,1)
%     imshow(rgbStack{a,1})
%     subplot(1,2,2)
%     imagesc(originalStack{a,1});
%     colormap jet
%     caxis([0,.52])
%     axis image
%     axis off
%     currentFrame = getframe(fig);
%     writeVideo(outputVideo, currentFrame);
% end
% close(outputVideo)
% close(fig)
%% movie file comparing rgb with processed data
outputVideo = VideoWriter('RGBvsProcDepth.avi');
fps = 15;   % default fps from video acquisition
speedUp = 2;   % speed up by factor of
outputVideo.FrameRate = fps*speedUp;
open(outputVideo);
fig = figure('Position',get(0,'Screensize'));
for a = 1:size(rgbStack,1)
    subplot(1,2,1)
    imshow(rgbStack{a,1})
    subplot(1,2,2)
    image = (100.*procStack(:,:,a) - 100*SuppData.caxis(2)).*-1;
    imagesc(image);
    colormap jet
    c = caxis([0,12]);
    ylabel(c,'Mouse height (cm)')
    axis image
    axis off
    currentFrame = getframe(fig);
    writeVideo(outputVideo, currentFrame);
end
close(outputVideo)
close(fig)
%% movie file showing motion and height tracking
outputVideo = VideoWriter('TrackingExample.avi');
fps = 15;   % default fps from video acquisition
speedUp = 2;   % speed up by factor of
outputVideo.FrameRate = fps*speedUp;
open(outputVideo);
fig = figure('Position',get(0,'Screensize'));
avg20Height = NaN(1,length(binStack));
max_caxis = SuppData.caxis;
maxVal = max_caxis(2);
x = [];
y = [];
distanceTraveled = 0;
distancePath = NaN(1,length(binStack));
binWidth_inches = 14;
distancePerPixel = (binWidth_inches/SuppData.binWidth)*2.54;   % in to cm
for a = 1:size(binStack,3)
    %% Motion
    imageA = binStack(:,:,a);
    [yA,xA] = ndgrid(1:size(imageA,1),1:size(imageA,2));
    centroidA = mean([xA(logical(imageA)),yA(logical(imageA))]);
    x = horzcat(x,centroidA(1)); %#ok<*AGROW>
    y = horzcat(y,centroidA(2));
    if a > 1
        imageB = binStack(:,:,a - 1);
        [yB,xB] = ndgrid(1:size(imageB,1),1:size(imageB,2));
        centroidB = mean([xB(logical(imageB)),yB(logical(imageB))]);        
        centroidCoord = [centroidB;centroidA];
        d = pdist(centroidCoord,'euclidean');
        if isnan(d) == true
            d = 0;
        end
        distanceTraveled = distanceTraveled+d;
    end
    distancePath(1,a) = distanceTraveled;
    %% Rearing
    depthImg = procStack(:,:,a);
    maxInds = depthImg == maxVal;
    depthImg(maxInds) = NaN;
    validPix = imcomplement(isnan(depthImg));
    pixelVec = depthImg(validPix);
    ascendPixelVals = sort(pixelVec(:),'ascend');
    twentyPercentile = ascendPixelVals(1:ceil(length(ascendPixelVals)*0.2));
    avg20Height(1,a) = mean(twentyPercentile);   
    %% figure
    subplot(2,2,[1,3])
    image = (100.*procStack(:,:,a) - 100*SuppData.caxis(2)).*-1;
    imagesc(image);
    colormap jet
    c = caxis([0,12]);
    ylabel(c,'Mouse height (cm)')
    axis image
    axis off
    hold on
    scatter(centroidA(1),centroidA(2),'MarkerEdgeColor','white','MarkerFaceColor','white')
    plot(x,y,'Color','w','LineWidth',2)  
    subplot(2,2,2)
    plot((1:size(binStack,3))/fps,(100*avg20Height - 100*maxVal)*-1,'k')
    title('Mouse height')
    ylabel('Height (cm)')
    xlabel('Time (s)')
    xlim([0,70])
    ylim([0,14])
    set(gca,'box','off')
    subplot(2,2,4)
    plot((1:size(binStack,3))/fps,distancePath.*distancePerPixel,'k')
    title('Distance traveled')
    ylabel('Distance (cm)')
    xlabel('Time (s)')
    xlim([0,70])
    set(gca,'box','off')
    currentFrame = getframe(fig);
    writeVideo(outputVideo, currentFrame);
end
close(outputVideo)
close(fig)
%% diagram and tracking figure
% rgb image
exampleFig = figure;
subplot(1,2,1)
imshow(rgbStack{750,1})
axis image
axis off
% depth image
image = (100.*procStack(:,:,750) - 100*SuppData.caxis(2)).*-1;
subplot(1,2,2)
imagesc(image);
colormap jet
caxis([0,12])
c = colorbar;
ylabel(c,'Mouse height (cm)')
axis image
axis off
hold on
scatter(centroidA(1), centroidA(2), 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'white')
plot(x(1:750),y(1:750),'Color','w','LineWidth',2)
savefig(exampleFig,'RearingExample');
close(exampleFig)
