clear all; close all; clc;

datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
%cd(datadir);
%SETTINGS

eeglab;
%ID= {'112';'113';'114';'115';'116';'117';'118';'119'};
ID= {'118'};
%ID = {'002';'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015'; '017'; '018'; '019'}
%ID = {'106','107','108','109','110','111','112','113','114','115','116','117','118','119','120'};

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'PrePost'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'DS_analysis_TBI' filesep]
outPath = [datadir filesep 'DS_analysis_TBI' filesep]; %where you want to save the data


for aaa = 1:size(ID,1);
    
    cd([inPath filesep ID{aaa,1}]); % creating a directory of inPath, filesep is either / or \

    for aa = 1:size(Sesh,1);
    

        for a = 1:size(tp,1); % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
            
            
            
   EEG = pop_loadset([inPath,ID{aaa,1}, filesep, ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_4.set']); %epoched
  % pop up a dialogue box to tell you what to do at this stage
        
        button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', 'Bad Electrode Rejection');
        
        %pop up a plot of the EEG trace, for you to check for bad
        %electrodes. pop_eegplot_Modified has been modified for use with
        %ECG and EEG data. Use the line under that (pop_eegplot) if you
        %don't have ECG data
%        pop_eegplot_Modified( EEG,1 ,1 ,0);
        pop_eegplot( EEG, 1, 1, 0);
        uiwait();
%        R1=input('Check the trace and note bad electrodes. Press enter here when ready to continue.');
        
        %Remove bad channels
        
        % pop up a dialogue box for you to enter the channels you want to
        % remove into
        bad=inputdlg('Enter bad channels separated by a space (i.e. Fz Cz P3 etc)', 'Bad channel removal', [1 50]);
        
        % the next two lines separate the information you entered into the dialogue box above
        % into separate strings, one for each electrode
        str=bad{1};
        EEG.badchan=strsplit(str);
        
        %if EEG.badchan is not empty, then remove the trials listed in
        %EEG.badchan
        if isempty(EEG.badchan)==0;
            EEG = pop_select( EEG,'nochannel',EEG.badchan);
        end;
        
        %double check the electrode rejection process for the next section
        
        %%
        button2=questdlg('Would you like to check if you should remove more bad electrodes?', 'Bad channel removal');
        
        s1 = 'Yes';
        
        if strcmp (button2,s1)==1;
            
            EEG = eeg_checkset( EEG );
            button=questdlg('Once you click YES here, take note of any bad channels, (with eye influenced channels remember blinks are OK, but atypical noise or flat line across most of the recording suggests a bad channel (except for electrodes near the ref, which are OK to be almost flat)). Change the scale to ~64 using the numbers on the keypad and hit enter for best viewing. Once bad channels are noted (i.e. Fz Cz P3 etc), close the trace to continue. Pressing ctrl + C in the MATLAB command window stops the script at any time', 'Bad channel removal');
%            pop_eegplot_Modified( EEG,1 ,1 ,0);
            pop_eegplot( EEG, 1, 1, 0);
            uiwait();
%            R1=input('Check the trace and note bad electrodes. Press enter here when ready to continue.');

            %Remove bad channels
            bad=inputdlg('Enter bad channels separated by a space (i.e. Fz Cz P3 etc)', 'Bad channel removal', [1 50]);
            str=bad{1};
            EEG.badchan2=strsplit(str);
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
        
        EEG = eeg_checkset( EEG );
        
        % as above, pop up the EEG trace (use the second line if you don't
        % have ECG data
%        pop_eegplot_Modified( EEG,1 ,1 ,0);

        Button=questdlg('Change the scale to ~64 using the numbers on the keypad and enter. Highlight any bad epochs and press "update marks". Note questionable files and epochs and check later with your supervisor.', 'BAD EPOCH REMOVAL');

        
        
        pop_eegplot( EEG, 1, 1, 0);
        
        uiwait();
             
        % Pop up a dialogue box telling you what to do. You'll be able to
        % click on epochs on the trace to mark them as bad, then follow the
        % instructions in the dialogue boxes to eliminate those epochs.
        %Button=questdlg('Change the scale to ~64 using the numbers on the keypad and enter. Highlight any bad epochs and press "update marks". Note questionable files and epochs and check later with your supervisor. Press enter in the MATLAB command window when you are ready to continue.', 'BAD EPOCH REMOVAL');
        %R1=input('Check the trace and mark bad epochs, then press "Update Marks". Press enter here when ready to continue.');
        
        %Remove bad trials
        EEG.trialparaxymal=find(EEG.reject.rejmanual==1);
        EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);
        EEG.ProcessingAndBehaviourData.badtrials=EEG.trialparaxymal;


        notesArtifactRejection=inputdlg('Note anything you are unsure of', 'Artifact removal', [1 200]);

        EEG.notesArtifactRejection=notesArtifactRejection;
        
        
       mkdir([outPath filesep ID{aaa,1} filesep]);
       EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_5.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]); %epoched

   
        close all;
        
    
end;
    end
        end



