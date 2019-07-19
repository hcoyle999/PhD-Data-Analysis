
% %% choose ROI chans 
% Pos_1={'AF4' ,'F1','FZ','F2','F4','F6','F8','FC3','FC1','FCZ','FC2','FC4','FC6'};
% Neg_1= {'P7','P5','P3','P6','P8','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};
% % % PRE
% % %  P60:
% Pos_2={'CP5' ,'P7','P5','P3','P1','PO7','PO3','POZ','O1'}; 
% % % POST 
% % % N100
% Pos_3 = {'AF4','F1','FZ','F2','F4','F6','F8','FC3','FC1','FC2','FC4','FC6','C4','C6'};
% Neg_2 =  {'CP5','P7','P5','P3','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};
%clusters ={Pos_1,Pos_2,Pos_3,Neg_1,Neg_2};
%% assemble ROIs to extract 

clabels={'P1','P2','P3','N1','N2'};
grp = {'CNT','TBI'} ; %% 
tp = {'PRE','POST'}; 

workDir = 'F:\TMS_EEG Data\SP_analysis_TBI_P2P'
 
for t= 1:2
    for g= 1:2
        
cond = ['SP_', grp{g}, '_BL_',tp{t}]; %

folder= [workDir, filesep, grp{g}, '_', tp{t}]
cd(folder)
filelist=dir(); 
filelist={filelist.name}; 
file = filelist{3};


EEG = pop_loadset('filename',file,'filepath',folder);


%% Extract group level peaks 
cd(workDir)
output = pop_tesa_peakoutputgroup( EEG, 'GMFA', 'GMFA',...
    'calcType', 'amplitude', 'winType', 'individual'...
    , 'averageWin', [], 'fixedPeak', [], 'tablePlot', 'on' );

out=struct2table(output); 
fn= [ cond,'_GMFA.csv']; 
writetable(out,fn); 

for c=1:length(clabels)
output = pop_tesa_peakoutputgroup( EEG, 'ROI', clabels{c}, 'calcType', 'amplitude', 'winType', 'individual', 'averageWin', 5, 'fixedPeak', [], 'tablePlot', 'on' );

out=struct2table(output); 
fn= [ cond,'_ROI_', clabels{c},'.csv']  ; 
writetable(out,fn);
end


STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
    end
end 



    