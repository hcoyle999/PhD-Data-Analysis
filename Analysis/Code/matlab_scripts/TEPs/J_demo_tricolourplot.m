
%[fig]=mytricolourplot(t,DATA1,DATA2,DATA3,useSEM)
these= logical(stat.posclusterslabelmat)
stat.label(these)'

these= logical(stat.negclusterslabelmat)
stat.label(these)'

    'AF4'    'F2'    'F4'    'F8'    'FC4'    'FC6'
% PRE
%  N100:
Pre_Pos={'AF4' ,'F1','FZ','F2','F4','F6','F8','FC3','FC1','FCZ','FC2','FC4','FC6'};
Pre_Neg= {'P7','P5','P3','P6','P8','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};

% PRE
%  P60:
Pre_Pos_1={'CP5' ,'P7','P5','P3','P1','PO7','PO3','POZ','O1'};


% POST 
% N100
Post_Pos = {'AF4','F1','FZ','F2','F4','F6','F8','FC3','FC1','FC2','FC4','FC6','C4','C6'};
Post_Neg =  {'CP5','P7','P5','P3','PO7','PO3','POZ','PO4','PO8','O1','OZ','O2'};

testname=['N100 POST NEG ',grp1,' vs ',grp2];


labels=D1.label
thischan= find(ismember(labels,Post_Neg'))
t=D1.time; 
DATA1=squeeze(mean(D1.individual(:,thischan,:),2))
DATA2=squeeze(mean(D2.individual(:,thischan,:),2))



%% PLOT 
mytricolourplot(t,DATA1,DATA2,[],0)
title(['ROI ',testname ])

% t1= find(t>=-0.100,1,'first');
% t2= find(t>=0.35,1,'first');
xlim([-0.1,0.35])