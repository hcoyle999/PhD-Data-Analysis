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

% Below creates variables 'SubjectStart' and 'SubjectFinish', used to
% define which subjects from the 'ID' variable above will be processed
% today. For example, SubjectStart=1 and SubjectFinish=1 will allow you to
% process the first subject listed in the ID variable above. 'nume1(ID);'
% refers to the end of the ID array, so will allow you to process right
% through to the last participant listed if you would like. The same is
% true for ConditionStart and ConditionFinish.

% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

SubjectStart=1;
SubjectFinish=numel(ftID);
%SubjectFinish=1;

% ConditionStart=1;
% ConditionFinish=1;

for Grp=1:2
    
if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P016' 'P017', 'P018', 'P019', 'P020'};
else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117'};
ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117'};
end 
SubjectFinish= numel(ftID); 
 
    
    
for Cond= 1:3

cd( ['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_', Group{Grp}] );

% load(data1m);
% load(data2m);

% THETA:
clear connectivitymeanALL

wPLIname = ['connectivitymeanFREQ_', Condition{Cond} ,  '.mat'];
load(wPLIname);

for  Subjects=SubjectStart:SubjectFinish;
    

            connectivitymeanALL.theta.BL (:,:,Subjects)=connectivitymeanFREQ.theta.BL.(ftID{1,Subjects});
            connectivitymeanALL.gamma.BL (:,:,Subjects)=connectivitymeanFREQ.gamma.BL.(ftID{1,Subjects});
            connectivitymeanALL.alpha.BL (:,:,Subjects)=connectivitymeanFREQ.alpha.BL.(ftID{1,Subjects});
end
     
  
    
savefile = ['connectivitymeanALL','_', Condition{Cond}, '.mat'];
save (savefile, 'connectivitymeanALL');

end

end

    