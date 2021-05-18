%% Last edit made by Kyle Mabry on 3/30/2020
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc... 

function allfiles_HDF_Sniff_AV()

clear all
close all

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

%NameFile= [input('What is the name of the HDF5 file:  ','s') '.h5'];
%FileNameInput = input('What is the name of the HDF5 file: ','s');  % Get the file name without the .hd5 (useful later on when saving excel file.
%NameFile = append(FileNameInput, '.h5');  % combine the two strings so we can find the file.


% Specify the folder where the files live.
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

% Get a list of all files in the folder with the desired file name pattern.
mousenum=input('Enter Mouse Number: ', 's');
mousexten=append('*',mousenum,'*.h5');
filePattern = fullfile(myFolder,mousexten); % Change to whatever pattern you need.
theFiles = dir(filePattern);
percentcorrectcounter = zeros(1,numel(theFiles));
percentincorrectcounter = zeros(1,numel(theFiles));
% percentdifferencepertrialcorrect = zeros(1,numel(theFiles));
% percentdifferencepertrialincorrect = zeros(1,numel(theFiles));
alltrialcounter=zeros(100,100);
GoHitCounter = 0;
NoGoHitCounter = 0;
GoMissCounter = 0;
NoGoMissCounter = 0;
performancearray=strings;
for k = 1 : length(theFiles)
    behavorialResponseArray=strings;
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    %fprintf(1, 'Now reading %s\n', fullFileName);
    % Now do whatever you want with this file name,
    % such as reading it in as an image array with imread()
    Data=h5read(fullFileName,'/Trials');

    %Data =  h5read(NameFile,'/Trials');
    % mouse = input("What is the number of this mouse? ");
    NumTrials = length(Data.trialNumber); %Determine the number of trials in this experiment in order to get the sniff data later on.
    Fs = 1000; %Our sampling frequency is 1000Hz.
    %initializes a counter for the Go Hits
    GoHitCounterarray = 0;
    %initializes a counter for the NoGo Hits
    NoGoHitCounterarray = 0;
    %initializes a counter for the Go Misses
    GoMissCounterarray = 0;
    %initializes a counter for the NoGo Misses
    NoGoMissCounterarray = 0;
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
%     GoHitCounter = 0;
%     NoGoHitCounter = 0;
%     GoMissCounter = 0;
%     NoGoMissCounter = 0;
    behavorialResponseArray(8, 2) = "Go Hit";
    behavorialResponseArray(9, 2) = "Go Miss";
    behavorialResponseArray(10, 2) = "No Go Hit";
    behavorialResponseArray(11, 2) = "No Go Miss";
    
    figure(1)
    %ratio=[2 1 1];
    %pbaspect(ratio)
    hold on
    grid on
    yticks(0:20:100)
    title('Performance')
    ylabel('Percent Correct')
    xlabel('Trial #')

    for Trials = 1:NumTrials
        % Get the animal's response for this trial.
        mouseResponse = Data.response(Trials);
        % Label which trial this is.
        behavorialResponseArray(4, Trials) = "Mouse's behavior";
        % Save the numerical result of this mouses' behavorial for the trial.
        behavorialResponseArray(5, Trials) = mouseResponse;
        % Translate the animals response for the trial.
        alltrialcounter(k,Trials)=1;
        if mouseResponse == 1
            behavorialResponseArray(6, Trials) = "Go Hit";
            %adds one to the array counter for Go Hit
            GoHitCounterarray = GoHitCounterarray +1;
            %adds one to the counter for Go Hit
            GoHitCounter = GoHitCounter + 1;
            behavorialResponseArray(8, 1) = GoHitCounterarray;
            num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
            if isnan(num)
              num=0;
            end
            xdata=sum(alltrialcounter,'all');
            scatter(xdata,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
            hold on
            scatter(xdata,num,'r','filled')
            hold on
        elseif mouseResponse == 2
            behavorialResponseArray(6, Trials) = "NoGo Hit";
            %adds one to the array counter for NoGoHit
            NoGoHitCounterarray = NoGoHitCounterarray +1;
            %adds one to the counter for NoGo Hit
            NoGoHitCounter = NoGoHitCounter + 1;
            behavorialResponseArray(10, 1) = NoGoHitCounterarray;
            num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
            if isnan(num)
              num=0;
            end
            xdata=sum(alltrialcounter,'all');
            scatter(xdata,num,47,'b','filled')
            hold on
            scatter(xdata,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
            hold on
        elseif mouseResponse == 3
            behavorialResponseArray(6, Trials) = "Go Miss";
            %adds one to the array counter for Go Miss
            GoMissCounterarray = GoMissCounterarray + 1;
            %adds one to the counter for Go Miss
            GoMissCounter = GoMissCounter + 1;
            behavorialResponseArray(9, 1) = GoMissCounterarray;
            num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
            if isnan(num)
              num=0;
            end
            xdata=sum(alltrialcounter,'all');
            scatter(xdata,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
            hold on
            scatter(xdata,num,'r','filled')
            hold on
        elseif mouseResponse == 4
            behavorialResponseArray(6, Trials) = "NoGo Miss";
            %adds one to the counter for NoGo Miss
            NoGoMissCounterarray = NoGoMissCounterarray + 1;
            %adds one to the counter for NoGo Miss
            NoGoMissCounter = NoGoMissCounter + 1;
            behavorialResponseArray(11, 1) = NoGoMissCounterarray;
            num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
            if isnan(num)
              num=0;
            end
            xdata=sum(alltrialcounter,'all');
            scatter(xdata,num,47,'b','filled')
            hold on
            scatter(xdata,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
            hold on
        end
    end
% Also indicate the total number of trials for this training session. 
    behavorialResponseArray(15, 1) = NumTrials;
    behavorialResponseArray(15, 2) = 'Total number of trials';
    Correctpercentage=((GoHitCounterarray + NoGoHitCounterarray)/NumTrials)*100;
    Incorrectpercentage=((GoMissCounterarray + NoGoMissCounterarray)/NumTrials)*100;
    behavorialResponseArray(9,3)= Correctpercentage;
    behavorialResponseArray(9,4)= '% Correct';
    behavorialResponseArray(10,3)= Incorrectpercentage;
    behavorialResponseArray(10,4)= '% Incorrect';
    
    %file=erase(baseFileName,'.h5');
% save the response time data and the behavorial response data to an excel file.
    %Allfilenames={theFiles.name};
    %for r=1:numel(theFiles)
     %   writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(file)),'FileType','spreadsheet','Sheet',Allfilenames{r});
    %end
    file=erase(baseFileName,'.h5');
    writematrix(behavorialResponseArray,"Interpreted_Data_" + convertCharsToStrings(file)+".xlsx",'FileType','spreadsheet');
    
    % writematrix(behavorialResponseArray, ("Interpreted Data Mouse " + mouse + " " + datestr(now,'yyyy_mm_dd') + datestr(now)), 'FileType', 'spreadsheet');
%format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')

    %GoHitCounter
    %NoGoHitCounter
    %GoMissCounter
    %NoGoMissCounter
%     Correctpercentage=((GoHitCounter + NoGoHitCounter)/NumTrials)*100;
%     Incorrectpercentage=((GoMissCounter + NoGoMissCounter)/NumTrials)*100;
    percentcorrectcounter(k)=Correctpercentage;
    percentincorrectcounter(k)=Incorrectpercentage;
    mousenum=Data.mouse(1:3,1)';
    performancearray(1,k)="Mouse: " +convertCharsToStrings(mousenum);
    sessionnum=Data.session(1);
    performancearray(2,k)="Session # " +convertCharsToStrings(sessionnum);
    performancearray(3,k)="# of Trials: " +convertCharsToStrings(NumTrials);
    performancearray(5,k)="Trial Responses";
    performancearray(6,k)="Go Hits: " + convertCharsToStrings(GoHitCounterarray);
    performancearray(7,k)="NoGo Hits: " + convertCharsToStrings(NoGoHitCounterarray);
    performancearray(8,k)="Go Misses: " + convertCharsToStrings(GoMissCounterarray);
    performancearray(9,k)="NoGo Misses: " + convertCharsToStrings(NoGoMissCounterarray);
    performancearray(10,k)= "Correct Percent = "+convertCharsToStrings(percentcorrectcounter(k));
    performancearray(11,k)= "Incorrect Percent = "+convertCharsToStrings(percentincorrectcounter(k));
    performancearray(12,k)="d prime: "; %PUT IN VARIABLE HERE (calculate above)

end
legend('Go Trial','NoGo Trial','location','best')
legend('boxoff')
%percentdifferencepertrialcorrect = diff(percentcorrectcounter);
%percentdifferencepertrialincorrect = diff(percentincorrectcounter);
%overallperformancetodate_correct=(percentcorrectcounter(numel(theFiles))-percentcorrectcounter(1));
%overallperformancetodate_incorrect=(percentincorrectcounter(numel(theFiles))-percentincorrectcounter(1));
%performancearray = strings;
avgcorr= mean(percentcorrectcounter);
performancearray(15,1)="Average Percent Correct: " + convertCharsToStrings(avgcorr);
avgincorr=mean(percentincorrectcounter);
performancearray(16,1)="Average Percent Incorrect: " + convertCharsToStrings(avgincorr);
%performancearray(14,2)= mean(percentincorrectcounter);
performancearray(14,1)="Total Number of Trials: " + convertCharsToStrings(xdata);

%performancearray(4,1)= '% Difference per trial (Correct)';
% u= numel(theFiles)-1;
% for n=1:u
%     percorr=percentdifferencepertrialcorrect(n);
%     performancearray(4+n,1)=percorr;
% end
% 
% performancearray(4,2)= '% Difference per trial (Incorrect)';
% for t=1:u
%     perincorr=percentdifferencepertrialincorrect(t);
%     performancearray(4+t,2)=perincorr;
% end
% performancearray(1,4)= 'Overall Correct Performance Change to Date';
% performancearray(1,5)= overallperformancetodate_correct;
% performancearray(2,4)= 'Overall Incorrect Performance Change to Date';
% performancearray(2,5)= overallperformancetodate_incorrect;

writematrix(performancearray,("Interpreted_Performance_Data"),'FileType','spreadsheet');
% plot(percentcorrectcounter,'b')
% hold on
% plot(percentincorrectcounter,'r')
% grid on
% ylabel('Performance Percent')
% xlabel('Trial #')
% ylim([0 100]);
% legend('Percent Correct','Percent Incorrect')



