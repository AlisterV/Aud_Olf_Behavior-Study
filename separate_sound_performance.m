%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function separate_sound_performance()

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
theFiles =string(uigetfile(filePattern,'Multiselect','on'));
%initializes a counter to keep track of all the trials continually through
y=zeros(length(theFiles),7);
for k = 1 : length(theFiles)
    figure(k)
    %selects the kth file
    fullFileName = theFiles{k};
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
    %sound levels tested [0,10,30,50,60,70,80]
    
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
            %                 elseif level==55
            %                     s55response(Trials)=mouseresponse;
        elseif level==60
            s60response(Trials)=mouseresponse;
            %                 elseif level==65
            %                     s65response(Trials)=mouseresponse;
        elseif level==70
            s70response(Trials)=mouseresponse;
            %                 elseif level==75
            %                     s75response(Trials)=mouseresponse;
        elseif level==80
            s80response(Trials)=mouseresponse;
        end
    end
    
    %do we need this?
    gohit0=0;
    nogohit0=0;
    gomiss0=0;
    nogomiss0=0;
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
    y(k,1)=percorr0;
    scatter(0,percorr0)
    hold on
    
    gohit10=0;
    nogohit10=0;
    gomiss10=0;
    nogomiss10=0;
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
    y(k,2)=percorr10;
    scatter(10,percorr10);
    hold on
    
    gohit30=0;
    nogohit30=0;
    gomiss30=0;
    nogomiss30=0;
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
    y(k,3)=percorr30;
    scatter(30,percorr30);
    hold on
    
    gohit50=0;
    nogohit50=0;
    gomiss50=0;
    nogomiss50=0;
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
    y(k,4)=percorr50;
    scatter(50,percorr50);
    hold on
    
    gohit55=0;
    nogohit55=0;
    gomiss55=0;
    nogomiss55=0;
    
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
    %             percorr=((gohit55)/(gohit55+gomiss55))*100;
    %             scatter(55,percorr);
    %             hold on
    
    gohit60=0;
    nogohit60=0;
    gomiss60=0;
    nogomiss60=0;
    
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
    y(k,5)=percorr60;
    scatter(60,percorr60);
    hold on
    
    gohit65=0;
    nogohit65=0;
    gomiss65=0;
    nogomiss65=0;
    
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
    %             percorr=((gohit65)/(gohit65+gomiss65))*100;
    %             scatter(65,percorr);
    %             hold on
    
    gohit70=0;
    nogohit70=0;
    gomiss70=0;
    nogomiss70=0;
    
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
    y(k,6)=percorr70;
    scatter(70,percorr70);
    hold on
    
    gohit75=0;
    nogohit75=0;
    gomiss75=0;
    nogomiss75=0;
    
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
    %             percorr=((gohit75)/(gohit75+gomiss75))*100;
    %             scatter(75,percorr);
    %             hold on
    
    gohit80=0;
    nogohit80=0;
    gomiss80=0;
    nogomiss80=0;
    
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
    y(k,7)=percorr80;
    scatter(80,percorr80)
    hold on
    %xticks([0 50 55 60 65 70 75 80])
    xticks(0:10:80)
    xlim([0 80])
    xlabel('Sound Intensities (dB)')
    yticks(0:10:100)
    ylim([0 100])
    ylabel('% Licks')
    title("Performance of Mouse "+convertCharsToStrings(mousenum)+" from Session " +convertCharsToStrings(sessionnum)+ " on each Sound Level")
    hold off
end
y=mean(y);
x=[0 10 30 50 60 70 80];
end