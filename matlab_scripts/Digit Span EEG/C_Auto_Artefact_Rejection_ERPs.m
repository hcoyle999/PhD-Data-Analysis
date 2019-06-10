clear; close all;
datadir='//Volumes/HOY BACKUP_/TMS_EEG Data';
caploc='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
%cd(datadir);
%SETTINGS

eeglab;
%ID= {'101';'102';'103';'104';'105'; '106'; '107'; '110'; '112';'113';'114';'115';'116';'117';'118';'119'};
ID= {'112'};
%ID = {'003';'004';'005'; '006'; '008'; '009'; '010'; '011';'012'; '013'; '014'; '015'; '017'; '018'; '019'}
%ID = {'106','107','108','109','110','111','112','113','114','115','116','117','118','119','120'};

Sesh = {'BL'};
% Sesh = {'BL';'T1';'T2'};
tp = {'PrePost'}; %trigger points
% tp = {'Pre';'Post';'Delay'}; %trigger points

inPath = [datadir filesep 'DS_analysis_TBI' filesep]
outPath = [datadir filesep 'DS_analysis_TBI' filesep]; %where you want to save the data


for aaa = 1:size(ID,1);
    
    cd([inPath filesep ID{aaa,1}]); % creating a directory of inPath, filesep is either / or \

    for aa = 1:size(Sesh,1);
        
        for a = 1:size(tp,1); % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
    % Loading data
    EEG = pop_loadset([inPath,ID{aaa,1}, filesep, ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_3.set']);
    EEG = eeg_checkset( EEG );
    
  
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
        n = EEG.nbchan;
        
        % we then use this value of 'n', representing all channels from the
        % head, to tell the following pop_eegthresh command to check all channels except
        % the last two channels (which are SO1 and ECG in the case of the
        % files for this script) to see if the voltage of those channels
        % varies by more than -250 to 250 microvolts in any of the epochs.
        % (pop_eegthresh is a command that is used by EEGLAB to check that
        % thresholds are not above certain values.
        EEG = pop_eegthresh(EEG,1,[6:n-1] ,-250,250,-0.101,1.00,0,0);
        
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
    
    if isempty(thresh)==0;
    EEG = pop_select( EEG,'nochannel',EEG.badchanthresh);
    end
    
    % the following command goes through the same channels and checks if
    % any epochs be excluded because they show a variation of more than
    % 5SDs of kurtosis for individual channels, or 3 for all channels.
    
    % Kurtosis is a measure of the 'peakiness' of the distribution of the
    % data. This method of exclusion runs on the theory that EEG data
    % should be normally distributed, so epochs that are unusal because they're too peaky are
    % excluded.
    
        n2 = EEG.nbchan;
        
        EEG = pop_rejkurt(EEG,1,[6:n2-1] ,5,3,0,0);

        % the following line rejects epochs based on whether the
        % power within the frequencies 25 to 45Hz exceeds -100 or 30dB.
        % power in these frequencies generally reflects muscle activity, so
        % if a lot of power is found in the activity in those frequencies
        % during any particular epoch, you've probably got muscle activity
        % rather than brain activity (eg. jaw clenching.
        
        %% PROBLEM IS HERE- not sure how to direct it to this file, cd, not working.
        
%         here=pwd;
%         cd('Users/han.coyle/Documents/MATLAB/toolbox/signal/signal');
%         
        EEG = pop_rejspec( EEG, 1,'elecrange',[1:n2-1] ,'threshold',[-100 30] ,'freqlimits',[25 45],'eegplotcom','','eegplotplotallrej',1,'eegplotreject',0);
        
 
        
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

EEG = eeg_checkset( EEG );
n3 = EEG.nbchan;

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
        
% n=(x);

% if n==n3;   
        
        EEG = pop_rejkurt( EEG,1,[6:n3-1] ,5,3,0,0);
        EEG = pop_rejspec( EEG, 1,'elecrange',[1:n3-1] ,'threshold',[-100 30] ,'freqlimits',[25 45],'eegplotcom','','eegplotplotallrej',1,'eegplotreject',0);
    
    
% end

% The following three lines use the 'unique' and 'find' functions to find
% the trials that should be rejected from the rejfreq and rejkurt functions
% (without doubling up and rejecting the epoch, then going through and
% rejecting the same number of epoch again (which will be a different
% epoch, because the first has already been rejected, because of
% potential overlap).

EEG.BadTrialspect=unique([find(EEG.reject.rejfreq==1)]);
EEG.BadTrialkurt=unique([find(EEG.reject.rejkurt==1)]);   

EEG.BadTr=unique([ find(EEG.reject.rejkurt==1)] );

EEG.BadTrialsAllTypes=cat(2,EEG.BadTrialspect,EEG.BadTrialkurt);

% pop_rejepoch rejects the trials listed in EEG.BadTr
        
EEG=pop_rejepoch(EEG,EEG.BadTrialsAllTypes,0);



EEG.ProcessingAndBehaviourData.badtrialauto=EEG.BadTrialsAllTypes;


mkdir([outPath filesep ID{aaa,1} filesep]);
a=1
 pop_saveset(EEG, 'filename', [ID{aaa,1},  '_digit_',Sesh{aa,1},'_',tp{a,1},'_4.set'], 'filepath',[outPath filesep ID{aaa,1} filesep]);


        end
    end
end


