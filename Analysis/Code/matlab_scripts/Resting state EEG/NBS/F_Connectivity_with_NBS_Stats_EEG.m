clear all; close all;

%% runNBSrun %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
%  Use NBS from the command line. This script uses NBSrun(UI) to perform
%  the operations specified by user inputs in the structure UI.
% 
%  Simon Baker, Monash University
%  Date modified: 11-Jun-2014

%% Update Matlab search path
datadir='F:\TMS_EEG Data';
%WheresMyScript= [datadir filesep 'SP_analysis_Statistics'];
WheresMyScript='//Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Statistics/';
 addpath(WheresMyScript);

%WheresNBS='C:\Users\Public\MATLAB\EEGWORKSPACE\TOOLSHED\Connectivity_NBS\NBS1.2'; 
WheresNBS='//Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/NBS1.2';
 addpath(WheresNBS);
% WheresSPM='C:\Program Files\MATLAB\spm8';
%  addpath(genpath(WheresSPM));
WheresBNV='//Users/han.coyle/Documents/Data_Analysis/MATLAB/eeglab14_1_1b/plugins/BrainNetViewer_20171031'
%WheresBNV='C:\Program Files\MATLAB\BrainNetViewer';
addpath(genpath(WheresBNV));

%%
Bandwidth={'theta','gamma','alpha','beta'};
TimeCondition={'BL'};
condition = {'eo', 'ec' };

Band=4;
Time=1;
Cond=2; 
SourceDir= ['/Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Statistics']; 

WorkDir=['/Volumes/HOY_2/TMS_EEG Data/Resting_analysis/Resting_analysis_Statistics' filesep [condition{1,Cond} ,'_',(Bandwidth{1,Band}),'_', (TimeCondition{1,Time})],  filesep];
mkdir(WorkDir);

% One-tailed probability value (alpha)
PVal=0.025;% two-tailed probability value (alpha)
% Degrees of freedom.
% Unpaired t test, between groups, df=(n1+n2)-2.
% Paired t test, within groups, df=n-1, where n is the number of observations.
DoF=54;
% One-tailed critical value
CritVal=icdf('t',(1-PVal),DoF); % Do not touch 
PValStr=strrep(num2str(PVal),'0.',''); % Do not touch
DoFStr=num2str(DoF); % Do not touch
Outname=sprintf('NBSoutput_%s_%s.mat',PValStr,DoFStr); % Do not touch

% Create an empty structure called UI.
UI=struct; % Do not touch
% Method: 'Run NBS' | 'Run FDR'. Perform NBS or FDR?
UI.method.ui='Run NBS';

%% Statistical Model

% Statistical Test: 'One Sample' | 't-test' | 'F-test'
UI.test.ui='t-test';

% Threshold: Scalar. Primary test statistic threshold.
UI.thresh.ui=num2str(CritVal);

% Design Matrix: n x p numeric array specifying a design matrix, including
% a column of ones if necessary. p is the number of independent variables
% in the GLM, n is the number of observations.
% Can be specified either as a:
% 1. Valid Matlab expression for an n x p array.
% 2. Text file containing numeric data arranged into n rows and p columns.
% 3. A binary Matlab file (.mat) storing an n x p numeric array.
UI.design.ui=[SourceDir,filesep,'DesignMatrix.mat'];

% Contrast: 1 x p numeric array specifying contrast, where p is the number
% of independent variables in the GLM.
% Must be specified as a valid Matlab expression for a 1 x p array.
    %%looking for a decrease in connectivity in my mtbi sample??%% i.e
    %%group 2 > group 1
UI.contrast.ui='[-1 1]';

%% Data

% Connectivity Matrices: N x N numeric array specifying a symmetric
% connectivity matrix for each of M observations (e.g. subjects), where N
% is the number of nodes.
% Can be specified either as a:
% 1. Valid Matlab expression for an N x N x M array.
% 2. A total of M seperate text files stored in a common directory, where
% each text file contains numeric data arranged into N rows and N columns.
% Specify only one such text file and the others within the same directory
% will be identified automatically.
% 3. A binary Matlab file (.mat) storing an N x N x M numeric array.
UI.matrices.ui=[SourceDir,filesep,condition{Cond},'_',Bandwidth{Band}, '_NNM.mat'];


% Node Coordinates (MNI) [optional]: N x 3 numeric array specifying node
% coordinates in MNI space, where N is the number of nodes.
% Can be specified either as a:
% 1. Valid Matlab expression for an N x 3 array.
% 2. Text file containing numeric data arranged into a N rows and 3 columns.
% 3. A binary Matlab file (.mat) storing an N x 3 numeric array.
UI.node_coor.ui=[SourceDir,filesep,'COG_50.mat'];

% Node Labels [optional]: N x 1 cell array of strings providing node
% labels, where N is the number of nodes.
% Can be specified either as a:
% 1. Valid Matlab expression for an N x 1 cell array of strings.
% 2. Text file containing data arranged into N rows.
% 3. A binary Matlab file (.mat) storing an N x 1 cell array of strings.
UI.node_label.ui=[SourceDir,filesep,'LABELS_FORMATTED_50.mat'];

%% Advanced Settings

% Permutations: Scalar integer. Number of permutations.
UI.perms.ui='5000';

% Significance: Scalar. Significance (alpha threshold).
UI.alpha.ui='0.05';

% Component Size: 'Extent' | 'Intensity'. Use intensity or extent to
% measure size of a network component? [optional if UI.method.ui=='Run FDR'].
UI.size.ui='Extent';

% Exchange Blocks [optional]: n x 1 numeric array specifying exchange
% blocks to constrain permutation for a repeated measures design, where n
% is the number of observations in the GLM.
% Can be specified either as a:
% 1. Valid Matlab expression for an n x 1 array.
% 2. Text file containing numeric data arranged into n rows.
% 3. A binary Matlab file (.mat) storing an n x 1 numeric array.
 UI.exchange.ui='';
%UI.exchange.ui=load('exchangeBlocks.mat');

cd(WheresNBS);
%% Run NBSrun
NBSrun(UI,[])

%% Post-NBS
% The current version of the software stores all numerical results in a
% Matlab structure called nbs. The nbs structure comprises four
% substructures: nbs.GLM, nbs.NBS, nbs.STATS and nbs.UI. To access the nbs
% structure, type global nbs at the Matlab command prompt and then type nbs
% to see the four substructures:
% 1. nbs.GLM stores the GLM specifications.
% 2. nbs.NBS stores the results.
% 3. nbs.STATS stores the test statistic threshold and the test statistics
% for all permutations.
% 4. nbs.UI stores the user inputs.
global nbs
Output=sprintf('%s%s%s',WorkDir,filesep,Outname);
save(Output,'nbs');

% The data stored in nbs.NBS is usually sufficient for most post-NBS
% processing and analysis. It can be accessed by typing nbs.NBS at the
% Matlab command prompt. Note that n is the number of significant networks
% found and con-mat stores the upper-triangular, binary adjacency matrices
% for each significant network.
nbs.NBS
clear ans;


%% NBSview Visualisation for Significant Network
NSigNet=nbs.NBS.n;
if NSigNet>0
    for SigNet=1:NSigNet
        fprintf(1,'Creating basic visualisation for significant network %d of %d.\n',SigNet,NSigNet);
        saveas(gcf,sprintf('%s%snetwork%dnbs.jpg',WorkDir,filesep,SigNet),'jpeg');
    end
end

% % % Adjacency Matrix for Significant Network
% % To generate a text file containing a binary adjacency matrix for 1(:n)
% % significant network(s), type the following at the Matlab command prompt:
% %   adj=nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}';
% %   dlmwrite('adj.txt',full(adj),'delimiter',' ','precision','%d');
% % Replace {1} with {n}, to repeat for n significant network(s).
% % NSigNet=nbs.NBS.n;
% % if NSigNet>0
% %     for SigNet=1:NSigNet
% %         fprintf(1,'Writing binary adjacency matrix for significant network %d of %d.\n',SigNet,NSigNet);
% %         adj=nbs.NBS.con_mat{SigNet}+nbs.NBS.con_mat{SigNet}';
% %         dlmwrite(sprintf('%s%sadj%d.txt',WorkDir,filesep,SigNet),full(adj),'delimiter',' ','precision','%d');
% %         fprintf(1,'Displaying scaled image of binary adjacency matrix for significant network %d of %d.\n',SigNet,NSigNet);
% %         A=full(adj); figure; set(gcf,'Color','w'); imagesc(A);
% %         Edges=length(find(A~=0))/2;
% %         set(gcf,'Colormap',[0,0,0;1,1,1]); title(sprintf('Network %d (Edges=%d)',SigNet,Edges),'FontSize',14,'FontWeight','bold');
% %         saveas(gcf,sprintf('%s%sadj%d.jpg',WorkDir,filesep,SigNet),'jpeg');
% %     end
% % end
% 
% % List of Connections in Significant Network
% To print to the screen a list of all connections comprising 1(:n)
% significant network(s), as well as their associated test statistics,
% type the following at the Matlab command prompt:
%   [i,j]=find(nbs.NBS.con_mat{1});
%     for n=1:length(i)
%     i_lab=nbs.NBS.node_label{i(n)};
%     j_lab=nbs.NBS.node_label{j(n)};
%     stat=nbs.NBS.test_stat(i(n),j(n));
%     fprintf('%s to %s. Test stat: %0.2f\n',i_lab,j_lab,stat);
%   end
% NSigNet=nbs.NBS.n;
% if NSigNet>0
%     for SigNet=1:NSigNet
%         fprintf(1,'Listing connections in significant network %d of %d.\n',SigNet,NSigNet);
%         [i,j]=find(nbs.NBS.con_mat{SigNet});
%         for n=1:length(i)
%             i_lab=nbs.NBS.node_label{i(n)};
%             j_lab=nbs.NBS.node_label{j(n)};
%             stat=nbs.NBS.test_stat(i(n),j(n));
%             fprintf('%s with %s. Test stat: %0.2f\n',i_lab,j_lab,stat);
%         end
%     end
% end

%% BrainNet Viewer Visualisation

%%% Get node labels
NodeLabels=nbs.NBS.node_label;
NumNodes=length(NodeLabels);

%%% Get node coordinates
NodeCoords=nbs.NBS.node_coor;
% NodeCoords(:,1)=-1*NodeCoords(:,1); % Flips sign of the X coordinates

NSigNet=nbs.NBS.n;
if NSigNet>0
    for SigNet=1:NSigNet
        
        %%% Write node file for BrainNetViewer
        fprintf(1,'Creating BrainNet Viewer visualisation for significant network %d of %d.\n',SigNet,NSigNet);
        % Get labels for nodes with significant edges
        [i,j]=find(nbs.NBS.con_mat{SigNet});
        for n=1:length(i)
            i_labels{n,1}=nbs.NBS.node_label{i(n)};
            j_labels{n,1}=nbs.NBS.node_label{j(n)};
        end
        Labels=vertcat(i_labels,j_labels);
        UnqLabels=unique(Labels);
        clear i j n i_labels j_labels
        NodeFileOutPath=sprintf('%s%snetwork%d.node',WorkDir,filesep,SigNet);
        fid=fopen(NodeFileOutPath,'w');
%         NodeColour=1;
%         NodeSize=1;
        for Node=1:NumNodes
            X=NodeCoords(Node,1);
            Y=NodeCoords(Node,2);
            Z=NodeCoords(Node,3);
            NodeLabel=NodeLabels{Node,1};
            if sum(strcmp(NodeLabel,UnqLabels))==0
                NodeColour=0;
                NodeSize=1;
            elseif sum(strcmp(NodeLabel,UnqLabels))==1
                NodeColour=1;
                NodeSize=2;
            end
            % Replace underscores and dashes with period so that BNV can
            % correctly display the node labels
            NewNodeLabel=strrep(NodeLabel,'_','.');
            NewNodeLabel=strrep(NodeLabel,'-','.');
            % Write node file for BrainNetViewer
            fprintf(fid,'%f\t%f\t%f\t%u\t%.4f\t%s\n',X,Y,Z,NodeColour,NodeSize,NewNodeLabel);
            clear X Y Z NodeLabel
        end
        fclose(fid);
        clear Node fid
        
        %%% Write binary edge file for BrainNetViewer
        BinEdgeFileOutPath=sprintf('%s%snetwork%dbin.edge',WorkDir,filesep,SigNet);
        adj=nbs.NBS.con_mat{SigNet}+nbs.NBS.con_mat{SigNet}';
        dlmwrite(BinEdgeFileOutPath,full(adj),'delimiter','\t','precision','%d');
        
        %%% Write weighted edge file for BrainNetViewer
        WeiEdgeFileOutPath=sprintf('%s%snetwork%dwei.edge',WorkDir,filesep,SigNet);
        adj=full(nbs.NBS.con_mat{SigNet}+nbs.NBS.con_mat{SigNet}').*abs(nbs.NBS.test_stat);
        dlmwrite(WeiEdgeFileOutPath,full(adj),'delimiter','\t','precision','%.4f');
        
        %%% Visualise significant network using BrainNet_MapCfg function
        BNVSurfaceName='BrainMesh_ICBM152_smoothed_tal.nv';
        BNVSurfacePath=sprintf('%s%sData%sSurfTemplate%s%s',WheresBNV,filesep,filesep,filesep,BNVSurfaceName);
        BNVNodeFilePath=NodeFileOutPath;
%         BNVEdgeFilePath=BinEdgeFileOutPath;
        BNVEdgeFilePath=WeiEdgeFileOutPath;
        BNVOptionsName='BrainNetOptions_full.mat';
%         BNVOptionsPath=sprintf('%s%s%s',WheresMyScript,filesep,BNVOptionsName);
        BNVOptionsPath=sprintf('%s%s%s',WheresBNV,filesep,BNVOptionsName);
        BNVOutPath=sprintf('%s%snetwork%dbnv.jpg',WorkDir,filesep,SigNet);
%         BrainNet_MapCfg(BNVSurfacePath,BNVNodeFilePath,BNVEdgeFilePath,BNVOptionsPath,BNVOutPath);
        BrainNet_MapCfg(BNVSurfacePath,BNVNodeFilePath,BNVEdgeFilePath);
        
    end
end
