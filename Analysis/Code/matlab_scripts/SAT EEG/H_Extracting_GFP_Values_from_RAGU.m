close all; clear all;
datadir='//Volumes/HOY_2/TMS_EEG Data';

cd([datadir filesep 'SAT_analysis']);

load('TCT_GFP results.mat');

% GFP is actually the standard deviation from the mean of all electrodes.
% Electrodes are in the 3rd dimension in the rd.V array, so taking the
% standard deviation of the 3rd dimension gives you the GFP values:
gfp = std(rd.V,1,3); 

% Then you average this GFP across the time window of interest
% (pre-selected in RAGU, which inputs the "startframe" and "endframe"
% values (or you can manually input those values below, but remember the
% start of the baseline period is counted as zero, regardless of when the
% stimulus appears

%Meangfp = mean(gfp(:,:,:,rd.StartFrame:rd.EndFrame),4); %(1 to 1000 for mine)
Meangfp = mean(gfp(:,:,:,375:576),4); 


%%% for timewindow (375-576 ms) 
Control_GFP_NoGo = Meangfp(1:17, 1:1); %17 control
mtbi_GFP_NoGo = Meangfp(18:37, 1:1); %20 mtbi
Control_GFP_Go = Meangfp(1:17, 2:2);
mtbi_GFP_Go = Meangfp(18:37, 2:2); 

% the first number range below is for participants, the second is for the
% conditions:
% ColorControls = Meangfp(1:28, 1:2);
% ColorControls = ColorControls(:);
% ColorControlsSD = std(ColorControls); 
% 
% ColorMeditators = Meangfp(29:62, 1:2);
% ColorMeditators = ColorMeditators(:);
% ColorMeditatorsSD = std(ColorMeditators); 
% 
% 
% EmotionControls = Meangfp(1:28, 3:4);
% EmotionControls = EmotionControls(:);
% EmotionControlsSD = std(EmotionControls); 
% 
% EmotionMeditators = Meangfp(29:62, 3:4);
% EmotionMeditators = EmotionMeditators(:);
% EmotionMeditatorsSD = std(EmotionMeditators); 







