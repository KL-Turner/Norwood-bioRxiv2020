function [] = ConvertRealSenseToAVI_JK2020(fileName,supplementalFile,inputType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: Create an avi movie from image stack
%________________________________________________________________________________________________________________________

close all
load(supplementalFile)
% RGB movie image stack to avi movie
if strcmp(inputType,'RGBStack')
    if ~exist([fileName(1:end - 4) '_5xSpeed.avi'],'file')
        disp('Generating RGB stack .AVI movie (sped-up 5X)...'); disp(' ')
        load(fileName)
        outputVideo = VideoWriter([fileName(1:end - 4) '_5xSpeed.avi']);
        outputVideo.FrameRate = SuppData.samplingRate*5;
        open(outputVideo);
        for a = 1:length(RGBStack) %#ok<*USENS>
            disp(['Processing RGB stack .AVI frame... (' num2str(a) '/' num2str(length(RGBStack)) ')']); disp(' ')
            writeVideo(outputVideo,im2frame(RGBStack{a,1}));
        end
        close(outputVideo)
        disp('RGB stack 5X speed .AVI movie - complete'); disp(' ')
    else
        disp([fileName(1:end - 4) '_5xSpeed.avi already exists. Continuing...']); disp(' ')
    end
    % processed depth stack stack to avi movie
elseif strcmp(inputType,'FullyProcDepthStack')
    if ~exist([fileName(1:end - 4) '_5xSpeed.avi'],'file')
        disp('Generating fully-processed depth stack .AVI movie (sped-up 5X)...'); disp(' ')
        load(fileName) 
        outputVideo = VideoWriter([fileName(1:end - 4) '_5xSpeed.avi']);
        outputVideo.FrameRate = SuppData.samplingRate*5;
        open(outputVideo);
        for b = 1:length(procDepthStack)
            disp(['Processing fully-processed depth stack .AVI frame... (' num2str(b) '/' num2str(size(procDepthStack,3)) ')']); disp(' ') 
            imagesc(procDepthStack(:,:,b));
            colormap jet
            caxis(SuppData.caxis)
            currentFrame = getframe;
            writeVideo(outputVideo,currentFrame);
        end
        close(outputVideo)
        disp('Fully-processed depth stack 5X speed .AVI movie - complete'); disp(' ')
    else
        disp([fileName(1:end - 4) '_5xSpeed.avi already exists. Continuing...']); disp(' ')
    end
end

end
