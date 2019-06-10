%% THIS IS A BASIC SCRIPT FOR CREATING A TOPOPLOT FOR TIME-FREQ DATA

clear; close all; clc 

%------------------------------------------------------------------------------------------------------------------------%
% %<<<NON-NORMALISED PLOT>>>
% load /Volumes/UNTITLED/OUTPUT/TMS_EEG/TFR_TESA/GrandAverage/HD_TMSEEG_final_T2_TFR_GA.mat
% 
% ave = grandAverage; 
% ave.powspctrm = [];
% temp = mean(grandAverage.powspctrm,1);
% ave.powspctrm = squeeze(temp(1,:,:,:)); % 'SQUEEZE' FUNCTION
% ave.dimord = 'chan_freq_time'; 
%------------------------------------------------------------------------------------------------------------------------%

%% <<<NORMALISED PLOT>>> 
clear; 
load /Volumes/UNTITLED/OUTPUT/TMS_EEG/TFR_TESA/GrandAverage/Post_Minus_Pre/HD_TMSEEG_final_T2_TFR_GA_CORRECTED.mat

ave = normalise; 
ave.powspctrm = [];
temp = mean(normalise.powspctrm,1);
ave.powspctrm = squeeze(temp(1,:,:,:)); % 'SQUEEZE' FUNCTION
ave.dimord = 'chan_freq_time'; 

%%
% <<FIGURE>>
figure
cfg = [];
cfg.channel     ={'all', '-M1', '-M2'};   %remove mastoids TFR
cfg.xlim        =[-0.1,0.3];
cfg.ylim        =[0,45];
%cfg.zlim       =[-1 4]; 

%cfg.zlim = [0,3];
cfg.layout = 'quickcap64.mat';
cfg.colorbar='yes'; 
%ft_multiplotTFR(cfg,ave);
ft_singleplotTFR(cfg,ave); 

xlabel('Time (ms)', 'FontSize',26,'FontWeight','bold');
ylabel('Frequency (Hz)','FontSize',26,'FontWeight','bold');
title(''); %stops title being the list of all selected electrodes!

%Set x-axis to ms (rather than sec)
labels = [-100 0 100 200 300];
set(gca, 'XTick', labels); % Change x-axis ticks
set(gca,'XTick',[cfg.xlim(1):0.1:cfg.xlim(2)]); 
set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
set(gca,'FontSize',26)

%Set y-axis parameters
ylabels = [5 10 15 20 25 30 35 40 45];
set(gca, 'YTick', ylabels);

% Refline at 0
refline = 1;
refposition = [0 0]; 
refposition2 = [-100 -100]; 

if refline >0
    h = line(refposition, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':','LineWidth',2);
  if refline==2
    h = line(refposition2, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':');
  end
end 

%print('-depsc');

%%
cfg.channel     ={'all'}; %ROI
ft_multiplotTFR(cfg,ave); 

%% for multiple plots over time
cfg.xlim = [0.02:0.05:0.32];%[start:plot-length:end]
cfg.ylim = [4, 7]; %Choose frequency range to plot
cfg.zlim = [-0.6, 0.6]; 
cfg.comment = 'xlim';
cfg.commentpos = 'title';
cfg.colorbar='no';

figure; ft_topoplotTFR(cfg,ave);

%% Single plot 
cfg.xlim = [0.02, 0.5];%[start:plot-length:end]
cfg.ylim = [4,7]; %Choose frequency range to plot
cfg.zlim = [-0.6, 0.6]; 
cfg.comment = 'xlim';
cfg.commentpos = 'title';

figure; ft_topoplotTFR(cfg,ave); 
 
