%--------------------------------------------------------------------------------%
%THIS SCRIPT CONDUCTS PEAK TO PEAK ANALYSIS OF TEP's WITH THE CLEANED AND EPOCHED
%TMS-EEG DATA
%--------------------------------------------------------------------------------%

%INPUT
clear; close all;
eeglab_path='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b';
cd(eeglab_path);
eeglab;
datadir='F:\TMS_EEG Data\'; 
%datadir='//Volumes/HOY_2/TMS_EEG Data/';
cd(datadir);

% ##### SETTINGS #####

%ID = {'101';'103';'104';'105';'106';'108';'107';'109';'110';'111';'112';'113';'114';'115';'116'; '117';'118';'119';'120';'121';'122';'123';'124';'125';'126';'127';'128';'129';'130'};
%ID = {'001';'002';'003';'004';'005';'006';'008';'009';'010';'011';'012';'013';'014';'015';'017';'018';'019';'020';'021';'022';'023';'024';'025';'026';'027';'028'};
ID= {'026'};
inPath = [datadir filesep 'SP_analysis_Control' filesep];%where the data is
outPath = [datadir filesep 'SP_analysis_P2P' filesep]; %where you want to save the data
mkdir(outPath)
%here=pwd;
ft_defaults;
%cd(here)
Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp ={'Post'};% {'Pre'}; %  (pre or post iTBS)
% tp = {'Pre';'Post';'Delay'}; %trigger points
  
% % PRE
% %  N100:
Pos_1={'AF4' ,'F1','FZ','F2','F4','F6','F8','FC3','FC1','FCZ','FC2','FC4','FC6'};
Neg_1= {'P7','P5','P3','P6','P8','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};
% % PRE
% %  P60:
Pos_2={'CP5' ,'P7','P5','P3','P1','PO7','PO3','POZ','O1'}; 
% % POST 
% % N100
Pos_3 = {'AF4','F1','FZ','F2','F4','F6','F8','FC3','FC1','FC2','FC4','FC6','C4','C6'};
Neg_2 =  {'CP5','P7','P5','P3','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};


clusters ={Pos_1,Pos_2,Pos_3,Neg_1,Neg_2};
clabels={'P1','P2','P3','N1','N2'};

% EEG = pop_tesa_peakanalysis( EEG,...
%     'GMFA', 'positive',...
%     [35 45 60 120 200], ...
%     [31 41;35 48;50 70;90 135;150 240],...
%     'method', 'largest', 'samples', 5 );

for x = 1:size(ID,1)
    for y = 1:size(Sesh,1)
        for z = 1:size(tp,1)
            cd(inPath)
             EEG = pop_loadset('filename', [ID{x,1} '_SP_',Sesh{y,1},'_',tp{z,1} '_final.set'], 'filepath',[inPath filesep ID{x,1} filesep]);
            % EEG = pop_tesa_tepextract( EEG, 'ROI', 'elecs', {'FC1','FC3','C1','C3'} );
             
             %GMFA all chans
             EEG = pop_tesa_tepextract( EEG, 'GMFA', 'tepName','GMFA' );
             EEG = pop_tesa_peakanalysis( EEG,'GMFA', 'positive',...
             [35, 45, 60 ,120, 200], ...
             [31 41;35 48;50 70;90 135;150 240]);
   
             % ROI clusters  
             for c=1:length(clabels)
             EEG = pop_tesa_tepextract( EEG, 'ROI', 'elecs', clusters{c} , 'tepName',clabels{c});
             end 
             
              EEG = pop_tesa_peakanalysis( EEG,'ROI', 'positive',...
             [35, 45, 60 ,120, 200], ...
             [31 41;35 48;50 70;90 135;150 240]);
             
             EEG = pop_tesa_peakanalysis( EEG,'ROI', 'negative',...
             [35, 45, 60 ,120, 200], ...
             [31 41;35 48;50 70;90 135;150 240]);

             % ROI neg cluster 
             %averages over trials to generate a TMS-evoked potential (TEP)            
             %EEG = tesa_findpulsepeak( EEG, elec, 'dtrnd', 'poly', 'thrshtype','dynamic', 'wpeaks', 'gui', 'plots', 'on', 'tmsLabel', '1'
             %EEG = tesa_peakanalysis( EEG, 'ROI', 'negative', 100, [80,120] ); % find a negative peak in all ROI analyses at 100 ms searching between 80 and 120 ms.
             %   EEG = tesa_peakanalysis( EEG, 'GMFA', 'positive', [30,60,180],[20,40;50,70;170,190] ); %find 3 positive peaks in the GMFA analysis at 30 ms (between 20-40ms), 60 ms (between 50-70 ms), and 180 ms (between 170-190 ms)
             %   EEG = tesa_peakanalysis( EEG, 'ROI', 'positive', [25,70], [15,35;60,80], 'method', 'centre', 'samples', 5, 'tepName', 'motor'); %find 2 positive peaks at 25 ms (15-35 ms), and 70 ms (60-80 ms) using the peak closest to the central peak (i.e. 25 ms or 70 ms), defining a peak as a data point that is larger than all data points +/- 5 samples and only for the ROI analysis named 'motor'.
             %output = tesa_peakoutput( EEG );
             %returns the results for the peak analysis in a table in the workspace and in a figure.
             %tesa_plot(EEG, 'tepType','GMFA', 'tepName', 'R1' ,'plotPeak','on');
             %plots TMS-evoked activity averaged over trials. Timing of
             %the TMS pulse is indicated with a red dashed line.
             cd(outPath)
             EEG = pop_saveset( EEG, 'filename',[ID{x,1} '_SP_',Sesh{y,1},'_',tp{z,1} '_peaks.set']);
        end
    end
end 