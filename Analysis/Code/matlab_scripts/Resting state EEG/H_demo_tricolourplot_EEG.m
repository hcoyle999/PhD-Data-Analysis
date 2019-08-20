
% %[fig]=mytricolourplot(t,DATA1,DATA2,DATA3,useSEM)
these= logical(stat.negclusterslabelmat)
stat.label(these)'
% 
% these= logical(stat.negclusterslabelmat)
% stat.label(these)'
 %Alpha eyesclosed absolute power negative cluster
Alpha_Neg= {'F2',    'FC2',    'FC4'  ,  'FC6'  , ...
    'CZ' , 'C2' ,  'C4'  ,  'C6' ,  'T8' , ...
    'CP2' , 'CP4' , 'CP6','P2',   'P8'};



testname=['Alpha Absolute Power ','Control' ' ' 'vs' ' ' 'mTBI'];


labels=D1.label
thischan= find(ismember(labels,Alpha_Neg'))
t=D1.freq; 
DATA1=squeeze(mean(D1.powspctrm(:,thischan,:),2))
DATA2=squeeze(mean(D2.powspctrm(:,thischan,:),2))



%% PLOT 
mytricolourplot(t,DATA1,DATA2,[],0)
title(['ROI',' ' testname])
%legend('Control','CI','mTBI','CI')

% t1= find(t>=-0.100,1,'first');
% t2= find(t>=0.35,1,'first');
xlim([4,14])
xlabel({'Frequency (Hz)'});
ylabel({'Power (arbitrary units)'});

%% try and make topoplots (distribution of alpha power btw groups)

    figure;

subplot(1,2,1);
cfg = [];
cfg.zlim = [0 0.1];
%cfg.xlim = 'maxmin';
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'powspctrm';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D1);
title([ 'Control Alpha'] , 'fontsize',12,'fontweight','bold');


subplot(1,2,2);
cfg = [];
cfg.zlim = [0 0.1];
%cfg.xlim = 'maxmin';
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'powspctrm';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D2);
title(['TBI Alpha'] , 'fontsize',12,'fontweight','bold');

    set(gcf, 'Position', [300 100 600 400]);
