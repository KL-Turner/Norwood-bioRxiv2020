function [] = CorrectRealSenseFrames_PatchHoles_JK2020(depthStackFile, supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: fill holes in the depth stack with outside-in interpolation
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Patch Holes'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_PatchedHoles_' depthStackFile(end - 4:end)],'file')
    depthStackStruct = load(depthStackFile);
    structField = fieldnames(depthStackStruct);
    depthStack = depthStackStruct.(structField{1,1});
    load(supplementalFile);   
    % fill image holes with interpolated values, outside -> in
    allImgs = cell(length(depthStack),1);
    for a = 1:length(depthStack)
        disp(['Filling image holes... (' num2str(a) '/' num2str(length(depthStack)) ')']); disp(' ') 
        image = depthStack{a,1};
        maxIndeces = image >= (SuppData.mouseBodyVal + 0.15);
        subIndeces = image <= (SuppData.mouseBodyVal - 0.15);
        image(maxIndeces) = 0;
        image(subIndeces) = 0;
        zeroIndeces = image == 0;
        allImgs{a,1} = regionfill(image,zeroIndeces);
    end
    holeImgStack = cat(3,allImgs{:});
    save([depthStackFile(1:end - 21) '_PatchedHoles_' depthStackFile(end - 4:end)],'holeImgStack','-v7.3')
    % determine caxis scaling final movie
    disp('Determining proper caxis scaling...'); disp(' ')
    tempMax = zeros(1,size(holeImgStack,3));
    tempMin = zeros(1,size(holeImgStack,3));
    for c = 1:length(holeImgStack)
        tempImg = holeImgStack(:,:,c);
        tempMax(1,c) = max(tempImg(:));
        tempMin(1,c) = min(tempImg(:));
    end
    SuppData.(structField{1,1}).caxis = [mean(tempMin),mean(tempMax)];
    % create cage image mask
    disp('Creating image mask...'); disp(' ')
    figure;
    shell = zeros(size(zeroIndeces));
    imagesc(shell)
    hold on;
    axis off
    mask = rectangle('Position',SuppData.cage,'Curvature',0.25,'FaceColor','white','EdgeColor','white'); %#ok<NASGU>
    frame = getframe(gca);
    maskImg = frame2im(frame);
    greyImg = rgb2gray(maskImg);
    resizedGreyImg = imresize(greyImg,[480,640]);
    SuppData.binCageImg = imbinarize(resizedGreyImg);
    close(gcf)
    save(supplementalFile,'SuppData')   
else
    disp([depthStackFile(1:end - 21) '_PatchedHoles_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
