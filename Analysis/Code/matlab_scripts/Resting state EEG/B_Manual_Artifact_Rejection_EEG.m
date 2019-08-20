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
ID = {'026','027'}; %'020',
%ID = {'001','009','010','012','013','014','015','017','018','019','020', '021','022','023','024','025','026','027','028'};
inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];

else
% mtbi participants included in analysis (N= 30)
ID = {'102'}; %'101','102','105','107', '109' '110', '111','118','119',
%ID= {'103','105','106','108', '109' '110', '111', '112','113','114','115', '116','117','119','120','122', '124','127','129','130'};
inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];
end
%ID= {'126'};
SubjectFinish= numel(ID);


    for Subjects=SubjectStart:SubjectFinish 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
      
        cd([inPath filesep ID{1,Subjects} filesep]);
        AutomaticRejectionsetname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_3.set'];
        EEG = pop_loadset(AutomaticRejectionsetname);
        EEG = eeg_checkset( EEG );
        
        %% 
        
        % MANUAL REJECTION PROCESS:
        
%Check for bad channel
        
        EEG = eeg_checkset( EEG );
        
        % pop up a dialogue box to tell you what to do at this stage
        
        button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace, then hit enter in the MATLAB command window when you are ready to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', (ID{1,Subjects}));
        
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
        button2=questdlg('Would you like to check if you should remove more bad electrodes?', (ID{1,Subjects}));
        
        s1 = 'Yes';
        
        if strcmp (button2,s1)==1;
            
            EEG = eeg_checkset( EEG );
            button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace, then hit enter in the MATLAB command window when you are ready to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', (ID{1,Subjects}));
            
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
        
        outPath= [inPath filesep ID{1,Subjects} filesep];
        cd(outPath);
        
        ManualRejectionsetname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_4.set'];
    
        EEG = pop_saveset(EEG, ManualRejectionsetname);
        
            end
        end
    end
end

