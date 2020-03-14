function [rgbImg,colorizedDepthImg] = VerifyRealSenseCamAlignment_JK2020()
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: grab a few frames from the RGB camera to verify it's properly aligned over the experiment bin
%________________________________________________________________________________________________________________________

% setup RealSense camera
pipe = realsense.pipeline();
colorizer = realsense.colorizer();
align_to = realsense.stream.color;
alignedFs = realsense.align(align_to);
pipe.start();
% allow camera to warm up for a few frames
for i = 1:5
    fs = pipe.wait_for_frames();    
end
pipe.stop();
% colorized depth img (no actual depth info, autoscaled color)
alignedFrames = alignedFs.process(fs);
depthFrame = alignedFrames.get_depth_frame();
depthColor = colorizer.colorize(depthFrame);
depthData = depthColor.get_data();
colorizedDepthImg = permute(reshape(depthData',[3,depthColor.get_width(),depthColor.get_height()]),[3,2,1]);
% RGB img
rgbFrame = fs.get_color_frame();
rgbData = rgbFrame.get_data();
rgbImg = permute(reshape(rgbData',[3,rgbFrame.get_width(),rgbFrame.get_height()]),[3,2,1]);

end
