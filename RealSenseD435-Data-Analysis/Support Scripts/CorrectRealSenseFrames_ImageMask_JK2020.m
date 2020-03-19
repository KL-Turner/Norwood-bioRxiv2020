function [] = CorrectRealSenseFrames_ImageMask_JK2020(depthStackFile,supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: ignore pixels outside of image mask of cage
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Image Mask'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_ImageMask_' depthStackFile(end - 4:end)],'file')
    holeImgStackFile = [depthStackFile(1:end - 21) '_PatchedHoles_' depthStackFile(end - 4:end)];
    load(holeImgStackFile)
    load(supplementalFile)    
    % overlay cage mask on each frame
    imgMaskStack = zeros(size(holeImgStack,1),size(holeImgStack,2),size(holeImgStack,3)); %#ok<*USENS>
    for b = 1:size(holeImgStack,3)
        disp(['Overlaying cage ROI mask on image... (' num2str(b) '/' num2str(length(holeImgStack)) ')']); disp(' ')
        imgMaskStack(:,:,b) = holeImgStack(:,:,b).*SuppData.binCageImg;
    end
    save([depthStackFile(1:end - 21) '_ImageMask_' depthStackFile(end - 4:end)],'imgMaskStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_ImageMask ' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end

