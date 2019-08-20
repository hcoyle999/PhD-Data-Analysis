%------------------------------------------------------------------------%
% CLUSTER-BASED PERMUTATION STATISTICS 
% This script runs cluster-based permutation statistics between two within
% subject conditions following time frequency analysis across a
% pre-determined frequency band (FOI) and time window of interest (TOI).
% The script averages across both time and frequency, but takes in to
% account space (i.e. electrode positions).

% Note that unlike the time-based version, there is no figure in the case
% of significant findings. Please check the stat output in workspace.
%------------------------------------------------------------------------%
  
                                                                                                                   
clear; close all;
%addpath('F:\TMS_EEG Data');
%datadir='F:\TMS_EEG Data';
datadir='//Volumes/HOY_2/TMS_EEG Data/';
%eeglab_path='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b';
%addpath(eeglab_path);
%cd(eeglab_path);
eeglab;
fieldtrip_path='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/Fieldtrip-lite170623';
addpath(fieldtrip_path);
cd(fieldtrip_path);
ft_defaults;

grp1 = 'C'; %% LE  HE M
grp2 = 'T';

para1 = 'eo';
para2= 'ec';

inPath = [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_Statistics' filesep]; 

%----SETTINGS----%
%Theta = 4-7 Hz
%Alpha = 8-13 Hz
%beta =  13-29 Hz
%Gamma = 30-45 Hz
%----------------%
%inPath={inPath_1,inPath_2,inPath_1,inPath_2}; 
outPath=  [datadir filesep 'Resting_analysis' filesep 'Resting_analysis_Statistics'];
mkdir(outPath); 

whichstat = 'indepsamplesT' %(between groups)
%whichstat = 'depsamplesT'; %(within groups)

% cond1 = ['SP_', grp1, '_BL_Pre']; % single - important, do not put a _ before the extension
% cond2 = ['SP_', grp2, '_BL_Pre'];
% cond3 = ['SP_', grp1, '_BL_Post']; % single - important, do not put a _ before the extension
% cond4 = ['SP_', grp2, '_BL_Post'];

%----------editable section ---------------%

 cond1 = ['Resting', '_', grp1, '_', 'BL', '_' para2] % single - important, do not put a _ before the extension
 cond2 = ['Resting', '_', grp2, '_', 'BL', '_' para2]
 
 %-------------------------------------------%
theta_FOI = [4 8];
alpha_FOI = [8 12];
beta_FOI = [12 30]; % for graph (P60)  [0.050 0.075];
gamma_FOI = [30 45]; % for graph (N100) 115 ( + - 35)
%tot_FOI = [1 45]; 
FOI={theta_FOI;alpha_FOI;beta_FOI;gamma_FOI};%tot_FOI}; 
FOINAMES = {'theta';'alpha';'beta';'gamma'};%'total'};
%TOI = [0.05,0.150]; % a time window of 50?250 ms for the slower ? and ? bands, with a
                    % narrower (50?150 ms) window used for the faster ? and ? bands.
                       

dodelta=0; dorel=0; 

for f = 2%1:size(FOI,1)%[2,3]% 1:5% 1:size(TOI,1);%5;%2; %

FOINAME = [FOINAMES{f}]; % change _total or _rel

%% 
ft_defaults;

%------------editable section------%
%set filename
filename1 = [cond1,'_GA.mat'];
load([inPath,filename1]);
D1 = grandAverage;

filename2 = [cond2,'_GA.mat'];
load([inPath,filename2]); % changed for w/in group comparison
D2 = grandAverage;

testname=[cond1,'_V_',cond2];

if dorel==1; 

%% do relative power transformation
minf = 0.1;
maxf=45;
t1=find(D1.freq>= minf,1,'first');
t2=find(D1.freq<= maxf ,1,'last');

for i=1:size(D1.powspctrm,1)
    rawpow= D1.powspctrm(i,:,:); 
    totpow= sum(D1.powspctrm(i,:,t1:t2),3);
relpow= rawpow./totpow; 
    D1.powspctrm(i,:,:)=relpow; 
%%     
end
    
   
for i=1:size(D2.powspctrm,1)
    rawpow= D2.powspctrm(i,:,:); 
    totpow= sum(D2.powspctrm(i,:,t1:t2),3);
relpow= rawpow./totpow; 
    D2.powspctrm(i,:,:)=relpow; 
%%     
end
end      

if dodelta==1; 
filename1 = [cond3,'_GA'];
load([inPath{3},filename1]);
D3 = grandAverage;
filename2 = [cond4,'_GA'];
load([inPath{4},filename2]);
D4 = grandAverage;    

D1.powspctrm=D1.powspctrm-D3.powspctrm; 
D2.powspctrm=D2.powspctrm-D4.powspctrm; 
testname=['delta_',grp1,'_V_delta_',grp2]; 

end
%Load neighbours template
load([datadir filesep 'Scripts/TEPs/Xtra_files/neighbours.mat']); %Elec neighbour template
%load('neighbours_50.mat');

%Run cluster-based permutation statistics
cfg = [];
if strcmp(whichstat, 'depsamplesT');
    %enter number of participants
    subj_1 = size(D1.powspctrm,1);
    design_1 = zeros(2,subj_1);
    for i = 1:subj_1
      design_1(1,i) = i;
    end
    subj_2 = size(D2.powspctrm,1);
     design_2 = zeros(2,subj_2);
    for i = 1:subj_2
      design_2(1,i) = i;
    end
    design_1(2,1:subj_1)        = 1;
    design_2(2,1:subj_2) = 2;
    
    design= [design_1 design_2];

    cfg.design = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;
    

    
    %cfg = [];
% if strcmp(whichstat, 'depsamplesT');
%     %enter number of participants
%     subj = size(D1.powspctrm,1);
%     design = zeros(2,2*subj);
%     for i = 1:subj
%       design(1,i) = i;
%     end
%     for i = 1:subj
%       design(1,subj+i) = i;
%     end
%     design(2,1:subj)        = 1;
%     design(2,subj+1:2*subj) = 2;
% 
%     cfg.design = design;
%     cfg.uvar  = 1;
%     cfg.ivar  = 2;

elseif strcmp(whichstat, 'indepsamplesT');

        
%     elseif strcmp(whichstat, 'ft_statfun_indepsamplesT');

    %enter number of participants
design = zeros(1,size(D1.powspctrm,1) + size(D2.powspctrm,1));
design(1,1:size(D1.powspctrm,1)) = 1;
design(1,(size(D1.powspctrm,1)+1):(size(D1.powspctrm,1) + size(D2.powspctrm,1))) = 2;

cfg.design = design;
cfg.ivar  = 1; %check this with caley- 
end 

cfg.channel     = {'all', '-M1', '-M2'}; %All channels (remove mastoids) 
cfg.minnbchan   = 2;                     %minimum number of channels for cluster
cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.alpha       = 0.025;
%cfg.latency     = TOI{t,1};
cfg.frequency   = FOI{f,1};
%cfg.avgovertime = 'yes'; %averge accross time %when this is no, looks at every ms block
cfg.avgoverfreq = 'yes'; %averge accross freq
cfg.avgoverchan = 'no';  %average accross channels %only do if we have a specific ROI we want to test
cfg.statistic   = whichstat ; %changes based on editable section
cfg.numrandomization = 5000;
cfg.correctm    = 'cluster';
cfg.method      = 'montecarlo'; 
cfg.tail             = 0; %two sided test
cfg.clustertail      = 0;
cfg.neighbours  = neighbours;
%cfg.parameter   = 'individual';
%cfg.design = design;
%cfg.uvar  = 1;
%cfg.ivar  = 2; % number of independent samples??

%define variables for comparison
[stat] = ft_freqstatistics(cfg, D1, D2); 

%Save stats
tempFOI = FOI;
foi= FOI{f,1};
% 
% tempTOI = TOI;
% toi = TOI{t,1};
save ([outPath, filesep, 'stat_',cond1,'_V_',cond2,'_',FOINAME], 'stat','foi' );


%Draw clusterplot for significant findings
% close all;
cd(outPath)
cfg=[];
cfg.alpha = 0.025;
cfg.parameter  = 'stat';
cfg.layout =  'quickcap64.mat'; % 'easycapM11.mat'; % 'quickcap64.mat';
cfg.gridscale=100;
cfg.colorbar='yes'; % yes for on, no for off
cfg.highlightcolorpos = [0 0 1];
cfg.highlightcolorneg = [1 1 0];
%cfg.commentpos = 'title';
% cfg.colormap = jet;
cfg.subplotsize               = [1 1];
cfg.zlim = [-3 3];
cfg.highlightsymbolseries     =['*','x','+','o','.']; %1x5 vector, highlight marker symbol series (default ['*','x','+','o','.'] for p < [0.01 0.05 0.1 0.2 0.3]
cfg.highlightsizeseries       =[10 10 10 10 10 ];%1x5 vector, highlight marker size series   (default [6 6 6 6 6] for p < [0.01 0.05 0.1 0.2 0.3])
savename = [testname,'_',FOINAME]; 
cfg.saveaspng= [testname,'_',FOINAME]

try
    ft_clusterplot(cfg,stat); 
set(gca,'FontSize',12,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')
title([FOINAME])

savefig(savename); 
%F = getframe;
   %imwrite(F.cdata, savename, 'png')
%saveas (pic, output, 'png');
catch ME
   disp([FOINAME 's nothing to plot...']);
  % pause 
  % close;
    disp(ME)
end
drawnow
% fn=['stat_',savename]; 
% save(fn,'stat')
FOI = tempFOI;
end

%% Draw clusterplot for significant findings
% close all;
% 
% cfg=[];
% cfg.alpha = 0.025;
% cfg.zparam = 'stat';
% cfg.layout = 'quickcap64.mat';
% cfg.highlightcolorpos = [1 0 0]; 
% cfg.highlightcolorneg = [1 0 0];
% cfg.highlightsizeseries = [10 10 10 10 10]; %Size of sig clusters
% cfg.colorbar    ='yes';          
% cfg.zlim = [-2.5 0.0]; 
% cfg.subplotsize = [1 1]; %size of plot (default = [3 5])
% ft_clusterplot(cfg,stat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% THIS DRAWS TOPOPLOTS FOR THE DIFFERENCE BETWEEN THE TWO INPUTTED VALUES
% THAT ARE BEING STATISTICALLY COMPARED
% Draw topoplot (useful for non-sig findings)

% close all;
% 
% cfg=[];
% cfg.zparam = 'stat';
% cfg.layout = 'quickcap64.mat'; 
% xlim = [0.04, 0.20];
% %cfg.zlim = [-0.6, 0.6]; 
% cfg.subplotsize = [1 1]; 
% ft_topoplotER(cfg,stat); colorbar; 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%