%% Last edit made by Kyle Mabry on 3/30/2020
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc... 

function Trial_Performance_GNG()

close all;
clear all;
clc;

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

myFolder = 'C:\VoyeurData';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end

%% HOLD Ctrl and click desired files
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.h5');
%opens user access to the desired folder 
FileNameInput = uigetfile(filePattern);

Data =  h5read(FileNameInput,'/Trials');
mousenum=Data.mouse(1:3,1)';
sessionnum=Data.session(1);
% mouse = input("What is the number of this mouse? ");
NumTrials = length(Data.trialNumber); %Determine the number of trials in this experiment in order to get the sniff data later on.
Fs = 1000; %Our sampling frequency is 1000Hz.

%%  Take the behavorial data and output it to a .csv file.
% Get the animal's response time in miliseconds by subtracting their first lick by the odor valve onset.
% for each tiral in the experiment.
behavorialResponseArray =strings;
for Trials = 1:NumTrials
    % response time is equal to the time of the first lick minus the time
    % of the odor valve onset.
    responseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials));
    % if the response time is negative then just set it equal to zero.
    if responseTime < 0
        responseTime = 0;
    end
    % save the response time into a string array.
    behavorialResponseArray(1,Trials) = "Trial # " + Trials;
    behavorialResponseArray(2,Trials) = "Response Time (ms)";
    behavorialResponseArray(3,Trials) = responseTime;
end

GoTrialPerformance=zeros(1,NumTrials);
NoGoTrialPerformance=zeros(1,NumTrials);
GoHitCounter = 0;
NoGoHitCounter = 0;
GoMissCounter = 0;
NoGoMissCounter = 0;
behavorialResponseArray(12, 1) = "Go Hit";
behavorialResponseArray(13, 1) = "Go Miss";
behavorialResponseArray(14, 1) = "No Go Hit";
behavorialResponseArray(15, 1) = "No Go Miss";

figure(1)
ratio=[2 1 1];
pbaspect(ratio)
hold on
grid on
yticks(0:20:100)
xlim([1 NumTrials])
title("Performance of Mouse "+convertCharsToStrings(mousenum)+" from Session "+convertCharsToStrings(sessionnum))
ylabel('Percent Correct')
xlabel('Trial #')
% correctpercenttracker=zeros(1,NumTrials);
% incorrectpercenttracker=zeros(1,NumTrials);
% corper=zeros(1,NumTrials);
% passcounter=0;
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    if isfield(Data,'sound_level')==1
        soundlevel = Data.sound_level(Trials);
        behavorialResponseArray(7,Trials)= "Sound Level";
        behavorialResponseArray(8,Trials)=soundlevel;
    else
    end
    odorvalve=Data.odorvalve(Trials);
    % Label which trial this is.
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    behavorialResponseArray(9,Trials)='Odor Valve';
    behavorialResponseArray(10,Trials)=odorvalve;
    % Save the numerical result of this mouses' behavorial for the trial.
    behavorialResponseArray(5, Trials) = mouseResponse;
    % Translate the animals response for the trial.
    if mouseResponse == 1
        behavorialResponseArray(6, Trials) = "Go Hit";
        GoHitCounter = GoHitCounter + 1;
        behavorialResponseArray(12, 2) = GoHitCounter;
%         correctpercenttracker(Trials)=1;
%         incorrectpercenttracker(Trials)=0;
        GoTrialPerformance(Trials)= 1;
        num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
        if isnan(num)
            num=0;
        end
        scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
        hold on
        scatter(Trials,num,'r','filled')
        hold on
    elseif mouseResponse == 2
        behavorialResponseArray(6, Trials) = "NoGo Hit";
        NoGoHitCounter = NoGoHitCounter + 1;
        behavorialResponseArray(14, 2) = NoGoHitCounter;
%         correctpercenttracker(Trials)=1;
%         incorrectpercenttracker(Trials)=0;
        NoGoTrialPerformance(Trials)=1;
        num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
        if isnan(num)
            num=0;
        end
        scatter(Trials,num,47,'b','filled')
        hold on
        scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
        hold on
        
    elseif mouseResponse == 3
        behavorialResponseArray(6, Trials) = "Go Miss";
        GoMissCounter = GoMissCounter + 1;
        behavorialResponseArray(13, 2) = GoMissCounter;
%         correctpercenttracker(Trials)=0;
%         incorrectpercenttracker(Trials)=1;
        GoTrialPerformance(Trials)=-1;
        num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
        if isnan(num)
            num=0;
        end
        scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
        hold on
        scatter(Trials,num,'r','filled')
        hold on
    elseif mouseResponse == 4
        behavorialResponseArray(6, Trials) = "NoGo Miss";
        NoGoMissCounter = NoGoMissCounter + 1;
        behavorialResponseArray(15, 2) = NoGoMissCounter;
%         correctpercenttracker(Trials)=0;
%         incorrectpercenttracker(Trials)=1;
        NoGoTrialPerformance(Trials) = -1;
        num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
        if isnan(num)
            num=0;
        end
        scatter(Trials,num,47,'b','filled')
        hold on
        scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
        hold on
    end
end
legend('Go Trial','NoGo Trial','location','best')
legend('boxoff')
% Also indicate the total number of trials for this training session. 
%behavorialResponseArray(13, 2) = NumTrials;
behavorialResponseArray(17, 1) = "Total number of trials: " +convertCharsToStrings(NumTrials);
Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100;
Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100;
%behavorialResponseArray(15,2)= Correctpercentage;
behavorialResponseArray(19,1)= "Correct Percent: " +convertCharsToStrings(Correctpercentage)+"%";
%behavorialResponseArray(16,2)= Incorrectpercentage;
behavorialResponseArray(20,1)= "Incorrect Percent: " +convertCharsToStrings(Incorrectpercentage)+"%";
pHit=GoHitCounter/(GoHitCounter+GoMissCounter); %NEED TO CHECK, possibly needs to be GoHits/All Trials
pFA=NoGoMissCounter/(NoGoMissCounter+NoGoHitCounter); %NEED TO CHECK, possibly needs to be just NoGoMiss/All Trials
nTarget=(GoHitCounter+GoMissCounter); %not sure if this means the number of trials in to tla of that it is based on
nDistract=(NoGoHitCounter+NoGoMissCounter);
[dpri,ccrit] = dprime(pHit,pFA,nTarget,nDistract);
behavorialResponseArray(21,1)="d prime: " +convertCharsToStrings(dpri); %PUT IN VARIABLE HERE (calculate above)
%behavorialResponseArray(17,2)=convertCharsToStrings(dpri);

file=erase(FileNameInput,'.h5');
% save the response time data and the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(file)+".xlsx"),'FileType','spreadsheet');
percentdifferencepertrialcorrect = diff(percentcorrectcounter);
percentdifferencepertrialincorrect = diff(percentincorrectcounter);
overallperformancetodate_correct=(percentcorrectcounter(numel(theFiles))-percentcorrectcounter(1));
overallperformancetodate_incorrect=(percentincorrectcounter(numel(theFiles))-percentincorrectcounter(1));
end

