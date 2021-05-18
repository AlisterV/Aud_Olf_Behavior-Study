%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function choose_combinedPerf_HDF_Sniff_AV()

%clears all previous data variables
clear all
%closes all previous figures
close all

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

%NameFile= [input('What is the name of the HDF5 file:  ','s') '.h5'];
%FileNameInput = input('What is the name of the HDF5 file: ','s');  % Get the file name without the .hd5 (useful later on when saving excel file.
%NameFile = append(FileNameInput, '.h5');  % combine the two strings so we can find the file.


% Specify the folder where the files live.
%% CHECK BEFORE EACH RUN
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
theFiles = uigetfile(filePattern,'Multiselect','on');

%initalizes a counter for correct percentages from one to the number of
%files selected
percentcorrectcounter = zeros(1,numel(theFiles));
%initalizes a counter for incorrect percentages from one to the number of
%files selected
percentincorrectcounter = zeros(1,numel(theFiles));
%initializes a counter to keep track of all the trials continually through
%every file
alltrialcounter=zeros(1000,1000);
%initializes a counter for the Go Hits
GoHitCounter = 0;
%initializes a counter for the NoGo Hits
NoGoHitCounter = 0;
%initializes a counter for the Go Misses
GoMissCounter = 0;
%initializes a counter for the NoGo Misses
NoGoMissCounter = 0;
%initializes the performance array
performancearray=strings;

%% Starts a loop through all of the selected files
for k = 1 : length(theFiles)
    %starts an array for the behavioral response
    behavorialResponseArray=strings;
    %selects the kth file
    fullFileName = theFiles{k};
    %reads the file and keeps the data in this variable
    Data=h5read(fullFileName,'/Trials');
    %Determines the number of trials for this particular file
    NumTrials = length(Data.trialNumber);
    %Our sampling frequency is 1000Hz.
    Fs = 1000;
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
    %% Begins inputing data to the behavioral array
    behavorialResponseArray(8, 2) = "Go Hit";
    behavorialResponseArray(9, 2) = "Go Miss";
    behavorialResponseArray(10, 2) = "No Go Hit";
    behavorialResponseArray(11, 2) = "No Go Miss";
    
    %initializes the figure for the performance graph
    figure(1)
    %ratio=[2 1 1];
    %pbaspect(ratio)
    %holds onto the graph for all data
    hold on
    %puts a grid on the graph
    grid on
    %makes sure the y axis goes from zero to one hundred by a count of 20
    yticks(0:20:100)
    %titles the performance graph
    title('Performance')
    %creates a yaxis label
    ylabel('Percent Correct')
    %creates an xaxis label
    xlabel('Trial #')

    %% Starts a loop for the specified kth file and loops through each trial
    for Trials = 1:NumTrials
        % Get the animal's response for this trial.
        mouseResponse = Data.response(Trials);
        % labels the mouse response section in the array
        behavorialResponseArray(4, Trials) = "Mouse's behavior";
        % Save the numerical result of this mouses' behavior for the trial.
        behavorialResponseArray(5, Trials) = mouseResponse;
        %keeps track of the number of trials through all files
        alltrialcounter(k,Trials)=1;
        
        %% Translates the behavioral response into words for array
        % if the mouse response is 1 then trial was a Go Hit
        if mouseResponse == 1
            behavorialResponseArray(6, Trials) = "Go Hit";
            %adds one to the array counter for Go Hit
            GoHitCounterarray = GoHitCounterarray +1;
            %adds one to the counter for Go Hit
            GoHitCounter = GoHitCounter + 1;
            %inputs the number of Go Hits so far into the array
            behavorialResponseArray(8, 1) = GoHitCounterarray;
            %calculates the current performance of No Go Trials
            num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
            % if num = NaN the code will not work, this ensures that if
            % that happens then num = 0 so the code will continue
            if isnan(num)
              num=0;
            end
            %sums the all trial counter so the performance graph can keep
            %track of what percent goes with what trial
            xdata=sum(alltrialcounter,'all');
            %creates the performance plot with the current trial number
            %(xdata) and the Go Trial performance; 47 makes the Go Trial
            %data point slightly larger so in the case of overlap, it is
            %obvious that there are two points
            scatter(xdata,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
            %holds onto the graph to plot NoGo Data
            hold on
            %plots NoGo Data
            scatter(xdata,num,'r','filled')
            hold on
            
        % if the mouse response is 2 then trial was a NoGo Hit
        elseif mouseResponse == 2
            behavorialResponseArray(6, Trials) = "NoGo Hit";
            %adds one to the array counter for NoGoHit
            NoGoHitCounterarray = NoGoHitCounterarray +1;
            %adds one to the counter for NoGo Hit
            NoGoHitCounter = NoGoHitCounter + 1;
            %inputs the number of NoGo Hits so far into the array
            behavorialResponseArray(10, 1) = NoGoHitCounterarray;
            %calculates the current performance of Go Trials
            num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
            % if num = NaN the code will not work, this ensures that if
            % that happens then num = 0 so the code will continue
            if isnan(num)
              num=0;
            end
            %sums the all trial counter so the performance graph can keep
            %track of what percent goes with what trial
            xdata=sum(alltrialcounter,'all');
            %creates the performance plot with the current trial number
            %(xdata) and the Go Trial performance; 47 makes the Go Trial
            %data point slightly larger so in the case of overlap, it is
            %obvious that there are two points
            scatter(xdata,num,47,'b','filled')
            %holds onto the graph to plot NoGo Data
            hold on
            %plots NoGo Data
            scatter(xdata,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
            hold on
            
        % if the mouse response is 3 then trial was a Go Miss
        elseif mouseResponse == 3
            behavorialResponseArray(6, Trials) = "Go Miss";
            %adds one to the array counter for Go Miss
            GoMissCounterarray = GoMissCounterarray + 1;
            %adds one to the counter for Go Miss
            GoMissCounter = GoMissCounter + 1;
            %inputs the number of Go Misses so far into the array
            behavorialResponseArray(9, 1) = GoMissCounterarray;
            %calculates the current performance of NoGo Trials
            num=(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100;
            % if num = NaN the code will not work, this ensures that if
            % that happens then num = 0 so the code will continue
            if isnan(num)
              num=0;
            end
            %sums the all trial counter so the performance graph can keep
            %track of what percent goes with what trial
            xdata=sum(alltrialcounter,'all');
            %creates the performance plot with the current trial number
            %(xdata) and the Go Trial performance; 47 makes the Go Trial
            %data point slightly larger so in the case of overlap, it is
            %obvious that there are two points
            scatter(xdata,(GoHitCounter/(GoHitCounter+GoMissCounter))*100,47,'b','filled')
            %holds onto the graph to plot NoGo Data
            hold on
            %plots NoGo Data
            scatter(xdata,num,'r','filled')
            hold on
            
        % if the mouse response is 4 then trial was a NoGo Miss
        elseif mouseResponse == 4
            behavorialResponseArray(6, Trials) = "NoGo Miss";
            %adds one to the counter for NoGo Miss
            NoGoMissCounterarray = NoGoMissCounterarray + 1;
            %adds one to the counter for NoGo Miss
            NoGoMissCounter = NoGoMissCounter + 1;
            %inputs the number of NoGo Misses so far into the array
            behavorialResponseArray(11, 1) = NoGoMissCounterarray;
            %calculates the current performance of Go Trials
            num=(GoHitCounter/(GoHitCounter+GoMissCounter))*100;
            % if num = NaN the code will not work, this ensures that if
            % that happens then num = 0 so the code will continue
            if isnan(num)
              num=0;
            end
            %sums the all trial counter so the performance graph can keep
            %track of what percent goes with what trial
            xdata=sum(alltrialcounter,'all');
            %creates the performance plot with the current trial number
            %(xdata) and the Go Trial performance; 47 makes the Go Trial
            %data point slightly larger so in the case of overlap, it is
            %obvious that there are two points
            scatter(xdata,num,47,'b','filled')
            %holds onto the graph to plot NoGo Data
            hold on
            %plots NoGo Data
            scatter(xdata,(NoGoHitCounter/(NoGoHitCounter+NoGoMissCounter))*100,'r','filled')
            hold on
        end
    end
    
    %totals the number of trials
    behavorialResponseArray(15, 1) = NumTrials;
    behavorialResponseArray(15, 2) = 'Total number of trials';
    %calculates the correct percentage
    Correctpercentage=((GoHitCounterarray + NoGoHitCounterarray)/NumTrials)*100;
    %calculates the incorrect percentage
    Incorrectpercentage=((GoMissCounterarray + NoGoMissCounterarray)/NumTrials)*100;
    %inputs correct percent to the array
    behavorialResponseArray(9,3)= Correctpercentage;
    behavorialResponseArray(9,4)= '% Correct';
    %inputs incorrect percent to the array
    behavorialResponseArray(10,3)= Incorrectpercentage;
    behavorialResponseArray(10,4)= '% Incorrect';
    
    %removes the file extension from the current kth file
    file=erase(fullFileName,'.h5');
    %creates a spreadsheet matrix using the behavioral array for the kth file
    writematrix(behavorialResponseArray,"Interpreted_Data_" + convertCharsToStrings(file)+".xlsx",'FileType','spreadsheet');
    %format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')

    %counts the percent correct for the kth file
    percentcorrectcounter(k)=Correctpercentage;
    %counts the percent incorrect for the kth file
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

%creates a legend for the performance graph, picking the best
%location to put it based on data points
legend('Go Trial','NoGo Trial','location','best')
%does not box the legend
legend('boxoff')
%calculates the percent difference between each subsequent trial (i.e.
%Trial 1 - Trial 0; Trial 2 - Trial 1
%percentdifferencepertrialcorrect = diff(percentcorrectcounter);
%percentdifferencepertrialincorrect = diff(percentincorrectcounter);
%overallperformancetodate_correct=(percentcorrectcounter(numel(theFiles))-percentcorrectcounter(1));
%overallperformancetodate_incorrect=(percentincorrectcounter(numel(theFiles))-percentincorrectcounter(1));
%performancearray = strings;
% performancearray(12,1)='Average Percent Correct';
% performancearray(12,2)= mean(percentcorrectcounter);
% performancearray(13,1)='Average Percent Incorrect';
% performancearray(13,2)= mean(percentincorrectcounter);

avgcorr= mean(percentcorrectcounter);
performancearray(15,1)="Average Percent Correct: " + convertCharsToStrings(avgcorr);
avgincorr=mean(percentincorrectcounter);
performancearray(16,1)="Average Percent Incorrect: " + convertCharsToStrings(avgincorr);
%performancearray(14,2)= mean(percentincorrectcounter);
performancearray(14,1)="Total Number of Trials: " + convertCharsToStrings(xdata);

% performancearray(4,1)= '% Difference per trial (Correct)';
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