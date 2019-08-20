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
clear; close all;
datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;

Tp = {'BL'}; 
Condition= {'CRT'};
Group = {'Control','TBI'};

% ----------editable section  -------%
SubjectStart=12;
%SubjectFinish=;

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;

for Grp=GroupStart:GroupFinish
    
    
    if Grp==1
        % control participants included in analysis (N= 17)
        ID = {'001','009','010','012','013','014','015','017','018','019','020', '021','022','023','024','027','028'};
    else
        % mtbi participants included in analysis (N= 20)
        ID= {'103','105','106','108', '109' '110', '111', '112','113','114','115', '116','117','119','120','122', '124','127','129','130'};
    end
     %ID= {'022'};
    SubjectFinish= numel(ID);
   
    
    inPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1,Grp}];
    cd(inPath);
    
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
    
    filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_5.set'];
    EEG = pop_loadset(filename);
    EEG = eeg_checkset( EEG );
    
        % The following pops up a display of the different ICA components that
    % could be selected for rejection if they're artifacts. View Delorme, Palmer, Onton, Oostenveld, Makeig (2012) -
    % 'Independent EEG sources are dipolar' for an explanation of which
    % components to reject.
    
    % The line requires Nigel's 'TMS-toolbox' to be installed. This toolbox
    % should be in the analysis scripts and tutorials folder on the shared
    % drive, but can be obtained by contacting neilwbailey@gmail.com if
    % not, or nigel.rogasch@monash.edu.
    
    %Remove bad components
    %     EEG = sortRemoveComp_nb2(EEG,'time',[-999 1999]);
    EEG = pop_tesa_compselect( EEG,'compCheck','on','comps',[],'figSize','small','plotTimeX',[-500 1000],'plotFreqX',[1 100],'tmsMuscle','off','tmsMuscleThresh',8,'tmsMuscleWin',[11 30],'tmsMuscleFeedback','off','blink','on','blinkThresh',2.5,'blinkElecs',{'AF3','AF4'},'blinkFeedback','off','move','on','moveThresh',2,'moveElecs',{'F7','F8'},'moveFeedback','off','muscle','on','muscleThresh',0.6,'muscleFreqWin',[30 100],'muscleFeedback','off','elecNoise','on','elecNoiseThresh',4,'elecNoiseFeedback','off' );

    %%
    
    % The following line interpolates missing channels (channels that were
    % bad or bridged). It does this based on the channels that should have
    % been there originally (which were stored in EEG.AllChannels).
        
    %Interpolate missing channels
    EEG = pop_interp(EEG, EEG.allchan, 'spherical');
    
    % The following two lines remove the remaining eye and ECG channels. If
    % you have different labels on your eye channels (for example E1), or no ECG channel, this
    % will need to be changed.
    
    EEG.NoCh={'E1' 'E3'};
    EEG=pop_select(EEG,'nochannel',EEG.NoCh);
    
    %notesICA=inputdlg('Note anything you are unsure of', 'ICA removal', [1 200]);

    %EEG.notesICA=notesICA;
    
    % The following line stores the bad components in location with all the
    % other processing and behaviour data. Then the following lines store
    % the bad components selected in a separate matlab file (however, this
    % will re-write the matlab file each time. It might be best to load the
    % matlab file, add the new components selected to the end of this file,
    % then re-save the file instead.
    
    %EEG.TMScomp= EEG.ProcessingAndBehaviourData.BadComponents;
    
     outPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1,Grp}]; %where you want to save the data
                mkdir(outPath);
                cd(outPath);
                
                filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_6.set'];
                EEG = pop_saveset(EEG, filename);
                
    [chns,pnts,eps]=size(EEG.data);
    COUNT_EPS(Subjects,Cond,Time)=eps; 
% COUNT_CHNS(aaa,aa,a)=chns; 
            end
        end
    end
end
