clear;

suf='.mat';

%ID = {'001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020'};
%ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020'};

%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116'};
ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116'};

Group = {'Control','TBI'};
Timepoint = {'BL'};
Datatype = {'resting'};
Condition= {'eo', 'ec', 'average'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

SubjectStart=1;
SubjectFinish=numel(ftID);
%SubjectFinish=1;



for Grp=1:2
    
if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020'};
else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116'};
ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116'};
end 
SubjectFinish= numel(ftID); 
 
    
    
for Cond= 1:3

cd( ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_', Group{Grp}] );

% load(data1m);
% load(data2m);

% THETA:
clear powermeanALL

fname = ['powermeanFREQ_', Condition{Cond} ,  '.mat'];
load(fname);

for  Subjects=SubjectStart:SubjectFinish;
    
            powermeanALL.theta.BL (:,:,Subjects)=powermeanFREQ.theta.BL.(ftID{1,Subjects});
            powermeanALL.gamma.BL (:,:,Subjects)=powermeanFREQ.gamma.BL.(ftID{1,Subjects});
            powermeanALL.alpha.BL (:,:,Subjects)=powermeanFREQ.alpha.BL.(ftID{1,Subjects});
end
     
  
    
savefile = ['powermeanALL','_', Condition{Cond}, '.mat'];
save (savefile, 'powermeanALL');

%% EXTRACTO-MATIC

%% REGION OF INTEREST 
THISCHAN = [4,6,12,14] %MY CHANNEL OF INTEREST 
THISBAND = {'theta'}
DAT= mean( squeeze(powermeanALL.(THISBAND{1,1}).BL(THISCHAN,1,:)),1 )' ;
savefile = ['powermeanROI_',THISBAND{1,1},'_', Condition{Cond}, '.mat'];
save (savefile, 'DAT');


%% CHANNEL OF INTEREST 
THISCHAN = [5] ;%f3 
THISBAND = {'theta'}
DAT=squeeze(powermeanALL.(THISBAND{1,1}).BL(THISCHAN,1,:)) ;
savefile = ['powermeanF3_',THISBAND{1,1},'_', Condition{Cond}, '.mat'];
save (savefile, 'DAT');
end

end

    