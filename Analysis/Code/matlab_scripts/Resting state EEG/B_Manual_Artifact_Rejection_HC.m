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

ID= {'110','111','112','116','119'};
%ID = {'006', '008', '009', '010', '011', '012','013', '014', '015', '017', '018', '019'};
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P007', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P016', 'P017', 'P018', 'P019', 'P020'};
%001', '002', '003', '004', '005', '006', '007', '008', '009', '010', 011', '012', '013')

%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117'};
%ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117'};

Group = {'Control','TBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre'};

%FolderCondition = {'BSL 3 mins eyes open', 'BSL 3 mins eyes closed', 'W6 3 mins eyes open', 'W6 3 mins eyes closed'};
%Condition = {'eyesopen_BL','eyesclosed_BL','eyesopen_END','eyesclosed_END'};

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
SubjectFinish=5;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

        AutomaticRejectionsetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_3.set'];
        EEG = pop_loadset(AutomaticRejectionsetname);
        EEG = eeg_checkset( EEG );
        
        %% 
        
        % MANUAL REJECTION PROCESS:
        
%Check for bad channel
        
        EEG = eeg_checkset( EEG );
        
        % pop up a dialogue box to tell you what to do at this stage
        
        button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace, then hit enter in the MATLAB command window when you are ready to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', (ftID{1,Subjects}));
        
        %pop up a plot of the EEG trace, for you to check for bad
        %electrodes. pop_eegplot_Modified has been modified for use with
        %ECG and EEG data. Use the line under that (pop_eegplot) if you
        %don't have ECG data
        
        pop_eegplot( EEG, 1, 1, 0);
        uiwait
        
        
        %Remove bad channels
        
        % pop up a dialogue box for you to enter the channels you want to
        % remove into
        

        [chanlist,chanliststr, allchanstr] = tesa_chansel({EEG.chanlocs.labels});
        % the next two lines separate the information you entered into the dialogue box above
        % into separate strings, one for each electrode
 
       EEG.badchan=chanlist;

        %if EEG.badchan is not empty, then remove the trials listed in
        %EEG.badchan
        if isempty(EEG.badchan)==0;
        EEG = pop_select( EEG,'nochannel',EEG.badchan);
        end;
        
        %double check the electrode rejection process for the next section
        
        %%
        button2=questdlg('Would you like to check if you should remove more bad electrodes?', (ftID{1,Subjects}));
        
        s1 = 'Yes';
        
        if strcmp (button2,s1)==1;
            
            EEG = eeg_checkset( EEG );
            button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace, then hit enter in the MATLAB command window when you are ready to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', (ftID{1,Subjects}));
            
            pop_eegplot( EEG, 1, 1, 0);
           % R1=input('Check the trace and note bad electrodes. Press enter here when ready to continue.');

        [bad,chanliststr, allchanstr] = tesa_chansel({EEG.chanlocs.labels});
    
            %Remove bad channels
          %  bad=inputdlg('Enter bad channels separated by a space (i.e. Fz Cz P3 etc)', 'Bad channel removal', [1]);
 %           str=bad{1};
            EEG.badchan2=bad;
            EEG.ProcessingAndBehaviourData.BadChannels2 = EEG.badchan2;
            if isempty(EEG.badchan2)==0;
            EEG = pop_select( EEG,'nochannel',EEG.badchan2);
            end;
        end
        
        if strcmp (button2,s1)==0;
            EEG.ProcessingAndBehaviourData.BadChannels2 = [];
        end
        
        EEG.ProcessingAndBehaviourData.BadChannels = EEG.badchan;
        
%%
        % manual search for bad trials  
        EEG = eeg_checkset( EEG );
        
        % Pop up a dialogue box telling you what to do. You'll be able to
        % click on epochs on the trace to mark them as bad, then follow the
        % instructions in the dialogue boxes to eliminate those epochs.
        Button=questdlg('Change the scale to ~64 using the numbers on the keypad and enter. Highlight any bad epochs and press "update marks". Note questionable files and epochs and check later with your supervisor. Press enter in the MATLAB command window when you are ready to continue.', 'BAD EPOCH REMOVAL');
        
        
        % as above, pop up the EEG trace (use the second line if you don't
        % have ECG data
        
        pop_eegplot( EEG, 1, 1, 0);
        
        uiwait

        %Remove bad trials
        EEG.trialparaxymal=find(EEG.reject.rejmanual==1);
        EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);
        EEG.ProcessingAndBehaviourData.badtrials=EEG.trialparaxymal;
        
        ManualRejectionsetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_4.set'];
        EEG = pop_saveset(EEG, ManualRejectionsetname);
        
    end
        end
    end
end

