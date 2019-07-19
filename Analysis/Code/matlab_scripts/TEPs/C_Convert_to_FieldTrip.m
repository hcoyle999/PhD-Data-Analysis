
% This script converts eeglab files in to field trip files. It will work
% for single pulse data and for uncorrected paired pulse data
clear; close all;
eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
cd(datadir);

% ##### SETTINGS #####

%ID = {'101';'103';'104';'105';'106';'108';'109';'110';'111';'112';'113';'114';'115';'116'};
ID = {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'017';'018';'019'};
ID= {'001';'002'};
inPath = [datadir filesep 'SP_analysis_Control' filesep];%where the data is
outPath = [datadir filesep 'SP_analysis_Control_FT' filesep]; %where you want to save the data

Sesh = {'T1'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Post'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

mkdir(outPath);

time = -2000:1:1999;

fs = 1000;




for x = 1:size(ID,1)
     
    for y = 1:size(Sesh,1)
        
        for z = 1:size(tp,1)
             
                            
        %LOAD DATA 
        EEG = pop_loadset('filename', [ID{x,1} '_SP_',Sesh{y,1},'_',tp{z,1} '_final.set'], 'filepath',[inPath filesep ID{x,1} filesep]);

      
        %%
        EEG = pop_select( EEG,'nochannel',{'M1' 'M2'});
        EEG = pop_reref( EEG, []);

    %convert to fieldtrip
    ftData = eeglab2fieldtrip(EEG, 'timelockanalysis');
    ftData.dimord = 'chan_time';
    
    %save
%     filename = [ID{a,1},fileExt,'_ft']; 
    
    filename = [ID{x,1} '_SP_' Sesh{y,1} '_final_' tp{z,1} '_ft'];
    

    save([outPath,filename],'ftData');
    
    fprintf('%s''s data converted from eeglab to fieldtrip\n', [ID{x,1} '_' Sesh{y,1} '_' tp{z,1}]); 
    
        end
    end
end

