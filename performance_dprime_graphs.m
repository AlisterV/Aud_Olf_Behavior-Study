%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function performance_dprime_graphs()

%clears all previous data variables
clear all
%closes all previous figures
close all

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

%NameFile= [input('What is the name of the HDF5 file:  ','s') '.h5'];
%FileNameInput = input('What is the name of the HDF5 file: ','s');  % Get the file name without the .hd5 (useful later on when saving excel file.
%NameFile = append(FileNameInput, '.h5');  % combine the two strings so we can find the file.
myFolder = 'C:\VoyeurData';
%prompts the user
answer = questdlg('Would you like: ','Option','All Files for mouse','Choose files','All Files for mouse');
% takes user response and changes into a value for the following if
% statement, switches the variable 'answer' from yes/no to 1/2 respectively
performancearray=strings;
switch answer
    case 'All Files for mouse'
        mousenum=input('Enter Mouse Number: ', 's');
        mousexten=append('*',mousenum,'*.h5');
        filePattern = fullfile(myFolder,mousexten); % Change to whatever pattern you need.
        theFiles = dir(filePattern);
        %theFiles=allFiles.name(:,:);
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
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        for k = 1 : length(theFiles)
            %selects the kth file
            %fullFileName = theFiles.name(k);
            %reads the file and keeps the data in this variable
            fullFileName = theFiles(k).name;
            %fullFileName = fullfile(theFiles(k).folder, baseFileName);
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
           

            %% Starts a loop for the specified kth file and loops through each trial
            for Trials = 1:NumTrials
                % Get the animal's response for this trial.
                mouseResponse = Data.response(Trials);
                %keeps track of the number of trials through all files
                alltrialcounter(k,Trials)=1;
                sessionnum=Data.session(1);

                %% Translates the behavioral response into words for array
                % if the mouse response is 1 then trial was a Go Hit
                if mouseResponse == 1
                    %adds one to the array counter for Go Hit
                    GoHitCounterarray = GoHitCounterarray +1;
                    %adds one to the counter for Go Hit
                    GoHitCounter = GoHitCounter + 1;
                % if the mouse response is 2 then trial was a NoGo Hit
                elseif mouseResponse == 2
                    %adds one to the array counter for NoGoHit
                    NoGoHitCounterarray = NoGoHitCounterarray +1;
                    %adds one to the counter for NoGo Hit
                    NoGoHitCounter = NoGoHitCounter + 1;

                % if the mouse response is 3 then trial was a Go Miss
                elseif mouseResponse == 3
                    %adds one to the array counter for Go Miss
                    GoMissCounterarray = GoMissCounterarray + 1;
                    %adds one to the counter for Go Miss
                    GoMissCounter = GoMissCounter + 1;

                % if the mouse response is 4 then trial was a NoGo Miss
                elseif mouseResponse == 4
                    %adds one to the counter for NoGo Miss
                    NoGoMissCounterarray = NoGoMissCounterarray + 1;
                    %adds one to the counter for NoGo Miss
                    NoGoMissCounter = NoGoMissCounter + 1;
                end
            end
            pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
            scatter(ax1,sessionnum,pHit)
            xlabel(ax1,'Session #')
            ylabel(ax1,'Percentage')
            yticks(ax1,0:.2:1)
            ylim(ax1,[0 1])
            title(ax1,'Go Hit Percentage')
            hold([ax1,ax2,ax3,ax4],'on')
            pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
            scatter(ax2,sessionnum,pFA)
            xlabel(ax2,'Session #')
            ylabel(ax2,'Percentage')
            yticks(ax2,0:.2:1)
            ylim(ax2,[0 1])
            title(ax2,'False Alarm Percentage')
            hold([ax1,ax2,ax3,ax4],'on')
            nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
            nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
            [dpri]=dprime(pHit,pFA,nTarget,nDistract);
            scatter(ax3,sessionnum,dpri)
            xlabel(ax3,'Session #')
            ylabel(ax3,"d'")
            title(ax3,"d' over sessions")
            hold([ax1,ax2,ax3,ax4],'on')
            percorr=(GoHitCounterarray+NoGoHitCounterarray)/(NumTrials);
            scatter(ax4,sessionnum,percorr)
            xlabel(ax4,'Session #')
            ylabel(ax4,'Percentage')
            yticks(ax4,0:0.2:1)
            ylim(ax4,[0 1])
            title(ax4,'Total Percent Correct')
            hold([ax1,ax2,ax3,ax4],'on')
            sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum))
            sessionnum=Data.session(1);
            performancearray(1,k)="Mouse "+convertCharsToStrings(mousenum);
            performancearray(2,k)="Session "+convertCharsToStrings(sessionnum);
            performancearray(3,k)="pHit="+convertCharsToStrings(pHit);
            performancearray(4,k)="pFA="+convertCharsToStrings(pFA);
            performancearray(5,k)="d'="+convertCharsToStrings(dpri);
            performancearray(6,k)="% Correct="+convertCharsToStrings(percorr);
%             if pHit-pFA >= .5 && dpri>=2
%                 performancearray(6,k)='PASSED';
%             elseif pHit-pFA <= .5 || dpri<=2
%                 performancearray(6,k)='FAIL';
%             end
            if dpri>=2 && percorr>=.8
                performancearray(7,k)='PASSED';
            elseif dpri<2 || percorr<.8
                performancearray(7,k)='FAILED';
            end
            writematrix(performancearray,"Performance Data_AllFiles.xlsx",'FileType','spreadsheet')
        end
    case 'Choose files'
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
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        for k = 1 : length(theFiles)
            %selects the kth file
            fullFileName = theFiles{k};
            %reads the file and keeps the data in this variable
            %baseFileName = theFiles(k).name;
            %fullFileName = fullfile(theFiles(k).folder, baseFileName);
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

            %% Starts a loop for the specified kth file and loops through each trial
            for Trials = 1:NumTrials
                % Get the animal's response for this trial.
                mouseResponse = Data.response(Trials);
                %keeps track of the number of trials through all files
                alltrialcounter(k,Trials)=1;
                sessionnum=Data.session(1);

                %% Translates the behavioral response into words for array
                % if the mouse response is 1 then trial was a Go Hit
                if mouseResponse == 1
                    %adds one to the array counter for Go Hit
                    GoHitCounterarray = GoHitCounterarray +1;
                    %adds one to the counter for Go Hit
                    GoHitCounter = GoHitCounter + 1;
                % if the mouse response is 2 then trial was a NoGo Hit
                elseif mouseResponse == 2
                    %adds one to the array counter for NoGoHit
                    NoGoHitCounterarray = NoGoHitCounterarray +1;
                    %adds one to the counter for NoGo Hit
                    NoGoHitCounter = NoGoHitCounter + 1;

                % if the mouse response is 3 then trial was a Go Miss
                elseif mouseResponse == 3
                    %adds one to the array counter for Go Miss
                    GoMissCounterarray = GoMissCounterarray + 1;
                    %adds one to the counter for Go Miss
                    GoMissCounter = GoMissCounter + 1;

                % if the mouse response is 4 then trial was a NoGo Miss
                elseif mouseResponse == 4
                    %adds one to the counter for NoGo Miss
                    NoGoMissCounterarray = NoGoMissCounterarray + 1;
                    %adds one to the counter for NoGo Miss
                    NoGoMissCounter = NoGoMissCounter + 1;
                end
            end
            pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
            scatter(ax1,sessionnum,pHit)
            xlabel(ax1,'Session #')
            ylabel(ax1,'Percentage')
            yticks(ax1,0:.2:1)
            ylim(ax1,[0 1])
            title(ax1,'Go Hit Percentage')
            hold([ax1,ax2,ax3],'on')
            pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
            scatter(ax2,sessionnum,pFA)
            xlabel(ax2,'Session #')
            ylabel(ax2,'Percentage')
            yticks(ax2,0:.2:1)
            ylim(ax2,[0 1])
            title(ax2,'False Alarm Percentage')
            hold([ax1,ax2,ax3],'on')
            nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
            nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
            [dpri]=dprime(pHit,pFA,nTarget,nDistract);
            scatter(ax3,sessionnum,dpri)
            xlabel(ax3,'Session #')
            ylabel(ax3,"d' value")
            title(ax3,"d' over sessions")
            hold([ax1,ax2,ax3],'on')
            percorr=(GoHitCounterarray+NoGoHitCounterarray)/(NumTrials);
            scatter(ax4,sessionnum,percorr)
            xlabel(ax4,'Session #')
            ylabel(ax4,'Percentage')
            yticks(ax4,0:0.2:1)
            ylim(ax4,[0 1])
            title(ax4,'Total Percent Correct')
            hold([ax1,ax2,ax3,ax4],'on')
            mousenum=Data.mouse(1:3,1)';
            sgtitle("Performance")
            sessionnum=Data.session(1);
            performancearray(1,k)="Mouse "+convertCharsToStrings(mousenum);
            performancearray(2,k)="Session "+convertCharsToStrings(sessionnum);
            performancearray(3,k)="pHit="+convertCharsToStrings(pHit);
            performancearray(4,k)="pFA="+convertCharsToStrings(pFA);
            performancearray(5,k)="d'="+convertCharsToStrings(dpri);
            performancearray(6,k)="% Correct="+convertCharsToStrings(percorr);
%             if pHit-pFA >= .5 && dpri>=2
%                 performancearray(6,k)='PASSED';
%             elseif pHit-pFA <= .5 || dpri<=2
%                 performancearray(6,k)='FAIL';
%             end
            if dpri>=2 && percorr>=.8
                performancearray(7,k)='PASSED';
            elseif dpri<2 || percorr<.8
                performancearray(7,k)='FAILED';
            end
            writematrix(newperformancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
        end
end
