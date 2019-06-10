% 
% cfg              = [];
% cfg.baseline     = [-0.5 -0.1];
% cfg.baselinetype = 'absolute';
% cfg.maskstyle    = 'saturation';
% cfg.zlim         = [-3e-27 3e-27];
% cfg.channel      = 'MRC15';
% cfg.interactive  = 'no';
% figure
% ft_singleplotTFR(cfg, TFRhann7);
% 
% 
% cfg = [];
% cfg.baseline     = [-0.5 -0.1];
% cfg.baselinetype = 'absolute';
% cfg.zlim         = [];
% cfg.showlabels   = 'yes';
% cfg.layout =  'quickcap64.mat'; %
% figure
% 
% ft_multiplotTFR(cfg,powerTotal)

% to make plots 
load('powerTotal.mat') %load default for structure


%Control_Pre Grand Average (Power Spectrum graph)
CNT_Pre=powerTotal; 
dat1= squeeze(mean(D1.powspctrm,1))
CNT_Pre.powspctrm=dat1; 

cfg = [];
cfg.baseline     = 'no'%[-0.5 -0.1];
%cfg.baselinetype = 'absolute';
cfg.zlim         = [-2 2];
%cfg.xlim         = [-0.5 1];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,CNT_Pre)

%Control_Post Grand Average (Power Spectrum graph)
CNT_Post=powerTotal; 
dat2= squeeze(mean(D3.powspctrm,1))
CNT_Post.powspctrm=dat2; 

cfg = [];
cfg.baseline     = 'no'%[-0.5 -0.1];
%cfg.baselinetype = 'no';
cfg.zlim         = [-2 2];
%cfg.xlim         = [-0.5 1];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,CNT_Post)

%TBI_Pre Grand Average (Power Spectrum graph)
TBI_Pre=powerTotal; 
dat3= squeeze(mean(D2.powspctrm,1)); 

TBI_Pre.powspctrm=dat3; 

cfg = [];
cfg.baseline     = 'no'%[-0.5 -0.1];
%cfg.baselinetype = 'absolute';
cfg.zlim         = [-2 2];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,TBI_Pre); 

%TBI_Post Grand Average (Power Spectrum graph)
TBI_Post=powerTotal; 
dat4= squeeze(mean(D4.powspctrm,1)); 

TBI_Post.powspctrm=dat4; 

cfg = [];
cfg.baseline     = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.zlim         = [-3 2];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,TBI_Post); 

%% To create graph of the differences
% Control_Pre vs mTBI_Pre
DIFF_Pre=powerTotal; 
DIFF_Pre.powspctrm=dat1 - dat3; 

cfg = [];
cfg.baseline     = 'no'%[-0.5 -0.1];
%cfg.baselinetype = 'absolute';
cfg.zlim         = [-0.5 0.5];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,DIFF_Pre); 

% Control_Post vs mTBI_Post
DIFF_Post=powerTotal; 
DIFF_Post.powspctrm=dat2 - dat4; 

cfg = [];
cfg.baseline     = 'no'%[-0.5 -0.1];
%cfg.baselinetype = 'absolute';
cfg.zlim         = [-0.5 0.5];
cfg.showlabels   = 'yes';
cfg.layout =  'quickcap64.mat'; %
figure

ft_multiplotTFR(cfg,DIFF_Post); 


