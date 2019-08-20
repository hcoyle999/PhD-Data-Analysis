%% ICA Rejected Script for Resting EEG %%

clear all; close all; clc;
datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
%caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;

Tp = {'T2'}; %T1 %T2
Condition= {'resting'};
Group = {'Control','TBI'};


% ----------editable section  -------%
SubjectStart=1;
%SubjectFinish=;

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;


for Grp=GroupStart:GroupFinish
   
if Grp==1
% control participants included in analysis (N= 26)
ID={'001','002','003','004','005','006','009','010','012','013','014','017','018','021','022','023','025','026','027'}
inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];

else
% mtbi participants included in analysis (N= 30)
ID= {'122', '124','125','127','129'}; %'101','102','105','107', '109' '110', '111','118','119',
inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];
end
%ID= {'126'};
SubjectFinish= numel(ID);


    for Subjects=SubjectStart:SubjectFinish 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
        cd([inPath filesep ID{1,Subjects} filesep]);
        ICASetname  = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_4.set'];
        EEG = pop_loadset(ICASetname);
        
%     %Remove bad components
%     EEG = sortRemoveCompNB(EEG,'time',[0 1998]);
%     belecs = {'AF3' , 'AF4'};
%     melecs = {'F7' , 'F8'};
% 
% %% Fast ICA 2
% EEG = tesa_compselect(EEG, 'blinkElecs', belecs , 'moveElecs', melecs, 'figSize', 'large','plotTimeX',[-200,700] ,'plotFreqX', [2,80]);

EEG = pop_select( EEG,'nochannel',{'SO1','E3','E1','HEOG'});
load('/Volumes/HOY_2/TMS_EEG Data/Scripts/Resting state EEG/mychans.mat') %EEG.chanlocs;
EEG.allchan =[]; 
EEG.allchan =mychans; 

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
EEG = pop_reref( EEG, []);
  [ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset( EEG );
        
 %Run AMICA
  %  [EEG.icaweights, EEG.icasphere, mods] = runamica15(EEG.data(:,:,:));
% Run fastICA
EEG = pop_tesa_fastica( EEG, 'approach', 'symm', 'g', 'tanh', 'stabilization', 'off' );
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset( EEG );

whereisICBM= ['/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/MARA1.2/inv_matrix_icbm152.mat'];

        
[ALLEEG,EEG,CURRENTSET] = processMARA(ALLEEG,EEG,CURRENTSET);
%% 
close all; 
TMP.reject.gcompreject = EEG.reject.gcompreject;

[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
these= find([EEG.reject.gcompreject]==1);
EEG = pop_subcomp( EEG,these , 0);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset( EEG );
        
    %%
    
    % The following line interpolates missing channels (channels that were
    % bad or bridged). It does this based on the channels that should have
    % been there originally (which were stored in EEG.allchan).
    
   
    %Interpolate missing channels
    EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    % The following two lines remove the remaining eye and ECG channels. If
    % you have different labels on your eye channels (for example E1), or no ECG channel, this
    % will need to be changed.
    % EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    EEG.NoCh={'E3','E1'};
    EEG=pop_select(EEG,'nochannel',EEG.NoCh);
    
    % The following line stores the bad components in location with all the
    % other processing and behaviour data. Then the following lines store
    % the bad components selected in a separate matlab file (however, this
    % will re-write the matlab file each time. It might be best to load the
    % matlab file, add the new components selected to the end of this file,
    % then re-save the file instead.
    
    EEG.ProcessingAndBehaviourData.BadComponents = these;
    ICARejectedSetname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_5.set'];
    EEG = pop_saveset(EEG, ICARejectedSetname);
    
            end
        end
    end
  end
    