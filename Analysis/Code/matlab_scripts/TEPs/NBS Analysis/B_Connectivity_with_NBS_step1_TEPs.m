clear;

%ID = {'001', '002', '003', '004', '005', '006', '007', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020'};

Group = {'Control','TBI'};
Timepoint = {'bp','ap'};
Datatype = {'TEPs'};
Condition= {'Pre', 'Post'};

%caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions


 % Do for Pre and Post seperately.
 
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

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=2;

ConditionStart=1;
ConditionFinish=2; %have to change manually for Pre and Post
% datadir='//Volumes/HOY_2/TMS_EEG Data/';
datadir='F:\TMS_EEG Data';


% load(data1m);
% load(data2m);

% THETA:


for Grp=GroupStart:GroupFinish
   
cd([datadir filesep 'SP_analysis_', Group{1,Grp}]);

if Grp==1
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P027','P028'};
cd([datadir filesep 'SP_analysis_', Group{1,Grp}]);
% exlcuded participant 7 (equipment malf) and 016 (noisy data) total 26
% controls
 
else
ftID = {'P101', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108', 'P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116', 'P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129','P130'};
cd([datadir filesep 'SP_analysis_', Group{1,Grp}]);
% exluded participant 102 mtbi participants teps included, total 29 mtbi
% tbi participants
end
SubjectStart=1;
SubjectFinish= numel(ftID);
  for Cond=ConditionStart:ConditionFinish

    for Subjects=SubjectStart:SubjectFinish; 
        for Time=TimepointStart:TimepointFinish  % time refers to bp = before pulse, ap= after pulse

 %% THETA   
        connectivitysavefile = ['power_wPLI_BL_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
     dat1=connectivityfile.wpli_debiasedspctrm (:,:,4:8,1:21); 
     dat2=connectivityfile.wpli_debiasedspctrm (:,:,4:8,21:41);  
      
       % connectivitytheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,4:8,:); %  theta %FOI
   
        % averaging in time
          if Time==1
               connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat1,4)
          elseif Time==2
               connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat2,4)
          end 
       
        % averaging in freq
        
        connectivitymeanFREQ.theta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % theta
% imagesc(connectivitymeanFREQ.theta.(Timepoint{1,Time}).(ftID{1,Subjects}))
%        drawnow 
            end
        end



%% GAMMA:               
           
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish

      
                  connectivitysavefile = ['power_wPLI_BL_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
     dat1=connectivityfile.wpli_debiasedspctrm (:,:,30:45,1:21); 
     dat2=connectivityfile.wpli_debiasedspctrm (:,:,30:45,21:41);  
      
       % connectivitytheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,4:8,:); %  theta %FOI
   
        % averaging in time
          if Time==1
        connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat1,4)
          elseif Time==2
               connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat2,4)
          end 
       
        % averaging in freq
        
        connectivitymeanFREQ.gamma.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % theta
% imagesc(connectivitymeanFREQ.gamma.(Timepoint{1,Time}).(ftID{1,Subjects}))
%        drawnow 
            end
        end


%% ALPHA:
        
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish

      
                  connectivitysavefile = ['power_wPLI_BL_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
     dat1=connectivityfile.wpli_debiasedspctrm (:,:,8:12,1:21); 
     dat2=connectivityfile.wpli_debiasedspctrm (:,:,8:12,21:41);  
      
       % connectivitytheta.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=connectivityfile.wpli_debiasedspctrm (:,:,4:8,:); %  theta %FOI
   
        % averaging in time
          if Time==1
        connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat1,4)
          elseif Time==2
               connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat2,4)
          end 
       
        % averaging in freq
        
        connectivitymeanFREQ.alpha.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % theta
% imagesc(connectivitymeanFREQ.alpha.(Timepoint{1,Time}).(ftID{1,Subjects}))
%        drawnow 
            end
        end



%% BETA:
        
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
           
      
                  connectivitysavefile = ['power_wPLI_BL_' (ftID{1,Subjects}) '_' (Condition{1,Cond}) '.mat'];
        load(connectivitysavefile);
     dat1=connectivityfile.wpli_debiasedspctrm (:,:,12:30,1:21);  
     dat2=connectivityfile.wpli_debiasedspctrm (:,:,12:30,21:41); 
      
        % averaging in time
          if Time==1
        connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat1,4)
          elseif Time==2
               connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm=nanmean(dat2,4)
          end 
       
        % averaging in freq
        
        connectivitymeanFREQ.beta.(Timepoint{1,Time}).(ftID{1,Subjects})=nanmean(connectivitymeantime.(Timepoint{1,Time}).(ftID{1,Subjects}).wpli_debiasedspctrm,3); % theta
% imagesc(connectivitymeanFREQ.beta.(Timepoint{1,Time}).(ftID{1,Subjects}))
%        drawnow 
            
        end
    end

mat='.mat';

savefile = ['connectivitymeanFREQ_', Group{1,Grp},'_',(Condition{1,Cond}), '.mat'];
save (savefile, 'connectivitymeanFREQ');


    end
end







        