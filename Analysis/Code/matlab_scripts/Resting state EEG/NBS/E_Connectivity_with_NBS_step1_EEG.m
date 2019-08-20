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

%have to change manually the conditions to get info for eo, ec and average 

ftID={'P001'};
SubjectStart=1;
SubjectFinish=numel(ftID);
%SubjectFinish=;
%SubjectFinish=1;

GroupStart=1;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1; %have to change manually for eo, ec and average

% load(data1m);
% load(data2m);

% THETA:


for Grp=GroupStart:GroupFinish
   
cd(['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_', Group{1,Grp}]);

if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P027','P028'};
% exlcuded participant 7 (equipment malf) and 016 (noisy data) total 26
% controls
else
ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129','P130'};
% all mtbi participants resting data included, total 30 mtbi
end
SubjectStart=1;
SubjectFinish= numel(ftID);


    for Subjects=SubjectStart:SubjectFinish; 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
 %% THETA   
        
        
 
        connectivitysavefile = ['power_wPLI_' (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
        
        f1=find(connectivityfile.freq>= 4 ,1,'first');
        f2=find(connectivityfile.freq<= 8 ,1,'last');
        
        connectivitytheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,f1:f2,:); % theta
        % averaging in time
        
        connectivitymeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(connectivitytheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,4); % theta

        
        % averaging in freq
        
        connectivitymeanFREQ.theta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantimetheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % theta

        
            end
        end
    end

%% GAMMA:

    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
        
       

        
        connectivitysavefile = ['power_wPLI_' (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
        
        f1=find(connectivityfile.freq>= 30 ,1,'first');
        f2=find(connectivityfile.freq<= 45 ,1,'last');
        
        connectivitygamma.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,f1:f2,:); % gamma
        
        
        % averaging in time
        
        connectivitymeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(connectivitygamma.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,4); % gamma
        
        % averaging in freq
        
        connectivitymeanFREQ.gamma.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantimegamma.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % gamma

        
            end
        end
    end

%% ALPHA:

    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
        
   
        
        connectivitysavefile = ['power_wPLI_' (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
        
        f1=find(connectivityfile.freq>= 8 ,1,'first');
        f2=find(connectivityfile.freq<= 12 ,1,'last');
        connectivityalpha.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,f1:f2,:); % alpha

        
        % averaging in time
        
        connectivitymeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(connectivityalpha.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,4); % alpha

        
        
        % averaging in freq
        
        connectivitymeanFREQ.alpha.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantimealpha.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % alpha

        
            end
        end
    end

%% BETA:

    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
        
       
        
        connectivitysavefile = ['power_wPLI_' (Timepoint{1,Time}) '_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
        
        f1=find(connectivityfile.freq>= 12,1,'first');
        f2=find(connectivityfile.freq<= 30 ,1,'last');
        connectivitybeta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,f1:f2,:); % beta
        % averaging in time
        
        connectivitymeantimebeta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(connectivitybeta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,4); % beta
        % averaging in freq
        
        connectivitymeanFREQ.beta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantimebeta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % beta
        %imagesc( connectivitymeanFREQ.beta.(Timepoint{1,Time}).(ftID{1,Subjects}))
        %drawnow
        
            end
        end
    end
mat='.mat';

savefile = ['connectivitymeanFREQ' '_' (Condition{1,Cond}), '.mat']
save (savefile, 'connectivitymeanFREQ');


end







        