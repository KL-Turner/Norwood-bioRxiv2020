function [] = DrawAnalysisROIs_JK2020(depthStackFile,supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: load a frame of the image stack to draw ROIs for image processing
%________________________________________________________________________________________________________________________

load(depthStackFile)
frame = DepthStack{1,1}; %#ok<*USENS>
load(supplementalFile)
% cage region of interest
yString = 'y';
theInput = 'n';
while strcmp(yString,theInput) ~= 1
    % Draw ROI
    disp('Draw a rectanglular ROI around the cage'); disp(' ')
    drawROI = figure;
    imagesc(frame)
    title('Click and drag a box around the cage');
    axis image
    axis off
    cageROI = drawrectangle();
    SuppData.cage = cageROI.Position;
    close(drawROI)  
    % verify ROI
    checkROI = figure;
    imagesc(frame);
    hold on;
    cageRectangle = SuppData.cage;
    rectangle('Position',cageRectangle,'Curvature',0.25,'LineWidth',3,'EdgeColor','white')
    title('White box shows the cage ROI');
    axis image
    axis off
    theInput = input('Is the cage ROI accurate? (y/n): ','s'); disp(' ')
    try
        close(checkROI)
    catch
    end
end
% mouse region of interest
yString = 'y';
theInput = 'n';
while strcmp(yString,theInput) ~= 1   
    % Draw ROI
    disp('Draw an ROI around the mouse'); disp(' ')
    drawROI = figure;
    imagesc(frame)
    title('Click and drag an ROI around the mouse');
    colormap jet
    axis image
    axis off
    [mouseROI,xi,yi] = roipoly();
    SuppData.mouseBodyVal = mean(frame(mouseROI));
    close(drawROI)
    % verify ROI
    checkROI = figure;
    imagesc(frame)
    hold on
    plot(xi,yi,'w','LineWidth',3)
    title('White polygon shows the mouse ROI')
    colormap jet
    axis image
    axis off
    theInput = input('Is the mouse ROI accurate? (y/n): ','s'); disp(' ')    
    try
        close(checkROI)
    catch
    end
end
% bin width line
yString = 'y';
theInput = 'n';
while strcmp(yString,theInput) ~= 1  
    % Draw ROI
    disp('Draw a line the width of the bin'); disp(' ')
    drawROI = figure;
    imagesc(frame)
    title('Click and drag a line the width of the bin');
    colormap jet
    axis image
    axis off
    hold on
    p1=[200,1];
    p2=[200,640];
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2)
    cageLine = drawline();
    L1 = cageLine.Position(1);
    L2 = cageLine.Position(2);
    close(drawROI)  
    % verify ROI
    checkROI = figure;
    imagesc(frame)
    colormap jet
    hold on
    p1=[200,L1];
    p2=[200,L2];
    plot([p1(2),p2(2)],[p1(1),p2(1)],'Color','w','LineWidth',2)
    axis image
    axis off
    binWidth = abs(round(L2) - round(L1));
    disp(['Bin width (pixels): ' num2str(binWidth)]); disp(' ')
    SuppData.binWidth = binWidth;
    theInput = input('Is the bin width accurate? (y/n): ','s'); disp(' ')   
    try
        close(checkROI)
    catch
    end
end
% save structures
save(supplementalFile,'SuppData')
% split stack into 3 because this hot mess requires a silly amount of RAM
depthStack_A = DepthStack(1:6000);
depthStack_B = DepthStack(6001:12000);
depthStack_C = DepthStack(12001:18000);
save([depthStackFile(1:end - 15) '_TrueDepthStack_A.mat'],'depthStack_A','-v7.3');
save([depthStackFile(1:end - 15) '_TrueDepthStack_B.mat'],'depthStack_B','-v7.3');
save([depthStackFile(1:end - 15) '_TrueDepthStack_C.mat'],'depthStack_C','-v7.3');

end

