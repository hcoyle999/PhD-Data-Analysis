%--------------------------------------------------------------------------------%
%THIS SCRIPT TAKES THE CLEANED AND EPOCHED TMS-EEG DATA AND RUNS A TIME-FREQUENCY
%ANALYSIS OVER A BROAD WINDOW OF 4 - 45 HZ (THETA THROUGH TO GAMMA) USING
%MORLET WAVELET ANALYSIS TO GET TOTAL POWER OVER THESE FREQUENCIES
%--------------------------------------------------------------------------------%

%INPUT
clear; close all;
%eeglab_path='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b';
%cd(eeglab_path);
eeglab;
fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
addpath(fieldtrip_path);
cd(fieldtrip_path);
ft_defaults;

%datadir='F:\TMS_EEG Data\'; 
datadir='//Volumes/HOY_2/TMS_EEG Data/';
cd(datadir);

% ##### SETTINGS #####

ID = {'101';'103';'104';'105';'106';'108';'107';'109';'110';'111';'112';'113';'114';'115';'116'; '117';'118';'119';'120';'121';'122';'123';'124';'125';'126';'127';'128';'129';'130'};
%ID = {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028'};
%ID= {'126'};
inPath = [datadir filesep 'SP_analysis_TBI' filesep];%where the data is
outPath = [datadir filesep 'SP_analysis_TBI_Oscillations' filesep]; %where you want to save the data

% here=pwd;
% cd('/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623')
% ft_defaults;
% cd(here)
Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Post'}; % 'Post' (pre or post iTBS)
% tp = {'Pre';'Post';'Delay'}; %trigger points



%% POWER TOTAL (evoked and induced combined)
for x = 1:size(ID,1)
    for y = 1:size(Sesh,1)
        for z = 1:size(tp,1)
            
            EEG = pop_loadset('filename', [ID{x,1} '_SP_',Sesh{y,1},'_',tp{z,1} '_final.set'], 'filepath',[inPath filesep ID{x,1} filesep]);
            
            
            temp1=eeglab2fieldtrip(EEG, 'preprocessing'); %convert from EEGLAB to Fieldtrip
            
            % WAVELET ANALYSIS: FIXED WAVELET CYCLE
            cfg=[];
            cfg.channel={'all'};               %Channels to include
            cfg.method='wavelet';              %Wavelet analysis
            cfg.foi= 2:1:45;                   %Analysis between 2 and 45 Hz in steps of 1Hz
            cfg.toi= -1:0.001:1; 
            cfg.width= 3.5 %3.5./cfg.foi;                  %Determines the width of the wavelet in number of cycles
            cfg.output='pow';                  %Return the power spectra
                          %sliding wavelet window (1ms steps)
       
%         cfg.foi        = 0.5:1:45;
%         cfg.t_ftimwin  = 3./cfg.foi;
%         cfg.toi        = -1:0.05:1.998;
%         cfg.keeptrials = 'yes';
            
            %WAVELET ANALYSIS: VARIABLE WAVELET CYCLE LENGTH
            %Linear increasing Q, where Q defines the temporal and spectral
            %resolution of the wavelet. This will lead to increasing Q accross frequencies
            
            %         cfg=[];
            %         cfg.channel={'all'};
            %         cfg.method='wavelet';
            %         cfg.width= linspace(4, 8, length(4:1:45));
            %         cfg.output='pow';
            %         cfg.foi= 4:1:45;
            %         cfg.toi=-1.00:0.001:1.00;
            
            powerTotal = ft_freqanalysis(cfg,temp1);
            
            
            %% BASELINE NORMALIZATION
            % THIS STEP CREATES ADDITIONAL FILES WITH THE SUFFIX '_bc' followed by type of normalisation used (e.g., bc_db).
            % THESE FILES ARE BASELINE CORRECTED - SO USE THESE IF YOU WANT TO USE THE BASELINE CORRECTED FILES
            % OTHERWISE USE THE FILES WITHOUT THIS EXTENSION
                
            cfg = [];
            cfg.baseline = [-0.5 -0.1];    %correct from -500 to -100 ms
            cfg.baselinetype = 'db';%'relative'; %relative power
            cfg.parameter='powspctrm';
            PowerTotalBc = [];
            PowerTotalBc = ft_freqbaseline(cfg,powerTotal)
                  
            %% SAVEPOINT
            
            if ~exist([outPath,ID{x,1},filesep],'dir')
                mkdir([outPath,ID{x,1},filesep]);
            end
            
            %Save both normalised and non-normalised files
            filename = [ID{x,1} '_SP_' Sesh{y,1} '_final_' tp{z,1} '_TFR_fixed_3.5.mat'];
            save([outPath,filename],'powerTotal', 'PowerTotalBc');
            fprintf('%s''s data converted from eeglab to fieldtrip, wavelet analysis performed, baseline correction\n', ID{x,1});
        end
    end
end
