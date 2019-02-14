clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
%cd(datadir);
%SETTINGS

eeglab;
%ID= {'101';'102';'103';'104';'105'; '106'; '107'; '110'; '111'; '113';'113';'114';'115';'116';'117';'118';'119';'120';'121';'122'};
ID= {'108'};
%ID = {'002';'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015';'016'; '017'; '018'; '019';'020';'021'}
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
    % Loading data
    EEG = pop_loadset([inPath,ID{aaa,1}, filesep, ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_5.set']);
    EEG = eeg_checkset( EEG );
    
    % The following section runs AMICA (a slow but the most accurate
    % version of ICA)
    
    % You'll need to install amica12 first, and in the folder that you
    % specify in the line below:
    
    % You can download amica12 from http://sccn.ucsd.edu/~jason/amica_web.htmlhttp://sccn.ucsd.edu/~jason/amica12/loadmodout12.m
    
    
    cd ('/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/amica1.5/');
    
    %Run AMICA
    [EEG.icaweights, EEG.icasphere, mods] = runamica15(EEG.data(:,:));
    EEG = eeg_checkset( EEG );
    
    % Other options for running ICA are listed below (fastica, which is a
    % fast version, and binica, which is a medium speed and accuracy
    % version) See Delorme, Palmer, Onton, Oostenveld, Makeig (2012) -
    % 'Independent EEG sources are dipolar' for a comparison of the different
    % ICA methods and their pros and cons.
    
    % Note also that FASTICA requires installing in the matlab folder, and
    % can be downloaded from http://research.ics.aalto.fi/ica/fastica/
    
    % EEG = pop_runica(EEG,'icatype','runica','approach', 'extended',1);
    % [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);

    % EEG = pop_runica(EEG,'icatype','fastica', 'approach', 'symm', 'g', 'tanh');

    mkdir([outPath filesep ID{aaa,1} filesep]);
     EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_6.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]); %AMICA run


        end
    end
end
