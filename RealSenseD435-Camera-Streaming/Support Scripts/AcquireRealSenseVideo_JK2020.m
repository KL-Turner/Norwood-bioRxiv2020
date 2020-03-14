function [RGBStack,DepthStack,SuppData] = AcquireRealSenseVideo_JK2020(numFramesToAcquire,trialDuration)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: Streams RealSense D435 camera and outputs the data into image stacks
%________________________________________________________________________________________________________________________

% setup RealSense camera
pipe = realsense.pipeline();
colorizer = realsense.colorizer(); %#ok<NASGU>
align_to = realsense.stream.color;
alignedFs = realsense.align(align_to);
prof = pipe.start();
devID = prof.get_device();
camName = devID.get_info(realsense.camera_info.name);
SuppData.cameraID = camName;
% pre-allocate image size and number of frames
imgMatSize = zeros(480,640);
framePreAloc = cell(numFramesToAcquire/2,1);
SuppData.frameTime = cell(numFramesToAcquire/2,1);
for a = 1:length(framePreAloc)
    framePreAloc{a,1} = imgMatSize;
end
RGBStack = framePreAloc;
DepthStack = framePreAloc;
% allow camera to warm up for a few frames
for b = 1:120
    pipe.wait_for_frames();
end
% acquire data stream
frameCount = 0;
a = 1;
tic;
while frameCount < numFramesToAcquire
    multiWaitbar_RealSense('Streaming RealSense Camera','Busy','Color',[0.1,0.5,0.8]);
    frameCount = frameCount + 1;
    frameT = clock;
    % acquire frame, align, and get colorized data
    fs = pipe.wait_for_frames();
    alignedFrames = alignedFs.process(fs);    
    % true color rgb image
    rgbFrame = fs.get_color_frame();
    rgbData = rgbFrame.get_data();
    RGBImg = permute(reshape(rgbData',[3,rgbFrame.get_width(),rgbFrame.get_height()]),[3,2,1]);   
    % accurate depth information, no auto-scaling of color
    depthSensor = devID.first('depth_sensor');
    depthScale = depthSensor.get_depth_scale();
    depthFrame = alignedFrames.get_depth_frame(); 
    depthWidth = depthFrame.get_width();
    depthHeight = depthFrame.get_height();
    depthVector = depthFrame.get_data();
    DepthImg = double(transpose(reshape(depthVector,[depthWidth,depthHeight]))).*depthScale;
%     % colorized image for viewing
%     depthColor = colorizer.colorize(depthFrame);
%     depthData = depthColor.get_data();
%     colorizedDepthImg = permute(reshape(depthData',[3,depthColor.get_width(),depthColor.get_height()]),[3,2,1]);
%     imshow(colorizedDepthImg)    
    % only save every other frame. 30 Fs is too much data -> 15 Fs
    if rem(frameCount,2) == 1
        SuppData.frameTime{a,1} = frameT;
        RGBStack{a,1} = RGBImg;
        DepthStack{a,1} = DepthImg;
        a = a + 1;
    end
end
pipe.stop();
elapsedTime = toc;
multiWaitbar_RealSense('Streaming RealSense Camera','Close');
timeDifference = elapsedTime - trialDuration;
disp(['Elapsed time is ' num2str(elapsedTime) ' seconds.']); disp(' ')
disp(['This is ' num2str(timeDifference) ' seconds off from optimal']); disp(' ')

end
