clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
cd(datadir);
%SETTINGS
eeglab;

ID = '004'; %just change participants as you go along

% ID = {'H201';'H202';'H203';'H204';'H205';'H206';'H207';'H208';'H209';'H210';'H212';'H213';'H214';'H215';'H216';'H217';'H218'};

Sesh = 'T1';

% Sesh = {'BL';'T1';'T2'};
tp = 'PrePost'; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'SP_analysis_Control' filesep]; %where the data is
outPath = [datadir filesep 'SP_analysis_Control' filesep]; %where you want to save the data


caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';

%this is for later for plotting
region1 = 'FCZ';
region2 = 'PZ';
% region2 = 'CP4';

elec = 'CZ';


%% loading ds file from Hannah_Sung_1 (updated to the PrePost merged file)
EEG = pop_loadset( 'filename', [ID,  '_SP_',Sesh,'_',tp,'.set'], 'filepath', [outPath filesep ID filesep]); %ds = downsample
  
try
EEG = pop_select( EEG,'nochannel',{'M1' 'M2' 'E3'});
catch
end
%% OPTIONAL IF LOOKS BAD

    EEG.allchan=EEG.chanlocs; % copy of all the channels you have (saved as EEG.allchan)

%Check for bad channel
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials, take note of any bad channels and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial1=find(EEG.reject.rejmanual==1); % saved as EEG.badtrial1
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

%Remove bad channels
bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end

%% Run fast ICA to find muscle artifact components (first run through)
    EEG = pop_tesa_fastica(EEG,'approach', 'symm', 'g', 'tanh', 'stabilization', 'on' ); 
    EEG = eeg_checkset( EEG );  
    
    
    %%%%%%
    
    %% save file post fastICA

EEG = pop_saveset(EEG, 'filename', [ID,  '_SP_',Sesh,'_',tp,'_ds_ica1.set'], 'filepath', [outPath ID filesep]);
% EEG = pop_loadset('filename', [ID,  '_SP_',Sesh,'_',tp,'_ds_ica1.set'], 'filepath', [outPath ID filesep]);
   
   % visual inspection of components, 1 = good, 2 = remove, d= done. Want to remove big components, which come first. 
EEG = pop_tesa_compselect( EEG, 'figSize', 'large','blink', 'off', 'move', 'off', 'muscle', 'off', 'elecNoise', 'off');


% filter (helpful for removing drift)
% loc=pwd;
% cd(filterfolder)

EEG = tesa_filtbutter( EEG, 1, 100, 4, 'bandpass' );
EEG = tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );

% cd(loc);


%%
%CLEAN 2

%Check for bad trials
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial2=find(EEG.reject.rejmanual==1);
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end

%ICA 2
    EEG = pop_tesa_fastica(EEG,'approach', 'symm', 'g', 'tanh', 'stabilization', 'on' ); 
%     EEG = pop_runica(EEG,'icatype','fastica', 'approach', 'symm', 'g', 'tanh'); 
    EEG = eeg_checkset( EEG );  
        

%%

%Save point
EEG = pop_saveset(EEG, 'filename', [ ID '_SP_',Sesh,'_',tp,'_ds_ica2.set'], 'filepath', [outPath ID filesep]);
% EEG = pop_loadset('filename', [ID '_TMSEEG_' Sesh '_ds_ica1_filt_ica2.set'], 'filepath', [outPath ID filesep]);
    %%
    
    
% % TESA (run to see what channels are missing incase have deleted AF3 AF4
% or F7 and F8- also can input new channels manually below)

%  figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
% belecs=inputdlg('Enter blink channels (two) separated by a space (i.e. AF3 AF4)', 'Blinks!!', [1 50]); % enter blink elecs to use
% str=belecs{1};
% belecs=strsplit(str);
% % 
% melecs=inputdlg('Enter horizontal eye channels (two) separated by a space (i.e. F7, F8)', 'Lateral eye!!', [1 50]); % enter blink elecs to use
% str2=melecs{1};
% melecs=strsplit(str2);
% 
% close all;

belecs = {'AF3' , 'AF4'};
melecs = {'F7' , 'F8'};

%% Fast ICA 2
EEG = tesa_compselect(EEG, 'blinkElecs', belecs , 'moveElecs', melecs, 'figSize', 'large','plotTimeX',[-200,700] ,'plotFreqX', [2,80]);

% EEG = tesa_detrend( EEG, 'linear', [21,1500] );

%%

%Save point
EEG = pop_saveset(EEG, 'filename', [ ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean.set'], 'filepath', [outPath ID filesep]);
% EEG = pop_loadset('filename', [ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean.set'], 'filepath', [outPath ID filesep]);

%%Sung double check for clean data
EEG = eeg_checkset( EEG );
pop_eegplot( EEG, 1, 1, 0);
R1=input('Highlight any bad trials, take note of any bad channels and press "update marks". Press enter when ready to continue.');

%Remove bad trials
EEG.badtrial1=find(EEG.reject.rejmanual==1); % saved as EEG.badtrial1
EEG=pop_rejepoch(EEG,find(EEG.reject.rejmanual==1),0);

%Remove bad channels
bad=inputdlg('Enter bad channels separated by a space (i.e. FZ CZ P3 etc)', 'Bad channel removal', [1 50]); % enter bad channels to remove
str=bad{1};
EEG.badchan=strsplit(str);
if isempty(EEG.badchan)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchan);
end

%%
%INTERPOLATE MISSING CHANNELS


%Save point
EEG = pop_saveset(EEG, 'filename', [ ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean2.set'], 'filepath', [outPath ID filesep]);
% EEG = pop_loadset('filename', [ ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean2.set'], 'filepath', [outPath ID filesep]);

EEG = pop_interp(EEG, EEG.allchan, 'spherical');

% %AVERAGE RE-REFERENCE - Run eeglab and use EEG.history to figure it out.

% M1= find(ismember({EEG.chanlocs.labels}, 'M1'));
% M2= find(ismember({EEG.chanlocs.labels}, 'M2'));
%  EEG = pop_reref( EEG, [],'exclude',[M1 M2] );

try
EEG = pop_select( EEG,'nochannel',{'M1' 'M2' 'E3'});
catch
end

[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 


%  EEG = pop_reref( EEG, []);
 EEG = pop_reref( EEG, [],'refloc',struct('labels',{'CPZ'},'type',{''},'theta',{180},'radius',{0.12662},'X',{-32.9279},'Y',{-4.0325e-15},'Z',{78.363},'sph_theta',{-180},'sph_phi',{67.208},'sph_radius',{85},'urchan',{67},'ref',{''},'datachan',{0}));

 

EEG = pop_saveset(EEG, 'filename', [ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean_reref.set'], 'filepath', [outPath ID filesep]);

%EEG = pop_loadset('filename', [ID '_SP_',Sesh,'_',tp,'_ds_ica2_clean_reref.set'], 'filepath', [outPath ID filesep]);

%%
%SPLIT INTO SEPERATE FILES
temp = EEG;

EEG = pop_selectevent( EEG, 'type',{'1'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = pop_saveset(EEG, 'filename', [ID '_SP_',Sesh,'_Pre_final.set'], 'filepath', [outPath ID filesep]);

Pre = EEG;

EEG = temp;
EEG = pop_selectevent( EEG, 'type',{'2'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = pop_saveset(EEG, 'filename', [ID '_SP_',Sesh,'_Post_final.set'], 'filepath', [outPath ID filesep]);
% 
Post = EEG;
% 


%% plotting

region = 'FCZ';
% %%  Graph of grand averages at each time point (specified channel)
    t1 = -300;
    t2 = 600;
    tp1 = find(EEG.times == t1);
    tp2 = find(EEG.times == t2);
    
%     
%         % Indexing channel
    COI = {EEG.chanlocs.labels};  % channel of interest
    IND = find(cellfun(@(x) strcmp(x, region), COI)); % giving it the number so you can just change setting to get whichever value
    
    if strcmp(IND,[]);
    noregion = menu('Oops, the channel must''ve been removed! Please choose among these',COI);    
    IND = noregion;
    end
     
    
    figure;
    plot(Pre.times(:,tp1:tp2,:),mean(Pre.data(IND,tp1:tp2,:),3),'b');hold on;
    plot(Post.times(:,tp1:tp2,:),mean(Post.data(IND,tp1:tp2,:),3),'r');hold on;
    legend('Pre','Post');
    
    saveas(gcf, [outPath filesep ID filesep [ID '_TEP_final_',region,'_',Sesh]])
    %% GMFA
%     
    [gfp1,gd1] = eeg_gfp([mean([Pre.data(:,:,:)],3)]',1);
    [gfp2,gd2] = eeg_gfp([mean([Post.data(:,:,:)],3)]',1);

    figure;
    plot(Pre.times(:,tp1:tp2,:),gfp1(tp1:tp2)','b');hold on;
    plot(Post.times(:,tp1:tp2,:),gfp2(tp1:tp2)','r');hold on;
    legend('Pre','Post');
    saveas(gcf, [outPath filesep ID filesep [ID '_GFP_final_',Sesh]]);

%% Butterfly
    figure;
   plot(Pre.times(1,tp1:tp2), mean(Pre.data(1,tp1:tp2,:),3), 'b'); hold on;
   plot(Post.times(1,tp1:tp2), mean(Post.data(1,tp1:tp2,:),3), 'r'); hold on;
    legend('Pre','Post');
    hold on 
   plot(Pre.times(:,tp1:tp2), mean(Pre.data(:,tp1:tp2,:),3), 'b'); hold on;
   plot(Post.times(:,tp1:tp2), mean(Post.data(:,tp1:tp2,:),3), 'r'); hold on;
    legend('Pre','Post');
    saveas(gcf, [outPath filesep ID filesep [ID '_Butter_final_',Sesh]]);
