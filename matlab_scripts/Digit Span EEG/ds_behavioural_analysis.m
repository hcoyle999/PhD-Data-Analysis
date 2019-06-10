clear all; close all; clc;

eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
outpath_1='/Users/han.coyle/Documents/PHD-Data-Analysis/PHD-Data-Analysis/Analysis/Data'

%ID = {'120','121','122','123'}
%ID = {'002', '003', '004', '005', '006', '007', '008', '009', '010','011', '012', '013'};
%ID = {'105'; '106'; '107'; '108'; '109'; '110'; '111'};
Group = {'Control','TBI'};
Timepoint = {'BL','T1','T2'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
Condition= {'Pre','Post','Delay'};

these=[];
GroupStart=1;
GroupFinish=2;

%SubjectStart=1;
%SubjectFinish=numel(ID);
%SubjectFinish=nume1(ID);

TimepointStart=1;
TimepointFinish=3;

ConditionStart=1;
ConditionFinish=3;

for Grp=GroupStart:GroupFinish
    if Grp==1
ID = {'001', '002', '003', '004', '005', '006', '008', '009', '010', '011', '012', '013', '014', 'P015','016', '017', '018', '019', '020','021','022','023','024','025','026','027','028'};

else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116','117'};
ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117','118','119','120','121','122','123','124','125','126','127','128','129'};
end
SubjectStart=1;
SubjectFinish= numel(ID);
    
    for Subjects=SubjectStart:SubjectFinish
        for Tp=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

                
inPath = [datadir filesep Group{1,Grp} filesep];
outPath = [outpath_1 filesep 'ds_behavioural_analysis' filesep ID{1,Subjects}]; %where you want to save the data

mkdir(outPath);
  %load text summmary file for digit span
  
  textFilename = [ID{1,Subjects} '/' Timepoint{1,Tp} '/' ID{1,Subjects} '_' Timepoint{1,Tp}, '_' Condition{1,Cond},'-Digit Span.txt'];
  try
  fopen(fullfile(inPath, textFilename));
   copyfile(fullfile(inPath,textFilename), outPath)
  catch 
   disp('file missing')
   disp(textFilename);
   end
 % if exist(textFilename, 'file') == 0
      %
 %end
            end
        end
    end
end
 
   
    

