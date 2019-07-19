eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';

ID = {'004'};
%ID = {'001','002','003', '004', '005','006', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020','021','022','023'};
%ID = {'101','103','104','105','106','107','108','109','110','111','112','113','114','115','116','117','118','119','120','121'};
%ftID = {'103'};

Group = {'Control','mTBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Post'};


caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

GroupStart=1;
GroupFinish=1;

SubjectStart=1;
%SubjectFinish=numel(ID);
SubjectFinish=1;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;




for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

        setname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control' '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,Cond} '_ds.set'];
        EEG = pop_loadset(setname);
        
 
%close all;

%% RECODING TMS PULSES
here= find([EEG.event.urevent]==1);     
               
%start= find(strcmp({EEG.event(1,:).type},'1'));%         
  
%for i=1:start;
% if strcmp(EEG.event(i).type,'1');
% EEG.event(i).type='2';
% end

for b = 1:size(EEG.event,2) % "." means Look into xxx before ".", we are looking at 2nd dimension
        EEG.event(1,b).type = '2'; %replace triggers with time markers, tp = time point, T0 T1 T2
    end
    
%     [ALLEEG, EEG, CURRENTSET]=eeg_store(ALLEEG, EEG, a); %store data in ALLEEG for merge (double-click ALLEEG in workspace) ALLEEG is a stroage, use sparingly cuz it will slow down with more 
    
end
 

[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

mkdir('//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control');
setname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control' '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,Cond} '_ds.set'];
EEG = pop_saveset(EEG, setname);
        end        
end
end


   

     
         
