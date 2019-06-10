clear;
suf='.mat';

Group = {'Control','TBI'};
Timepoint = {'bp', 'ap'}; %before pulse, after pulse
Datatype = {'TEPs'};
Condition= {'Pre', 'Post'};

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


for Grp=2:2
    
if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P027','P028'};
% excluded participant 7 (equipment malf) and 016 (noisy data) total 26
% controls
else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116', '117'};
ftID = {'P101', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129','P130'};
% exluded participant 102 mtbi participants teps included, total 29 mtbi
% tbi participants
end 
SubjectFinish= numel(ftID); 
 
  % datadir='//Volumes/HOY_2/TMS_EEG Data/';
datadir='F:\TMS_EEG Data';  
    
for Cond= 1:2

cd( [datadir filesep 'SP_analysis_', Group{Grp}] );

% load(data1m);
% load(data2m);

% THETA:
clear connectivitymeanALL

wPLIname = ['connectivitymeanFREQ_', Group{1,Grp},'_',(Condition{1,Cond}), '.mat'];
load(wPLIname);

for  Tp= 1:2
for  Subjects=SubjectStart:SubjectFinish;
    

            connectivitymeanALL.theta.(Timepoint{Tp}) (:,:,Subjects)=connectivitymeanFREQ.theta.(Timepoint{Tp}).(ftID{1,Subjects}); %takes each ptx substructure and turns
            connectivitymeanALL.gamma.(Timepoint{Tp}) (:,:,Subjects)=connectivitymeanFREQ.gamma.(Timepoint{Tp}).(ftID{1,Subjects}); % it into a 3D matrix
            connectivitymeanALL.alpha.(Timepoint{Tp}) (:,:,Subjects)=connectivitymeanFREQ.alpha.(Timepoint{Tp}).(ftID{1,Subjects});
            connectivitymeanALL.beta.(Timepoint{Tp}) (:,:,Subjects)=connectivitymeanFREQ.beta.(Timepoint{Tp}).(ftID{1,Subjects});
end
end
     
  
    
savefile = ['connectivitymeanALL','_', Group{1,Grp}, '_' Condition{Cond}, '.mat'];
save (savefile, 'connectivitymeanALL');

end

end

    