%logfile=[ID{aaa,1},'_' ,Sesh{aa,1},'_',tp{a,1},'-Digit Span.log'];
function [EEG]=recodeDigitsBackwards(EEG,logfile,suffix) 
fields = loadtxt(logfile, 'delim', 9, 'skipline', 3, 'nlines', 1, 'verbose', 'off');
idx= find(strcmp(fields,  'accuracy(str)'))
data = loadtxt(logfile, 'delim', 9, 'skipline', 4, 'nlines', 500, 'verbose', 'off');
acc=data(:,idx); 
 idx= find(strcmp(acc,  'ReqDur'))
acc(idx:end)=[];

ACC=[]; j=1; 
for i=1:length(acc)
    if ~isempty(acc{i})
        out=[acc{i}];
        ACC{j}=out;
        j=j+1;
    end 
end 

these= find([EEG.event.type]==99);
if (isempty(these))
these= find(strcmp({EEG.event.type},'99'));
for i =1:length({EEG.event.type}); 
     try ; EEG.event(i).type=str2num(EEG.event(i).type); catch; end ;
end
end

j=1; 
for i = these; 
     EEG.event(i).accuracy=[ACC{j}]; 
     j=j+1;
end
%not sure what this section does and seemed to be making it go wrong-
%relabelling fixations as 88?
% these= find([EEG.event.type]==11)
% j=1; 
% for i = these; 
%      EEG.event(i).accuracy=[ACC{j}]; 
%       EEG.event(i).type=88;
%      j=j+1;
%end

j=1; 
if (strcmp(ACC{end},'Correct')); label=['CR_',suffix]; else label=['IN_',suffix]; end 
    
for i =[length([EEG.event.type]):-1:1]; 
    if (strcmp(EEG.event(i).accuracy,'Correct'));
    label=['CR_',suffix];
    elseif(strcmp(EEG.event(i).accuracy,'Incorrect')); 
    label=['IN_',suffix] 
    end 
    EEG.event(i).label=label
end

%% Relabel events by type    
for i =1:length([EEG.event.type]);  
    
    if (strcmp(EEG.event(i).label,['CR_',suffix]));
    EEG.event(i).digit= EEG.event(i).type;     
    EEG.event(i).type= ['CR_',suffix];
    elseif(strcmp(EEG.event(i).label,['IN_',suffix] ));
    EEG.event(i).digit= EEG.event(i).type; 
    EEG.event(i).type= ['IN_',suffix] ;
    end 
    if (EEG.event(i).digit==11) 
    EEG.event(i).type= ['FIX']
    elseif (EEG.event(i).digit==100) 
    EEG.event(i).type= ['ENTER']
    elseif  (EEG.event(i).digit==99) 
       EEG.event(i).type= ['RECALL'] 
    end 
end