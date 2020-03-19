function [] = CorrectColorScale_JK2020(supplementalFile)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: Reset the colormap caxis after background removal to emphasive differences in animal height
%________________________________________________________________________________________________________________________

load(supplementalFile)
% identify minimum value from separated data
cMin(1,1) = SuppData.depthStack_A.caxis(1,1);
cMin(1,2) = SuppData.depthStack_B.caxis(1,1);
cMin(1,3) = SuppData.depthStack_C.caxis(1,1);
caxisMin = min(cMin);
% identify maximum value from separated data
cMax(1,1) = SuppData.depthStack_A.caxis(1,2);
cMax(1,2) = SuppData.depthStack_B.caxis(1,2);
cMax(1,3) = SuppData.depthStack_C.caxis(1,2);
caxisMax = max(cMax);
% save new caxis values
SuppData.caxis = [caxisMin,caxisMax];
save(supplementalFile,'SuppData')

end
