
clear; close all;
datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
%caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;

Tp = {'BL'}; 
Condition= {'Pre'};
Group = {'Control','TBI'};
countfilename= 'Epoch_count_Resting_EEG_Control.csv' 



% ----------editable section  -------%
SubjectStart=1;
%SubjectFinish=;

GroupStart=1;
GroupFinish=1;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;


for Grp=GroupStart:GroupFinish
   
if Grp==1
% control participants included in analysis (N= 26)
%ID= {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028'};
ID=ID';
else
% mtbi participants included in analysis (N= 30)
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116','117','118','119','120', '121', '122','123', '124','125','126','127','128','129','130'};
end
ID= {'006'};
SubjectFinish= numel(ID);

inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_Analysis_' Group{1,Grp}]; 
EpochCount=nan(size(ID,3))

    for Subjects=SubjectStart:SubjectFinish 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

    % Loading data
   %file is post ICA (so last step before splitting file) 
filename =  [inPath '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Tp{1,Time} '_' Condition{1,Cond} '_2.set'];
EEG = pop_loadset(filename);

EEG = eeg_checkset( EEG );    

% create structure to put info in 
eo_count= find(strcmp({EEG.event(1,:).type},'eo'));% 
eo_count= num2cell(eo_count);
eo_count= size(eo_count,2);
ec_count= find(strcmp({EEG.event(1,:).type},'ec'));
ec_count= num2cell(ec_count);
ec_count= size(ec_count,2);

%EpochCount_titles={'Participant_ID', 'Eyes_Open', 'Eyes_Close'};
 
EpochCount(Subjects,1)= str2num(ID{1, Subjects});
EpochCount(Subjects,2)= eo_count;
EpochCount(Subjects,3)= ec_count;



            end
        end
    end
end
outPath = [datadir filesep 'Resting_analysis' filesep 'Resting_Analysis_' Group{1,Grp}]; 
cd(outPath);
disp(EpochCount);
csvwrite(countfilename,EpochCount); 