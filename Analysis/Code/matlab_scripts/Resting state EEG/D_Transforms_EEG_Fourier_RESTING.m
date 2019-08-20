% The following line gets rid of anything that might already be open:

clear all; close all; clc;

% The following lines sets up an 'array' of strings (sequence of letters). An array is a table where
% each cell contains the digits or letters within the quotation marks. The
% array created below is titled 'ID' (which is why 'ID' is on the left hand
% side of the equals sign). The values in the ID array are referred to
% later in order to call specific variables, so that the script knows which
% files to load.

% ID has a 'P' at the front of the participant number, because field trip
% (ft) saves files as .mat format, and MATLAB doesn't seem to like files
% to start with numbers.

% If you go into the MATLAB command window and look in the workspace (usually on the right hand side), you
% can view the variables and arrays that have been created. This is useful
% for testing whether you've created the correct array that refers to the
% correct file/folder. If MATLAB comes up with an error, this is a good way
% to trouble shoot.

eeglab;
fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
addpath(fieldtrip_path);
cd(fieldtrip_path);
ft_defaults;

datadir='//Volumes/HOY_2/TMS_EEG Data/';


% ID= {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';                '015';'017';'018';'019';'020';'021';'022';      '023';'024';'025';'026';'028'}; 
% ftID= {'P001';'P002';'P003';'P004';'P005';'P006';'P008';'P009';'P010';'P011';'P012';'P013';'P014';'P015';'P017';'P018';'P019';'P020';'P021';'P022';'P023';'P024';'P025';'P026';'P028'};
% ID=ID'; %% column transpose to row 
% ftID=ftID'; 

ID = {'101', '103', '105', '107',      '109',  '110', '111', '112', '116','118','119','120', '121',  '122', '124','125','126','127','129','130'};
ftID = {'P101', 'P103', 'P105', 'P107', 'P109', 'P110', 'P111', 'P112','P116','P118','P119','P120','P121','P122','P124','P125','P126','P127','P129', 'P130'};

% ID = {'130'}
% ftID = {'P130'} 

Group = {'Control','TBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre'};

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

% Below creates variables 'SubjectStart' and 'SubjectFinish', used to
% define which subjects from the 'ID' variable above will be processed
% today. For example, SubjectStart=1 and SubjectFinish=1 will allow you to
% process the first subject listed in the ID variable above. 'nume1(ID);'
% refers to the end of the ID array, so will allow you to process right
% through to the last participant listed if you would like. The same is
% true for ConditionStart and ConditionFinish.

% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

GroupStart=2;
GroupFinish=2;

SubjectStart=1;
SubjectFinish=numel(ID);
%SubjectFinish=17;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1
clear temp

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
 outfolder =  ['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_' Group{1,Grp} '/' Timepoint{1,Tp} ];
 mkdir(outfolder);
 cd(outfolder);



mat='_eo.mat';
        ICARejectedSetname = ['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_5.set'];
        EEG = pop_loadset(ICARejectedSetname);
EEG = pop_select( EEG,'nochannel',{'E3','M1','M2','CPZ'}); 
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );

        temp.(Timepoint{1,Tp}).(ftID{1,Subjects}) = EEG;
        
        Total=eeglab2fieldtrip(temp.(Timepoint{1,Tp}).(ftID{1,Subjects}), 'preprocessing', 'coord_transform');
       % FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');
        %% Loop over eyes open
eps= 1:EEG.trials; 
these=[find(strcmp({EEG.event.type},'eo'))];
eps(unique([EEG.event(these).epoch]))=[];

%% perform FFT XIANWEI STYLE
cfg = [];
cfg.method     = 'mtmfft';
cfg.taper      = 'hanning';
cfg.output     = 'fourier';% this keeps the complex of the data
cfg.pad        = 10; % this is to incrase the freq resolution; also cause the change of the power amplitude
cfg.foi        = 0.1:0.2:100; % 0.1 might be more accurate in IAF; the total power is the same.
cfg.keeptrials = 'yes' ; % turn yes on just for connectivity analysis
%%%%%%%%
        cd(outfolder);
        powerfile=ft_freqanalysis(cfg, Total);   
                powersavefile = ['power_' (Timepoint{1,Tp}) '_' (ftID{1,Subjects}) mat];
                save (powersavefile, 'powerfile');
                 %Debiased wPLI
                cfg = [];
                cfg.method = 'wpli_debiased';
                connectivityfile = ft_connectivityanalysis(cfg,powerfile);
                connectivitysavefile = ['power_wPLI_' (Timepoint{1,Tp}) '_' (ftID{1,Subjects}) mat];
                save (connectivitysavefile, 'connectivityfile');
     
    end
                 
        end
    end
end



%%%%% loop over EC
for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
   outfolder =  ['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_' Group{1,Grp} '/' Timepoint{1,Tp}];
   mkdir(outfolder);
   cd(outfolder);
mat='_ec.mat';
        ICARejectedSetname = ['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_5.set'];
        EEG = pop_loadset(ICARejectedSetname);
EEG = pop_select( EEG,'nochannel',{'E3','M1','M2','CPZ'});   
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
        
        temp.(Timepoint{1,Tp}).(ftID{1,Subjects}) = EEG;
 Total=eeglab2fieldtrip(temp.(Timepoint{1,Tp}).(ftID{1,Subjects}), 'preprocessing', 'coord_transform');
      
        %Eyes closed
eps= 1:EEG.trials; 
these= [find(strcmp({EEG.event.type},'ec'))];
eps(unique([EEG.event(these).epoch]))=[];
        
%% perform FFT XIANWEI STYLE
cfg = [];
cfg.method     = 'mtmfft';
cfg.taper      = 'hanning';
cfg.output     = 'fourier';% this keeps the complex of the data
cfg.pad        = 10; % this is to incrase the freq resolution; also cause the change of the power amplitude
cfg.foi        = 0.1:0.2:100; % 0.1 might be more accurate in IAF; the total power is the same.
cfg.keeptrials = 'yes' ; % turn yes on just for connectivity analysis
 %%%%%%%%
        cd(outfolder);
        powerfile=ft_freqanalysis(cfg, Total);

                powersavefile = ['power_' (Timepoint{1,Tp}) '_' (ftID{1,Subjects}) mat];
                save (powersavefile, 'powerfile');

                 %Debiased wPLI
                cfg = [];
                cfg.method = 'wpli_debiased';

                connectivityfile = ft_connectivityanalysis(cfg,powerfile);

                connectivitysavefile = ['power_wPLI_' (Timepoint{1,Tp}) '_' (ftID{1,Subjects}) mat];
                save (connectivitysavefile, 'connectivityfile');
     
             end
                 
        end
    end
end


