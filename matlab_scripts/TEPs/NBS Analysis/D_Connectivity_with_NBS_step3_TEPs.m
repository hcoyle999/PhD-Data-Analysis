close all;

Bandwidth={'theta','gamma','alpha','beta'};
Timepoint={'bp','ap'};
Condition = { 'Pre', 'Post'};
Group = {'Control','TBI'};
% datadir='//Volumes/HOY_2/TMS_EEG Data/';
datadir='F:\TMS_EEG Data';
outPath=[datadir filesep 'SP_analysis_Statistics' filesep 'NNM_Statistics'];
 mkdir(outPath);
%------------------------------%
% editable section %
grp1 = 1;  %1=control 2=mtbi
grp2 = 2;

t1=    2; %1=bp, 2=ap
t2=    2;

c1=    2 ; % 1= Pre. 2= Post
c2=    2 ; % 
%--------------------------------%
inPath_1 = [datadir filesep 'SP_analysis', '_', Group{grp1}, filesep];
connectivitymeanALL=[];
filename1 = ['connectivitymeanALL_', Group{grp1},'_', Condition{c1}];
load([inPath_1,filename1]);
D1 =connectivitymeanALL;
inPath_2 = [datadir filesep 'SP_analysis', '_', Group{grp2}, filesep];
connectivitymeanALL=[];
filename2 = ['connectivitymeanALL_', Group{grp2},'_', Condition{c2}];
load([inPath_2,filename2]);
D2 =connectivitymeanALL;


for Band=1:4

% %Band=1;
% for Time=1:2;
% 
% for Cond=1:2;
%         
% cd([datadir filesep 'SP_analysis_', Group{1,Grp}]);
% HCpath= [datadir filesep 'SP_analysis_', Group{1,1}];
% TBIpath= [datadir filesep 'SP_analysis_', Group{1,2}];
% path3=[datadir filesep 'SP_analysis_Statistics'];
% 
% 
% mkdir(path3);
% 
% load ([HCpath filesep 'connectivitymeanALL' '_', Group{1,1}, '_' Condition{Cond} '.mat']);
% HC=connectivitymeanALL.;
% 
% 
% load ([TBIpath filesep 'connectivitymeanALL' '_', Group{1,2}, '_' Condition{Cond} '.mat']);
% TBI=connectivitymeanALL.(Bandwidth{1,Band}).(Timepoint{1,Time});

d1=D1.(Bandwidth{1,Band}).(Timepoint{1,t1});
d2=D2.(Bandwidth{1,Band}).(Timepoint{1,t2});
NNM = cat(3,d1,d2) ;
cd (outPath)       ;
filename= [Condition{c1},'_V_',Condition{c2},'_',Group{grp1},'_V_',Group{grp2},'_',Timepoint{1,t1},'_V_',Timepoint{1,t2},'_' Bandwidth{1,Band} '_NNM.mat'];
save ([outPath filesep filename], 'NNM');
imagesc([nanmean(d1,3)-nanmean(d2,3)],[-0.09,0.09])


title(Bandwidth{1,Band})
drawnow
end
% end
% end
