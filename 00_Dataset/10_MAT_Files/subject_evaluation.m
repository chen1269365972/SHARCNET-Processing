


%% Environment

close all;  clear all;  clc;



%% Load Variables

load FS;
load Main_File_of_names;
subject_no=input('subject ID:');
name=['subject_no_',num2str(subject_no)];
a=exist([name,'_updated_index.mat'],'file');
if a>0
    load([name,'_updated_index.mat'])
    cases=updated_index(1);
    words=updated_index(2);
    load([name,'_evaluation'],'Subject_evaluation');
else
    cases=1;
    words=1;
end;
while cases<=5,
        strng1=File_of_names{words,cases}
        if strng1(end-6)=='w'
            strng2=strng1(end-6:end);
        elseif strng1(end-5)=='w'
            strng2=strng1(end-5:end);
            elseif strng1(end-4)=='w'
                strng2=strng1(end-4:end);
        end;
        clear x;
        load(strng2);
        sound(x*0.9/max(abs(x)),FS);
        pause;
        load(['subject_',num2str(subject_no),'_',strng1,'WrittenResponse']);
        disp(subject_word);
        result=input('Result:');
        if isempty(result),result=0;end; 
        Subject_evaluation(words+350*(cases-1))=result;
        updated_index(1)=cases;
        updated_index(2)=words;
        save([name,'_updated_index.mat'],'updated_index');
        save([name,'_evaluation'],'Subject_evaluation');
        if words<350
            words=words+1;
        else
            words=1;
            cases=cases+1;
        end;
end;