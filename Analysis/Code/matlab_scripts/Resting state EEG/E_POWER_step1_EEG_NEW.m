clear;

Group = {'Control','TBI'};
Timepoint = {'T1'};
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

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=2;   %% HAVE to change manually for some reason
ConditionFinish=2;

dorel=0

% load(data1m);
% load(data2m);

% THETA:

for Grp=GroupStart:GroupFinish
if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P028'}; %T1 exclude 007, 016, 027
else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116'};
%ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108',
%'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129', 'P130'}; %BL participants 
ftID = {'P101', 'P103', 'P105', 'P107', 'P109', 'P110', 'P111', 'P112', 'P116','P118','P119','P120','P121','P122','P124','P125','P126','P127','P129', 'P130'}; %T1 participants

end
SubjectFinish= numel(ftID); 


    for Subjects=SubjectStart:SubjectFinish; 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
                
cd(['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_', Group{1,Grp}, filesep, Timepoint{1,Time}]);

% THETA        
        powersavefile = ['power_'  (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(powersavefile);
        cfg=[];
        [powerfile] = ft_freqdescriptives(cfg, powerfile);  
        %% do relative power transformation
if dorel==1
minf = 0.1; maxf=45;
t1=find(powerfile.freq>= minf,1,'first');
t2=find(powerfile.freq<= maxf ,1,'last');
    rawpow= powerfile.powspctrm(:,:); 
    totpow= sum(powerfile.powspctrm(:,t1:t2),2);
relpow= rawpow./totpow; 
powerfile.powspctrm(:,:)=relpow; 
%     
end
        f1=find(powerfile.freq>= 4 ,1,'first');
        f2=find(powerfile.freq<= 8 ,1,'last');
        
        powertheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,f1:f2,:); % theta
        % averaging in time      
        powermeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(powertheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % theta
        % averaging in freq
        powermeanFREQ.theta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % theta

        
 % BETA:
        f1=find(powerfile.freq>= 12,1,'first');
        f2=find(powerfile.freq<= 30 ,1,'last');

        powerbeta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,f1:f2,:); % beta
        % averaging in time      
        powermeantimebeta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(powerbeta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % beta
        % averaging in freq
        powermeanFREQ.beta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimebeta.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % beta    
        
% GAMMA:
        f1=find(powerfile.freq>= 30 ,1,'first');
        f2=find(powerfile.freq<= 45 ,1,'last');

        powergamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,f1:f2,:); % gamma
        % averaging in time
        powermeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(powergamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % gamma
        % averaging in freq    
        powermeanFREQ.gamma.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % gamma

% ALPHA:  
        f1=find(powerfile.freq>= 8 ,1,'first');
        f2=find(powerfile.freq<= 12 ,1,'last');
         
        poweralpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=powerfile.powspctrm (:,f1:f2,:); % alpha
        % averaging in time   
        powermeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm=nanmean(poweralpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,3); % alpha
        % averaging in freq 
        powermeanFREQ.alpha.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(powermeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).powspctrm,2); % alpha   
            end
        end
    end

mat='.mat';

savefile = ['powermeanFREQ' '_' (Condition{1,Cond}), '.mat'];
if dorel==1;
    savefile = ['powermeanFREQ' '_' (Condition{1,Cond}), '_rel.mat'];
end
%savefile = ['powermeanFREQ' '_', (Condition{1,Cond}), '.mat'];
save (savefile, 'powermeanFREQ');

end





% numbers for analysis = powermeanFREQ.P101 (1,:), powermeanFREQ.P102 (2,:)


        