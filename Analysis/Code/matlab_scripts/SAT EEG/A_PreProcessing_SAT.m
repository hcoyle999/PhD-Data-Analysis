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

inPath = [datadir filesep 'SAT_analysis' filesep 'SAT_Data' filesep 'raw_data'];


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
   
cd(inPath);

if Grp==1
% control participants included in analysis (N= 17)
%ID = {'001','009','010','012','013','014','015','017','018','019','020', '021','022','023','024','027','028'};
else
% mtbi participants included in analysis (N= 20)
%ID= {'103','105','106','108', '109' '110', '111', '112','113','114','115', '116','117','119','120','122', '124','127','129','130'};
end
ID= {'114'};
SubjectFinish= numel(ID);


    for Subjects=SubjectStart:SubjectFinish 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

    % Loading data
    cd(inPath);
    filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'.cnt'];
    EEG = pop_loadcnt(filename, 'dataformat', 'auto', 'memmapfile', '');
    EEG = eeg_checkset( EEG );
    
%% Downsample
    EEG=pop_resample(EEG,1000)
    
%% Channel locations
    EEG = pop_chanedit(EEG, 'lookup', caploc); %caploc - channel information

%% Remove unused channels
   EEG = pop_select( EEG,'nochannel',{'FP1' 'FPZ' 'FP2' 'FT7' 'FT8' 'TP7' 'TP8' 'CB1' 'CB2' 'HEOG' 'PO5' 'PO6' 'E1' 'E2' 'E3' 'M1' 'M2'});
   [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 

%% Relabel CPz as online reference (check this)  
   refno = find(strcmp({EEG.chanlocs.labels}, 'CPZ'));
    EEG.data(refno,:,:)=0;
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, refno);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');     
%% copy of all the channels you have (saved as EEG.allchan)
    EEG.allchan=EEG.chanlocs; 

    %save temp file for trouble shooting
    temp=EEG;
%% RECODE Go and No Go conditions
cd ([inPath]);
logfile=[ID{1,Subjects}, '_', Tp{1,Time}, '-Go-NoGo Task.log'];
[EEG]=recodeGoNoGo(EEG,logfile) ; 
EEG = eeg_checkset( EEG );
% 
% 
% %    blk=0; 
% for a = 1:size(EEG.event,2)-1;
%     
%     evt= num2str(EEG.event(a).type);
%     evt2= num2str(EEG.event(a+1).type);
% %     
% %     if strcmp(evt, '99') 
% %         blk=blk+1; 
% %     end 
%     
% %     if blk>0
%             if strcmp(evt, '10') && (strcmp( evt2, '1'));
%                 EEG.event(a).type = 'Go_Hit';
%                 EEG.urevent(a).type = 'Go_Hit';
%             elseif strcmp(evt, '10') && (strcmp( evt2, '10'))|(strcmp( evt2, '100'));
%                 EEG.event(a).type = 'Go_Miss';
%                 EEG.urevent(a).type = 'Go_Miss';
%             elseif strcmp(evt, '100') && ( strcmp(evt2, '1'));
%                 EEG.event(a).type = 'NoGo_FA';
%                 EEG.urevent(a).type = 'NoGo_FA';
%             elseif strcmp(evt, '100') && (strcmp( evt2, '10'))|(strcmp( evt2, '100'));
%                 EEG.event(a).type = 'NoGo_CR';
%                 EEG.urevent(a).type = 'NoGo_CR';
%             elseif strcmp(evt, '99');
%                 EEG.event(a).type = 'Break';
%                 EEG.urevent(a).type = 'Break';
%             end
%     end

            
%% Save Continuous File
EEG = eeg_checkset( EEG );
outPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1, Grp}]; %where you want to save the data
mkdir(outPath);
cd(outPath);
filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_1.set'];
EEG = pop_saveset(EEG, filename); %ds = downsample

%% filter the data (second order butterworth filter)
         EEG = pop_tesa_filtbutter( EEG, 1.000000e-01, 100, 4, 'bandpass' );
         EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' ); 
         
%% Epoch the data
EEG = eeg_checkset( EEG );
EEG = pop_epoch( EEG, {'NoGo_other', 'Go_hit', 'NoGo_false_alarm', 'Go_miss' },[-1  2], 'newname', 'CNT file epochs', 'epochinfo', 'yes');
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-100,0]); %remove baseline 
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
 
cd(outPath);     
%% Save Epoched/Filtered Data 
filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_2.set'];
EEG = pop_saveset(EEG, filename); 

            end
        end
    end
    
end

