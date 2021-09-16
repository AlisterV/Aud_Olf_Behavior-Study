%% Last edit made by Alister Virkler 6/17/2021
% This code recreates the Go/NoGo performance graph from the GUI for a
% specific trial.

function GUI_performance_recreation()

close all;
clear all;

%sets the folder
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

%% Click desired file
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.h5');
%opens user access to the desired folder 
FileNameInput = uigetfile(filePattern);

%reads the file into matlab
Data =  h5read(FileNameInput,'/Trials');
%finds the files mouse number
mousenum=Data.mouse(1:3,1)';
%finds the files session number
sessionnum=Data.session(1);
%finds the number of trials
NumTrials = length(Data.trialNumber);

%%  Take the behavorial data and output it to a .xlsx file.
%creates a string array
behavorialResponseArray =strings;

%loops through every trial from the file for response times
for Trials = 1:NumTrials
    % response time is equal to the time of the first lick minus the time
    % of the odor valve onset.
    responseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials))-1000;
    % if the response time is negative then just set it equal to zero.
    if responseTime < 0
        responseTime = 0;
    end
    % save the response time into a string array.
    behavorialResponseArray(1,Trials) = "Trial # " + Trials;
    behavorialResponseArray(2,Trials) = "Response Time (ms)";
    behavorialResponseArray(3,Trials) = responseTime;
end

%initializes array and counters
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

%opens a figure
figure(1)
%creates a ratio for the figure
ratio=[2 1 1];
%applies the ratio to the figure
pbaspect(ratio)
hold on
%turns on a grid for the figure
grid on
%creates y ticks from zero to 100 by 20 
yticks(0:20:100)
%sets x limits from 1 to the number of trials
xlim([1 NumTrials])
%creates a title
title("Performance of Mouse "+convertCharsToStrings(mousenum)+" from Session "+convertCharsToStrings(sessionnum))
%creates a y axis label
ylabel('Percent Correct')
%creates an x axis label
xlabel('Trial #')

%loops through all the trials for the file
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    %sees if the file contains a field called sound level, later files have
    %this but not all
    if isfield(Data,'sound_level')==1
      %if the file contains sound level the choose the trils level
        soundlevel = Data.sound_level(Trials);
        behavorialResponseArray(7,Trials)= "Sound Level";
        behavorialResponseArray(8,Trials)=soundlevel;
    else
    end
    %finds the odor valve for each trial
    odorvalve=Data.odorvalve(Trials);
    %puts this data into the array
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    behavorialResponseArray(9,Trials)='Odor Valve';
    behavorialResponseArray(10,Trials)=odorvalve;
    % Save the numerical result of this mouses' behavorial for the trial.
    behavorialResponseArray(5, Trials) = mouseResponse;
    
    % Translate the animals response for the trial.
    if mouseResponse == 1
      %adds this to the array
        behavorialResponseArray(6, Trials) = "Go Hit";
        %adds one to the go hit counter
        GoHitCounter = GoHitCounter + 1;
        behavorialResponseArray(12, 2) = GoHitCounter;
        %puts a one in this array
        GoTrialPerformance(Trials)= 1;
        %calculates the no go performance
        num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
        %if there is no nogo data then it will be NaN
        if isnan(num)
          %sets num to zero if it is NaN
            num=0;
        end
        %plots the go hit percentage
        scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
        hold on
        %plots the nogo hit percentage
        scatter(Trials,num,'r','filled')
        hold on
        
    elseif mouseResponse == 2
      %adds this to the array
        behavorialResponseArray(6, Trials) = "NoGo Hit";
        %adds one o the nogo hit counter
        NoGoHitCounter = NoGoHitCounter + 1;
        behavorialResponseArray(14, 2) = NoGoHitCounter;
        %adds one to this array
        NoGoTrialPerformance(Trials)=1;
        %calculates the go percentage
        num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
        %if there is no nogo data then it will be NaN
        if isnan(num)
          %sets num to zero if it is NaN
            num=0;
        end
        %plots the go percentage
        scatter(Trials,num,47,'b','filled')
        hold on
        %plots the no go percentage
        scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
        hold on
        
    elseif mouseResponse == 3
      %adds this to the array
        behavorialResponseArray(6, Trials) = "Go Miss";
        %adds one to the go miss counter
        GoMissCounter = GoMissCounter + 1;
        behavorialResponseArray(13, 2) = GoMissCounter;
        %adds negative one to this array
        GoTrialPerformance(Trials)=-1;
        %calculates the no go percentage
        num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
        %if there is no go data then it will be NaN
        if isnan(num)
          %sets num to zero
            num=0;
        end
        %plots the go percentage
        scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
        hold on
        %plots the no go percentage
        scatter(Trials,num,'r','filled')
        hold on
        
    elseif mouseResponse == 4
      %adds this to the array
        behavorialResponseArray(6, Trials) = "NoGo Miss";
        %adds one to the no go miss counter
        NoGoMissCounter = NoGoMissCounter + 1;
        behavorialResponseArray(15, 2) = NoGoMissCounter;
        %adds negative one to this array
        NoGoTrialPerformance(Trials) = -1;
        %calculates the go percentage
        num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
        %if there is no nogo data then it will be NaN
        if isnan(num)
          %sets num to zero
            num=0;
        end
        %pots the go percentage
        scatter(Trials,num,47,'b','filled')
        hold on
        %plots the nogo percentage
        scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
        hold on
    end
end
%creates a legend
legend('Go Trial','NoGo Trial','location','best')
%makes the legend not have a box around it
legend('boxoff')

%writes the number of trials for the file
behavorialResponseArray(17, 1) = "Total number of trials: " +convertCharsToStrings(NumTrials);
%calculates the correct percentage
Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100;
%calculates the incorrect percentage
Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100;
%writes the correct percentage
behavorialResponseArray(19,1)= "Correct Percent: " +convertCharsToStrings(Correctpercentage)+"%";
%writes the incorrect percentage
behavorialResponseArray(20,1)= "Incorrect Percent: " +convertCharsToStrings(Incorrectpercentage)+"%";

%calculates hit rate
pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
%writes pHit into array
behavorialResponseArray(19,2)="pHit="+convertCharsToStrings(pHit);
%calculates the false alarm rate
pFA=NoGoMissCounter/(NoGoMissCounter+NoGoHitCounter);
%writes pFA into array
behavorialResponseArray(20,2)="pFA="+convertCharsToStrings(pFA);
%need this to determine amount of go trials in case pHit=1
nTarget=(GoHitCounter+GoMissCounter);
%need this to determine amount of no go trials in case pFA=1;
nDistract=(NoGoHitCounter+NoGoMissCounter);
%calls the dprime function and calculates the d prime value
[dpri,ccrit] = dprime(pHit,pFA,nTarget,nDistract);
%writes the d prime value into the array
behavorialResponseArray(21,1)="d prime: " +convertCharsToStrings(dpri);


% save the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(FileNameInput)+".xlsx"),'FileType','spreadsheet');

end