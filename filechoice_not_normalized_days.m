%% Last edit made by Alister Virkler on 5/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc...
% In addition, the code recreates the performance data graph from the
% python GUI to visualize the percent correct Go and NoGo Trials. Also, it
% creates an overall performance data sheet for easier analysis.

function filechoice_not_normalized_days()

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
answer = questdlg('Would you like: ','Option 3','All Files for mouse','Choose files','All Files for mouse');
% takes user response and changes into a value for the following if
% statement, switches the variable 'answer' from yes/no to 1/2 respectively
performancearray=strings;
switch answer
    case 'All Files for mouse'
        mousenum=input('Enter Mouse Number: ', 's');
        mousexten=append('*',mousenum,'*.h5');
        filePattern = fullfile(myFolder,mousexten); % Change to whatever pattern you need.
        theFiles = dir(filePattern);
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        theFiles=struct2table(theFiles);
        theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
        theFiles=sortrows(theFiles,'datenum');
        datenum=string(theFiles.datenum);
        day=0;
        %G=findgroups(cellstr(datenum));
        %theFiles=addvars(theFiles,G);
        %maxgroup=max(G);
        %theFiles=table2struct(theFiles);
        %attach the group number into the table and make it into a struct, then say
        %if the group numbers are equal go through???
        [C,ia,ic]=unique(datenum);
        for i=1:numel(C)
            holder=C(i);
            comp=strcmp(holder,datenum);
            day=day+1;
            %initializes a counter for the Go Hits
            GoHitCounterarray = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounterarray = 0;
            %initializes a counter for the Go Misses043
            GoMissCounterarray = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounterarray = 0;
            %if comp==1
            datepositions=find(comp==1);
            alltrialcounter=zeros(1,length(datepositions));
            for r=1:length(datepositions)
                fullFileName = string(theFiles.name(datepositions(r)));
                %fullFileName = fullfile(theFiles(k).folder, baseFileName);
                Data=h5read(fullFileName,'/Trials');
                %Determines the number of trials for this particular file
                NumTrials = length(Data.trialNumber);
                %Our sampling frequency is 1000Hz.
                Fs = 1000;
                alltrialcounter(r)=NumTrials;
                %% Starts a loop for the specified kth file and loops through each trial
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %keeps track of the number of trials through all files
                    %alltrialcounter(r,Trials)=1;
                    sessionnum=Data.session(1);
                    
                    %% Translates the behavioral response into words for array
                    % if the mouse response is 1 then trial was a Go Hit
                    if mouseResponse == 1
                        %adds one to the array counter for Go Hit
                        GoHitCounterarray = GoHitCounterarray +1;
                        % if the mouse response is 2 then trial was a NoGo Hit
                    elseif mouseResponse == 2
                        %adds one to the array counter for NoGoHit
                        NoGoHitCounterarray = NoGoHitCounterarray +1;
                        % if the mouse response is 3 then trial was a Go Miss
                    elseif mouseResponse == 3
                        %adds one to the array counter for Go Miss
                        GoMissCounterarray = GoMissCounterarray + 1;
                        % if the mouse response is 4 then trial was a NoGo Miss
                    elseif mouseResponse == 4
                        %adds one to the counter for NoGo Miss
                        NoGoMissCounterarray = NoGoMissCounterarray + 1;
                    end
                end
                
            end
            if contains(fullFileName,'t')==1
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit,'filled')
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA,'filled')
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri,'filled')
                xlabel(ax3,'Day #')
                ylabel(ax3,"d'")
                title(ax3,"d' over Days")
                hold([ax1,ax2,ax3,ax4],'on')
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                scatter(ax4,day,percorr,'filled')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum))
                sessionnum=Data.session(1);
                performancearray(1,i)="Mouse "+convertCharsToStrings(mousenum);
                performancearray(2,i)="Day "+convertCharsToStrings(day);
                performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
                performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
                performancearray(5,i)="d'="+convertCharsToStrings(dpri);
                performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);
                if dpri>=2 && percorr>=.8
                    performancearray(7,i)='PASSED';
                elseif dpri<2 || percorr<.8
                    performancearray(7,i)='FAILED';
                end
            else
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit)
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA)
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri)
                xlabel(ax3,'Days #')
                ylabel(ax3,"d'")
                title(ax3,"d' over Days")
                hold([ax1,ax2,ax3,ax4],'on')
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                scatter(ax4,day,percorr)
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum))
                sessionnum=Data.session(1);
                performancearray(1,i)="Mouse "+convertCharsToStrings(mousenum);
                performancearray(2,i)="Day "+convertCharsToStrings(day);
                performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
                performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
                performancearray(5,i)="d'="+convertCharsToStrings(dpri);
                performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);
                %             if pHit-pFA >= .5 && dpri>=2
                %                 performancearray(6,k)='PASSED';
                %             elseif pHit-pFA <= .5 || dpri<=2
                %                 performancearray(6,k)='FAIL';
                %             end
                if dpri>=2 && percorr>=.8
                    performancearray(7,i)='PASSED';
                elseif dpri<2 || percorr<.8
                    performancearray(7,i)='FAILED';
                end
            end
        end
        writematrix(performancearray,"Performance Data_AllFiles.xlsx",'FileType','spreadsheet')
        
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
        theFile =string(uigetfile(filePattern,'Multiselect','on'));
        %initializes a counter to keep track of all the trials continually through
        %every file
        structrow=0;
        for x=1:length(theFile)
            structrow=structrow+1;
            theFiles(structrow)=dir(theFile(x));
        end
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        theFiles=struct2table(theFiles);
        theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
        theFiles=sortrows(theFiles,'datenum');
        datenum=string(theFiles.datenum);
        day=0;
        %G=findgroups(cellstr(datenum));
        %theFiles=addvars(theFiles,G);
        %maxgroup=max(G);
        %theFiles=table2struct(theFiles);
        %attach the group number into the table and make it into a struct, then say
        %if the group numbers are equal go through???
        [C,ia,ic]=unique(datenum);
        for i=1:numel(C)
            holder=C(i);
            comp=strcmp(holder,datenum);
            day=day+1;
            %initializes a counter for the Go Hits
            GoHitCounterarray = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounterarray = 0;
            %initializes a counter for the Go Misses043
            GoMissCounterarray = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounterarray = 0;
            %if comp==1
            datepositions=find(comp==1);
            alltrialcounter=zeros(1,length(datepositions));
            for r=1:length(datepositions)
                fullFileName = string(theFiles.name(datepositions(r)));
                %fullFileName = fullfile(theFiles(k).folder, baseFileName);
                Data=h5read(fullFileName,'/Trials');
                %Determines the number of trials for this particular file
                NumTrials = length(Data.trialNumber);
                %Our sampling frequency is 1000Hz.
                Fs = 1000;
                alltrialcounter(r)=NumTrials;
                %% Starts a loop for the specified kth file and loops through each trial
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %keeps track of the number of trials through all files
                    %alltrialcounter(r,Trials)=1;
                    sessionnum=Data.session(1);
                    
                    %% Translates the behavioral response into words for array
                    % if the mouse response is 1 then trial was a Go Hit
                    if mouseResponse == 1
                        %adds one to the array counter for Go Hit
                        GoHitCounterarray = GoHitCounterarray +1;
                        % if the mouse response is 2 then trial was a NoGo Hit
                    elseif mouseResponse == 2
                        %adds one to the array counter for NoGoHit
                        NoGoHitCounterarray = NoGoHitCounterarray +1;
                        % if the mouse response is 3 then trial was a Go Miss
                    elseif mouseResponse == 3
                        %adds one to the array counter for Go Miss
                        GoMissCounterarray = GoMissCounterarray + 1;
                        % if the mouse response is 4 then trial was a NoGo Miss
                    elseif mouseResponse == 4
                        %adds one to the counter for NoGo Miss
                        NoGoMissCounterarray = NoGoMissCounterarray + 1;
                    end
                end
                
            end
            if contains(fullFileName,'t')==1
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit,'filled')
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA,'filled')
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri,'filled')
                xlabel(ax3,'Day #')
                ylabel(ax3,"d'")
                title(ax3,"d' over Days")
                hold([ax1,ax2,ax3,ax4],'on')
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                scatter(ax4,day,percorr,'filled')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance for Mouse ")%+convertCharsToStrings(mousenum))
                sessionnum=Data.session(1);
                performancearray(1,i)="Mouse ";%+convertCharsToStrings(mousenum);
                performancearray(2,i)="Day "+convertCharsToStrings(day);
                performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
                performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
                performancearray(5,i)="d'="+convertCharsToStrings(dpri);
                performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);
                if dpri>=2 && percorr>=.8
                    performancearray(7,i)='PASSED';
                elseif dpri<2 || percorr<.8
                    performancearray(7,i)='FAILED';
                end
            else
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit)
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA)
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri)
                xlabel(ax3,'Days #')
                ylabel(ax3,"d'")
                title(ax3,"d' over Days")
                hold([ax1,ax2,ax3,ax4],'on')
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                scatter(ax4,day,percorr)
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance for Mouse")%+convertCharsToStrings(mousenum))
                sessionnum=Data.session(1);
                performancearray(1,i)="Mouse ";%+convertCharsToStrings(mousenum);
                performancearray(2,i)="Day "+convertCharsToStrings(day);
                performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
                performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
                performancearray(5,i)="d'="+convertCharsToStrings(dpri);
                performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);
                %             if pHit-pFA >= .5 && dpri>=2
                %                 performancearray(6,k)='PASSED';
                %             elseif pHit-pFA <= .5 || dpri<=2
                %                 performancearray(6,k)='FAIL';
                %             end
                if dpri>=2 && percorr>=.8
                    performancearray(7,i)='PASSED';
                elseif dpri<2 || percorr<.8
                    performancearray(7,i)='FAILED';
                end
            end
        end
        writematrix(performancearray,"Performance Data_AllFiles.xlsx",'FileType','spreadsheet')
end