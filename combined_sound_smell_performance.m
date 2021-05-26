%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function combined_sound_smell_performance()

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
gohitodor0=0;
nogohit0=0;
nogohitodor0=0;
gomiss0=0;
gomissodor0=0;
nogomiss0=0;
nogomissodor0=0;

gohit50=0;
gohitodor50=0;
nogohit50=0;
nogohitodor50=0;
gomiss50=0;
gomissodor50=0;
nogomiss50=0;
nogomissodor50=0;

gohit55=0;
gohitodor55=0;
nogohit55=0;
nogohitodor55=0;
gomiss55=0;
gomissodor55=0;
nogomiss55=0;
nogomissodor55=0;

gohit60=0;
gohitodor60=0;
nogohit60=0;
nogohitodor60=0;
gomiss60=0;
gomissodor60=0;
nogomiss60=0;
nogomissodor60=0;

gohit65=0;
gohitodor65=0;
nogohit65=0;
nogohitodor65=0;
gomiss65=0;
gomissodor65=0;
nogomiss65=0;
nogomissodor65=0;

gohit70=0;
gohitodor70=0;
nogohit70=0;
nogohitodor70=0;
gomiss70=0;
gomissodor70=0;
nogomiss70=0;
nogomissodor70=0;

gohit75=0;
gohitodor75=0;
nogohit75=0;
nogohitodor75=0;
gomiss75=0;
gomissodor75=0;
nogomiss75=0;
nogomissodor75=0;

gohit80=0;
gohitodor80=0;
nogohit80=0;
nogohitodor80=0;
gomiss80=0;
gomissodor80=0;
nogomiss80=0;
nogomissodor80=0;
    
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
    s0responseodor=zeros(1,NumTrials);
    s50responseodor=zeros(1,NumTrials);
    s55responseodor=zeros(1,NumTrials);
    s60responseodor=zeros(1,NumTrials);
    s65responseodor=zeros(1,NumTrials);
    s70responseodor=zeros(1,NumTrials);
    s75responseodor=zeros(1,NumTrials);
    s80responseodor=zeros(1,NumTrials);
    for Trials=1:NumTrials
        mouseresponse=Data.response(Trials);
        level=Data.sound_level(Trials);
        odor=Data.odorvalve(Trials);
        if level==0 && odor==5
            s0response(Trials)=mouseresponse;
        elseif level==0 && odor==8
            s0responseodor(Trials)=mouseresponse;
        elseif level==50 && odor==5
            s50response(Trials)=mouseresponse;
        elseif level==50 && odor==8
            s50responseodor(Trials)=mouseresponse;
        elseif level==55 && odor==5
            s55response(Trials)=mouseresponse;
        elseif level==55 && odor==8
            s55responseodor(Trials)=mouseresponse;
        elseif level==60 && odor==5
            s60response(Trials)=mouseresponse;
        elseif level==60 && odor==8
            s60responseodor(Trials)=mouseresponse;
        elseif level==65 && odor==5
            s65response(Trials)=mouseresponse;
        elseif level==65 && odor==8
            s65responseodor(Trials)=mouseresponse;
        elseif level==70 && odor==5
            s70response(Trials)=mouseresponse;
        elseif level==70 && odor==8
            s70responseodor(Trials)=mouseresponse;
        elseif level==75 && odor==5
            s75response(Trials)=mouseresponse;
        elseif level==75 && odor==8
            s75responseodor(Trials)=mouseresponse;
        elseif level==80 && odor==5
            s80response(Trials)=mouseresponse;
        elseif level==80 && odor==8
            s80responseodor(Trials)=mouseresponse;
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
    
    for r=1:length(s0responseodor)
        if s0responseodor(r) == 1
            gohitodor0=gohitodor0+1;
        elseif s0responseodor(r) == 2
            nogohitodor0=nogohitodor0+1;
        elseif s0responseodor(r) == 3
            gomissodor0=gomissodor0+1;
        elseif s0responseodor(r) == 4
            nogomissodor0=nogomissodor0+1;
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
    
    for r=1:length(s50responseodor)
        if s50responseodor(r) == 1
            gohitodor50=gohitodor50+1;
        elseif s50responseodor(r) == 2
            nogohitodor50=nogohitodor50+1;
        elseif s50responseodor(r) == 3
            gomissodor50=gomissodor50+1;
        elseif s50responseodor(r) == 4
            nogomissodor50=nogomissodor50+1;
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
    
    for r=1:length(s55responseodor)
        if s55responseodor(r) == 1
            gohitodor55=gohitodor55+1;
        elseif s55responseodor(r) == 2
            nogohitodor55=nogohitodor55+1;
        elseif s55responseodor(r) == 3
            gomissodor55=gomissodor55+1;
        elseif s55responseodor(r) == 4
            nogomissodor55=nogomissodor55+1;
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
    
    for r=1:length(s60responseodor)
        if s60responseodor(r) == 1
            gohitodor60=gohitodor60+1;
        elseif s60responseodor(r) == 2
            nogohitodor60=nogohitodor60+1;
        elseif s60responseodor(r) == 3
            gomissodor60=gomissodor60+1;
        elseif s60responseodor(r) == 4
            nogomissodor60=nogomissodor60+1;
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
    
    for r=1:length(s65responseodor)
        if s65responseodor(r) == 1
            gohitodor65=gohitodor65+1;
        elseif s65responseodor(r) == 2
            nogohitodor65=nogohitodor65+1;
        elseif s65responseodor(r) == 3
            gomissodor65=gomissodor65+1;
        elseif s65responseodor(r) == 4
            nogomissodor65=nogomissodor65+1;
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
    
    for r=1:length(s70responseodor)
        if s70responseodor(r) == 1
            gohitodor70=gohitodor70+1;
        elseif s70responseodor(r) == 2
            nogohitodor70=nogohitodor70+1;
        elseif s70responseodor(r) == 3
            gomissodor70=gomissodor70+1;
        elseif s70responseodor(r) == 4
            nogomissodor70=nogomissodor70+1;
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
    
    for r=1:length(s75responseodor)
        if s75responseodor(r) == 1
            gohitodor75=gohitodor75+1;
        elseif s75responseodor(r) == 2
            nogohitodor75=nogohitodor75+1;
        elseif s75responseodor(r) == 3
            gomissodor75=gomissodor75+1;
        elseif s75responseodor(r) == 4
            nogomissodor75=nogomissodor75+1;
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
    
    for r=1:length(s80responseodor)
        if s80responseodor(r) == 1
            gohitodor80=gohitodor80+1;
        elseif s80responseodor(r) == 2
            nogohitodor80=nogohitodor80+1;
        elseif s80responseodor(r) == 3
            gomissodor80=gomissodor80+1;
        elseif s80responseodor(r) == 4
            nogomissodor80=nogomissodor80+1;
        else
        end
    end
end
    percorr0=((nogohit0)/(nogohit0+nogomiss0))*100;
    scatter(0,percorr0)
    hold on
    percorrodor0=((nogohitodor0)/(nogohitodor0+nogomissodor0))*100;
    scatter(0,percorrodor0,'filled')
    hold on
    percorr50=((gohit50)/(gohit50+gomiss50))*100;
    scatter(50,percorr50)
    hold on
    percorrodor50=((gohitodor50)/(gohitodor50+gomissodor50))*100;
    scatter(50,percorrodor50,'filled')
    hold on
    percorr55=((gohit55)/(gohit55+gomiss55))*100;
    scatter(55,percorr55)
    hold on
    percorrodor55=((gohitodor55)/(gohitodor55+gomissodor55))*100;
    scatter(55,percorrodor55,'filled')
    hold on
    percorr60=((gohit60)/(gohit60+gomiss60))*100;
    scatter(60,percorr60)
    hold on
    percorrodor60=((gohitodor60)/(gohitodor60+gomissodor60))*100;
    scatter(60,percorrodor60,'filled')
    hold on
    percorr65=((gohit65)/(gohit65+gomiss65))*100;
    scatter(65,percorr65)
    hold on
    percorrodor65=((gohitodor65)/(gohitodor65+gomissodor65))*100;
    scatter(65,percorrodor65,'filled')
    hold on
    percorr70=((gohit70)/(gohit70+gomiss70))*100;
    scatter(70,percorr70)
    hold on
    percorrodor70=((gohitodor70)/(gohitodor70+gomissodor70))*100;
    scatter(70,percorrodor70,'filled')
    hold on
    percorr75=((gohit75)/(gohit75+gomiss75))*100;
    scatter(75,percorr75)
    hold on
    percorrodor75=((gohitodor75)/(gohitodor75+gomissodor75))*100;
    scatter(75,percorrodor75,'filled')
    hold on
    percorr80=((gohit80)/(gohit80+gomiss80))*100;
    scatter(80,percorr80)
    hold on
    percorrodor80=((gohitodor80)/(gohitodor80+gomissodor80))*100;
    scatter(80,percorrodor80,'filled')
    hold on
    %xticks([0 50 55 60 65 70 75 80])
    xticks(0:5:80)
    xlabel('Sound Intensities (dB)')
    yticks(0:10:100)
    ylim([0 100])
    ylabel('% Correct')
    title("Combined Performance on each Sound Level")
    legend('No Odor','Odor','location','best')
    hold off
end