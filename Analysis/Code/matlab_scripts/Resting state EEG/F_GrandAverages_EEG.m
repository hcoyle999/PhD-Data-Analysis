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

%eeglab_path='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b';
%cd(eeglab_path);
eeglab;
 fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
 addpath(fieldtrip_path);
 cd(fieldtrip_path);
ft_defaults;
%datadir='F:\TMS_EEG Data\'; 
 datadir='//Volumes/HOY_2/TMS_EEG Data/';

% BL participants included
%ftID = {'P001'; 'P002'; 'P003'; 'P004'; 'P005'; 'P006'; 'P008'; 'P009'; 'P010'; 'P011'; 'P012'; 'P013'; 'P014'; 'P015'; 'P017'; 'P018'; 'P019'; 'P020';'P021';'P022';'P023';'P024';'P025';'P026';'P027';'P028'};
%ftID = {'P101'; 'P102'; 'P103'; 'P104'; 'P105';'P106'; 'P107'; 'P108'; 'P109'; 'P110'; 'P111'; 'P112'; 'P113'; 'P114'; 'P115'; 'P116'; 'P117';'P118';'P119';'P120';'P121';'P122';'P123';'P124';'P125';'P126';'P127';'P128';'P129';'P130'};

% T1 participants included
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P028'}; %T1 exclude 007, 016, 027
%ftID = {'P101', 'P103', 'P105', 'P107', 'P109', 'P110', 'P111', 'P112', 'P116','P118','P119','P120','P121','P122','P124','P125','P126','P127','P129', 'P130'}; %T1 participants
ftID= ftID'

Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Condition = { 'eo'; 'ec'}; % or 'ec'
% tp = {'Pre';'Post';'Delay'}; %trigger points
grp ='C';%  'C' % or 'T';

inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_Control']; %where the data comes from
outPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_Statistics' filesep]; %where you want to save the data


%%
ft_defaults; 
 
for z = 1:size(Condition,1)
     
    for y = 1:size(Timepoint,1)
        
         for x = 1:size(ftID,1)
             
    filename = ['power', '_', Timepoint{y,1}, '_',ftID{x,1}, '_', Condition{z,1} '.mat'];

            %set filepath
            filepath = [inPath,filesep,Timepoint{y,1}, filesep];
            
            %load file
            load([filepath,filename]);
 cfg=[];
        [powerfile] = ft_freqdescriptives(cfg, powerfile);  
        

            %create structure - creates ID for particpants 
            ALL.(ftID{x,1}) = powerfile; %change to match savepoint from previous script
        end

        %Perform grand average
        cfg=[];
        cfg.keepindividual = 'yes';

        %IMPOTANT! Check that number of id{x,1} is equal to number of participants
        grandAverage = ft_freqgrandaverage(cfg,...
        ALL.(ftID{1,1}),...
        ALL.(ftID{2,1}),...
        ALL.(ftID{3,1}),...
        ALL.(ftID{4,1}),...
        ALL.(ftID{5,1}),...
        ALL.(ftID{6,1}),...
        ALL.(ftID{7,1}),...
        ALL.(ftID{8,1}),...
        ALL.(ftID{9,1}),...
        ALL.(ftID{10,1}),...
        ALL.(ftID{11,1}),...
        ALL.(ftID{12,1}),...
        ALL.(ftID{13,1}),...
        ALL.(ftID{14,1}),...   
        ALL.(ftID{15,1}),...
        ALL.(ftID{16,1}),...
        ALL.(ftID{17,1}),...        
        ALL.(ftID{18,1}),...
        ALL.(ftID{19,1}),...
        ALL.(ftID{20,1}),...
        ALL.(ftID{21,1}),...
        ALL.(ftID{22,1}),...
        ALL.(ftID{23,1}),...
        ALL.(ftID{24,1}),...
        ALL.(ftID{25,1}));
%         ALL.(ftID{26,1}),...
%         ALL.(ftID{27,1}),...
%         ALL.(ftID{28,1}),...
%         ALL.(ftID{29,1}),...
%         ALL.(ftID{30,1}));
         

        %Checks that the number of participants is correct
        if size(ftID,1) ~= size(grandAverage.powspctrm,1)
            error('Number of participants in grandAverage does not match number of participants in ID. Data not saved');
        end

        %set filename
       filename = ['Resting_' grp '_' Timepoint{y,1} '_' Condition{z,1} '_GA'];

        %Save data
        mkdir([outPath filesep Timepoint{y,1}])
        cd ([outPath filesep Timepoint{y,1}])
        %save([outPath,filename],'grandAverage');
        save(filename,'grandAverage');
    end
 end

 
