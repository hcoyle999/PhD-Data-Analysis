close all;
clear all;

datadir= '//Volumes/HOY_2/TMS_EEG Data/Resting_analysis'
Bandwidth={'theta','gamma','alpha','beta'};
TimeCondition={'BL'};
condition = { 'eo', 'ec'};
for Band=1:4

%Band=1;
Time=1;

for Cond=1:2 
    
cd(datadir);
HCpath= [datadir filesep 'Resting_analysis_Control'];
TBIpath=[datadir filesep 'Resting_analysis_TBI'];
path3=[datadir filesep 'Resting_analysis_Statistics'];


mkdir(path3);
connectivitymeanALL=[];
load ([HCpath filesep 'connectivitymeanALL' '_' condition{Cond} '.mat']);
HC=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});
connectivitymeanALL=[];
load ([TBIpath filesep 'connectivitymeanALL' '_' condition{Cond} '.mat']);
TBI=connectivitymeanALL.(Bandwidth{1,Band}).(TimeCondition{1,Time});
NNM = cat(3,HC,TBI);

save ([path3 filesep condition{Cond} '_' Bandwidth{Band} '_' 'NNM.mat'], 'NNM');
cd (path3)
end
end
