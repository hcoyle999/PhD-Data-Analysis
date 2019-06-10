clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;
ID= {'018';'019'};
%ID= {'101';'102';'103';'104';'105'; '106'; '107';'108'};
%ID = {'002';'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015';'016'; '017'; '018'; '019';'020';'021'}
%ID = {'102';'103';'104';'105'; '106'; '107'; '110'; '111';'106','107','108','109','110','111','112','113','114','115','116','117','118','119','120'};
%
Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Post'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'Control' filesep];
outPath = [datadir filesep 'DS_analysis_Control' filesep]; %where you want to save the data

mkdir(outPath);


region = 'FCZ';
elec = 'CZ';

%%
for aaa = 1:size(ID,1);
    
    cd([inPath filesep ID{aaa,1}]); % creating a directory of inPath, filesep is either / or \

    for aa = 1:size(Sesh,1);
    

        for a = 1:size(tp,1); % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
    
    % Loading data (if doing initially properly coded files)
    EEG = pop_loadcnt([inPath,ID{aaa,1}, filesep,Sesh{aa,1}, filesep, ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'.cnt'], 'dataformat', 'auto', 'memmapfile', '');
    EEG = eeg_checkset( EEG );
      
     
%% Downsample
    EEG=pop_resample(EEG,1000)
   
%% Channel locations
    
    EEG = pop_chanedit(EEG, 'lookup', caploc); %caploc - channel information

%% Remove unused channels
   EEG = pop_select( EEG,'nochannel',{'FP1' 'FPZ' 'FP2' 'FT7' 'FT8' 'TP7' 'TP8' 'CB1' 'CB2' 'HEOG' 'PO5' 'PO6' 'E1' 'E2' 'E3' 'M1' 'M2'});
   [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

%% Relabel CPz as online reference (check this)  
   refno = find(strcmp({EEG.chanlocs.labels}, 'CPZ'));
    EEG.data(refno,:,:)=0;
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, refno);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');     
%% copy of all the channels you have (saved as EEG.allchan)
    EEG.allchan=EEG.chanlocs; 
    EEG = eeg_checkset( EEG );     
%   EEG.AllChannels=EEG.chanlocs;

%% Create folder
 mkdir([outPath filesep ID{aaa,1} filesep]);
%% RECODE DIGITSPAN 
here=pwd;
cd ([inPath,ID{aaa,1},filesep,Sesh{aa,1}]) 
logfile=[ID{aaa,1},'_' ,Sesh{aa,1},'_',tp{a,1},'-Digit Span.log'];
[EEG]=recodeDigitsBackwards(EEG,logfile,tp{a,1}) ; 
cd(here) 
%% Save Continuous File
EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_1.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]); %ds = downsample

%% Epoch all digits (correct) +/-1sec
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, { ['CR_',tp{a,1}] }, [-1  1], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-1000,0]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
 
%% filter the data (second order butterworth filter- from resting scripts/Caley- will need to check)
         EEG = pop_tesa_filtbutter( EEG, 1.000000e-01, 100, 4, 'bandpass' );
         EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );      

%% Save Epoched/Filtered Data 

mkdir([outPath filesep ID{aaa,1} filesep]);
 EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_2.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]); %epoched



        end    
    end
end


