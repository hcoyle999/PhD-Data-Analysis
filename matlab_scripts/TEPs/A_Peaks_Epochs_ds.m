clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';
cd(datadir);
%SETTINGS

eeglab;
ID= {'004'};
%ID = {'001';'002';'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015';'016'; '017'; '018'; '019';'020';'021'}
%'112'; '113'; '114'; '115';'116'; '117'; '118'; '119'};
%ID = {'103';'105';'107';'109';'110';'111';'112';'116';};
% ID = {'H201';'H202';'H203';'H204';'H205';'H206';'H207';'H208';'H209';'H210';'H212';'H213';'H214';'H215';'H216';'H217';'H218'};

Sesh = {'T1'};
% Sesh = {'BL';'T1';'T2'};
tp = {'Post'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'Control' filesep];
outPath = [datadir filesep 'SP_analysis_Control' filesep]; %where you want to save the data

mkdir(outPath);


caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';

region = 'FCZ';
elec = 'CZ';
%% 


for aaa = 1:size(ID,1);
    
    cd([inPath filesep ID{aaa,1}]); % creating a directory of inPath, filesep is either / or \

    for aa = 1:size(Sesh,1);
    

        for a = 1:size(tp,1); % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
    
    % Loading data
    EEG = pop_loadcnt([inPath,ID{aaa,1}, filesep,Sesh{aa,1}, filesep, ID{aaa,1},  '_SP_',Sesh{aa,1},'_',tp{a,1},'.cnt'], 'dataformat', 'auto', 'memmapfile', '');
%     EEG = pop_loadcnt([inPath,ID{aaa,1}, filesep, Sesh{aa,1}, filesep 'TMSEEG', filesep,ID{aaa,1},'_',Sesh{aa,1},'_',tp{a,1},'_SP.cnt'], 'dataformat', 'auto', 'memmapfile', '');

% Removes existing triggers/events
    EEG.event =[];
    EEG = eeg_checkset( EEG );
%     EEG = eeg_eegrej( EEG, [1416714 1418322] );
    
    %Channel locations

    EEG = pop_chanedit(EEG, 'lookup', caploc); %caploc - channel information

    %Remove unused channels
    EEG = pop_select( EEG,'nochannel',{'FP1' 'FPZ' 'FP2' 'FT7' 'FT8' 'TP7' 'TP8' 'CB1' 'CB2' 'HEOG' 'PO5' 'PO6' 'E1' 'E2' 'E3' 'M1' 'M2'});
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
    
    % copy of all the channels you have (saved as EEG.allchan)
    EEG.allchan=EEG.chanlocs; 
   
    %% Relabel CPZ as online reference 
    refno = find(strcmp({EEG.chanlocs.labels}, 'CPZ'));
    EEG.data(refno,:,:)=0;
    EEG = eeg_checkset( EEG );
    EEG = pop_reref( EEG, refno);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off'); 
   
    % Voltage threshold for no Trigger label
    
%     EEG = tesa_findpulse( EEG, 'Cz','refract', 50, 'rate', 2e8, 'tmsLabel','1', 'plots','on');
%     EEG = tesa_findpulse( EEG, elec ,'tmsLabel','1', 'plots','on');

   
EEG = tesa_findpulsepeak( EEG, elec, 'dtrnd', 'poly', 'thrshtype','dynamic', 'wpeaks', 'pos', 'plots', 'on', 'tmsLabel', '1');
% EEG = tesa_findpulsepeak( EEG, elec, 'dtrnd', 'poly', 'thrshtype','dynamic', 'wpeaks', 'gui', 'plots', 'on', 'tmsLabel', '1');

% % % EEG = tesa_findpulsepeak( EEG, elec, 'dtrnd', 'poly', 'thrshtype','dynamic', 'wpeaks', 'gui', 'plots', 'on', 'tmsLabel', 'spike');

% % % TempEEG = tesa_findpulsepeak( EEG, 'F1', 'dtrnd', 'poly', 'thrshtype',15, 'wpeaks', 'pos', 'plots', 'on', 'tmsLabel', 'spike');



% Removes magnetic pulse artifact and interpolate
[EEG,nanspan] = tesa_artwidth(EEG,-5,15);
[EEG,nanspan] = tesa_artcheck(EEG,nanspan,50);
[~,section]= tesa_artwindow(EEG,nanspan);
% [~,section]= tesa_artwindow(EEG,nanspan, 'plot','F1');

%[EEG]=pop_select('no channel ')

[EEG]= tesa_removeandinterpolate(EEG,nanspan,section,1,2,0, elec ,1);
[~,nanspan] = tesa_artwidth(EEG,-5,15);
% [~,nanspan] = tesa_artwidth(EEG,-2,10);

[~,mask]= tesa_artwindow(EEG,nanspan);
% [~,mask]= tesa_artwindow(EEG,nanspan, 'plot','F1');

%% interpolate then filter spikes (to remove spikes) 
blanks = []; 
blanks = NaN(size(mask));
t=[]; 
t=1:EEG.pnts;
x=[];
rawdata=[];
data=[];
cleandata=[];       
[ch,pnts,eps]=size(EEG.data);
SPK=EEG;

for c=1:ch;
    for e=1:eps;  
 x=[];
rawdata=[];
data=[];
cleandata=[];           
        
        
rawdata = SPK.data(c,:,e);
data=rawdata;
data(mask) = blanks;
x=data;
nans = isnan(x);
x(nans) = interp1(t(~nans), x(~nans), t(nans),'pchip');
rawdat=x;  
% % % %         cleandat1=medfilt1(rawdat,100);
% % % %         cleandat2=medfilt1(rawdat,1000);
% % % %         cleandat3= hampel(rawdat,1000,5);
% % % %         cleandat33= hampel(rawdat,100,3);
        [cleandat,I]= hampel(rawdat,200,3);
% % % %         cleandat11=medfilt1(rawdat,5);

%         figure; plot(EEG.times,rawdata,'k:');
% % % %         hold on ; 
% % % %          plot(EEG.times,cleandat1);
% % % %           plot(EEG.times,cleandat2);
% % % %          plot(EEG.times,cleandat3);
% % % %           plot(EEG.times,cleandat33);
% % % %           plot(EEG.times,cleandat33,'m');
% % % %         plot(EEG.times,cleandat,'r');

 cleandat(I)=NaN;
 x=cleandat;
nans = isnan(x);
x(nans) = interp1(t(~nans), x(~nans), t(nans),'pchip');
% x(nans) = interp1(t(~nans), x(~nans), t(nans),'linear');

cleandata=x;  
cleandata(mask)=rawdata(mask)   ;     
%  plot(EEG.times,cleandata,'g');
%  drawnow;
%  hold off; 
SPK.data(c,:,e)= cleandata;
    end
end

EEG=[];
EEG=SPK;

%%
    
    % Epoch -1 to 2s ('1' is the identifier)
    EEG = pop_epoch( EEG, { '1' } , [-1  2], 'newname', 'CNT file epochs', 'epochinfo', 'yes');   
  
    % Baseline correction -500 to -50 (making sure everything fluctuates
    % around 0) What we record is DC, so it brings baseline to 0
    EEG = pop_rmbase( EEG, [-500   -50]); % Before the TMS pulse
%     EEG = eeg_checkset( EEG );
    
    % Loop within the loop, looking at events (** for when you are doing
    % multiple timepoints**)
    %for b = 1:size(EEG.event,2) % "." means Look into xxx before ".", we are looking at 2nd dimension
        %EEG.event(1,b).type = tp{a,1}; %replace triggers with time markers, tp = time point, BL T1 T2
   %end
    
    %[ALLEEG, EEG, CURRENTSET]=eeg_store(ALLEEG, EEG, a); %store data in ALLEEG for merge (double-click ALLEEG in workspace) ALLEEG is a stroage, use sparingly cuz it will slow down with more 
    
end


%% Merge Files (**also for when you are doing multiple timepoints**)
%sizeTp = 1:1:size(tp,1); %create number of time points -> 3 time points
%EEG = pop_mergeset(ALLEEG, sizeTp, 0); %merge time points

%EEG.urevent =[]; %reconstruct urevent -> making sure that information within EEG structure is consistent (event and urevent)

%for a = 1:size(EEG.event,2);
    %EEG.urevent(1,a).epoch = EEG.event(1,a).epoch;
    %EEG.urevent(1,a).type = EEG.event(1,a).type;
    %EEG.urevent(1,a).latency = EEG.event(1,a).latency;
%end

%%
%REMOVE UNUSED CHANNELS


% EEG = tesa_removedata( EEG, [-5 20] );
% EEG = tesa_interpdata( EEG, 'linear' );

% Downsample the data
EEG = pop_resample(EEG, 1000); 

mkdir([outPath filesep ID{aaa,1} filesep]);
EEG = pop_saveset(EEG, 'filename', [ID{aaa,1},  '_SP_',Sesh{aa,1},'_',tp{a,1},'_ds.set'], 'filepath', [outPath filesep ID{aaa,1} filesep]); %ds = downsample


clear blanks cleandat cleandata data I nans nanspan rawdat rawdata section t x SPK EEG



    end
    
end


