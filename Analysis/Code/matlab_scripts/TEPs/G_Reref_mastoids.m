eeglab;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data/';


% ID = {'017', '018', '019', '020','021','022','023'};
%ID = {'001', '002','005', '006', '008', '009', '010', '011', '012', '013', '014', '015', '016', '017', '018', '019', '020','021','022','023'};

%ID = {'101','102','103','104','105','106','107', '108','109','110','111','112','113','114','115','116','117','118','119'};
ID = {'004'};

Group = {'Control','mTBI'};

Timepoint = {'BL'};
% Sesh = {'BL';'T1';'T2'};
Datatype = {'resting'};
% Condition= {'PrePost'};

caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions

GroupStart=2;
GroupFinish=2;

SubjectStart=1;
%SubjectFinish=numel(ID);
SubjectFinish=20;

TimepointStart=1;
TimepointFinish=1;

inPath = [datadir filesep 'SP_analysis_Control' filesep]; %where the data is
outPath = [datadir filesep 'SP_analysis_Control' filesep]; %where you want to save the data
% ConditionStart=1;
% ConditionFinish=2;

%Cond=ConditionStart:ConditionFinish;


%%
for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
%         for Tp=TimepointStart:TimepointFinish
            
            
                     
        EEG=[];
        
 try

EEG = pop_loadset('filename', [ ID{1,Subjects} '_SP_BL_PrePost_ds_ica2_clean2.set'], 'filepath', [inPath ID{1,Subjects} filesep]);


EEG = pop_interp(EEG, EEG.allchan, 'spherical');

% %AVERAGE RE-REFERENCE - Run eeglab and use EEG.history to figure it out.

% M1= find(ismember({EEG.chanlocs.labels}, 'M1'));
% M2= find(ismember({EEG.chanlocs.labels}, 'M2'));
%  EEG = pop_reref( EEG, [],'exclude',[M1 M2] );

EEG = pop_select( EEG,'nochannel',{'M1' 'M2' 'E3'});
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 


%  EEG = pop_reref( EEG, []);
 EEG = pop_reref( EEG, [],'refloc',struct('labels',{'CPZ'},'type',{''},'theta',{180},'radius',{0.12662},'X',{-32.9279},'Y',{-4.0325e-15},'Z',{78.363},'sph_theta',{-180},'sph_phi',{67.208},'sph_radius',{85},'urchan',{67},'ref',{''},'datachan',{0}));

 

EEG = pop_saveset(EEG, 'filename', [ID{1,Subjects} '_SP_BL_PrePost_ds_ica2_clean2_reref.set'], 'filepath', [outPath ID{1,Subjects} filesep]);
% EEG = pop_loadset('filename', [ID{1,Subjects} '_SP_BL_PrePost_ds_ica2_clean2_reref.set'], 'filepath', [outPath ID{1,Subjects} filesep]);


%%new part
temp = EEG;

EEG = pop_selectevent( EEG, 'type',{'1'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = pop_saveset(EEG, 'filename', [ID{1,Subjects} '_SP_BL_Pre_final.set'], 'filepath', [outPath ID{1,Subjects} filesep]);

Pre = EEG;

EEG = temp;
EEG = pop_selectevent( EEG, 'type',{'2'},'deleteevents','off','deleteepochs','on','invertepochs','off');
EEG = pop_saveset(EEG, 'filename', [ID{1,Subjects} '_SP_BL_Post_final.set'], 'filepath', [outPath ID{1,Subjects} filesep]);
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
    
    saveas(gcf, [outPath filesep ID{1,Subjects} filesep [ID{1,Subjects} '_TEP_final_' region]])
    %% GMFA
%     
    [gfp1,gd1] = eeg_gfp([mean([Pre.data(:,:,:)],3)]',1);
    [gfp2,gd2] = eeg_gfp([mean([Post.data(:,:,:)],3)]',1);

    figure;
    plot(Pre.times(:,tp1:tp2,:),gfp1(tp1:tp2)','b');hold on;
    plot(Post.times(:,tp1:tp2,:),gfp2(tp1:tp2)','r');hold on;
    legend('Pre','Post');
    saveas(gcf, [outPath filesep ID{1,Subjects} filesep [ID{1,Subjects} '_GFP_final']]);

%% Butterfly
    figure;
   plot(Pre.times(1,tp1:tp2), mean(Pre.data(1,tp1:tp2,:),3), 'b'); hold on;
   plot(Post.times(1,tp1:tp2), mean(Post.data(1,tp1:tp2,:),3), 'r'); hold on;
    legend('Pre','Post');
    hold on 
   plot(Pre.times(:,tp1:tp2), mean(Pre.data(:,tp1:tp2,:),3), 'b'); hold on;
   plot(Post.times(:,tp1:tp2), mean(Post.data(:,tp1:tp2,:),3), 'r'); hold on;
    legend('Pre','Post');
    saveas(gcf, [outPath filesep ID{1,Subjects} filesep [ID{1,Subjects} '_Butter_final']]);


    close all;

 catch
     
 end
 
    end
end
