clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
 
grp1 = 'C'; %% LE  HE M
grp2 = 'P';
% % % %Cond


comp1 = ' control';
comp2 = ' TBI';
if exist('cond3') == 1;
comp3 = ' T20';
end

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Pre'}; %trigger points


cond1 = ['SP_' grp1 '_BL_Pre']; % single - important, do not put a _ before the extension
cond2 = ['SP_' grp2 '_BL_Pre'];
% cond2 = ['TMSEEG_' group '_final_P1']; % paired - important, do not put a _ before the extension
% cond3 = ['TMSEEG_' group '_final_P2']; % paired - important, do not put a _ before the extension


% for graph legend
% comp1 = 'M-Pre';
% comp2 = 'LE-Pre';
% 
% if exist('cond3') == 1;
% comp3 = 'HE-Pre';
% end



ROI = {'FC1', 'F1', 'F3', 'FZ', 'FCZ'};
% ROI = {'F3','FC3','F1','FC1','FZ','FCZ'};
% ROI = {'FC3','FC1','F1','FZ','FCZ'};
% ROI = {'F1','FZ','FC3','FC1','FCZ','C3'};

%Path

inPath = [datadir filesep 'SP_analysis_Control_FT' filesep];


% for graph legend
% comp1 = [' ' group '-BL'];
% comp2 = [' ' group '-T5'];

% if exist('cond3') == 1;
% comp3 = [' ' group '-T20'];
% end


ploterrorbars = 0 ; % [1|0] - ['SEM'|'none'  ]

% box setting for peaks
P35bar = 0;
N45bar = 1;
P60bar = 1; % [1|0] - 1 is yes
N120bar = 1; % [1|0] - 0 is no
P200bar = 1;

P35time = [0.031 0.041];
N45time = [0.035 0.048];
P60time = [0.050 0.075]; % for graph (P60)
N120time = [0.090 0.135]; % for graph (N100) 115 ( + - 35)
P200time = [0.15 0.24]; % 200 ( +- 40)

whichxlim = [-0.05 0.350];

% last graph (for publication) peak amplitude
ymin = -6; ymax = 6;
gmfaymin = 0; gmfaymax = 5;

ft_defaults;
try
%%%set filename
filename1 = [cond1,'_GA'];
load([inPath,filename1]);
D1 = grandAverage;

filename2 = [cond2,'_GA'];
load([inPath,filename2]);
D2 = grandAverage;

if exist('cond3') == 1;
filename3 = [cond3,'_GA'];
load([inPath,filename3]);
D3 = grandAverage;
end

catch
%%set filename
filename1 = [cond1,'_GA'];
load([inPath,filename1]);
D1 = grandAverageNorm;

filename2 = [cond2,'_GA'];
load([inPath,filename2]);
D2 = grandAverageNorm;


if exist('cond3') == 1;
filename3 = [cond3,'_GA'];
load([inPath,filename3]);
D3 = grandAverageNorm;
end
end


% % Figures
cfg = [];
cfg.showlabels  = 'yes';
cfg.layout = 'quickcap64.mat';
cfg.xlim = whichxlim;
if exist('cond3') == 1;
figure; ft_multiplotER(cfg,D1, D2, D3);
else
figure; ft_multiplotER(cfg,D1, D2);
end






%% Last plot will be based on the setting here


cfg = [];
cfg.channel     =  ROI;
cfg.xlim = whichxlim;
if exist('cond3') == 1;
figure; ft_singleplotER(cfg,D1, D2, D3);
else
figure; ft_singleplotER(cfg,D1, D2);
end



%%





figure;
t1 = cfg.xlim(1,1);
t2 = cfg.xlim(1,2);
    
    ftchan = cfg.channel;
    for i = 1:length(ftchan);
    chanidx(i) = find(strcmp(ftchan{1,i}, D1.label'));
    end

avgD1 = mean(D1.individual); %average across participants of D1
sqavgD1 = squeeze(avgD1);    %Squeezing (getting rid of 1 dimention)

StdevD1 = std(D1.individual); SEMD1 = std(D1.individual)/sqrt(size((D1.individual),1)); % Stdev and SEM
sqStdevD1 = squeeze(StdevD1); sqSEMD1 = squeeze(SEMD1);

avgD2 = mean(D2.individual); %average across participants of D2
sqavgD2 = squeeze(avgD2);    %Squeezing (getting rid of 1 dimention)

StdevD2 = std(D2.individual); SEMD2 = std(D2.individual)/sqrt(size((D2.individual),1)); % Stdev and SEM
sqStdevD2 = squeeze(StdevD2); sqSEMD2 = squeeze(SEMD2);



if exist('cond3') == 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
avgD3 = mean(D3.individual); %average across participants of 3
sqavgD3 = squeeze(avgD3);    %Squeezing (getting rid of 1 dimention)

StdevD3 = std(D3.individual); SEMD3 = std(D3.individual)/sqrt(size((D3.individual),1)); % Stdev and SEM
sqStdevD3 = squeeze(StdevD3); sqSEMD3 = squeeze(SEMD3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

indsqavgD1 = sqavgD1(chanidx,:); %finding only D1 data of channels (from cfg.channel designated above)
indsqavgD2 = sqavgD2(chanidx,:); %finding only D2 data of channels (from cfg.channel designated above)
if exist('cond3') == 1;
indsqavgD3 = sqavgD3(chanidx,:); %finding only D3 data of channels (from cfg.channel designated above)
end

indsqStdevD1 = sqStdevD1(chanidx,:); indsqSEMD1 = sqSEMD1(chanidx,:);
indsqStdevD2 = sqStdevD2(chanidx,:); indsqSEMD2 = sqSEMD2(chanidx,:);
if exist('cond3') == 1;
indsqStdevD3 = sqStdevD3(chanidx,:); indsqSEMD3 = sqSEMD3(chanidx,:);
end

avgindsqavgD1 = mean(indsqavgD1); % averaging those found D1 data
avgindsqavgD2 = mean(indsqavgD2); % averaging those found D2 data
if exist('cond3') == 1;
avgindsqavgD3 = mean(indsqavgD3); % averaging those found D3 data
end

avgindsqStdevD1 = mean(indsqStdevD1); avgindsqSEMD1 = mean(indsqSEMD1);
avgindsqStdevD2 = mean(indsqStdevD2); avgindsqSEMD2 = mean(indsqSEMD2);
if exist('cond3') == 1;
avgindsqStdevD3 = mean(indsqStdevD3); avgindsqSEMD3 = mean(indsqSEMD3);
end

d1t = round(D1.time,4); % rounding up decimals to 4
% d2t = round(D2.time,4); % rounding up decimals to 4

tdx1 = find(d1t == t1); % finding where it is
tdx2 = find(d1t == t2); % finding where it is





% for SEM.. but I don't like it, since it looks like there's no sig :P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ploterrorbars == 1 ;

if exist('cond3') == 1;
    [hl, hp] = boundedline(...
    D1.time(tdx1:tdx2),avgindsqavgD1(tdx1:tdx2),avgindsqSEMD1(tdx1:tdx2),'b',...
    D2.time(tdx1:tdx2),avgindsqavgD2(tdx1:tdx2),avgindsqSEMD2(tdx1:tdx2),'r',...
    D3.time(tdx1:tdx2),avgindsqavgD3(tdx1:tdx2),avgindsqSEMD3(tdx1:tdx2),'g',...
    'alpha','transparency', 0.1);
    else
    [hl, hp] = boundedline(...
    D1.time(tdx1:tdx2),avgindsqavgD1(tdx1:tdx2),avgindsqSEMD1(tdx1:tdx2),'b',...
    D2.time(tdx1:tdx2),avgindsqavgD2(tdx1:tdx2),avgindsqSEMD2(tdx1:tdx2),'r',...
    'alpha','transparency', 0.1);
    end



% graph stuff
axis([cfg.xlim(1) cfg.xlim(2) ymin ymax]);    % axis[xmin xmax ymin ymax] 
% set(gca,'XTick',[-0.1 -0.05 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4] );
labels = t1*1000:50:t2*1000;
% labels = [-100 -50 0 50 100 150 200 250 300 350 400];
% set(gca, 'XTick', labels); % Change x-axis ticks
set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
set(gca,'FontSize',10)
xlabel('Time(ms)', 'FontSize',12,'FontWeight','bold');
ylabel('Amplitude(µV)','FontSize',12,'FontWeight','bold');
if exist('cond3') == 1;
h_legend = legend(comp1,comp2, comp3);
else
h_legend = legend(comp1,comp2);
end

% set(h_legend,'FontSize',14, 'position',[0.75 0.1 0.2 0.2]);
set(h_legend,'FontSize',12, 'Location','southeast');
% set(h_legend,'FontSize',10, 'Location','northwest');

legend boxoff
box off

refline = 1;
refposition = [0 0]; 
refposition2 = [-100 -100]; 

if refline >0;
    h = line(refposition, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':','LineWidth',3);
  if refline==2;
    h = line(refposition2, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':', 'LineWidth',3);
  end;
end ;


% this is line at 0

refline = 1;
refposition = [0 0]; 
refposition2 = [-100 -100]; 

if refline >0;
    h = line(refposition, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':');
  if refline==2;
    h = line(refposition2, get(gca, 'YLim'), 'Color', [0 0 0],'LineStyle',':');
  end;
end ;



% creating a box
if N45bar == 1; 
xN45 = [N45time(1) N45time(2) N45time(2) N45time(1)];
y = [ymin ymin ymax ymax];
p1=patch(xN45,y,'r');
set(p1,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
else
end

if P60bar == 1;   
xP60 = [P60time(1) P60time(2) P60time(2) P60time(1)];
y = [ymin ymin ymax ymax];
p2=patch(xP60,y,'r');
set(p2,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
else
end

if N120bar == 1 ;    
xN120 = [N120time(1) N120time(2) N120time(2) N120time(1)];
y = [ymin ymin ymax ymax];
p3=patch(xN120,y,'r');
set(p3,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
else
end


if P200bar == 1 ;   
xP200 = [P200time(1) P200time(2) P200time(2) P200time(1)];
y = [ymin ymin ymax ymax];
p4=patch(xP200,y,'r');
set(p4,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
else
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    

%%


% graph settings. CRAZY!!
% 
% plot(D1.time(tdx1:tdx2), avgindsqavgD1(tdx1:tdx2), 'b', 'LineWidth',2); hold on;
% plot(D2.time(tdx1:tdx2), avgindsqavgD2(tdx1:tdx2), 'r', 'LineWidth',2); hold on;
% if exist('cond3') == 1;
% plot(D3.time(tdx1:tdx2), avgindsqavgD3(tdx1:tdx2), 'g', 'LineWidth',2);
% end

% color1 = hex2rgb('377eb8');
color1 = 'b'; %hex2rgb('377eb8');
color2 = 'r'; %hex2rgb('e41a1c');
color3 = 'g'; %hex2rgb('4daf4a');

% color1 = hex2rgb('4daf4a');
% color2 = hex2rgb('377eb8');
% color3 = hex2rgb('e41a1c');

% color1 = hex2rgb('e41a1c');
% color2 = hex2rgb('377eb8');
% color3 = hex2rgb('4daf4a');


% graph settings. CRAZY!!
plot(D1.time(tdx1:tdx2), avgindsqavgD1(tdx1:tdx2), 'color', color1, 'LineWidth',3); hold on;
plot(D2.time(tdx1:tdx2), avgindsqavgD2(tdx1:tdx2), 'color', color2 , 'LineWidth',3); hold on;
if exist('cond3') == 1;
plot(D3.time(tdx1:tdx2), avgindsqavgD3(tdx1:tdx2), 'color', color3, 'LineWidth',3);
end

if ploterrorbars == 1;
SEMfill1 = fill([D1.time(tdx1:tdx2),fliplr(D1.time(tdx1:tdx2))],[avgindsqavgD1(tdx1:tdx2)-avgindsqSEMD1(tdx1:tdx2),fliplr(avgindsqavgD1(tdx1:tdx2)+avgindsqSEMD1(tdx1:tdx2))], 'b');
set(SEMfill1, 'FaceAlpha' ,0.1); set(SEMfill1,'EdgeColor', 'none');
SEMfill2 = fill([D2.time(tdx1:tdx2),fliplr(D2.time(tdx1:tdx2))],[avgindsqavgD2(tdx1:tdx2)-avgindsqSEMD2(tdx1:tdx2),fliplr(avgindsqavgD2(tdx1:tdx2)+avgindsqSEMD2(tdx1:tdx2))], 'r');
set(SEMfill2, 'FaceAlpha' ,0.1); set(SEMfill2, 'EdgeColor', 'none');
if exist('cond3') == 1;
SEMfill3 = fill([D1.time(tdx1:tdx2),fliplr(D3.time(tdx1:tdx2))],[avgindsqavgD3(tdx1:tdx2)-avgindsqSEMD3(tdx1:tdx2),fliplr(avgindsqavgD3(tdx1:tdx2)+avgindsqSEMD3(tdx1:tdx2))], 'g');
set(SEMfill3, 'FaceAlpha' ,0.1); set(SEMfill3, 'EdgeColor', 'none');
end
else
end

% [0 0.447 0.741]
% [0.85 0.325 0.098]
% [0.929 0.694 0.125]

if ploterrorbars == 2;
SEMfill1 = fill([D1.time(tdx1:tdx2),fliplr(D1.time(tdx1:tdx2))],[avgindsqavgD1(tdx1:tdx2)-avgindsqCI95D1(tdx1:tdx2),fliplr(avgindsqavgD1(tdx1:tdx2)+avgindsqCI95D1(tdx1:tdx2))], 'b');
set(SEMfill1, 'FaceAlpha' ,0.1); set(SEMfill1, 'EdgeColor', 'none');
SEMfill2 = fill([D2.time(tdx1:tdx2),fliplr(D2.time(tdx1:tdx2))],[avgindsqavgD2(tdx1:tdx2)-avgindsqCI95D2(tdx1:tdx2),fliplr(avgindsqavgD2(tdx1:tdx2)+avgindsqCI95D2(tdx1:tdx2))], 'r');
set(SEMfill2, 'FaceAlpha' ,0.1); set(SEMfill2, 'EdgeColor', 'none');
if exist('cond3') == 1;
SEMfill3 = fill([D1.time(tdx1:tdx2),fliplr(D3.time(tdx1:tdx2))],[avgindsqavgD3(tdx1:tdx2)-avgindsqCI95D3(tdx1:tdx2),fliplr(avgindsqavgD3(tdx1:tdx2)+avgindsqCI95D3(tdx1:tdx2))], 'g');
set(SEMfill3, 'FaceAlpha' ,0.1); set(SEMfill3, 'EdgeColor', 'none');
end
else
end


axis([cfg.xlim(1) cfg.xlim(2) ymin ymax]);    % axis[xmin xmax ymin ymax] 
% set(gca,'XTick',[-0.1 -0.05 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4] );
labels = t1*1000:50:t2*1000;
% labels = [-100 -50 0 50 100 150 200 250 300 350 400];
% set(gca, 'XTick', labels); % Change x-axis ticks
set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
set(gca,'FontSize',24)
xlabel('Time (ms)', 'FontSize',24,'FontWeight','bold');
ylabel('Amplitude (µV)','FontSize',24,'FontWeight','bold');
if exist('cond3') == 1;
h_legend = legend(comp1,comp2, comp3);
else
h_legend = legend(comp1,comp2);
end
% set(h_legend,'FontSize',14, 'position',[0.75 0.1 0.2 0.2]);
set(h_legend,'FontSize',24, 'Location','northeast');
% set(h_legend,'FontSize',10, 'Location','northwest');
set(gca,'FontSize',24,'fontWeight','bold','LineWidth',3)

legend boxoff
box off



% this is line at 0

refline = 1;
refposition = [0 0]; 
refposition2 = [-100 -100]; 

if refline >0;
    h = line(refposition, get(gca, 'YLim'), 'Color', [0 0 0],'LineWidth',3,'LineStyle',':');
  if refline==2;
    h = line(refposition2, get(gca, 'YLim'), 'Color', [0 0 0],'LineWidth',3,'LineStyle',':');
  end;
end ;




if P35bar == 1;   
xP35 = [P35time(1) P35time(2) P35time(2) P35time(1)];
y = [ymin ymin ymax ymax];
p0=patch(xP35,y,'r');
% set(p0,'FaceAlpha',0.2, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
set(p0,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');

else
end

% creating a box
if N45bar == 1;   
xN45 = [N45time(1) N45time(2) N45time(2) N45time(1)];
y = [ymin ymin ymax ymax];
p1=patch(xN45,y,'r');
% set(p1,'FaceAlpha',0.2, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
set(p1,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');

else
end

% set(p1,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');

if P60bar == 1;   
xP60 = [P60time(1) P60time(2) P60time(2) P60time(1)];
y = [ymin ymin ymax ymax];
p2=patch(xP60,y,'r');
% set(p2,'FaceAlpha',0.2, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
set(p2,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');

else
end

% set(p2,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');


if N120bar == 1 ; 
xN120 = [N120time(1) N120time(2) N120time(2) N120time(1)];
y = [ymin ymin ymax ymax];
p3=patch(xN120,y,'r');
% set(p3,'FaceAlpha',0.2, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
set(p3,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');

else
end

% set(p3,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');

if P200bar == 1 ; 
xP200 = [P200time(1) P200time(2) P200time(2) P200time(1)];
y = [ymin ymin ymax ymax];
p4=patch(xP200,y,'r');
% set(p4,'FaceAlpha',0.2, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
set(p4,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');

else
end

% set(p4,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');

    set(gcf, 'Position', [350 300 800 600]);

    %%
    
   legend off
   
   if exist('cond3') == 1;
h_legend = legend(comp1,comp2, comp3);
else
h_legend = legend(comp1,comp2);
end
% set(h_legend,'FontSize',14, 'position',[0.75 0.1 0.2 0.2]);
set(h_legend,'FontSize',24, 'Location','northeast');
% set(h_legend,'FontSize',10, 'Location','northwest');
set(gca,'FontSize',24,'fontWeight','bold','LineWidth',3)

legend boxoff
box off
    
    set(gcf, 'Position', [350 300 800 600]);

  %%  
% %%
% %%%%%%%%%%%%%%%%%%%% GMFA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%% MUST REPLOT THIS %%%%% FOR SOME REASON!!!%%%%%
% 
% 
% cfg = [];
% 
% D1.avg = ft_timelockanalysis(cfg, D1);
% D2.avg = ft_timelockanalysis(cfg, D2);
% if exist('cond3') == 1;
% D3.avg = ft_timelockanalysis(cfg, D3);
% end
% 
% 
% cfg.xlim = whichxlim;
% cfg.method = 'amplitude';
% GMFAD1 = ft_globalmeanfield(cfg, D1.avg); 
% GMFAD2 = ft_globalmeanfield(cfg, D2.avg); 
% if exist('cond3') == 1;
% GMFAD3 = ft_globalmeanfield(cfg, D3.avg); 
% end
% 
% figure;
% plot(GMFAD1.time(tdx1:tdx2), GMFAD1.avg(tdx1:tdx2), 'color', color1, 'LineWidth',3); hold on;
% plot(GMFAD2.time(tdx1:tdx2), GMFAD2.avg(tdx1:tdx2), 'color', color2, 'LineWidth',3); hold on;
% if exist('cond3') == 1;
% plot(GMFAD3.time(tdx1:tdx2), GMFAD3.avg(tdx1:tdx2), 'color', color3, 'LineWidth',3); hold on;
% end
% axis([cfg.xlim(1) cfg.xlim(2) gmfaymin gmfaymax]);    % axis[xmin xmax ymin ymax] 
% % set(gca,'XTick',[-0.1 -0.05 0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4] );
% 
% labels = t1*1000:50:t2*1000;
% % labels = [-100 -50 0 50 100 150 200 250 300 350 400];
% % set(gca, 'XTick', labels); % Change x-axis ticks
% set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
% set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
% set(gca,'FontSize',24)
% xlabel('Time (ms)', 'FontSize',24,'FontWeight','bold');
% ylabel('Amplitude (µV)','FontSize',24,'FontWeight','bold');
% if exist('cond3') == 1;
% h_legend = legend(comp1,comp2, comp3);
% else
% h_legend = legend(comp1,comp2);
% end
% % set(h_legend,'FontSize',14, 'position',[0.75 0.1 0.2 0.2]);
% set(h_legend,'FontSize',24, 'Location','northeast');
% % set(h_legend,'FontSize',10, 'Location','northwest');
% set(gca,'FontSize',24,'fontWeight','bold','LineWidth',3)
% set(findall(gcf,'type','text'),'FontSize',25,'fontWeight','bold')
% 
% legend boxoff
% box off
% 
% 
% 
% % this is line at 0
% 
% refline = 1;
% refposition = [0 0]; 
% refposition2 = [-100 -100]; 
% 
% if refline >0;
%     h = line(refposition, get(gca, 'YLim'), 'Color', [0 0 0],'LineWidth',3,'LineStyle',':');
%   if refline==2;
%     h = line(refposition2, get(gca, 'YLim'), 'Color', [0 0 0],'LineWidth',3,'LineStyle',':');
%   end;
% end ;
% 
% 
% 
% if P35bar == 1;   
% xP35 = [P35time(1) P35time(2) P35time(2) P35time(1)];
% y = [gmfaymin gmfaymin gmfaymax gmfaymax];
% p0=patch(xP35,y,'r');
% % set(p0,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
% set(p0,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');
% 
% else
% end
% 
% % creating a box
% if N45bar == 1;   
% xN45 = [N45time(1) N45time(2) N45time(2) N45time(1)];
% y = [gmfaymin gmfaymin gmfaymax gmfaymax];
% p1=patch(xN45,y,'r');
% % set(p1,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
% set(p1,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');
% 
% else
% end
% 
% 
% 
% if P60bar == 1;   
% xP60 = [P60time(1) P60time(2) P60time(2) P60time(1)];
% y = [gmfaymin gmfaymin gmfaymax gmfaymax];
% p2=patch(xP60,y,'r');
% % set(p2,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
% set(p2,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');
% 
% else
% end
% 
% 
% if N120bar == 1 ; 
% xN120 = [N120time(1) N120time(2) N120time(2) N120time(1)];
% y = [gmfaymin gmfaymin gmfaymax gmfaymax];
% p3=patch(xN120,y,'r');
% % set(p3,'FaceAlpha',0.3, 'FaceColor',[0.7 0.7 1], 'EdgeColor','none');
% set(p3,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');
% 
% else
% end
% 
% 
% if P200bar == 1 ; 
% xP200 = [P200time(1) P200time(2) P200time(2) P200time(1)];
% y = [gmfaymin gmfaymin gmfaymax gmfaymax];
% p4=patch(xP200,y,'r');
% % set(p4,'FaceAlpha',0.3, 'FaceColor',[1 0.7 0.7], 'EdgeColor','none');
% set(p4,'FaceAlpha',0.1, 'FaceColor','k', 'EdgeColor','none');
% 
% else
% end
% 
% 
%     set(gcf, 'Position', [350 300 800 600]);
% 
% 
% 
% %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% %Plot check
% 
% %Plotting ROI electrode over butter
% 
% plotROI     =  ROI;
% chaninfo = D1.label';
% 
%     for ii = 1:length(plotROI);
%     plotROIidx(ii) = find(strcmp(plotROI{1,ii}, chaninfo));
%     end
%     
%    mplotROID1 = mean(D1.individual(:,plotROIidx,tdx1:tdx2),1);
%    sqm2plotROID1 = squeeze(mean(mplotROID1,2))';
%     
%    mplotROID2 = mean(D2.individual(:,plotROIidx,tdx1:tdx2),1);
%    sqm2plotROID2 = squeeze(mean(mplotROID2,2))';  
%    
%    if exist('cond3') == 1;
%    mplotROID3 = mean(D3.individual(:,plotROIidx,tdx1:tdx2),1);
%    sqm2plotROID3 = squeeze(mean(mplotROID3,2))';
%    end
%    
%    
%    
%    
% %    plotROI2     =  {'FC1', 'FC1'};
%     plotROI2 = {'FC3','FC1','FZ','FCZ'};
%     chaninfo = D1.label';
% 
%     for ii = 1:length(plotROI2);
%     plotROIidx2(ii) = find(strcmp(plotROI2{1,ii}, chaninfo));
%     end
%     
%    mplotROID21 = mean(D1.individual(:,plotROIidx2,tdx1:tdx2),1);
%    sqm2plotROID21 = squeeze(mean(mplotROID21,2))';
%     
%    mplotROID22 = mean(D2.individual(:,plotROIidx2,tdx1:tdx2),1);
%    sqm2plotROID22 = squeeze(mean(mplotROID22,2))';  
%    
%    if exist('cond3') == 1;
%    mplotROID23 = mean(D3.individual(:,plotROIidx2,tdx1:tdx2),1);
%    sqm2plotROID23 = squeeze(mean(mplotROID23,2))';
%    end
%    
% %    {'AF4', 'F6' , 'F4', 'FC4' , 'F2' , 'FC2' , 'FZ', 'FCZ'};
%    
%     
% % plotPZ     =  {'PZ'};
% % chaninfo = D1.label';
% % 
% %     for ii = 1:length(plotPZ);
% %     plotPZidx(ii) = find(strcmp(plotPZ{1,ii}, chaninfo));
% %     end
%     
% 
% 
%     f1 = figure;
%     
%     if exist('cond3') == 1;
%     subplot(1,3,1)
%     else
%     subplot(1,2,1)
%     end
%         plot(D1.time(tdx1:tdx2),squeeze(mean(D1.individual(:,:,tdx1:tdx2),1)),'color', [0 0.4470 0.7410]); grid on; hold on;
%         plot(D1.time(tdx1:tdx2),sqm2plotROID1,'r','LineWidth',2); grid on; hold on;
% %         plot(D1.time(tdx1:tdx2),sqm2plotROID21,'b','LineWidth',2); grid on; hold on;
% 
% 
% 
% 
% %     plot([0 0], get(gca,'ylim'),'r--');
%     plot([0 0], [-8 8],'r--');
%     set(gca,'Xlim', cfg.xlim);
%     %labels = t1*1000:50:t2*1000;
%     set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
%     set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
%     xlabel('Time (ms)');
%     ylabel('Amplitude (\muV)');
%     title( comp1,'fontweight','bold');
%     yScale = get(gca,'ylim');
% 
%     if exist('cond3') == 1;
%     subplot(1,3,2)
%     else
%     subplot(1,2,2)
%     end
%         plot(D2.time(tdx1:tdx2),squeeze(mean(D2.individual(:,:,tdx1:tdx2),1)),'color', [0 0.4470 0.7410]); grid on; hold on;
%         plot(D2.time(tdx1:tdx2),sqm2plotROID2,'r','LineWidth',2); grid on; hold on;
% %         plot(D2.time(tdx1:tdx2),sqm2plotROID22,'b','LineWidth',2); grid on; hold on;
% 
%     plot([0 0], yScale,'r--');
%     set(gca,'Xlim', cfg.xlim,'ylim',yScale);
%     set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
%     set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
%     xlabel('Time (ms)');
%     ylabel('Amplitude (\muV)');
%     title(comp2 ,'fontweight','bold');
% 
%     
%     if exist('cond3') == 1;
%     subplot(1,3,3)
%     plot(D3.time(tdx1:tdx2),squeeze(mean(D3.individual(:,:,tdx1:tdx2),1)),'color', [0 0.4470 0.7410]); grid on; hold on;
%     plot(D3.time(tdx1:tdx2),sqm2plotROID3,'r','LineWidth',2); grid on; hold on;
% %     plot(D3.time(tdx1:tdx2),sqm2plotROID23,'b','LineWidth',2); grid on; hold on;
% 
%     
%     
%     plot([0 0], yScale,'r--');
%     plot([0 0], yScale,'r--');    
%     set(gca,'Xlim', cfg.xlim,'ylim',yScale);
%     set(gca,'XTick',[cfg.xlim(1):0.05:cfg.xlim(2)]); 
%     set(gca, 'XTickLabel', labels); % Change x-axis ticks labels.
%     xlabel('Time (ms)');
%     ylabel('Amplitude (\muV)');
%     title(comp3 ,'fontweight','bold');
%     end
%     
%     set(gcf, 'Position', [50 500 1800 360]);
%     
%     
%     
%     
%%     
% %%    
%     % TOPOPLOTs!!!!

D1.avg=squeeze(mean(D1.individual,1));
D2.avg=squeeze(mean(D2.individual,1));

if exist('cond3') == 1;
D3.avg=squeeze(mean(D3.individual,1));
end


%%%% almost same as topoplotER
D2.prediff = D2.avg - D1.avg;
if exist('cond3') == 1;
D3.prediff = D3.avg - D1.avg;
end

% N45time = [0.035 0.05];
% P60time = [0.055 0.08]; % for graph (P60)
% N100time = [0.085 0.140]; % for graph (N100)
% P200time = [0.16 0.24];




% N45
    figure;

subplot(2,1,1);
cfg = [];
cfg.zlim = [-1.5 1.5];
cfg.xlim = [0.03,0.05];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D1);
title([comp1 ' N45'] , 'fontsize',12,'fontweight','bold');


subplot(2,1,2);
cfg = [];
cfg.zlim = [-1.5 1.5];
cfg.xlim = [0.03,0.05];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D2);
title([comp2 ' N45'] , 'fontsize',12,'fontweight','bold');

    set(gcf, 'Position', [300 100 600 400]);


% P60
  figure;

subplot(2,1,1);
cfg = [];
cfg.zlim = [-1.5 1.5];
cfg.xlim = [0.05,0.08];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D1);
title([comp1 ' P60'] , 'fontsize',12,'fontweight','bold');


subplot(2,1,2);
cfg = [];
cfg.zlim = [-1.5 1.5];
cfg.xlim = [0.05,0.08];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D2);
title([comp2 ' P60'] , 'fontsize',12,'fontweight','bold');

    set(gcf, 'Position', [300 100 600 400]);




% N100
figure;
subplot(2,1,1);
cfg = [];
cfg.zlim = [-3 3];
cfg.xlim = [0.09,0.13];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D1);
title([comp1 ' N100'] , 'fontsize',12,'fontweight','bold');



subplot(2,1,2);
cfg = [];
cfg.zlim = [-3 3];
cfg.xlim = [0.09,0.13];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D2);
title([comp2 ' N100'] , 'fontsize',12,'fontweight','bold');



   % P200 
    figure;

subplot(2,1,1);
cfg = [];
cfg.zlim = [-4 4];
cfg.xlim = [0.16,0.24];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D1);
title([comp1 ' P200'] , 'fontsize',12,'fontweight','bold');


subplot(2,1,2);
cfg = [];
cfg.zlim = [-4 4];
cfg.xlim = [0.16,0.24];
cfg.comment='xlim';
cfg.commentpos = 'title';
cfg.layout = 'quickcap64.mat';
cfg.parameter = 'avg';
cfg.channel = 'all';
cfg.colorbar = 'yes';
cfg.colormap = 'jet';
ft_topoplotER(cfg,D2);
title([comp2 ' P200'] , 'fontsize',12,'fontweight','bold');

    set(gcf, 'Position', [300 100 600 400]);


%%
% 
% % N100 Diff
% figure;
% 
% subplot(2,1,1);
% cfg = [];
% cfg.zlim = [-1 1];%[-4 4];
% cfg.xlim = [0.10,0.14];
% cfg.comment='xlim';
% cfg.commentpos = 'title';
% cfg.layout = 'quickcap64.mat';
% cfg.parameter = 'prediff';
% cfg.channel = 'all';
% cfg.colorbar = 'yes';
% cfg.colormap = 'jet';
% ft_topoplotER(cfg,D2);
% title('T1-BL N100' , 'fontsize',12,'fontweight','bold');
% set(gca,'FontSize',15,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')
% 
% subplot(2,1,2);
% cfg = [];
% cfg.zlim = [-1 1]; %[-4 4];
% cfg.xlim = [0.10,0.14];
% cfg.comment='xlim';
% cfg.commentpos = 'title';
% cfg.layout = 'quickcap64.mat';
% cfg.parameter = 'prediff';
% cfg.channel = 'all';
% cfg.colorbar = 'yes';
% cfg.colormap = 'jet';
% ft_topoplotER(cfg,D3);
% title('T2-BL N100' , 'fontsize',12,'fontweight','bold');
% 
%     set(gcf, 'Position', [300 100 1200 800]);
% set(gca,'FontSize',15,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')
% 
%     
%     
%     
%     
%     
% % P200 Diff
% 
% figure;
% subplot(2,1,1);
% cfg = [];
% cfg.zlim = [-1 1]; %[-5 5];
% cfg.xlim = [0.16,0.24];
% cfg.comment='xlim';
% cfg.commentpos = 'title';
% cfg.layout = 'quickcap64.mat';
% cfg.parameter = 'prediff';
% cfg.channel = 'all';
% cfg.colorbar = 'yes';
% cfg.colormap = 'jet';
% ft_topoplotER(cfg,D2);
% title('T1-BL P200' , 'fontsize',12,'fontweight','bold');
% set(gca,'FontSize',15,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',12,'fontWeight','bold')
% 
% subplot(2,1,2);
% cfg = [];
% cfg.zlim = [-1 1];%[-5 5];
% cfg.xlim = [0.16,0.24];
% cfg.comment='xlim';
% cfg.commentpos = 'title';
% cfg.layout = 'quickcap64.mat';
% cfg.parameter = 'prediff';
% cfg.channel = 'all';
% cfg.colorbar = 'yes';
% cfg.colormap = 'jet';
% ft_topoplotER(cfg,D3);
% title('T2-BL P200' , 'fontsize',12,'fontweight','bold');
% 
% set(gcf, 'Position', [300 100 1200 800]);
% set(gca,'FontSize',15,'fontWeight','bold')
% set(findall(gcf,'type','text'),'FontSize',15,'fontWeight','bold')
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% %%
% %%%% topoplotER
% 
% % cfg = [];
% % % cfg.xlim = [0.246:0.004:0.288];
% % cfg.xlim = [0.085,0.14];
% % cfg.comment = 'xlim';
% % cfg.zlim = [-4 4];
% % cfg.colorbar = 'yes';
% % cfg.layout = 'quickcap64.mat';
% % cfg.commentpos = 'title';
% % cfg.colormap = 'jet';
% % figure; ft_topoplotER(cfg,D1);
% % 
% % % 
% % % 
% % % 
% % cfg = [];
% % % cfg.xlim = [0.08 0.11];
% % % cfg.xlim = [0.13 0.165];
% % cfg.xlim = [0.085,0.14];
% % cfg.comment = 'xlim';
% % cfg.zlim = [-4 4];
% % cfg.colorbar = 'yes';
% % cfg.layout = 'quickcap64.mat';
% % cfg.commentpos = 'title';
% % cfg.colormap = 'jet';
% % figure; ft_topoplotER(cfg,D2);
% % 
% % 
% % if exist('cond3') == 1;
% % cfg = [];
% % cfg.xlim = [0.085,0.14];
% % cfg.comment = 'xlim';
% % cfg.zlim = [-4 4];
% % cfg.colorbar = 'yes';
% % cfg.layout = 'quickcap64.mat';
% % cfg.commentpos = 'title';
% % cfg.colormap = 'jet';
% % figure; ft_topoplotER(cfg,D3);
% % end