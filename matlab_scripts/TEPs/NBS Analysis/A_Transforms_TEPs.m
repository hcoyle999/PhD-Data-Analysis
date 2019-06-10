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

eeglab;
% fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
% addpath(fieldtrip_path);
% cd(fieldtrip_path);
% ft_defaults;
% datadir='//Volumes/HOY_2/TMS_EEG Data/';
datadir='F:\TMS_EEG Data';

ID = {'101', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116','117','118','119','120','121','122','123','124','125','126','127','128','129','130'};
ftID = {'P101', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116','P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129','P130'};

% 102 excluded  (29 included)

%ID = {'101'};
%ftID = {'P101'};

%ID =       {'001','002','003','004',       '005','006',  '008','009',   '010', '011', '012',   '013',  '014',  '015', '017',  '018','019',   '020','021',   '022','023',  '024', '025','026','027','028'};
%ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006','P008', 'P009', 'P010', 'P011',       ,'P013', 'P014', 'P015','P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P027','P028'};
%ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006','P008', 'P009', 'P010', 'P011', 'P012','P013', 'P014', 'P015','P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P027','P028'};

% 007 and 016 excluded from controls for TEPs analysis (26 included)

Group = {'Control','TBI'};
Timepoint = {'BL'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'TEPs'};
Condition= {'Pre','Post'};

%caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

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
ConditionFinish=2;
clear temp

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
 outfolder =  [datadir filesep 'SP_analysis_' Group{1,Grp}];
 mkdir(outfolder);
 cd(outfolder);

mat=['_' Condition{1,Cond} '.mat'];
        ICARejectedSetname = [datadir filesep 'SP_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,Cond} '_final.set'];
        %ICARejectedSetname = ['//Volumes/HOY_2/TMS_EEG Data/SP_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_SP_' Timepoint{1,Tp} '_' Condition{1,Cond} '_final.set'];
        EEG = pop_loadset(ICARejectedSetname);
EEG = pop_select( EEG,'nochannel',{'E3','M1','M2'});        
        temp.(Timepoint{1,Tp}).(ftID{1,Subjects}) = EEG;     
        Total=eeglab2fieldtrip(temp.(Timepoint{1,Tp}).(ftID{1,Subjects}), 'preprocessing', 'coord_transform');
       % FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');

   eps= 1:EEG.trials; 
%these=[find(strcmp({EEG.event.type},'eo'))];
%eps(unique([EEG.event(these).epoch]))=[];
        cfg=[];
        cfg.trials= [eps];
        cfg.channel={'all'};
        cfg.output     = 'fourier'%'pow';
        cfg.method     = 'mtmconvol';
        cfg.taper      = 'hanning';
        cfg.foi        = 0.5:1:45;
        cfg.t_ftimwin  = 3.5%/cfg.foi;
        cfg.toi        = -1:0.05:1.998;
        cfg.keeptrials = 'yes';

        
%             WAVELET ANALYSIS: FIXED WAVELET CYCLE
%             cfg=[];
%             cfg.channel={'all'};               %Channels to include
%             cfg.method='wavelet';              %Wavelet analysis
%             cfg.width= 3.5;                    %Determines the width of the wavelet in number of cycles
%             cfg.output='pow';                  %Return the power spectra
%             cfg.foi= 4:1:45;                   %Analysis between 4 and 45 Hz in steps of 1Hz
%             cfg.toi= -1:0.001:1;               %sliding wavelet window (1ms steps)
     
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





