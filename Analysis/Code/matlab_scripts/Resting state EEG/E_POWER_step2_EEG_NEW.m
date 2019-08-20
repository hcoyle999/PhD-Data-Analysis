clear;

suf='.mat';

Group = {'Control','TBI'};
Timepoint = {'BL','T1'};
Datatype = {'resting'};
Condition= {'eo', 'ec'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

datadir= '//Volumes/HOY_2/TMS_EEG Data';
outPath= [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_Statistics']
% ADJUST THE SUBJECTSTART AND SUBJECTFINISH VALUES BELOW TO ALLOCATE THE
% SUBJECT RANGE YOU ARE PROCESSING TODAY

SubjectStart=1;
%SubjectFinish=numel(ftID);
%SubjectFinish=1;
dorel=0;

for Grp=1:2
    for Tp=2:2
    
if Grp==1
%ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009','P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019','P020','P021','P022','P023','P024','P025','P026','P027','P028'}; %BLparticipants
ftID = {'P001', 'P002', 'P003', 'P004', 'P005', 'P006', 'P008', 'P009', 'P010', 'P011', 'P012', 'P013', 'P014', 'P015', 'P017', 'P018', 'P019', 'P020','P021','P022','P023','P024','P025','P026','P028'}; %T1 exclude 007, 016, 027

else
%ID = {'101', '102', '103', '104', '105', '106', '107', '108', '109', '110', '111', '112', '113', '114', '115', '116'};
%ftID = {'P101', 'P102', 'P103', 'P104', 'P105', 'P106', 'P107', 'P108','P109', 'P110', 'P111', 'P112', 'P113', 'P114', 'P115', 'P116','P117','P118','P119','P120','P121','P122','P123','P124','P125','P126','P127','P128','P129','P130'};% BL participants
ftID = {'P101', 'P103', 'P105', 'P107', 'P109', 'P110', 'P111', 'P112', 'P116','P118','P119','P120','P121','P122','P124','P125','P126','P127','P129', 'P130'}; %T1 participants

end 
SubjectFinish= numel(ftID); 
  
    
for Cond= 1:2

cd( ['//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_', Group{Grp} filesep Timepoint{Tp}] );


% THETA:
clear powermeanALL
if dorel==0;
fname = ['powermeanFREQ_', Condition{Cond} '.mat'];
load(fname);
else
fname = ['powermeanFREQ_', Condition{Cond} '_rel.mat'];
end
load(fname);    

for  Subjects=SubjectStart:SubjectFinish;
    
            powermeanALL.theta.(Timepoint{Tp})(:,:,Subjects)=powermeanFREQ.theta.(Timepoint{Tp}).(ftID{1,Subjects});
            powermeanALL.gamma.(Timepoint{Tp}) (:,:,Subjects)=powermeanFREQ.gamma.(Timepoint{Tp}).(ftID{1,Subjects});
            powermeanALL.alpha.(Timepoint{Tp}) (:,:,Subjects)=powermeanFREQ.alpha.(Timepoint{Tp}).(ftID{1,Subjects});
            powermeanALL.beta.(Timepoint{Tp}) (:,:,Subjects)=powermeanFREQ.beta.(Timepoint{Tp}).(ftID{1,Subjects});
            
%            %% 
            theta(:,Subjects)=powermeanFREQ.theta.(Timepoint{Tp}).(ftID{1,Subjects});
            gamma(:,Subjects)=powermeanFREQ.gamma.(Timepoint{Tp}).(ftID{1,Subjects});
            alpha(:,Subjects)=powermeanFREQ.alpha.(Timepoint{Tp}).(ftID{1,Subjects});
            beta(:,Subjects)=powermeanFREQ.beta.(Timepoint{Tp}).(ftID{1,Subjects});

end
end
if dorel==0;   
cd (outPath)
mkdir([outPath filesep Timepoint{Tp}])
cd ([outPath filesep Timepoint{Tp}])
savefile = ['powermeanALL','_theta_', Group{Grp}, '_' Condition{Cond}, '_abs.mat'];
save (savefile, 'theta');

savefile = ['powermeanALL','_theta_', Group{Grp}, '_' Condition{Cond}, '_abs.csv'];
dlmwrite(savefile,theta,'precision','%.6f');

savefile = ['powermeanALL','_alpha_', Group{Grp}, '_' Condition{Cond}, '_abs.mat'];
save (savefile, 'alpha');
savefile = ['powermeanALL','_alpha_', Group{Grp},'_' Condition{Cond}, '_abs.csv'];
dlmwrite(savefile,alpha,'precision','%.6f');

savefile = ['powermeanALL','_beta_', Group{Grp}, '_' Condition{Cond}, '_abs.mat'];
save (savefile, 'beta');
savefile = ['powermeanALL','_beta_', Group{Grp},'_' Condition{Cond}, '_abs.csv'];
dlmwrite(savefile,beta,'precision','%.6f');

savefile = ['powermeanALL','_gamma_', Group{Grp}, '_' Condition{Cond}, '_abs.mat'];
save (savefile, 'gamma');
savefile = ['powermeanALL','_gamma_', Group{Grp}, '_' Condition{Cond}, '_abs.csv'];
dlmwrite(savefile,gamma,'precision','%.6f');
else

savefile = ['powermeanALL','_theta_', Group{Grp}, '_' Condition{Cond}, '_rel.mat'];
save (savefile, 'theta');
savefile = ['powermeanALL','_theta_', Group{Grp}, '_' Condition{Cond}, '_rel.csv'];
dlmwrite(savefile,theta,'precision','%.6f');

savefile = ['powermeanALL','_alpha_', Group{Grp}, '_' Condition{Cond}, '_rel.mat'];
save (savefile, 'alpha');
savefile = ['powermeanALL','_alpha_', Group{Grp},'_' Condition{Cond}, '_rel.csv'];
dlmwrite(savefile,alpha,'precision','%.6f');

savefile = ['powermeanALL','_beta_', Group{Grp}, '_' Condition{Cond}, '_rel.mat'];
save (savefile, 'beta');
savefile = ['powermeanALL','_beta_', Group{Grp},'_' Condition{Cond}, '_rel.csv'];
dlmwrite(savefile,beta,'precision','%.6f');

savefile = ['powermeanALL','_gamma_', Group{Grp}, '_' Condition{Cond}, '_rel.mat'];
save (savefile, 'gamma');
savefile = ['powermeanALL','_gamma_', Group{Grp}, '_' Condition{Cond}, '_rel.csv'];
dlmwrite(savefile,gamma,'precision','%.6f');
end
clear theta alpha beta gamma; 
% savefile = ['powermeanALL','_', Group{Grp}, Condition{Cond}, '.mat'];
% save (savefile, 'powermeanALL');

%% EXTRACTO-MATIC

% %% REGION OF INTEREST 
% THISCHAN = [4,6,12,14] %MY CHANNEL OF INTEREST 
% THISBAND = {'theta'}
% DAT= mean( squeeze(powermeanALL.(THISBAND{1,1}).BL(THISCHAN,1,:)),1 )' ;
% savefile = ['powermeanROI_',THISBAND{1,1},'_', Group{Grp}, Condition{Cond}, '.mat'];
% save (savefile, 'DAT');

% 
% %% CHANNEL OF INTEREST 
% THISCHAN = [5] ;%f3 
% THISBAND = {'theta'}
% DAT=squeeze(powermeanALL.(THISBAND{1,1}).BL(THISCHAN,1,:))' ;
% savefile = ['powermeanF3_theta_',THISBAND{1,1},'_', Condition{Cond},'_', Group{Grp},  '.mat'];
% save (savefile, 'DAT');
% end

%% ------------------------------------------------------------------------
%            Export desired features to Excel Sheet
% -------------------------------------------------------------------------

   
end
end


