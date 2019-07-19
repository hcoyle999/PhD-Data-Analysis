close all;

Bandwidth={'theta','gamma','alpha'};
TimeCondition={'BL'};
condition = { 'ec', 'eo','average'};
for Band=1:3

%Band=1;
Time=1;

for Cond=1:3 
    
cd('//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_TBI/');
HCpath='//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_Control/';
TBIpath='//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_TBI/';
%path2='S:\R-MNHS-MAPrc\Neil-Bailey\Predict_REST\12-NBS-Connectivity\W1\';
path3=['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_Statistics/'];
%path4=['S:\R-MNHS-MAPrc\Neil-Bailey\Predict_REST\12-NBS-Connectivity\Statistics\End\' (Bandwidth{1,Band}) filesep];

mkdir(path3);

load ([HCpath 'connectivitymeanALL' '_' condition{Cond} '.mat']);
HC=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});
load ([TBIpath 'connectivitymeanALL' '_' condition{Cond} '.mat']);
TBI=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});
NNM = cat(3,HC,TBI);

save ([path3 condition{Cond} '_' Bandwidth{Band} '_' 'NNM.mat'], 'NNM');
cd (path3)
end
end
