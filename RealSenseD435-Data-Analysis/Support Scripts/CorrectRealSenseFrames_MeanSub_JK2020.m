function [] = CorrectRealSenseFrames_MeanSub(depthStackFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: mean subtract the background image
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Mean Subtraction'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_MeanSub_' depthStackFile(end - 4:end)],'file')
    kalmanStackFile = [depthStackFile(1:end - 21) '_Kalman_' depthStackFile(end - 4:end)];
    load(kalmanStackFile)   
    % mean subtract background image
    pixelMeans = mean(kalmanImgStack,3); %#ok<*USENS>
    meanSubImgStack = zeros(size(kalmanImgStack,1),size(kalmanImgStack,2),size(kalmanImgStack,3));
    for c = 1:size(kalmanImgStack,3)
        disp(['Mean subtracking to remove background from image... (' num2str(c) '/' num2str(length(kalmanImgStack)) ')']); disp(' ')
        meanSubImgStack(:,:,c) = kalmanImgStack(:,:,c) - pixelMeans;
    end
    save([depthStackFile(1:end - 21) '_MeanSub_' depthStackFile(end - 4:end)],'meanSubImgStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_MeanSub_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
