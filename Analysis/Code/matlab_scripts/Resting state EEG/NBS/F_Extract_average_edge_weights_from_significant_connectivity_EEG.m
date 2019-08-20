clear; close all; clc;
%Wrapper script for plotting significant NBS networks on 2D heads using
%topoplot_connect.m

%Requirements:
%- topoplot_connect.m added to matlab path
%- NBS output file with significant network
%- EEGLAB file with channel positions

%Settings for file to load (you will need to change this to suit your
%files)
path = '/Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Statistics/eo_beta_BL';
group = {'Control';'TBI'};
pval = {'025'};
df = {'54'};
cond = {'high'};
freq = {'beta'};
freqN = {'beta'};
timeRange = [0,1];
contrast = {'AB'};
i = 1;

Bandwidth={'theta','gamma','alpha','beta'};
TimeCondition={'BL'};

%Load NBS output matrix
%load([path,'nbs\','group_load\','group_',cond{i,1},'_',freq{i,1},'_',num2str(timeRange(i,1)),'_',num2str(timeRange(i,2)),filesep,contrast{i,1},filesep,'NBSoutput_',pval{i,1},'_',df{i,1},'.mat']);
load([path,filesep,'NBSoutput_',pval{i,1},'_',df{i,1},'.mat']);
NBS = nbs;

%Find the signifanct connections
[h,j,s] = find(NBS.NBS.con_mat{:});

%Settings for topoplot_connect - set to create a map showing all of the
%significant connections in one colour.
%Note that you can also plot edge weights using ds.connectStrength - see
%topoplot_connect for additional options. 
ds.chanPairs = [h,j];

%====== INPUT ======

set='.set';
mat='.mat';


cd('//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Statistics/');

%addpath ('C:\Program Files\MATLAB\fieldtrip-20140626');
ft_defaults;

% adapt the following to select time windows of interest to compare
% connectivity across and average across those windows to take it from a 3D
% chan_chan_freq dimord to a 2D chan_chan dimord for theta, alpha, and
% gamma

% first limit to frequency windows of interest:
for Band=4;
for Time=1;    

wPLIname = '//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Control/connectivitymeanALL_eo.mat';
load(wPLIname);
HC=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});

wPLIname = '//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_TBI/connectivitymeanALL_eo.mat';
load(wPLIname);
TBI=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});

%Nsubjects=18;

%ParticipantList = {'001', '002', '003', '004', '005', '006', '008', '009', '010', '011', '012', '013', '014', '015', '017', '018', '019', '020'};
%ParticipantList=fieldnames(connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time}));



for k=1:size(HC,3); 
    dat= HC;
    %connectivity_matrix.theta.total_eo.BL(k)= dat(h,j,k); 
    HCconnVal(k)= mean(mean(HC(h,j,k)));
end    

for k=1:size(TBI,3); 
    TBIconnVal(k)= mean(mean(TBI(h,j,k)));
   % (ds.chanPairs(c,1),ds.chanPairs(c,2),(k,3)));
end 

end
end 
