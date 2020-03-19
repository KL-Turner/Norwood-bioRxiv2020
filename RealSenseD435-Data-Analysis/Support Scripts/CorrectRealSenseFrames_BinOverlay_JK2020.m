function [] = CorrectRealSenseFrames_BinOverlay_JK2020(depthStackFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: Overlays the depth image with processed binary image
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Binary Overlay'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_BinOverlay_' depthStackFile(end - 4:end)],'file')
    binStackFile = [depthStackFile(1:end - 21) '_Binarize_' depthStackFile(end - 4:end)];
    load(binStackFile)
    holeStackFile = [depthStackFile(1:end - 21) '_PatchedHoles_' depthStackFile(end - 4:end)];
    load(holeStackFile)
    % overlay the depth image with the processed binary image
    binOverlayImgStack = zeros(size(binImgStack,1),size(binImgStack,2),size(binImgStack,3)); %#ok<*USENS>
    for a = 1:size(binImgStack,3)
        disp(['Overlaying original depth on binarized image... (' num2str(a) '/' num2str(length(binImgStack)) ')']); disp(' ')
        binOverlayImgStack(:,:,a) = holeImgStack(:,:,a).*binImgStack(:,:,a);
    end
    save([depthStackFile(1:end - 21) '_BinOverlay_' depthStackFile(end - 4:end)],'binOverlayImgStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_BinOverlay_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
