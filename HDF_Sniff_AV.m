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

%NameFile= [input('What is the name of the HDF5 file:  ','s') '.h5'];
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
    behavorialResponseArray(1,Trials) = "Trial # " + Trials;
    behavorialResponseArray(2,Trials) = "Response Time (ms)";
    behavorialResponseArray(3,Trials) = responseTime;
end

% Initialize behavorial response arrays that tally the total number of
% responses of each type to be output into the final excel sheet later on. 
% GoHitCounter = 0;
% RightHitCounter = 0;
% LeftMissCounter = 0;
% RightMissCounter = 0;
% LeftNoResponseCounter = 0;
% RightNoResponseCounter = 0;
% % Behavorial response array.
% % behavorialResponseArray(8, 2) = "Left hit";
% % behavorialResponseArray(9, 2) = "Right hit";
% % behavorialResponseArray(10, 2) = "Left miss";
% % behavorialResponseArray(11, 2) = "Right miss";
% % behavorialResponseArray(12, 2) = "Left no response";
% % behavorialResponseArray(13, 2) = "Right no response";
% behavorialResponseArray(8, 2) = "Go Hit";
% behavorialResponseArray(9, 2) = "Go Miss";
% behavorialResponseArray(10, 2) = "No Go Hit";
% behavorialResponseArray(11, 2) = "No Go Miss";

% Determine whether behavior of mouse was correct for the given trial.
% 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss
% 5 = Left no response -- 6 = Right no response
% for Trials = 1:NumTrials
%     % Get the animal's response for this trial.
%     mouseResponse = Data.response(Trials);
%     % Label which trial this is.
%     behavorialResponseArray(4, Trials) = "Mouse's behavior";
%     % Save the numerical result of this mouses' behavorial for the trial.
%     behavorialResponseArray(5, Trials) = mouseResponse;
%     % Translate the animals response for the trial.
%     if mouseResponse == 1
%         behavorialResponseArray(6, Trials) = "Go Hit";
%         GoHitCounter = GoHitCounter + 1;
%         behavorialResponseArray(8, 1) = GoHitCounter;
%     elseif mouseResponse == 2
%         behavorialResponseArray(6, Trials) = "Right hit";
%         RightHitCounter = RightHitCounter + 1;
%         behavorialResponseArray(9, 1) = RightHitCounter;
%     elseif mouseResponse == 3
%         behavorialResponseArray(6, Trials) = "Left miss";
%         LeftMissCounter = LeftMissCounter + 1;
%         behavorialResponseArray(10, 1) = LeftMissCounter;
%     elseif mouseResponse == 4
%         behavorialResponseArray(6, Trials) = "Right miss";
%         RightMissCounter = RightMissCounter + 1;
%         behavorialResponseArray(11, 1) = RightMissCounter;
%     elseif mouseResponse == 5
%         behavorialResponseArray(6, Trials) = "Left no response";
%         LeftNoResponseCounter = LeftNoResponseCounter + 1;
%         behavorialResponseArray(12, 1) = LeftNoResponseCounter;
%     elseif mouseResponse == 6
%         behavorialResponseArray(6, Trials) = "Right no response";
%         RightNoResponseCounter = RightNoResponseCounter + 1;
%         behavorialResponseArray(13, 1) = RightNoResponseCounter;
%     end
% end
GoHitCounter = 0;
GoTrialPerformance=zeros(1,NumTrials);
NoGoTrialPerformance=zeros(1,NumTrials);
NoGoHitCounter = 0;
GoMissCounter = 0;
NoGoMissCounter = 0;
%LeftNoResponseCounter = 0;
%RightNoResponseCounter = 0;
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


figure(1)
ratio=[2 1 1];
pbaspect(ratio)
hold on
grid on
yticks(0:20:100)
xlim([1 NumTrials])
title('Performance')
ylabel('Percent Correct')
xlabel('Trial #')
% correctpercenttracker=zeros(1,NumTrials);
% incorrectpercenttracker=zeros(1,NumTrials);
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    % Label which trial this is.
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    % Save the numerical result of this mouses' behavorial for the trial.
    behavorialResponseArray(5, Trials) = mouseResponse;
    % Translate the animals response for the trial.
    if mouseResponse == 1
        behavorialResponseArray(6, Trials) = "Go Hit";
        GoHitCounter = GoHitCounter + 1;
        behavorialResponseArray(8, 1) = GoHitCounter;
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
        behavorialResponseArray(10, 1) = NoGoHitCounter;
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
        behavorialResponseArray(9, 1) = GoMissCounter;
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
        behavorialResponseArray(11, 1) = NoGoMissCounter;
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
%     elseif mouseResponse == 5
%         behavorialResponseArray(6, Trials) = "Left no response";
%         LeftNoResponseCounter = LeftNoResponseCounter + 1;
%         behavorialResponseArray(12, 1) = LeftNoResponseCounter;
%     elseif mouseResponse == 6
%         behavorialResponseArray(6, Trials) = "Right no response";
%         RightNoResponseCounter = RightNoResponseCounter + 1;
%         behavorialResponseArray(13, 1) = RightNoResponseCounter;
    end
    legend('Go Trial','NoGo Trial','location','best')
    legend('boxoff')
end
% Also indicate the total number of trials for this training session. 
behavorialResponseArray(13, 1) = NumTrials;
behavorialResponseArray(13, 2) = 'Total number of trials';
Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100;
Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100;
behavorialResponseArray(9,3)= Correctpercentage;
behavorialResponseArray(9,4)= '% Correct';
behavorialResponseArray(10,3)= Incorrectpercentage;
behavorialResponseArray(10,4)= '% Incorrect';

% save the response time data and the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(FileNameInput)),'FileType','spreadsheet','Sheet',FileNameInput);


% AllGoPerf=nonzeros(GoTrialPerformance);
% AllNoGoPerf=nonzeros(NoGoTrialPerformance);


GoPerf=zeros(1,NumTrials);
% for u=1:NumTrials
%     holder=sum(GoTrialPerformance(1:u));
%     GoPerf(u)=holder/u;
% end
% 
% NoGoPerf=zeros(1,NumTrials);
% for u=1:NumTrials
%     holder2=sum(NoGoTrialPerformance(1:u));
%     NoGoPerf(u)=holder2/u;
% end

% plot(GoPerf,'b')
% hold on
% plot(NoGoPerf,'r')
    %writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(fullFileName)), 'FileType', 'spreadsheet');
    
    % writematrix(behavorialResponseArray, ("Interpreted Data Mouse " + mouse + " " + datestr(now,'yyyy_mm_dd') + datestr(now)), 'FileType', 'spreadsheet');
%format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')

% GoHitCounter
% NoGoHitCounter
% GoMissCounter
% NoGoMissCounter
% 
% Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100
% Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100

% perc=zeros(1,NumTrials);
% perct=zeros(1,NumTrials);
%  for u = 1:NumTrials
%      tracker=correctpercenttracker(u);
%       if tracker == 1
%           holder= sum(correctpercenttracker(1:u));
%           perc(u)=holder/u;
%       elseif tracker == 0
%           invert= ~correctpercenttracker;
%           holder2=sum(invert(1:u));
%           perct(u)=holder2/u;
%       end
%  end
% %  
%  for i=1:NumTrials
%      if GoTrialPerformance(i) == 0 && i > 1
%          GoPerf(i)=GoTrialPerformance(i);
%          GoTrialPerformance(i)= [];
%          i=i-1;
%      elseif GoTrialPerformance(i) == 1
%         holder=sum(GoTrialPerformance(1:i));
%         GoPerf(i)=holder/i;
%      elseif GoTrialPerformance(i) == -1
%          GoTrialPerformance(i)= 0;         
%      end
%      if i==1 && GoTrialPerformance(i) == 0
%          GoPerf(i)=GoTrialPerformance(i);
%          GoTrialPerformance(i)= [];
%          i=0;
%      end
% 
%  end
%  
%   for k=1:NumTrials
%      if perct(i) == 0
%          perct(i)=perct(i-1);
%      elseif perct(i) == 1
%      end
%  end
         
%  figure(1)
%  a=nonzeros(perc)'*100;
%  plot(a,'b')
%  hold on
%  b=nonzeros(perct)'*100;
%  plot(b,'r')
%  ylim([0 100])
%  grid on
%  title('Aligned Percentage Correct/Incorrect')
%  legend('Correct Perecntage','Incorrect Percentage')
%  
%  hold off
%  
%  figure(2)
%  plot(perc*100,'b')
%  hold on
%  plot(perct*100,'r')
%  ylim([0 100])
%  grid on
%  title('Percent Correct/Incorrect For Current Trial')
%  legend('Correct Percentage','Incorrect Percentage')
