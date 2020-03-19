function [] = CorrectRealSenseFrames_KalmanFilter_JK2020(depthStackFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: apply kalman filter through the image stack
%________________________________________________________________________________________________________________________

disp('CorrectRealSenseFrames: Kalman Filter'); disp(' ')
if ~exist([depthStackFile(1:end - 21) '_Kalman_' depthStackFile(end - 4:end)],'file')
    imgMaskStackFile = [depthStackFile(1:end - 21) '_ImageMask_' depthStackFile(end - 4:end)];
    load(imgMaskStackFile)    
    % Kalman filter
    kalmanImgStack = Kalman_Stack_Filter(imgMaskStack,0.75,0.75);
    save([depthStackFile(1:end - 21) '_Kalman_' depthStackFile(end - 4:end)],'kalmanImgStack','-v7.3')
else
    disp([depthStackFile(1:end - 21) '_Kalman_' depthStackFile(end - 4:end) ' already exists. Continuing...']); disp(' ')
end

end
