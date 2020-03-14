function [] = CorrectRealSenseFrames_ResetDepth_JK2020(depthStackFile,supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: reset the depth of the processed stack to emphasize mouse's height
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Reset Depth'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_ProcDepthStack_' depthStackFile(end - 4:end)],'file')
    binOverlayStackFile = [depthStackFile(1:end - 21) '_BinOverlay_' depthStackFile(end - 4:end)];
    load(binOverlayStackFile)
    load(supplementalFile)    
    procImgStack = zeros(size(binOverlayImgStack,1),size(binOverlayImgStack,2),size(binOverlayImgStack,3)); %#ok<*USENS>
    for a = 1:size(binOverlayImgStack,3)
        disp(['Setting zero-pixels to desired colormap height in image... (' num2str(a) '/' num2str(length(binOverlayImgStack)) ')']); disp(' ')
        depthImg = binOverlayImgStack(:,:,a);
        logicalImg = depthImg == 0; 
        depthImg(logicalImg) = SuppData.caxis(2);
        procImgStack(:,:,a) = depthImg;
    end
    save([depthStackFile(1:end - 21) '_ProcDepthStack_' depthStackFile(end - 4:end)],'procImgStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_ProcDepthStack_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
