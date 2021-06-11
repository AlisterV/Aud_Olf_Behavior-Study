%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.
%This code assumes that the NoGo Trials are on sound level 0dB and they are
%the first input value.

function combined_soundperformance_psychocurve()

%clears all previous data variables
clear all
%closes all previous figures
close all
myFolder = 'C:\VoyeurData';
windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.
% answer=inputdlg('Enter Sound Levels Used: ');
% x=str2num(answer{1});
x=[0 10 30 50 60 70 80];
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
        % User clicked Cancel
        return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.h5');
%opens user access to the desired folder
theFile =string(uigetfile(filePattern,'Multiselect','on'));
structrow=0;
for m=1:length(theFile)
    structrow=structrow+1;
    theFiles(structrow)=dir(theFile(m));
end
theFiles=struct2table(theFiles);
theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
theFiles=sortrows(theFiles,'datenum');
theFiles=table2struct(theFiles);

%trialcounterarray=zeros(numel(x),length(theFiles));
%percorrarray=zeros(numel(x),length(theFiles));
%FAarray=zeros(numel(x),length(theFiles));
gohitarray=zeros(numel(x),length(theFiles));
nogohitarray=zeros(numel(x),length(theFiles));
gomissarray=zeros(numel(x),length(theFiles));
nogomissarray=zeros(numel(x),length(theFiles));
trialcounterarray=zeros(numel(x),length(theFiles));

for k = 1 : length(theFiles)
    
    fullFileName = theFiles(k).name;
    %reads the file and keeps the data in this variable
    %baseFileName = theFiles(k).name;
    %fullFileName = fullfile(theFiles(k).folder, baseFileName);
    Data=h5read(fullFileName,'/Trials');
    %Determines the number of trials for this particular file
    NumTrials = length(Data.trialNumber);
    mousenum=Data.mouse(1:3,1)';
    sessionnum=Data.session(1);
    %Our sampling frequency is 1000Hz.
    Fs = 1000;
    soundresponse=zeros(numel(x),NumTrials);
    
    
    
    %     for Trials=1:NumTrials
    %         mouseresponse=Data.response(Trials);
    %         level=Data.sound_level(Trials);
    %         pos=level==x;
    %         where=find(pos);
    %         soundresponse=soundresponse(where,Trials);
    for Trials=1:NumTrials
        trialcounter=zeros(numel(x),NumTrials);
    end
    
    for Trials=1:NumTrials
        level=Data.sound_level(Trials);
        mouseresponse=Data.response(Trials);
        for e=1:numel(x)
            if level==x(e)
                soundresponse(e,Trials)=mouseresponse;
                trialcounter(e,Trials)=1;
            end
        end
    end
    trialcounterarray(:,k)=sum(trialcounter,2);
    
    for p=1:numel(x)
        gohit=0;
        gomiss=0;
        nogohit=0;
        nogomiss=0;
        for w=1:NumTrials
            response=soundresponse(p,w);
            if response == 1
                gohit=gohit+1;
            elseif response == 2
                nogohit=nogohit+1;
            elseif response == 3
                gomiss=gomiss+1;
            elseif response == 4
                nogomiss=nogomiss+1;
            else
            end
        end
        gohitarray(p,k)=gohit;
        gomissarray(p,k)=gomiss;
        nogohitarray(p,k)=nogohit;
        nogomissarray(p,k)=nogomiss;
    end
end

percorrarray=gohitarray./trialcounterarray;
FAarray=nogomissarray./trialcounterarray;
FAarray=FAarray(1,:);
percorrarray=percorrarray(2:end,:);
y=percorrarray';
meanpercorr=mean(percorrarray,2);
%meanFA=mean(FAarray,2);
sdcorr=std(percorrarray,0,2);
stecorr=sdcorr./(sqrt(length(theFiles)));
sdFA=std(FAarray);
steFA=sdFA/(sqrt(length(theFiles)));

figure();
axes('position',[.1,.25,.8,.7])
xticks(min(x):10:max(x))
xlim([min(x) max(x)])
%scatter(x(1),mean(FAarray))
errorbar(x(1),mean(FAarray),steFA,'or')
hold on
%scatter(x,meanpercorr)
for o=1:numel(x)
    if x(o)==0
        x(o)=[];
        break
    end
end
errorbar(x,meanpercorr',stecorr,'or')



hold on
xlabel('Sound Intensities (dB)')
yticks(0:0.1:1)
ylim([0 1])
ylabel('Hit rate')
title("Combined Performance on each Sound Level")
hold on

x1=x;
for i=1:length(theFiles)
    if i==1
        x=x;
    else
        x=[x;x1];
    end
end

[params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(x(:),y(:));
xf=linspace(min(x(:)),max(x(:)),100);
plot(xf,mdl(params,xf))
hold on
xline(threshold,'--',"Threshold = "+convertCharsToStrings(threshold)+"dB",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')


% holdnames={'Sound Level: ','# of Trials: '};
% idle=x1;
% idle2=sum(trialcounterarray,'all')';
% hold0=[0,sum(trialcounter0,'all')];
% hold10=[10,sum(trialcounter10,'all')];
% hold30=[30,sum(trialcounter30,'all')];
% hold50=[50,sum(trialcounter50,'all')];
% hold60=[60,sum(trialcounter60,'all')];
% hold70=[70,sum(trialcounter70,'all')];
% hold80=[80,sum(trialcounter80,'all')];
% T=table(holdnames',idle',idle2');
% tableCell = table2cell(T);
% tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
% tableChar = splitapply(@strjoin,pad(tableCell),[1;2]);
% % % Add axes (not visible) & text (use a fixed width font)
% hold on
% axes('position',[.1,0,2,.1], 'Visible','off')
% t=text(.225,.95,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
% t.FontSize=7.5;
% % 
end




