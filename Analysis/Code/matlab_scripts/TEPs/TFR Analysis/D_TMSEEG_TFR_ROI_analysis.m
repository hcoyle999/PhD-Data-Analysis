%---------------------------------------------------------------------------------------------%
% ROI ANALYSIS TIME FREQUENCY ANALYSIS
% This script runs a ROI analysis for a given condition on a given electrode and averages over
% both a frequency band of interest and a time window of interest. The
% output for each individual is given as the variable ROIfreqOutput in the
% workspace. Each row represents the value for an individual (in the order
% they were entered in to the grand average script).

% Note that the grand average script must be run prior to this script.
% Also, there is nothing saved so the output needs to be copy and pasted in
% to another program (excel, SPSS etc.). 
%---------------------------------------------------------------------------------------------%

clear;
%-------------------%
%Theta = 4-7 Hz
%Alpha = 8-13 Hz
%beta =  14-29 Hz
%Gamma = 30-45 Hz
%-------------------%

%SETTINGS 
%-------------------%
elec = {'F1'};
TIMEPOINT = 'T2';
FOI = [14,29];      
TOI = [0.05,0.15];  
COND = 'SH';  
%-------------------%

fileExt = [COND '_' 'TMSEEG_final']; 
root = '/Volumes/UNTITLED/OUTPUT/TMS_EEG/TFR_TESA/GrandAverage/Post_Minus_Pre';

%%
%load file
filepath = [root,filesep];

filename = [fileExt, '_' TIMEPOINT '_TFR_GA_CORRECTED']; 

load([filepath,filename]);

%LOOP THROUGH EACH ROI ELECTRODE
for a=1:size(elec,1)
%FIND ELECTRODE NUMBER
elecNo = find(strcmp(elec{a,1},normalise.label));

%FIND FREQUENCIES
[ind f1] = min(abs(FOI(1,1) - normalise.freq));
[ind f2] = min(abs(FOI(1,2) - normalise.freq));

%FIND TIME
[ind t1] = min(abs(TOI(1,1) - normalise.time));
[ind t2] = min(abs(TOI(1,2) - normalise.time));

%CALCULATE AVERAGE
elec{a,1} = mean(normalise.powspctrm(:,elecNo,:,t1:t2),4);
end 

%PULL THE AVERAGE FOR EACH ELECTRODE
aveF1 = mean(elec{1,1}(:,:,f1:f2),3);
% aveFC3 = mean(elec{2,1}(:,:,f1:f2),3);
% aveF5 = mean(elec{3,1}(:,:,f1:f2),3);
% aveAF3 = mean(elec{4,1}(:,:,f1:f2),3);

%CALCULATE THE AVERAGE ACCROSS THE 4 ROI ELECTRODES
%ROIFreqOutput = (aveF1 + aveFC3 + aveF5 + aveAF3)/4;
ROIFreqOutput = aveF1;


% clear workspace (except for freqOutput
clearvars -except ROIFreqOutput

