% The following line gets rid of anything that might already be open:

clear all; close all; clc;

% The following lines sets up an 'array' of strings (sequence of letters). An array is a table where
% each cell contains the digits or letters within the quotation marks. The
% array created below is titled 'ID' (which is why 'ID' is on the left hand
% side of the equals sign). The values in the ID array are referred to
% later in order to call specific variables, so that the script knows which
% files to load.

% ftID has a 'P' at the front of the participant number, because field trip
% (ft) saves files as .mat format, and MATLAB doesn't seem to like files
% to start with numbers.

% If you go into the MATLAB command window and look in the workspace (usually on the right hand side), you
% can view the variables and arrays that have been created. This is useful
% for testing whether you've created the correct array that refers to the
% correct file/folder. If MATLAB comes up with an error, this is a good way
% to trouble shoot.

eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';

%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117'};
%ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116'};
%ID = {'003', '004', '005', '006', '008', '009', '010', '011', '013', '014', '015', '017', '018', '019'};%ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P007', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P016', 'P017', 'P018', 'P019', 'P020'};
%ID= {'105','107','109',',110','111','112','116','118','119'};
ID= {'111'};
Group = {'Control','TBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre'};


caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

% Below creates variables 'SubjectStart' and 'SubjectFinish', used to
% define which subjects from the 'ID' variable above will be processed
% today. For example, SubjectStart=1 and SubjectFinish=1 will allow you to
% process the first subject listed in the ID variable above. 'nume1(ID);'
% refers to the end of the ID array, so will allow you to process right
% through to the last participant listed if you would like. The same is
% true for ConditionStart and ConditionFinish.

% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

GroupStart=2;
GroupFinish=2;

SubjectStart=1;
%SubjectFinish=numel(ID);
SubjectFinish=1;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
                
        ICASetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects}  '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_4.set'];
        EEG = pop_loadset(ICASetname);
        
        %%Not sure if this needs to be included- erroring when
        %%interpolating chanells- 
        %EEG.allchan = 1:EEG.nbchan;
     
    
    %Remove bad components
   % EEG = sortRemoveCompNB(EEG,'time',[0 1998]);
% belecs = {'AF3' , 'AF4'};
% melecs = {'F7' , 'F8'};
% 
% %% Fast ICA 2
% EEG = tesa_compselect(EEG, 'blinkElecs', belecs , 'moveElecs', melecs, 'figSize', 'large','plotTimeX',[-200,700] ,'plotFreqX', [2,80]);
EEG = pop_select( EEG,'nochannel',{'SO1','E3','E1','HEOG'});
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
     EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    EEG.NoCh={'SO1','E3','E1'};
    EEG=pop_select(EEG,'nochannel',EEG.NoCh);
    
    % The following line stores the bad components in location with all the
    % other processing and behaviour data. Then the following lines store
    % the bad components selected in a separate matlab file (however, this
    % will re-write the matlab file each time. It might be best to load the
    % matlab file, add the new components selected to the end of this file,
    % then re-save the file instead.
    
    EEG.ProcessingAndBehaviourData.BadComponents = these;
    
    ICARejectedSetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_5.set'];
    EEG = pop_saveset(EEG, ICARejectedSetname);
    
            end
        end
    end
  end
    