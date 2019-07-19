clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
%cd(datadir);
%SETTINGS

eeglab;
%ID= {'101';'102';'103';'104';'105'; '106'; '107'; '110'; '111'; '113';'113';'114';'115';'116';'117';'118';'119';'120';'121';'122'};
ID= {'001'};
%ID = {'002';'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015';'016'; '017'; '018'; '019'}
%ID = {'106','107','108','109','110','111','112','113','114','115','116','117','118','119','120'};

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'PrePost'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'DS_analysis_Control' filesep]
outPath = [datadir filesep 'DS_analysis_Control' filesep]; %where you want to save the data

for aaa = 1:size(ID,1);
    
    cd([inPath filesep ID{aaa,1}]); % creating a directory of inPath, filesep is either / or \

    for aa = 1:size(Sesh,1);
    

        for a = 1:size(tp,1); % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
    % Loading data
    EEG = pop_loadset([inPath,ID{aaa,1}, filesep, ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_6.set']);
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
    EEG = sortRemoveComp_nb2(EEG,'time',[-999 1999]);
    
    %%
    
    % The following line interpolates missing channels (channels that were
    % bad or bridged). It does this based on the channels that should have
    % been there originally (which were stored in EEG.AllChannels).
        
    %Interpolate missing channels
    EEG = pop_interp(EEG, EEG.AllChannels, 'spherical');
    
    % The following two lines remove the remaining eye and ECG channels. If
    % you have different labels on your eye channels (for example E1), or no ECG channel, this
    % will need to be changed.
    
    EEG.NoCh={'SO1' 'ECG'};
    EEG=pop_select(EEG,'nochannel',EEG.NoCh);
    
    notesICA=inputdlg('Note anything you are unsure of', 'ICA removal', [1 200]);

    EEG.notesICA=notesICA;
    
    % The following line stores the bad components in location with all the
    % other processing and behaviour data. Then the following lines store
    % the bad components selected in a separate matlab file (however, this
    % will re-write the matlab file each time. It might be best to load the
    % matlab file, add the new components selected to the end of this file,
    % then re-save the file instead.
    
    EEG.ProcessingAndBehaviourData.BadComponents = EEG.TMScomp;
    
    mkdir([outPath filesep ID{aaa,1} filesep]);
     EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_7.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]); %ICA removed run
        end
    end
end