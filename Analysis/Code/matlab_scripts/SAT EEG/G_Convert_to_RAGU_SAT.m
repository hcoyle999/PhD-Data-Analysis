
% This script converts eeglab files in to field trip files. It will work
% for single pulse data and for uncorrected paired pulse data
clear; close all;
datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
%caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;

Tp = {'BL'}; 
Condition= {'CRT'};
Group = {'Control','TBI'};

% ----------editable section  -------%
SubjectStart=1;
%SubjectFinish=;

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;

for Grp=GroupStart:GroupFinish
    
    
    if Grp==1
        % control participants included in analysis (N= 17)
        ID = {'001','009','010','012','013','014','015','017','018','019','020', '021','022','023','024','027','028'};
        countfilename='EpochCount_Control.csv';
    else
        % mtbi participants included in analysis (N= 20)
        ID= {'103','105','106','108', '109' '110', '111', '112','113','114','115', '116','117','119','120','122', '124','127','129','130'};
        countfilename='EpochCount_TBI.csv';
    end
    SubjectFinish= numel(ID);
    %ID= {'001'};
    
    inPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1,Grp}];
    outPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_RAGU']; 
    EpochCount=nan(size(ID,5))
    
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
   

        %LOAD DATA 
       cd(inPath);
       filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_6.set'];
       EEG = pop_loadset(filename);
   
        %load('mychans50.mat')
        %EEG = pop_interp(EEG, mychans, 'spherical'); 
        [chns,pnts,eps] = size(EEG.data);

        % baseline correction
       % EEG = pop_rmbase( EEG, [-100    0]);

       temp = EEG;
        % epoch from -100 to 900ms post
       EEG = pop_selectevent( EEG, 'type',{'Go_hit'},'latency', '-10 <= 10', 'deleteevents','on','deleteepochs','on','invertepochs','off'); 
        
       EEG = pop_epoch( EEG, {}, [-0.1  0.9], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
       [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
       
       EEG = eeg_checkset( EEG )
        %SPLIT INTO SEPERATE FILES

Go_hit = EEG;

mkdir(outPath)
cd([outPath])
%convert to ascii file
%pop_export(EEG,'filename',,'precision',7);
fn=['Go_hit','_CRT_',Tp{1,Time},'_' 'S',ID{1,Subjects},'.asc']; 

DATA=mean(EEG.data,3)'; 
dlmwrite(fn, DATA, 'delimiter','\t');  
%  pop_export(Pre,fn,'transpose','on','erp','on');

countHit(Subjects,Time)=size(Go_hit.data,3)

EEG = temp;

       EEG = pop_selectevent( EEG, 'type',{'NoGo_other'},'latency', '-10 <= 10', 'deleteevents','on','deleteepochs','on','invertepochs','off'); 
        
       EEG = pop_epoch( EEG, {}, [-0.1  0.9], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
       [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
       

NoGo_other  = EEG;
cd([outPath]);
%convert to ascii file
%pop_export(EEG,'filename',,'precision',7);
fn=['NoGo_other','_CRT_',Tp{1,Time},'_' 'S',ID{1,Subjects},'.asc']; 
%pop_export(Post,fn,'transpose','on','erp','on');
DATA=mean(EEG.data,3)'; 
 dlmwrite(fn, DATA, 'delimiter','\t');  
               
 countNoGo(Subjects,Time)=size(NoGo_other.data,3); 
% 
 EpochCount(Subjects,1)= str2num(ID{1,Subjects});
 EpochCount(Subjects,2)=size(Go_hit.data,3); 
 EpochCount(Subjects,3)=size(NoGo_other.data,3);
 EpochCount(Subjects,4)=size(Go_hit.data,1); 
 EpochCount(Subjects,5)=size(NoGo_other.data,2);

            end
         end
    end
end

 disp(EpochCount);
 csvwrite(countfilename,EpochCount);
 %csvwrite('chans.xyz',COG);
% For making channel file for RAGU
%dlmwrite('xyz_new_new', mychans2, 'delimiter','\t');  
