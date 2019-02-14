clear;

%ID = {'001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020'};

Group = {'Control','TBI'};
Timepoint = {'BL'};
Datatype = {'resting'};
Condition= {'eo', 'ec'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions


 % Do for eyes open and eyes closed seperately and then together.
 
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
%SubjectFinish=;
%SubjectFinish=1;

GroupStart=1;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=2;
ConditionFinish=2;



% load(data1m);
% load(data2m);

% THETA:


for Grp=GroupStart:GroupFinish
   
cd(['//Volumes/HOY BACKUP_/TMS_EEG Data/Resting_analysis_', Group{1,Grp}]);

if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020'};
else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116'};
ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116'};
end 
SubjectFinish= numel(ftID); 


    for Subjects=SubjectStart:SubjectFinish; 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
% THETA        
        powersavefile = ['power_'   (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(powersavefile);
        cfg=[];
        [powerfile] = ft_freqdescriptives(cfg, powerfile);        
        powertheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,5:9,:); % theta
        % averaging in time      
        powermeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(powertheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % theta
        % averaging in freq
        powermeanFREQ.theta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % theta

% GAMMA:
        powergamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,30:45,:); % gamma
        % averaging in time
        powermeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(powergamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % gamma
        % averaging in freq    
        powermeanFREQ.gamma.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % gamma
% ALPHA:        
        poweralpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,8:13,:); % alpha
        % averaging in time   
        powermeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(poweralpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % alpha
        % averaging in freq 
        powermeanFREQ.alpha.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % alpha   
            end
        end
    end

mat='.mat';

savefile = ['powermeanFREQ' '_' 'ec' '.mat'];
save (savefile, 'powermeanFREQ');

end







        