function [] = CorrectRealSenseFrames_Binarize_JK2020(depthStackFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: set remaining pixels back to zero
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Binarize'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_Binarize_' depthStackFile(end - 4:end)],'file')
    thresholdStackFile = [depthStackFile(1:end - 21) '_Threshold_' depthStackFile(end - 4:end)];
    load(thresholdStackFile)
    %% set remaining pixels above threshold = to zero
    binImgStack = zeros(size(threshImgStack,1),size(threshImgStack,2),size(threshImgStack,3)); %#ok<*USENS>
    for a = 1:size(threshImgStack,3)
        disp(['Converting to grayscale and binarizing image... (' num2str(a) '/' num2str(size(threshImgStack,3)) ')']); disp(' ')
        binImgStack(:,:,a) = imfill(bwareaopen(imcomplement(imbinarize(mat2gray(threshImgStack(:,:,a)))),1500),'holes');
    end
    save([depthStackFile(1:end - 21) '_Binarize_' depthStackFile(end - 4:end)],'binImgStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_Binarize_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
