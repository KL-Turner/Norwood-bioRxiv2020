function [] = JoinProcessedFiles_JK2020(depthStacks,stackType)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
% Purpse: put the previously split files back together again into one stack
%________________________________________________________________________________________________________________________

% processed stack concatenation
if strcmp(stackType,'processed') == true
    disp('Loading processed depth stack A...'); disp(' ')
    depthStackA_struct = load([depthStacks{1,1}(1:end - 21) '_ProcDepthStack_A.mat']);
    depthStackA = depthStackA_struct.procImgStack;
    disp('Loading processed depth stack B...'); disp(' ')
    depthStackB_struct = load([depthStacks{1,1}(1:end - 21) '_ProcDepthStack_B.mat']);
    depthStackB = depthStackB_struct.procImgStack;
    disp('Loading processed depth stack C...'); disp(' ')
    depthStackC_struct = load([depthStacks{1,1}(1:end - 21) '_ProcDepthStack_C.mat']);
    depthStackC = depthStackC_struct.procImgStack;
    disp('Concatenating stacks A, B, C'); disp(' ')
    procDepthStack = cat(3,depthStackA,depthStackB,depthStackC);
    disp('Saving processed depth stack...'); disp(' ')
    save([depthStacks{1,1}(1:end-21) '_ProcDepthStack.mat'],'procDepthStack','-v7.3')
    % binary stack concatenation
elseif strcmp(stackType,'binary') == true
    disp('Loading binary depth stack A...'); disp(' ')
    depthStackA_struct = load([depthStacks{1,1}(1:end - 21) '_Binarize_A.mat']);
    depthStackA = depthStackA_struct.binImgStack;   
    disp('Loading binary depth stack B...'); disp(' ')
    depthStackB_struct = load([depthStacks{1,1}(1:end - 21) '_Binarize_B.mat']);
    depthStackB = depthStackB_struct.binImgStack;  
    disp('Loading binary depth stack C...'); disp(' ')
    depthStackC_struct = load([depthStacks{1,1}(1:end - 21) '_Binarize_C.mat']);
    depthStackC = depthStackC_struct.binImgStack;  
    disp('Concatenating stacks A, B, C'); disp(' ')
    binDepthStack = cat(3,depthStackA,depthStackB,depthStackC);
    disp('Saving binarized depth stack...'); disp(' ')
    save([depthStacks{1,1}(1:end-21) '_BinDepthStack.mat'],'binDepthStack','-v7.3')
end

end
