eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';


%ID = {'001', '002','005', '006', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020','021','022','023'};
%ID = {'101','103','104','105','106','108','109','110','111','112','113','114','115','116','117','118','119'};
ID = {'004'};

Group = {'Control','mTBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre','Post'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

GroupStart=1;
GroupFinish=1;

SubjectStart=1;
%SubjectFinish=numel(ID);
SubjectFinish=1;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=2;

Cond=ConditionStart:ConditionFinish;

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
%             for Cond=ConditionStart:ConditionFinish

                
                
        EEG=[];
        setname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control' '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,1} '_ds.set'];
        EEG = pop_loadset(setname);
        
        [ALLEEG, EEG, CURRENTSET]=eeg_store(ALLEEG, EEG, 1);
        
        EEG=[];
        
        setname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control' '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,2} '_ds.set'];
        EEG = pop_loadset(setname);
        
        [ALLEEG, EEG, CURRENTSET]=eeg_store(ALLEEG, EEG, 2);
        
%% Merge Files
sizeTp = 1:1:length(Cond); %create number of time points -> 3 time points
EEG = pop_mergeset(ALLEEG, sizeTp, 0); %merge time points

EEG.urevent =[]; %reconstruct urevent -> making sure that information within EEG structure is consistent (event and urevent)

for a = 1:size(EEG.event,2);
    EEG.urevent(1,a).epoch = EEG.event(1,a).epoch;
    EEG.urevent(1,a).type = EEG.event(1,a).type;
    EEG.urevent(1,a).latency = EEG.event(1,a).latency;
end

mkdir('//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control');
setname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/SP_analysis_Control' '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,Cond} '.set'];
EEG = pop_saveset(EEG, setname);

    STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];

            end
        end
    end
% end

