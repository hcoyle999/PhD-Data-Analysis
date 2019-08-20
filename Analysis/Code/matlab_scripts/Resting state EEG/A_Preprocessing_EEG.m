
%% Resting EEG PreProcessing Script%%
clear all; close all; clc;

datadir_1='//Volumes/HOY BACKUP_/TMS_EEG Data/';
datadir_2='//Volumes/HOY_2/TMS_EEG Data/';

%datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
%caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir_1);
%SETTINGS

eeglab;

Tp = {'T2'}; %T1 %T2
Condition= {'resting'};
Group = {'Control','TBI'};


% ----------editable section  -------%
SubjectStart=1;
%SubjectFinish=;

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;


for Grp=GroupStart:GroupFinish
   
if Grp==1
% control participants included in analysis (N= 26)
%ID = {,'024','025','026', '027','028'};
ID = {'027'} % '001','002','003','004''005','006','009','010','012','013','014','015','021','022','023','024','025','026','027','028'};
inPath = [datadir_2 filesep Group{1, Grp} filesep];
outPath = [datadir_2 filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];

else
% mtbi participants included in analysis (N= 30)
%ID = {'120','121','122', '124','127','129','130'};
%ID= {'101','102','105','107', '109' '110', '111','118','119'}
ID= {'124'};
inPath = [datadir_2 filesep Group{1, Grp} filesep];
outPath = [datadir_2 filesep 'Resting_analysis' filesep 'Resting_analysis_' Group{1, Grp}];
end
%ID= {'126'};
SubjectFinish= numel(ID);


    for Subjects=SubjectStart:SubjectFinish 
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

        %load data from parent 'Control' folder
        cd([inPath ID{1,Subjects} filesep Tp{1,Time}]);
        cntname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre' '.cnt'];
        %EEG = pop_loadcnt(cntname, 'dataformat', 'auto', 'keystroke', 'on', 'memmapfile', '');
        %EEG = pop_loadcnt(cntname, 'dataformat', 'auto', 'keystroke', 'off', 'memmapfile', '');
        EEG = pop_loadcnt(cntname , 'dataformat', 'auto', 'memmapfile', '');
        
        EEG = pop_chanedit(EEG, 'lookup', caploc);
        EEG = pop_select( EEG,'nochannel',{'FP1' 'FPZ' 'FP2' 'FT7' 'FT8' 'TP7' 'TP8' 'CB1' 'CB2' 'HEOG' 'PO5' 'PO6' 'E2'});
        
  
        %Downsample EEG 
        EEG = pop_resample( EEG, 500);
        EEG = eeg_checkset( EEG );
%         
        % The lines below saves the .cnt file as a .set file using the
        % EEGLAB command pop_saveset, after defining the variable 'setname'
        %mkdir([outPath filesep ID{1,Subjects} filesep]);
        cd([outPath filesep ID{1,Subjects} filesep]);
        %mkdir('//Volumes/HOY_2/TMS_EEG Data/Resting_analysis_Control');
        setname = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time}, '_Pre_1.set'];
       
        EEG = pop_saveset(EEG, setname);
            end
        end
    end
end


for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
        cd([outPath filesep ID{1,Subjects} filesep]);
        setname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_1.set'];
        EEG = pop_loadset(setname);
%         
% % Filtering:
%         
%         % Leave the following as unchanged as possible. I try not to mess
%         % with it because I haven't explored all the parameters, and I
%         % don't know what does what. Having said that, the values that
%         % follow 's1', 's2', 'all1', and 'all2' can be varied depending on
%         % which frequencies you want to notch filter out (with s1 and s2)
%         % and high pass (with all1) and low pass (with all2).
%         
%         % Also, the following section can often error out due to command
%         % conflicts. Make sure you only have one copy of the 'butter' file
%         % (which is called below in a number of lines, for example: [z1 p1 k1] = butter(ord1, [all1 all2]./(Fs/2), 'bandpass'); % 10th order filter
%         % You can find out which butter is being called by typing 'which
%         % butter' in the MATLAB command window (without the speech marks).
%         % The answer it comes up with should be something like:
%         % C:\Program Files\MATLAB\R2015a\toolbox\signal\signal\butter.m 
%         % If that isn't the answer that is revealed, maybe change the other
%         % file somehow so that it finds the correct file (change the name of the other file to 'butter2' or something.
%         
        %%
        EEG = eeg_checkset( EEG );
        dir= pwd;
                               % go to BUTTER 
    
        cd('/Users/han.coyle/Documents/Data_Analysis/MATLAB/');
        
        
        %filter the data (second order butterworth filter)
        %Fs=EEG.srate; ord1=2; ord2=2;
        
        % The next two lines define high pass and low pass filters. The
        % 47-53Hz is a notch filter to remove 50Hz line noise. The 1-80Hz
        % gets rid of low and high frequency noise.
        
%         s1=47; s2=53;
%         all1=0.1; all2=100;     
%         [z1 p1 k1] = butter(ord1, [all1 all2]./(Fs/2), 'bandpass'); % 10th order filter
%         [sos1,g1] = zp2sos(z1,p1,k1); % Convert to 2nd order sections form
%         [z2 p2 k2] = butter(ord2, [s1 s2]./(Fs/2), 'stop'); % 10th order filter
%         [sos2,g2] = zp2sos(z2,p2,k2);
%         EEG.data=double(EEG.data);
%         temp=NaN(size(EEG.data,1),EEG.pnts,size(EEG.data,3));
%         for ch=1:size(EEG.data,1) % for each chan
%             for trial=1:size(EEG.data,3) % for each trial
%                 dataFilt1=filtfilt(sos1,g1,EEG.data(ch,:,trial));
%                 dataFilt2=filtfilt(sos2,g2,dataFilt1);
%                 temp(ch,:,trial)=dataFilt2;
%             end%--- end of trials
%         end %--- end of channels
%         EEG.data=temp;
%         EEG = eeg_checkset( EEG );
%         clear temp
%         cd(dir);                                                      % GO BACK 
%                 % I cant believe it's not BUTTER!   
                
        EEG = pop_tesa_filtbutter( EEG, 1.000000e-01, 100, 4, 'bandpass' );
        EEG = pop_tesa_filtbutter( EEG, 48, 52, 4, 'bandstop' );
        %Save chanlocs
        EEG = eeg_checkset( EEG );
         
    
EEG=eeg_regepochs(EEG,'recurrence',2,'limits',[-1 1],'rmbase',[NaN], 'extractepochs', ['off']); %% four second epochs overlap 75%



[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
     
%close all;

%% EYE CODING 
here= find([EEG.event.urevent]==1);     
         

         % epoch the resting data into two second epochs (the two numbers in brackets), 
         % 2 seconds apart (the first number), 
         % and correct to the full epoch baseline (the final number
         % baseline corrects to all values prior to that number)
start= find(strcmp({EEG.event(1,:).type},'22'));%         
here= find(strcmp({EEG.event(1,:).type},'33'));%find([EEG.event.urevent]==1);
done= find(strcmp({EEG.event(1,:).type},'44'));%   





for i=1:start;
if strcmp(EEG.event(i).type,'X');
EEG.event(i).type='X';
end ;
end;

for i=start+1:here;
if strcmp(EEG.event(i).type,'X');
EEG.event(i).type='eo';
end ;
end;

for i=here:done;
if strcmp(EEG.event(i).type,'X');
EEG.event(i).type='ec';
end ;
end;
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
EEG = eeg_checkset( EEG );
         
%          EEG = eeg_regepochs(EEG, 2, [0 2], 2); 
%         
%         if strcmp(EEG.event(1,a).type,'33');
%             EOorEC='2';
%                 if strcmp(EOorEC(1,1),'2');
%                     if strcmp (EEG.event(1,a).type,'X');
%                         EEG.event(1,a).type='EC';
%                     end
%                 end
%         end
%         
%         if (Cond==1)||(Cond==3);
%             for a = 1:size(EEG.event,2);
%                 if strcmp(EEG.event(1,a).type, 'X');
%                     EEG.event(1,a).type = 'EO';
%                     EEG.urevent(1,a).type = 'EO';
%                 end
%             end
%         end
%         
%         if (Cond==2)||(Cond==4);
%             for a = 1:size(EEG.event,2);
%                 if strcmp(EEG.event(1,a).type, 'X');
%                     EEG.event(1,a).type = 'EC';
%                     EEG.urevent(1,a).type = 'EC';
%                 end
%             end
%         end
cd([outPath filesep ID{1,Subjects} filesep]);
setname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_2.set'];

EEG = pop_epoch( EEG, {  'ec'  'eo'  }, [-1  1], 'newname', setname, 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);
        EEG = eeg_checkset( EEG );
        
         EEG = pop_saveset(EEG, setname);

          end
        end
    end
end

eeglab
clear EEG;
clear ALLEEG;
eeglab;

for Grp=GroupStart:GroupFinish
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish

      cd([outPath filesep ID{1,Subjects} filesep]);
      setname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_2.set'];


       EEG = pop_loadset(setname);
        

        
        %%
        
        % AUTOMATIC ARTIFACT REJECTION OPTIONS:
        
        % This can be done instead of manual rejection, or prior to manual
        % rejection (which means the manual rejection is more of a spot
        % check, and makes the manual rejection process faster), or not at
        % all (and only the manual rejection method could be used).
        
        % The advantages of the automatic process are that it's objective
        % (all subjects/conditions have the same criteria for bad
        % channels/epochs), and it's faster and  less manually intensive.
        % The objective nature of the automatic process makes your study
        % easier to be published in some cases (some reviewers distrust the
        % manual process).
        % Disadvantages are that it seems to be less rigorous, you can't be
        % sure if you can trust it, and from my testing, gives less
        % statistically significant differences than the manual process.
    
    %Check for bad channel
        
        EEG.origionalepochind= (1:numel(EEG.data(1,1,:)));
        
        % the following line gets the total number of channels listed from
        % before the ECG processing (which adds extra channels).
        n = numel(EEG.chanlocs);
        
        % we then use this value of 'n', representing all channels from the
        % head, to tell the following pop_eegthresh command to check all channels except
        % the last two channels (which are SO1 and ECG in the case of the
        % files for this script) to see if the voltage of those channels
        % varies by more than -250 to 250 microvolts in any of the epochs.
        % (pop_eegthresh is a command that is used by EEGLAB to check that
        % thresholds are not above certain values.
        EEG = pop_eegthresh(EEG,1,[1:n-1] ,-250,250,0,2.0,0,0);
        
        % The following line averages (using the 'mean' command) the
        % EEG.reject.rejthreshE variable along the second dimension (which
        % is where the number of bad epochs for each channel are listed).
        % This can be fed into the following line to ensure less than 3% of
        % the epochs are bad for each channel. If more are bad, this
        % process can be used to delete that channel
        
        EEG.badelectrodesthresh=mean(EEG.reject.rejthreshE,2);
        
        % the following line checks if more than 3% (0.03) of the epochs have a channel that varies by
        % more than -250 to 250 microvolts
        
        thresh=unique([find(EEG.badelectrodesthresh>0.03)]);


        
        % the following few lines transpose the 'thresh' variable so that
        % it can be used in field trip formatting, in order to get a fix on
        % which channels should be excluded. I think I've done this to get
        % the arrays to be formatted so that the pop_select function can
        % read them properly. There's probably a more elegant solution, I
        % jsut don't know what it is.
        
        threshtransposed=transpose(thresh);
        
        FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');
        
    for threshb=1:length(threshtransposed);
        threshc=threshtransposed(1,threshb);
        
        EEG.badchanthresh(1,threshb)=FTdata.label(1,threshc);
        
    end
    
    
    
    
    % if the command 'isempty' is false for the variable 'thresh' (or in
    % other words equals 0), then there are channels that vary by more than
    % -250 to 250 microvolts. pop_select is then used to exclude those
    % channels
    
    newN=n-1;
    
    if isempty(thresh)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchanthresh);
    newN=n-1-threshb;
    end
    
    % the following command goes through the same channels and checks if
    % any epochs be excluded because they show a variation of more than
    % 5SDs of kurtosis for individual channels, or 3 for all channels.
    
    % Kurtosis is a measure of the 'peakiness' of the distribution of the
    % data. This method of exclusion runs on the theory that EEG data
    % should be normally distributed, so epochs that are unusal because they're too peaky are
    % excluded.
        
        EEG = pop_rejkurt(EEG,1,[1:newN] ,5,3,0,0);

        % the following line rejects epochs based on whether the
        % power within the frequencies 25 to 45Hz exceeds -100 or 30dB.
        % power in these frequencies generally reflects muscle activity, so
        % if a lot of power is found in the activity in those frequencies
        % during any particular epoch, you've probably got muscle activity
        % rather than brain activity (eg. jaw clenching.
        
        EEG = pop_rejspec( EEG, 1,'elecrange',[1:newN] ,'threshold',[-100 30] ,'freqlimits',[25 45],'eegplotcom','','eegplotplotallrej',1,'eegplotreject',0);
        
        %%
        
        
        %The following few lines do the same thing as above with the
        %threshold for each channel, but for kurtosis and frequency
        %measures of noise,
        %and reject the channel if it's caused
        %more than 3% of epochs to be rejected as bad due to noise.
        
        EEG.badelectrodeskurt=mean(EEG.reject.rejkurtE,2);
        EEG.badelectrodesfreq=mean(EEG.reject.rejfreqE,2);
       
              
        x=unique([find(EEG.badelectrodeskurt>0.03)]);
          
        xtransposed=transpose(x);
        
        FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');
        
    for y=1:length(xtransposed);
        z=xtransposed(1,y);
        
        EEG.badchankurt(1,y)=FTdata.label(1,z);
        
    end
    
    a=unique([find(EEG.badelectrodesfreq>0.03)]);
    

        
        atransposed=transpose(a);
        
        FTdata = eeglab2fieldtrip(EEG, 'preprocessing', 'coord_transform');
        
    for b=1:length(atransposed);
        c=atransposed(1,b);
        
        EEG.badchanfreq(1,b)=FTdata.label(1,c);
        
    end
    
    
 
if isempty(x)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchankurt);
    EEG.ProcessingAndBehaviourData.badchankurt=EEG.badchankurt;
end

if isempty(a)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchanfreq);
    EEG.ProcessingAndBehaviourData.badchanfreq=EEG.badchanfreq;
end

% Once bad channels are rejected (those that cause more than 3% of epochs
% to be rejected, we do a check to see if channels were rejected. If none
% were rejected, then we can use the overall channel epoch rejection that
% was calculated with pop_rejkurt and pop_rejspec functions above. If
% channels were rejected, the following two lines will come up with 'no' in
% answer to the question 'is n (reflecting number of channels rejected)
% equal to 0?', and the 'if' statement (which is formatted to equal 0, or
% 'no') will then perform the following two functions again (pop_rejkurt
% and pop_rejspec). That way, we'll get a bad epoch rejection run without
% including the bad channels that have been excluded because they cause too many epochs to be rejected.
        
n=cat(1,a,x);

if isempty(n)==0;   
        
        EEG = pop_rejkurt( EEG,1,[1:n-1] ,5,3,0,0);
        EEG = pop_rejspec( EEG, 1,'elecrange',[1:n-1] ,'threshold',[-100 30] ,'freqlimits',[25 45],'eegplotcom','','eegplotplotallrej',1,'eegplotreject',0);
    
    
end

% The following three lines use the 'unique' and 'find' functions to find
% the trials that should be rejected from the rejfreq and rejkurt functions
% (without doubling up and rejecting the epoch, then going through and
% rejecting the same number of epoch again (which will be a different
% epoch, because the first has already been rejected, because of
% potential overlap).

EEG.BadTrialspect=unique([find(EEG.reject.rejfreq==1)]);
EEG.BadTrialkurt=unique([find(EEG.reject.rejkurt==1)]);   

EEG.BadTr=unique([find(EEG.reject.rejfreq==1) find(EEG.reject.rejkurt==1)]);

% pop_rejepoch rejects the trials listed in EEG.BadTr
        
EEG=pop_rejepoch(EEG,EEG.BadTr,0);



EEG.ProcessingAndBehaviourData.badtrialauto=EEG.BadTr;

 %where you want to save the data
      cd([outPath filesep ID{1,Subjects} filesep]);
      AutomaticRejectionsetname = [ID{1,Subjects} '_' Condition{1,Cond} '_' Tp{1,Time} '_Pre_3.set'];
       
      EEG = pop_saveset(EEG, AutomaticRejectionsetname);
        
            end
        end
    end
end







        