%% Last edit made by Kyle Mabry on 3/30/2020
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc... 

function HDF_Sniff_AV()

close all;
clear all;
clc;

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

%  NameFile= [input('What is the name of the HDF5 file):  ','s') '.h5'];
FileNameInput = input('What is the name of the HDF5 file: ','s');  % Get the file name without the .hd5 (useful later on when saving excel file.
NameFile = append(FileNameInput, '.h5');  % combine the two strings so we can find the file.
Data =  h5read(NameFile,'/Trials');
% mouse = input("What is the number of this mouse? ");
NumTrials = length(Data.trialNumber); %Determine the number of trials in this experiment in order to get the sniff data later on.
Fs = 1000; %Our sampling frequency is 1000Hz.

%%  Take the behavorial data and output it to a .csv file.
% Get the animal's response time in miliseconds by subtracting their first lick by the odor valve onset.
% for each tiral in the experiment.

for Trials = 1:NumTrials
    % response time is equal to the time of the first lick minus the time
    % of the odor valve onset.
    responseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials));
    % if the response time is negative then just set it equal to zero.
    if responseTime < 0
        responseTime = 0;
    end
    % save the response time into a string array.
    behavorialResponseArray(1,Trials) = "Trial number:  " + Trials;
    behavorialResponseArray(2,Trials) = "Response Time (ms)";
    behavorialResponseArray(3,Trials) = responseTime;
end

% Initialize behavorial response arrays that tally the total number of
% responses of each type to be output into the final excel sheet later on. 
GoHitCounter = 0;
RightHitCounter = 0;
LeftMissCounter = 0;
RightMissCounter = 0;
LeftNoResponseCounter = 0;
RightNoResponseCounter = 0;
% Behavorial response array.
% behavorialResponseArray(8, 2) = "Left hit";
% behavorialResponseArray(9, 2) = "Right hit";
% behavorialResponseArray(10, 2) = "Left miss";
% behavorialResponseArray(11, 2) = "Right miss";
% behavorialResponseArray(12, 2) = "Left no response";
% behavorialResponseArray(13, 2) = "Right no response";
behavorialResponseArray(8, 2) = "Go Hit";
behavorialResponseArray(9, 2) = "Go Miss";
behavorialResponseArray(10, 2) = "No Go Hit";
behavorialResponseArray(11, 2) = "No Go Miss";

% Determine whether behavior of mouse was correct for the given trial.
% 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss
% 5 = Left no response -- 6 = Right no response
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    % Label which trial this is.
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    % Save the numerical result of this mouses' behavorial for the trial.
    behavorialResponseArray(5, Trials) = mouseResponse;
    % Translate the animals response for the trial.
    if mouseResponse == 1
        behavorialResponseArray(6, Trials) = "Left hit";
        GoHitCounter = GoHitCounter + 1;
        behavorialResponseArray(8, 1) = GoHitCounter;
    elseif mouseResponse == 2
        behavorialResponseArray(6, Trials) = "Right hit";
        RightHitCounter = RightHitCounter + 1;
        behavorialResponseArray(9, 1) = RightHitCounter;
    elseif mouseResponse == 3
        behavorialResponseArray(6, Trials) = "Left miss";
        LeftMissCounter = LeftMissCounter + 1;
        behavorialResponseArray(10, 1) = LeftMissCounter;
    elseif mouseResponse == 4
        behavorialResponseArray(6, Trials) = "Right miss";
        RightMissCounter = RightMissCounter + 1;
        behavorialResponseArray(11, 1) = RightMissCounter;
    elseif mouseResponse == 5
        behavorialResponseArray(6, Trials) = "Left no response";
        LeftNoResponseCounter = LeftNoResponseCounter + 1;
        behavorialResponseArray(12, 1) = LeftNoResponseCounter;
    elseif mouseResponse == 6
        behavorialResponseArray(6, Trials) = "Right no response";
        RightNoResponseCounter = RightNoResponseCounter + 1;
        behavorialResponseArray(13, 1) = RightNoResponseCounter;
    end
end

% Also indicate the total number of trials for this training session. 
behavorialResponseArray(15, 1) = NumTrials;
behavorialResponseArray(15, 2) = 'Total number of trials';

% save the response time data and the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(FileNameInput)), 'FileType', 'spreadsheet');
% writematrix(behavorialResponseArray, ("Interpreted Data Mouse " + mouse + " " + datestr(now,'yyyy_mm_dd') + datestr(now)), 'FileType', 'spreadsheet');
%format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')

