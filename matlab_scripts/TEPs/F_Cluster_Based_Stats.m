clear; close all;
% ##### CLUSTER-BASED PERMUTATION STATISTICS #####
addpath('/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/fieldtrip-20170705/template/')
% This script runs cluster-based permutation statistics between two within
% subject conditions across a pre-determined time window of interest (TOI)

datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
 
grp1 = 'C'; %% LE  HE M
grp2 = 'P';

inPath = [datadir filesep 'SP_analysis_Control_FT' filesep];

eeglab;


% whichstat = 'depsamplesT'; %%% depsamplesT = for WINTHIN SUBJECT
whichstat = 'indepsamplesT'; %%% between subj


% % 
cd(inPath);

cond1 = ['SP_' grp1 '_BL_Pre']; % single - important, do not put a _ before the extension
cond2 = ['SP_' grp2 '_BL_Pre'];



TOINAMES = {'N45';'P60';'N100';'P200';'ALL'};

TOI = {[0.035,0.050];[0.055,0.075];[0.090,0.130];[0.160,0.240]};

for f = 1:size(TOI,1);
    
    if TOI{f,1} == [0.035,0.050];
% 
        TOINAME = TOINAMES{1};

    elseif TOI{f,1} == [0.055,0.075];

        TOINAME = TOINAMES{2};

    elseif TOI{f,1} == [0.090,0.130];

        TOINAME = TOINAMES{3};

            elseif TOI{f,1}  == [0.160,0.240];


        TOINAME = TOINAMES{4};

  
    end;



% ##### SCRIPT #####


%Set path
% filepath = [root,'ft',filesep];

%set filename
filename1 = [cond1,'_GA'];
load([inPath,filename1]);
D1 = grandAverage;



filename2 = [cond2,'_GA'];
load([inPath,filename2]);
D2 = grandAverage;


% % % % Load neighbours template
load('neighbours_template.mat');

% load('neighbours_template_rTMS.mat');




% pause;

%Run cluster-based permutation statistics
cfg = [];


    if strcmp(whichstat, 'depsamplesT');
    %enter number of participants
    subj = size(D1.individual,1);
    design = zeros(2,2*subj);
    for i = 1:subj
      design(1,i) = i;
    end
    for i = 1:subj
      design(1,subj+i) = i;
    end
    design(2,1:subj)        = 1;
    design(2,subj+1:2*subj) = 2;

    cfg.design = design;
    cfg.uvar  = 1;
    cfg.ivar  = 2;

    elseif strcmp(whichstat, 'indepsamplesT');

        
%     elseif strcmp(whichstat, 'ft_statfun_indepsamplesT');

    %enter number of participants
design = zeros(1,size(D1.individual,1) + size(D2.individual,1));
design(1,1:size(D1.individual,1)) = 1;
design(1,(size(D1.individual,1)+1):(size(D1.individual,1) + size(D2.individual,1))) = 2;

% cfg.design = [ones(size(design));design];
% cfg.ivar  = 2;
cfg.design = design;
cfg.ivar  = 1;

    end





cfg.channel     = {'all'};
% cfg.minnbchan        = 1;
cfg.minnbchan        = 2;

cfg.clusteralpha = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.alpha       = 0.025; %0.025 for two-tailed, 0.05 for one-tailed
% cfg.latency     = TOI;
cfg.latency     = TOI{f,1};
cfg.avgovertime = 'no'; %can change this between no and yes depending if you want time included
cfg.avgoverchan = 'no';
cfg.statistic   = whichstat; %'indepsamplesT';  % 'depsamplestT'; 'ft_statfun_indepsamplesT'
cfg.numrandomization = 2500;
cfg.correctm    = 'cluster';
cfg.method      = 'montecarlo'; 
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.neighbours  = neighbours;
cfg.parameter   = 'individual';




%define variables for comparison
[stat] = ft_timelockstatistics(cfg, D1, D2);

%Save stats

tempTOI = TOI;
TOI = TOI{f,1};
save ([inPath, 'stats_', cond1,'_V_',cond2,'_',TOINAME], 'stat','TOI');

%Draw clusterplot for significant findings
% close all;

cfg=[];
cfg.alpha = 0.025;
cfg.zparam = 'stat';
cfg.layout =  'quickcap64.mat'; % 'easycapM11.mat'; % 'quickcap64.mat';
cfg.gridscale=100;
cfg.colorbar='yes'; % yes for on, no for off
cfg.highlightcolorpos = [0 0 1];
cfg.highlightcolorneg = [1 1 0];
% cfg.colormap = jet;
cfg.subplotsize               = [1 1];
cfg.zlim = [-3 3];
cfg.highlightsymbolseries     =['*','x','+','o','.']; %1x5 vector, highlight marker symbol series (default ['*','x','+','o','.'] for p < [0.01 0.05 0.1 0.2 0.3]
cfg.highlightsizeseries       =[10 10 10 10 10 ];%1x5 vector, highlight marker size series   (default [6 6 6 6 6] for p < [0.01 0.05 0.1 0.2 0.3])

try
    
    ft_clusterplot(cfg,stat);
    
set(gca,'FontSize',12,'fontWeight','bold')
set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')

catch
    display([TOINAME 's nothing to plot.']);
    close;
end

TOI = tempTOI;
end


