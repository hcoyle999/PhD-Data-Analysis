clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
% cd(datadir);

% ##### SETTINGS #####
id = {'101';'103';'104';'105';'106';'108';'109';'110';'111';'112';'113';'114';'115';'116'};
%id = {'001';'002';'003';'004';'005';'006';'007';'008';'009';'010';'011';'012';'013';'014';'015';'016';'017';'018';'019'};

grp = 'P'; % 'P';

inPath = [datadir filesep 'SP_analysis_TBI_FT' filesep];%where the data is
outPath = [datadir filesep 'SP_analysis_TBI_FT' filesep]; %where you want to save the data

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Pre'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

% ##### SCRIPT #####


 for z = 1:size(tp,1)
     
    for y = 1:size(Sesh,1)
        
               for x = 1:size(id,1)
     
    filename = [id{x,1} '_SP_' Sesh{y,1} '_final_' tp{z,1} '_ft'];
    

    %load file
    load([inPath,filename]);
    
    id{x,1} = [grp id{x,1}];
    
    ALL.(id{x,1}) = ftData;

               end
%%

%Perform grand average
cfg=[];
cfg.keepindividual = 'yes';

%IMPOTANT! Check that number of id{x,1} is equal to number of participants
grandAverage = ft_timelockgrandaverage(cfg,...
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
        ALL.(id{14,1}));   
        %ALL.(id{15,1}),...
        %ALL.(id{16,1}),...
        %ALL.(id{17,1}),...        
        %ALL.(id{18,1}),...
        %ALL.(id{19,1}));
    

    
%Checks that the number of participants is correct
if size(id,1) ~= size(grandAverage.individual,1)
    error('Number of participants in grandAverage does not match number of participants in ID. Data not saved');
end

%set filename
filename = ['SP_' grp '_' Sesh{y,1} '_' tp{z,1} '_GA'];


%Save data
save([outPath,filename],'grandAverage');

    
    end
        
 
 end
