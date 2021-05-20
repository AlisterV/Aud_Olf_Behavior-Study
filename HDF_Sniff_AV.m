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
title('Performance')
ylabel('Percent Correct')
xlabel('Trial #')
% correctpercenttracker=zeros(1,NumTrials);
% incorrectpercenttracker=zeros(1,NumTrials);
% corper=zeros(1,NumTrials);
% passcounter=0;
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    soundlevel = Data.sound_level(Trials);
    odorvalve=Data.odorvalve(Trials);
    % Label which trial this is.
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    behavorialResponseArray(7,Trials)= "Sound Level";
    behavorialResponseArray(8,Trials)=soundlevel;
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
% nTarget=NumTrials;
% nDistract=NumTrials;
[dpri,ccrit] = dprime(pHit,pFA,nTarget,nDistract);
behavorialResponseArray(21,1)="d prime: " +convertCharsToStrings(dpri); %PUT IN VARIABLE HERE (calculate above)
%behavorialResponseArray(17,2)=convertCharsToStrings(dpri);

file=erase(FileNameInput,'.h5');
% save the response time data and the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(file)+".xlsx"),'FileType','spreadsheet');




% GoTrialPerformance=zeros(1,NumTrials);
% NoGoTrialPerformance=zeros(1,NumTrials);
% GoHitCounter = 0;
% NoGoHitCounter = 0;
% GoMissCounter = 0;
% NoGoMissCounter = 0;

% figure(1)
% ratio=[2 1 1];
% pbaspect(ratio)
% hold on
% grid on
% yticks(0:20:100)
% xlim([1 NumTrials])
% title('Performance')
% ylabel('Percent Correct')
% xlabel('Trial #')
% correctpercenttracker=zeros(1,NumTrials);
% incorrectpercenttracker=zeros(1,NumTrials);
% corper=zeros(1,NumTrials);
% passcounter=0;
% for Trials = 1:NumTrials
%     % Get the animal's response for this trial.
%     mouseResponse = Data.response(Trials);
%     soundlevel = Data.sound_level(Trials);
%     if soundlevel == 0
%         c0=c0+1;
%         if mouseresponse == 1
%             gohhitcounter0=gohitcounter0+1;
%         elseif mouseresponse == 2
%             noghitcounter0=nogohitcounter+1
%     % Label which trial this is.
%     behavorialResponseArray(4, Trials) = "Mouse's behavior";
%     behavorialResponseArray(7,Trials)= "Sound Level";
%     behavorialResponseArray(8,Trials)=soundlevel;
%     behavorialResponseArray(9,Trials)='Odor Valve';
%     behavorialResponseArray(10,Trials)=odorvalve;
%     % Save the numerical result of this mouses' behavorial for the trial.
%     behavorialResponseArray(5, Trials) = mouseResponse;
%     % Translate the animals response for the trial.
%     if mouseResponse == 1
%         behavorialResponseArray(6, Trials) = "Go Hit";
%         GoHitCounter = GoHitCounter + 1;
%         behavorialResponseArray(12, 2) = GoHitCounter;
% %         correctpercenttracker(Trials)=1;
% %         incorrectpercenttracker(Trials)=0;
%         GoTrialPerformance(Trials)= 1;
%         num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
%         if isnan(num)
%             num=0;
%         end
%         scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
%         hold on
%         scatter(Trials,num,'r','filled')
%         hold on
%     elseif mouseResponse == 2
%         behavorialResponseArray(6, Trials) = "NoGo Hit";
%         NoGoHitCounter = NoGoHitCounter + 1;
%         behavorialResponseArray(14, 2) = NoGoHitCounter;
% %         correctpercenttracker(Trials)=1;
% %         incorrectpercenttracker(Trials)=0;
%         NoGoTrialPerformance(Trials)=1;
%         num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
%         if isnan(num)
%             num=0;
%         end
%         scatter(Trials,num,47,'b','filled')
%         hold on
%         scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
%         hold on
%         
%     elseif mouseResponse == 3
%         behavorialResponseArray(6, Trials) = "Go Miss";
%         GoMissCounter = GoMissCounter + 1;
%         behavorialResponseArray(13, 2) = GoMissCounter;
% %         correctpercenttracker(Trials)=0;
% %         incorrectpercenttracker(Trials)=1;
%         GoTrialPerformance(Trials)=-1;
%         num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
%         if isnan(num)
%             num=0;
%         end
%         scatter(Trials,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
%         hold on
%         scatter(Trials,num,'r','filled')
%         hold on
%     elseif mouseResponse == 4
%         behavorialResponseArray(6, Trials) = "NoGo Miss";
%         NoGoMissCounter = NoGoMissCounter + 1;
%         behavorialResponseArray(15, 2) = NoGoMissCounter;
% %         correctpercenttracker(Trials)=0;
% %         incorrectpercenttracker(Trials)=1;
%         NoGoTrialPerformance(Trials) = -1;
%         num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
%         if isnan(num)
%             num=0;
%         end
%         scatter(Trials,num,47,'b','filled')
%         hold on
%         scatter(Trials,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
%         hold on
%     end
% end
% 
% % sl0=0;
% % sl80=0;
% % for x=1:NumTrials
% %     soundlevel = Data.sound_level(x);
% %     if soundlevel == 0
% %         sl0=sl0+1;
% %     elseif soundlevel == 80
% %         sl80=sl80+1;
% %     end
% % end
% % sl80plot=sl80/NumTrials;
% % sl0plot=sl0/NumTrials;
% % 
% % bar(80,sl80plot)
% % hold on
% % bar(0,sl0plot)
% % xlabel('Sound Levels')
% % ylabel('Percent Correct')
%     %writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(fullFileName)), 'FileType', 'spreadsheet');
%     
%     % writematrix(behavorialResponseArray, ("Interpreted Data Mouse " + mouse + " " + datestr(now,'yyyy_mm_dd') + datestr(now)), 'FileType', 'spreadsheet');
% %format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')
% 
% % GoHitCounter
% % NoGoHitCounter
% % GoMissCounter
% % NoGoMissCounter
% % 
% % Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100
% % Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100
% 
% % perc=zeros(1,NumTrials);
% % perct=zeros(1,NumTrials);
% %  for u = 1:NumTrials
% %      tracker=correctpercenttracker(u);
% %       if tracker == 1
% %           holder= sum(correctpercenttracker(1:u));
% %           perc(u)=holder/u;
% %       elseif tracker == 0
% %           invert= ~correctpercenttracker;
% %           holder2=sum(invert(1:u));
% %           perct(u)=holder2/u;
% %       end
% %  end
% % %  
% %  for i=1:NumTrials
% %      if GoTrialPerformance(i) == 0 && i > 1
% %          GoPerf(i)=GoTrialPerformance(i);
% %          GoTrialPerformance(i)= [];
% %          i=i-1;
% %      elseif GoTrialPerformance(i) == 1
% %         holder=sum(GoTrialPerformance(1:i));
% %         GoPerf(i)=holder/i;
% %      elseif GoTrialPerformance(i) == -1
% %          GoTrialPerformance(i)= 0;         
% %      end
% %      if i==1 && GoTrialPerformance(i) == 0
% %          GoPerf(i)=GoTrialPerformance(i);
% %          GoTrialPerformance(i)= [];
% %          i=0;
% %      end
% % 
% %  end
% %  
% %   for k=1:NumTrials
% %      if perct(i) == 0
% %          perct(i)=perct(i-1);
% %      elseif perct(i) == 1
% %      end
% %  end
%          
% %  figure(1)
% %  a=nonzeros(perc)'*100;
% %  plot(a,'b')
% %  hold on
% %  b=nonzeros(perct)'*100;
% %  plot(b,'r')
% %  ylim([0 100])
% %  grid on
% %  title('Aligned Percentage Correct/Incorrect')
% %  legend('Correct Perecntage','Incorrect Percentage')
% %  
% %  hold off
% %  
% %  figure(2)
% %  plot(perc*100,'b')
% %  hold on
% %  plot(perct*100,'r')
% %  ylim([0 100])
% %  grid on
% %  title('Percent Correct/Incorrect For Current Trial')
% %  legend('Correct Percentage','Incorrect Percentage')
