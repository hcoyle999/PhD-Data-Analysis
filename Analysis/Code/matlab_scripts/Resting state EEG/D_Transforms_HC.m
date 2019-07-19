% The following line gets rid of anything that might already be open:

clear all; close all; clc;

% The following lines sets up an 'array' of strings (sequence of letters). An array is a table where
% each cell contains the digits or letters within the quotation marks. The
% array created below is titled 'ID' (which is why 'ID' is on the left hand
% side of the equals sign). The values in the ID array are referred to
% later in order to call specific variables, so that the script knows which
% files to load.

% ftID has a 'P' at the front of the participant number, because field trip
% (ft) saves files as .mat format, and MATLAB doesn't seem to like files
% to start with numbers.

% If you go into the MATLAB command window and look in the workspace (usually on the right hand side), you
% can view the variables and arrays that have been created. This is useful
% for testing whether you've created the correct array that refers to the
% correct file/folder. If MATLAB comes up with an error, this is a good way
% to trouble shoot.

eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';

%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116','117'};
%ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116','P117'};

ID = {'001', '002', '003', '004', '005', '006', [], '008', '009', '010', '011', [], '013', '014', '015',[], '017', '018', '019', '020'};
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006',[],  'P008', 'P009', 'P010', 'P011', [], 'P013', 'P014', 'P015', [],'P017', 'P018', 'P019', 'P020'};

Group = {'Control','TBI'};
Timepoint = {'T1'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

% Below creates variables 'SubjectStart' and 'SubjectFinish', used to
% define which subjects from the 'ID' variable above will be processed
% today. For example, SubjectStart=1 and SubjectFinish=1 will allow you to
% process the first subject listed in the ID variable above. 'nume1(ID);'
% refers to the end of the ID array, so will allow you to process right
% through to the last participant listed if you would like. The same is
% true for ConditionStart and ConditionFinish.

% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

GroupStart=1;
GroupFinish=1;

SubjectStart=1;
SubjectFinish=16;
%SubjectFinish=17;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
 outfolder =  ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp}];
 mkdir(outfolder);
 cd(outfolder);



mat='_eo.mat';
        ICARejectedSetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_5.set'];
        EEG = pop_loadset(ICARejectedSetname);
EEG = pop_select( EEG,'nochannel',{'E3','M1','M2'});        
        temp.(Timepoint{1,Tp}).(ftID{1,Subjects}) = EEG;

        Total=eeglab2fieldtrip(temp.(Timepoint{1,Tp}).(ftID{1,Subjects}), 'preprocessing', 'coord_transform');
       % FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');
        %% Loop over eyes open
eps= 1:EEG.trials; 
these= [find(strcmp({EEG.event.type},'eo'))];
eps(unique([EEG.event(these).epoch]))=[];

        cfg=[];
        cfg.trials= [eps];
        cfg.channel={'all'};
        cfg.output     = 'fourier';
        cfg.method     = 'mtmconvol';
        cfg.taper      = 'hanning';
        cfg.foi        = 0.5:1:45;
        cfg.t_ftimwin  = 3./cfg.foi;
        cfg.toi        = 0:0.05:1.998;
        cfg.keeptrials = 'yes';

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
mat='_ec.mat';
        ICARejectedSetname = ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_' Group{1,Grp} '/' ID{1,Subjects} '/' ID{1,Subjects} '_resting_' Timepoint{1,Tp} '_' Condition{1,Cond} '_5.set'];
        EEG = pop_loadset(ICARejectedSetname);
EEG = pop_select( EEG,'nochannel',{'E3','M1','M2'});   
        
        temp.(Timepoint{1,Tp}).(ftID{1,Subjects}) = EEG;
 Total=eeglab2fieldtrip(temp.(Timepoint{1,Tp}).(ftID{1,Subjects}), 'preprocessing', 'coord_transform');
      
        %Eyes closed
eps= 1:EEG.trials; 
these= [find(strcmp({EEG.event.type},'ec'))];
eps(unique([EEG.event(these).epoch]))=[];

        cfg=[];
        cfg.trials= [eps];
        cfg.channel={'all'};
        cfg.output     = 'fourier';
        cfg.method     = 'mtmconvol';
        cfg.taper      = 'hanning';
        cfg.foi        = 0.5:1:45;
        cfg.t_ftimwin  = 3./cfg.foi;
        cfg.toi        = 0:0.05:1.998;
        cfg.keeptrials = 'yes';

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


