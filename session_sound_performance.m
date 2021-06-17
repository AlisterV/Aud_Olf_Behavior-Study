%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function [x,y]=session_sound_performance()

%clears all previous data variables
clear all
%closes all previous figures
close all
myFolder = 'C:\VoyeurData';
windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.
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
for x=1:length(theFile)
    structrow=structrow+1;
    theFiles(structrow)=dir(theFile(x));
end
theFiles=struct2table(theFiles);
theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
theFiles=sortrows(theFiles,'datenum');
datenum=string(theFiles.datenum);
theFiles=table2struct(theFiles);

trialcounter0=zeros(1,length(theFiles));
trialcounter10=zeros(1,length(theFiles));
trialcounter30=zeros(1,length(theFiles));
trialcounter50=zeros(1,length(theFiles));
trialcounter60=zeros(1,length(theFiles));
trialcounter70=zeros(1,length(theFiles));
trialcounter80=zeros(1,length(theFiles));
%sound levels tested [0,10,30,50,60,70,80]
percorr0array=zeros(1,length(theFiles));
percorr10array=zeros(1,length(theFiles));
percorr30array=zeros(1,length(theFiles));
percorr50array=zeros(1,length(theFiles));
percorr60array=zeros(1,length(theFiles));
percorr70array=zeros(1,length(theFiles));
percorr80array=zeros(1,length(theFiles));



%initializes a counter to keep track of all the trials continually through
for k = 1 : length(theFiles)
    %figure(k)
    %selects the kth file
    gohit0=0;
    nogohit0=0;
    gomiss0=0;
    nogomiss0=0;
    
    gohit10=0;
    nogohit10=0;
    gomiss10=0;
    nogomiss10=0;
    
    gohit30=0;
    nogohit30=0;
    gomiss30=0;
    nogomiss30=0;
    
    gohit50=0;
    nogohit50=0;
    gomiss50=0;
    nogomiss50=0;
    
    gohit60=0;
    nogohit60=0;
    gomiss60=0;
    nogomiss60=0;
    
    gohit70=0;
    nogohit70=0;
    gomiss70=0;
    nogomiss70=0;
    
    gohit80=0;
    nogohit80=0;
    gomiss80=0;
    nogomiss80=0;
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
    s0response=zeros(1,NumTrials);
    s10response=zeros(1,NumTrials);
    s30response=zeros(1,NumTrials);
    s50response=zeros(1,NumTrials);
    s55response=zeros(1,NumTrials);
    s60response=zeros(1,NumTrials);
    s65response=zeros(1,NumTrials);
    s70response=zeros(1,NumTrials);
    s75response=zeros(1,NumTrials);
    s80response=zeros(1,NumTrials);
    
    for Trials=1:NumTrials
        mouseresponse=Data.response(Trials);
        level=Data.sound_level(Trials);
        if level==0
            s0response(Trials)=mouseresponse;
        elseif level==10
            s10response(Trials)=mouseresponse;
        elseif level==30
            s30response(Trials)=mouseresponse;
        elseif level==50
            s50response(Trials)=mouseresponse;
        elseif level==55
            s55response(Trials)=mouseresponse;
        elseif level==60
            s60response(Trials)=mouseresponse;
        elseif level==65
            s65response(Trials)=mouseresponse;
        elseif level==70
            s70response(Trials)=mouseresponse;
        elseif level==75
            s75response(Trials)=mouseresponse;
        elseif level==80
            s80response(Trials)=mouseresponse;
        end
    end
    
    
    for r=1:length(s0response)
        if s0response(r) == 1
            gohit0=gohit0+1;
        elseif s0response(r) == 2
            nogohit0=nogohit0+1;
        elseif s0response(r) == 3
            gomiss0=gomiss0+1;
        elseif s0response(r) == 4
            nogomiss0=nogomiss0+1;
        else
        end
    end
    percorr0=((nogomiss0)/(nogohit0+nogomiss0))*100;
    percorr0array(k)=percorr0;
    trialcounter0(k)=numel((find(s0response)~=0));
    
    for r=1:length(s10response)
        if s10response(r) == 1
            gohit10=gohit10+1;
        elseif s10response(r) == 2
            nogohit10=nogohit10+1;
        elseif s10response(r) == 3
            gomiss10=gomiss10+1;
        elseif s10response(r) == 4
            nogomiss10=nogomiss10+1;
        else
        end
    end
    percorr10=((gohit10)/(gohit10+gomiss10))*100;
    percorr10array(k)=percorr10;
    trialcounter10(k)=numel((find(s10response)~=0));
    
    for r=1:length(s30response)
        if s30response(r) == 1
            gohit30=gohit30+1;
        elseif s30response(r) == 2
            nogohit30=nogohit30+1;
        elseif s30response(r) == 3
            gomiss30=gomiss30+1;
        elseif s30response(r) == 4
            nogomiss30=nogomiss30+1;
        else
        end
    end
    percorr30=((gohit30)/(gohit30+gomiss30))*100;
    percorr30array(k)=percorr30;
    trialcounter30(k)=numel((find(s30response)~=0));
    
    for r=1:length(s50response)
        if s50response(r) == 1
            gohit50=gohit50+1;
        elseif s50response(r) == 2
            nogohit50=nogohit50+1;
        elseif s50response(r) == 3
            gomiss50=gomiss50+1;
        elseif s50response(r) == 4
            nogomiss50=nogomiss50+1;
        else
        end
    end
    percorr50=((gohit50)/(gohit50+gomiss50))*100;
    percorr50array(k)=percorr50;
    trialcounter50(k)=numel((find(s50response)~=0));
    
    for r=1:length(s55response)
        if s55response(r) == 1
            gohit55=gohit55+1;
        elseif s55response(r) == 2
            nogohit55=nogohit55+1;
        elseif s55response(r) == 3
            gomiss55=gomiss55+1;
        elseif s55response(r) == 4
            nogomiss55=nogomiss55+1;
        else
        end
    end
    
    for r=1:length(s60response)
        if s60response(r) == 1
            gohit60=gohit60+1;
        elseif s60response(r) == 2
            nogohit60=nogohit60+1;
        elseif s60response(r) == 3
            gomiss60=gomiss60+1;
        elseif s60response(r) == 4
            nogomiss60=nogomiss60+1;
        else
        end
    end
    percorr60=((gohit60)/(gohit60+gomiss60))*100;
    percorr60array(k)=percorr60;
    trialcounter60(k)=numel((find(s60response)~=0));
    
    for r=1:length(s65response)
        if s65response(r) == 1
            gohit65=gohit65+1;
        elseif s65response(r) == 2
            nogohit65=nogohit65+1;
        elseif s65response(r) == 3
            gomiss65=gomiss65+1;
        elseif s65response(r) == 4
            nogomiss65=nogomiss65+1;
        else
        end
    end
    
    for r=1:length(s70response)
        if s70response(r) == 1
            gohit70=gohit70+1;
        elseif s70response(r) == 2
            nogohit70=nogohit70+1;
        elseif s70response(r) == 3
            gomiss70=gomiss70+1;
        elseif s70response(r) == 4
            nogomiss70=nogomiss70+1;
        else
        end
    end
    percorr70=((gohit70)/(gohit70+gomiss70))*100;
    percorr70array(k)=percorr70;
    trialcounter70(k)=numel((find(s70response)~=0));
    
    for r=1:length(s75response)
        if s75response(r) == 1
            gohit75=gohit75+1;
        elseif s75response(r) == 2
            nogohit75=nogohit75+1;
        elseif s75response(r) == 3
            gomiss75=gomiss75+1;
        elseif s75response(r) == 4
            nogomiss75=nogomiss75+1;
        else
        end
    end
    
    for r=1:length(s80response)
        if s80response(r) == 1
            gohit80=gohit80+1;
        elseif s80response(r) == 2
            nogohit80=nogohit80+1;
        elseif s80response(r) == 3
            gomiss80=gomiss80+1;
        elseif s80response(r) == 4
            nogomiss80=nogomiss80+1;
        else
        end
    end
    percorr80=((gohit80)/(gohit80+gomiss80))*100;
    percorr80array(k)=percorr80;
    trialcounter80(k)=numel((find(s80response)~=0));
    
    y=[percorr0 percorr10 percorr30 percorr50 percorr60 percorr70 percorr80];
    x=[0 10 30 50 60 70 80];
    scatter(x,y)
    line(x,y,'color',rand(1,3))
    xticks(0:10:80)
    xlim([0 80])
    xlabel('Sound Intensities (dB)')
    yticks(0:10:100)
    ylim([0 100])
    ylabel('% Licks')
    title('Session Sound Level Performance for Mouse '+convertCharsToStrings(mousenum))
    hold on
end

legend('','Test 1','','Test 2','','Test 3','','Test 4','','Test 5','Location','bestoutside')        
%legend('Test 1','Test 2','Test 3','Test 4','Test 5','Location','bestoutside')        

%ax1=nexttile
        %sound_levels_used={'0','10','30','50','60','70','80'};
        %trialcounter=[trialcounter0,trialcounter10,trialcounter30,trialcounter50,trialcounter60,trialcounter70,trialcounter80];
%         holdnames={'Sound Level: ','# of Trials: '};
%         hold0=[0,sum(trialcounter0,'all')];
%         hold10=[10,sum(trialcounter10,'all')];
%         hold30=[30,sum(trialcounter30,'all')];
%         hold50=[50,sum(trialcounter50,'all')];
%         hold60=[60,sum(trialcounter60,'all')];
%         hold70=[70,sum(trialcounter70,'all')];
%         hold80=[80,sum(trialcounter80,'all')];
%         T=table(holdnames',hold0',hold10',hold30',hold50',hold60',hold70',hold80');
%         tableCell = table2cell(T);
%         tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
%         tableChar = splitapply(@strjoin,pad(tableCell),[1;2]);
%         % Add axes (not visible) & text (use a fixed width font)
%         hold on
%         axes('position',[.1,0,2,.1], 'Visible','off')
%         t=text(.225,.95,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
%         t.FontSize=7.5;
end
