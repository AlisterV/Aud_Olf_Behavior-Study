%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function combined_sound_performance()

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
theFiles =string(uigetfile(filePattern,'Multiselect','on'));

    gohit0=0;
    nogohit0=0;
    gomiss0=0;
    nogomiss0=0;
    gohit80=0;
    nogohit80=0;
    gomiss80=0;
    nogomiss80=0;
    
%initializes a counter to keep track of all the trials continually through
for k = 1 : length(theFiles)
    %figure(k)
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
end
    percorr0=((nogohit0)/(nogohit0+nogomiss0))*100;
    scatter(0,percorr0)
    hold on
    percorr50=((nogohit50)/(nogohit50+nogomiss50))*100;
    scatter(50,percorr50)
    hold on
    percorr55=((nogohit55)/(nogohit55+nogomiss55))*100;
    scatter(55,percorr55)
    hold on
    percorr60=((nogohit60)/(nogohit60+nogomiss60))*100;
    scatter(60,percorr60)
    hold on
    percorr65=((nogohit65)/(nogohit65+nogomiss65))*100;
    scatter(65,percorr65)
    hold on
    percorr70=((nogohit70)/(nogohit70+nogomiss70))*100;
    scatter(70,percorr70)
    hold on
    percorr75=((nogohit75)/(nogohit75+nogomiss75))*100;
    scatter(75,percorr75)
    hold on
    percorr80=((gohit80)/(gohit80+gomiss80))*100;
    scatter(80,percorr80)
    hold on
    %xticks([0 50 55 60 65 70 75 80])
    xticks(0:5:80)
    xlabel('Sound Intensities (dB)')
    yticks(0:10:100)
    ylim([0 100])
    ylabel('% Correct')
    title("Combined Performance on each Sound Level")
    hold off
end