%% BrainNet Viewer Visualisation
WheresBNV ='/Users/han.coyle/Documents/MATLAB/eeglab14_1_1b/plugins/BrainNetViewer_20171031'%%% Get node labels
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
%         BNVOptionsName='BrainNetOptions_full.mat';
%         BNVOptionsPath=sprintf('%s%s%s',WheresMyScript,filesep,BNVOptionsName);
        %BNVOptionsPath=sprintf('%s%s%s',WheresBNV,filesep,BNVOptionsName);
      %  BNVOutPath=sprintf('%s%snetwork%dbnv.jpg',WorkDir,filesep,SigNet);
%         BrainNet_MapCfg(BNVSurfacePath,BNVNodeFilePath,BNVEdgeFilePath,BNVOptionsPath,BNVOutPath);
     %  BrainNet_MapCfg(BNVSurfacePath,BNVNodeFilePath,BNVEdgeFilePath);
        
    end
end
