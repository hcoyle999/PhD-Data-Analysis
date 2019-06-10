%-----------------------------------------------------------------------%
% GRAND AVERAGE TIME FREQUENCY ANALYSIS
% This script converts single fieldtrip files in to a grand average which
% is required for input in to the cluster-based permutation statistics
% script.

% IMPORTANT!!!
% Before running the script, make sure that the number of id{x,1} is equal 
% the to number of participants 
%-----------------------------------------------------------------------%
clear; close all;

eeglab_path='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b';
cd(eeglab_path);
eeglab;
% fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
% addpath(fieldtrip_path);
% cd(fieldtrip_path);
ft_defaults;
datadir='F:\TMS_EEG Data\'; 
% datadir='//Volumes/HOY_2/TMS_EEG Data/';

id = {'101';'103';'104';'105';'106';'108';'107';'109';'110';'111';'112';'113';'114';'115';'116'; '117';'118';'119';'120';'121';'122';'123';'124';'125';'126';'127';'128';'129';'130'};
%id = {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028'};
%id= {'001'};

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Post'}; % 'Post' (pre or post iTBS)
% tp = {'Pre';'Post';'Delay'}; %trigger points
grp = 'T'; % 'C' or 'T';

inPath = [datadir filesep 'SP_analysis_TBI_Oscillations' filesep]; %where you want to save the data
outPath = [datadir filesep 'SP_analysis_TBI_Oscillations' filesep]; %where you want to save the data


%%
ft_defaults;

 for z = 1:size(tp,1)
     
    for y = 1:size(Sesh,1)
        
               for x = 1:size(id,1)
     
    filename = [id{x,1} '_SP_' Sesh{y,1} '_final_' tp{z,1} '_TFR2.mat'];
   
            %set filepath
            filepath = [inPath,filesep];
            
            %load file
            load([filepath,filename]);

            %create structure - creates ID for particpants 
            id{x,1} = ['P',id{x,1}];      %Need a letter in front of ID numbers for script to work - hence 'P'
            ALL.(id{x,1}) = PowerTotalBc; %change to match savepoint from previous script
        end

        %Perform grand average
        cfg=[];
        cfg.keepindividual = 'yes';

        %IMPOTANT! Check that number of id{x,1} is equal to number of participants
        grandAverage = ft_freqgrandaverage(cfg,...
         ALL.(id{1,1}),...
        ALL.(id{2,1}),...
        ALL.(id{3,1}),...
        ALL.(id{4,1}),...
        ALL.(id{5,1}),...
        ALL.(id{6,1}),...
        ALL.(id{7,1}),...
        ALL.(id{8,1}),...
        ALL.(id{9,1}),...
        ALL.(id{10,1}),...
        ALL.(id{11,1}),...
        ALL.(id{12,1}),...
        ALL.(id{13,1}),...
        ALL.(id{14,1}),...   
        ALL.(id{15,1}),...
        ALL.(id{16,1}),...
        ALL.(id{17,1}),...        
        ALL.(id{18,1}),...
        ALL.(id{19,1}),...
        ALL.(id{20,1}),...
        ALL.(id{21,1}),...
        ALL.(id{22,1}),...
        ALL.(id{23,1}),...
        ALL.(id{24,1}),...
        ALL.(id{25,1}),...
        ALL.(id{26,1}),...
        ALL.(id{27,1}),...
        ALL.(id{28,1}),...
        ALL.(id{29,1}));
         %ALL.(id{29,1}));

        %Checks that the number of participants is correct
        if size(id,1) ~= size(grandAverage.powspctrm,1)
            error('Number of participants in grandAverage does not match number of participants in ID. Data not saved');
        end

        %set filename
       filename = ['SP_' grp '_' Sesh{y,1} '_' tp{z,1} '_GA_2'];

        %Save data
        save([outPath,filename],'grandAverage');

    end
end
