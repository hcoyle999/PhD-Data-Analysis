clear; close all;
datadir='//Volumes/HOY_2/TMS_EEG Data';
%datadir= 'F:\TMS_EEG Data';
caploc= 'C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\dipfit2.3\standard_BESA\standard-10-5-cap385.elp';

caploc='/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp'; %path containing electrode positions
%filterfolder ='C:\Program Files\MATLAB\R2015b\toolbox\signal\signal\';
cd(datadir);
%SETTINGS

eeglab;

Tp = {'BL'}; 
Condition= {'CRT'};
Group = {'Control','TBI'};

% ----------editable section  -------%
SubjectStart=12;
%SubjectFinish=;

GroupStart=2;
GroupFinish=2;

TimepointStart=1;
TimepointFinish=1;

ConditionStart=1;
ConditionFinish=1;

for Grp=GroupStart:GroupFinish
    
    
    if Grp==1
        % control participants included in analysis (N= 17)
        ID = {'001','009','010','012','013','014','015','017','018','019','020', '021','022','023','024','027','028'};
    else
        % mtbi participants included in analysis (N= 20)
        ID= {'103','105','106','108', '109' '110', '111', '112','113','114','115', '116','117','119','120','122', '124','127','129','130'};
    end
    %ID= {'022'};
    SubjectFinish= numel(ID);
  
    
    
    inPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1,Grp}];
    cd(inPath);
    
    for Subjects=SubjectStart:SubjectFinish
        for Time=TimepointStart:TimepointFinish
            for Cond=ConditionStart:ConditionFinish
                
                % creating a loop, so that a = 1 to what's designated, which is the tpition. 1 in "tp,1" is dimension
                % Loading data
                filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_4.set'];
                EEG = pop_loadset(filename);
                
                EEG = eeg_checkset( EEG );
                
                % The following section runs AMICA (a slow but the most accurate
                % version of ICA)
                
                % You'll need to install amica12 first, and in the folder that you
                % specify in the line below:
                
                % You can download amica12 from http://sccn.ucsd.edu/~jason/amica_web.htmlhttp://sccn.ucsd.edu/~jason/amica12/loadmodout12.m
                
                
                cd ('/Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/amica1.5/');
                %cd('C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\eeglab14_1_2b\plugins\AMICA1.5.1');
%                 % define parameters
%                 numprocs = 1;       % # of nodes (default = 1)
%                 max_threads =12;    % # of threads per node
%                 %     num_models = 1;     % # of models of mixture ICA
%                 %     max_iter = 2000;    % max number of learning steps
                
                %Run AMICA
                
                [EEG.icaweights, EEG.icasphere, mods] = runamica15(EEG.data(:,:));
                 EEG = eeg_checkset( EEG );
                
%                 [EEG.icaweights, EEG.icasphere, mods] = runamica15(EEG.data(:,:), 'max_threads', max_threads, 'max_iter',max_iter);
%                 EEG = eeg_checkset( EEG );
                
                %
                %     % run amica
                %     outdir = [ pwd filesep 'amicaouttmp' filesep ];
                %     [weights,sphere,mods] = runamica15(EEG.data, 'num_models',num_models, 'outdir',outdir, ...
                %         'numprocs', numprocs, 'max_threads', max_threads, 'max_iter',max_iter);
                % Other options for running ICA are listed below (fastica, which is a
                % fast version, and binica, which is a medium speed and accuracy
                % version) See Delorme, Palmer, Onton, Oostenveld, Makeig (2012) -
                % 'Independent EEG sources are dipolar' for a comparison of the different
                % ICA methods and their pros and cons.
                
                % Note also that FASTICA requires installing in the matlab folder, and
                % can be downloaded from http://research.ics.aalto.fi/ica/fastica/
                
                % EEG = pop_runica(EEG,'icatype','runica','approach', 'extended',1);
                % [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
                
                % EEG = pop_runica(EEG,'icatype','fastica', 'approach', 'symm', 'g', 'tanh');
                
                outPath = [datadir filesep 'SAT_analysis' filesep 'SAT_analysis_' Group{1,Grp}]; %where you want to save the data
                mkdir(outPath);
                cd(outPath);
                filename = [ID{1,Subjects}, '_', Condition{1,Cond}, '_', Tp{1,Time},'_5.set'];
                EEG = pop_saveset(EEG, filename);
                close all;
            end
        end
    end
end
