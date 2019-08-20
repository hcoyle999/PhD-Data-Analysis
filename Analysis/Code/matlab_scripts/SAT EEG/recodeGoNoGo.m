% logfile=[ID{1,Subjects}, '_', Tp{1,Time}, '-Go-NoGo Task.log'];

function [EEG]=recodeGoNoGo(EEG,logfile) 
% fields = loadtxt(logfile, 'delim', 9, 'skipline', 3, 'nlines', 1, 'verbose', 'off');
data = loadtxt(logfile, 'delim', 9, 'skipline', 5, 'nlines', 1500, 'verbose', 'off');

evtlist=[];idx=1
for i =1:size(data,1)
if ismember(char(data{i,8}),{'Go', 'NoGo'})
disp(data{i,8})
label= [data{i,8} ,'_'  ,data{i,18}];
evtlist{idx,1}=label; 
idx=idx+1 
end 
end 

marks = [EEG.event.type];
% 10 = X (GO) 100= A (NoGo)
these = find(marks==100|marks==10);
% start from 11th event marker (to avoid practice trials)
for i=1:length(these)
    this = these(i); 
% disp(    EEG.event(this).type)
EEG.event(this).mark = EEG.event(this).type;
EEG.event(this).type = evtlist(i);
end 



% 1= mouse click 
these = find(marks==1);
for i=1:length(these)
    this = these(i); 
% disp(    EEG.event(this).type)
EEG.event(this).mark = EEG.event(this).type;
EEG.event(this).type = 'click';
end 

% 99= break
these = find(marks==99);
for i=1:length(these)
    this = these(i); 
% disp(    EEG.event(this).type)
EEG.event(this).mark = EEG.event(this).type;
EEG.event(this).type = 'break';
end 

for i=1:length(marks)
EEG.event(i).type =char(EEG.event(i).type);
end 
end
