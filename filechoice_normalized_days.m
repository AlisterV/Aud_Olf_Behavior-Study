%% Last edit made by Alister Virkler on 6/17/2021
%This function gets called by dprimegraph_alloptions. This code plots
%either all of the files for a certain mouse or allows specific files to be
%selected. The plot contains Percent correct on Go trials, False alarm
%rate, d prime, and total percent correct. Also, the testing day files are
%normalized based on sound level which can be changed (since training days
%are for sound levels 0dB and 80 dB, the testing day percentages and
%dprimes are only calculated using the responses for 0dB and 80dB).
%Groups data by Date/Day

function filechoice_normalized_days()

%% Prompts User
%clears all previous data variables
clear all
%closes all previous figures
close all
%Sets the default folder that Matlab will look into
myFolder = 'C:\VoyeurData';

%prompts the user
answer = questdlg('Would you like: ','Option 3','All Files for mouse','Choose files','All Files for mouse');
%initializes a string array for the performance data
performancearray=strings;

%makes a case for each possible answer from user
switch answer
    %% Case 1: All Files
    %if the user selects 'All Files for Mouse' then matlab will ask the
    %user to input the Mouse# and then procede to select all files with
    %that mouse#
    case 'All Files for mouse'
        %prompts user to inpput mouse#
        mousenum=input('Enter Mouse Number: ', 's');
        %creates an extension that contains the mouse number
        mousexten=append('*',mousenum,'*.h5');
        %creates the file pattern from the folder and extension
        filePattern = fullfile(myFolder,mousexten);
        %goes to the directory and gets all of the files that match the
        %file pattern
        theFiles = dir(filePattern);
        %initializes tiles within a figure
        t = tiledlayout(2,2,'Padding','compact','tilespacing','normal');
        ax1=nexttile(1);
        ax2=nexttile(2);
        ax3=nexttile(3);
        ax4=nexttile(4);
        structrow=0;
        
        %% Organizes the Files
        %turns the Files from a structure into a table
        theFiles=struct2table(theFiles);
        %creates a column cell array vector with the height of the files
        newcolumn=cell(height(theFiles),1);
        %joines the files with the new column and creates that column with variable
        %name 'Date'
        theFiles=[theFiles table(newcolumn,'VariableName',{'Date'})];
        %loops through each file and takes out the date information from the file
        %name string. Turns this string into a date and saves it into the table of
        %files
        for g=1:height(theFiles)
            %takes out everything before 'T' in the name
            before=extractBefore(theFiles(g,1).name,'T');
            %takes out everything after 'D' in the name
            after=extractAfter(before,'D');
            %turns the string into a date
            date=datestr(after,'mm/dd/yyyy');
            %turns the date into a cell
            D=cellstr(date);
            %adds the file date into the table
            theFiles(g,7)=D;
        end
        %sorts the rows of the table by their dates in descending order
        theFiles=sortrows(theFiles,'Date');
        %turns the date column into a string
        dates=string(theFiles.Date);
        %turns the file table back into the structure
        theFiles=table2struct(theFiles);
        %initializes a day counter
        day=0;
        %finds all the different dates within all the files
        [C,ia,ic]=unique(dates);
        
        %% Loops through every File and organizes data by day and then by testing type
        
        %loops through each unique date, groups the data together and then
        %plots it
        for i=1:numel(C)
            %gets the first unique date
            holder=C(i);
            %compares this date with the entire string of dates from each
            %file and makes a logical vector where the dates match
            comp=strcmp(holder,dates);
            %adds one to the day counter
            day=day+1;
            %initializes a counter for the Go Hits
            GoHitCounterarray = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounterarray = 0;
            %initializes a counter for the Go Misses043
            GoMissCounterarray = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounterarray = 0;
            %initializes more counters
            trial080counter=0;
            testcount=0;
            testcounto=0;
            %finds where the compare function is true and gets their
            %postions in that vector
            datepositions=find(comp==1);
            %makes a trial counter
            alltrialcounter=zeros(1,length(datepositions));
            
            %loops through how every many files there are with the same
            %unique date
            for r=1:length(datepositions)
                %gets the file the is linked with the position from before
                fullFileName = string(theFiles(datepositions(r)).name);
                %reads the file into matlab
                Data=h5read(fullFileName,'/Trials');
                %Determines the number of trials for this particular file
                NumTrials = length(Data.trialNumber);
                %adds the number of trials from this file into the counter
                alltrialcounter(r)=NumTrials;
                
                %if the file contains that it is a sound only test session
                %the code continues here
                if contains(fullFileName,'t_')==1
                    %adds one to the sound only test counter
                    testcount=1;
                    %loops through all the trials in this sound only test
                    %file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %gets the session number
                        sessionnum=Data.session(1);
                        %gets the curent trial's sound level
                        soundlevel=Data.sound_level(Trials);
                        
                        %This is what normalizes the test days
                        %if the sound level is either 0dB or 80dB, then the
                        %code will continue to read the mouse response,
                        %otherwise, the code will ignore this trial
                        if soundlevel==0 || soundlevel==80
                            %Translates the behavioral response into words for array
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
                            %makes a trial counter specifically for test
                            %days
                            trial080counter=trial080counter+1;
                        end
                    end
                    
                %if the file contains that it is a sound and odor test session
                %the code continues here
                elseif contains(fullFileName,'to_')==1
                    %adds one to the odor test counter
                    testcounto=1;
                    %loops through all the trials in this sound and odor test
                    %file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %finds the session number
                        sessionnum=Data.session(1);
                        %gets the curent trial's sound level
                        soundlevel=Data.sound_level(Trials);
                        
                        %This is what normalizes the test days
                        %if the sound level is either 0dB or 80dB, then the
                        %code will continue to read the mouse response,
                        %otherwise, the code will ignore this trial
                        if soundlevel==0 || soundlevel==80
                            %Translates the behavioral response into words for array
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
                            %creates a test counter specifically for the
                            %test day
                            trial080counter=trial080counter+1;
                        end
                    end
                
                %if the file is just a training day (no 't_' or 'to_') then
                %the code contunies here
                else
                    %loops through all the trials in this training file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %finds the session number 
                        sessionnum=Data.session(1);
                        %Translates the behavioral response into words for array
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
            end
            
            %% Plots based off testing type
            
            %if the day contained a sound only test day, the code continues here
            if testcount==1
                %resets the counter to be used for the next unique day
                testcount=0;
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter
                scatter(ax1,day,pHit,'s','filled')
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y acis
                ylabel(ax1,'Percentage')
                %makes y tick marks from zero to one by 0.2 
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %makes a title for this graph
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA,'s','filled')
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                % sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %plots a scatter of the dprime
                scatter(ax3,day,dpri,'s','filled')
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over days")
                %holds on to all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                %creates a scatter
                scatter(ax4,day,percorr,'s','filled')
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                % sets the y limits
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all graphs
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            
            %if the day contained a sound and odor test day, the code continues here
            elseif testcounto==1
                %resets the counter to be used for the next unique day
                testcounto=0;
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter ('d' makes the marker a diamond for
                %these specific test types)
                scatter(ax1,day,pHit,'filled','d')
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                % sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA,'filled','d')
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                % sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,day,dpri,'filled','d')
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over days")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                %creates a scatter
                scatter(ax4,day,percorr,'filled','d')
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                % sets the y limits
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all graphs
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            
            %if the day contained a training day, the code continues here
            else
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter
                scatter(ax1,day,pHit)
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA)
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,day,dpri)
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over Days")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                %creates a scatter
                scatter(ax4,day,percorr)
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                %sets the y limits
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all graphs
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            end
            
            %% Adds data to the performance report
            
            %adds mouse number
            performancearray(1,i)="Mouse "+convertCharsToStrings(mousenum);
            %adds day number
            performancearray(2,i)="Day "+convertCharsToStrings(day);
            %adds pHit
            performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
            %adds pFA
            performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
            %adds d prime
            performancearray(5,i)="d'="+convertCharsToStrings(dpri);
            %adds entire percent correct
            performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);

            %creates a criteria for the mouse to see if they performed well
            %enough for that day
            %if the mouse's dprime is greater than 2 and its entire percent
            %correct is above 80
            if dpri>=2 && percorr>=.8
                %mark that the mouse passed that day
                performancearray(7,i)='PASSED';
            %if either case is not met
            elseif dpri<2 || percorr<.8
                %mark that the mouse failed that day
                performancearray(7,i)='FAILED';
            end
        end

        hold(ax3,'on')
        %creates a scatter with the same icon in black as the plotted data
        reg_trial=scatter(1,100,'ok','DisplayName','Regular Trials');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_trial=scatter(1,100,'sk','filled','DisplayName','Sound Only Tests');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_odr_trial=scatter(1,100,'dk','filled','DisplayName','Odor + Sound Tests');
        %makes the legend 
        legend(ax3,[reg_trial snd_trial snd_odr_trial],'location','southoutside')
        %this writes the performance report
        writematrix(performancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
    
        
    %% Case 2: Choose Files
    %if the user selects 'Choose Files for Mouse' then matlab will ask the
    %user to select the desired files
    case 'Choose files'
        %if the user's folder does not exist matlab makes the user choose a
        %folder
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
        %creates a counter
        structrow=0;
        %adds a row to the directory of the files selected
        for x=1:length(theFile)
            structrow=structrow+1;
            theFiles(structrow)=dir(theFile(x));
        end
        %initializes plots
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        
        %% Organizes the Files
        %turns the files from a structure to a table
        theFiles=struct2table(theFiles);
        %creates a column cell array vector with the height of the files
        newcolumn=cell(height(theFiles),1);
        %joines the files with the new column and creates that column with variable
        %name 'Date'
        theFiles=[theFiles table(newcolumn,'VariableName',{'Date'})];
        %loops through each file and takes out the date information from the file
        %name string. Turns this string into a date and saves it into the table of
        %files
        for g=1:height(theFiles)
            %takes out everything before 'T' in the name
            before=extractBefore(theFiles(g,1).name,'T');
            %takes out everything after 'D' in the name
            after=extractAfter(before,'D');
            %turns the string into a date
            date=datestr(after,'mm/dd/yyyy');
            %turns the date into a cell
            D=cellstr(date);
            %adds the file date into the table
            theFiles(g,7)=D;
        end
        %sorts the rows of the table by their dates in descending order
        theFiles=sortrows(theFiles,'Date');
        %turns the date column into a string
        dates=string(theFiles.Date);
        %turns the file table back into the structure
        theFiles=table2struct(theFiles);
        %initializes a day counter
        day=0;
        %finds all the different dates within all the files
        [C,ia,ic]=unique(dates);
        
        %% Loops through every File and organizes data by day and then by testing type
        
        %loops through each unique date, groups the data together and then
        %plots it
        for i=1:numel(C)
            %gets the first unique date
            holder=C(i);
            %compares this date with the entire string of dates from each
            %file and makes a logical vector where the dates match
            comp=strcmp(holder,dates);
            %adds one to the day counter
            day=day+1;
            %initializes a counter for the Go Hits
            GoHitCounterarray = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounterarray = 0;
            %initializes a counter for the Go Misses043
            GoMissCounterarray = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounterarray = 0;
            %initializes test counter
            testcount=0;
            testcounto=0;
            trial080counter=0;
            %finds where the compare function is true and gets their
            %postions in that vector
            datepositions=find(comp==1);
            %creates a trial counter
            alltrialcounter=zeros(1,length(datepositions));
            
            %loops through how every many files there are with the same
            %unique date
            for r=1:length(datepositions)
                %gets the file from the position before
                fullFileName = string(theFiles(datepositions(r)).name);
                %reads the file into matlab
                Data=h5read(fullFileName,'/Trials');
                %Determines the number of trials for this particular file
                NumTrials = length(Data.trialNumber);
                %finds the mouse's ID#
                mousenum=Data.mouse(1:3,1)';
                %adds the number of trials to the counter
                alltrialcounter(r)=NumTrials;
                
                %if the file contains that it is a sound only test session
                %the code continues here
                if contains(fullFileName,'t_')==1
                    %adds one to the sound only test counter
                    testcount=1;
                    %loops through all the trials in this sound only test
                    %file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %gets the curent trial's sound level
                        soundlevel=Data.sound_level(Trials);
                        
                        %This is what normalizes the test days
                        %if the sound level is either 0dB or 80dB, then the
                        %code will continue to read the mouse response,
                        %otherwise, the code will ignore this trial
                        if soundlevel==0 || soundlevel==80
                            %Translates the behavioral response into words for array
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
                            %makes a trial counter specifically for test
                            %days
                            trial080counter=trial080counter+1;
                        end
                    end
                    
                %if the file contains that it is a sound and odor test session
                %the code continues here
                elseif contains(fullFileName,'to_')==1
                    %adds one to the odor test counter
                    testcounto=1;
                    %loops through all the trials in this sound and odor test
                    %file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %gets the current trials sound level
                        soundlevel=Data.sound_level(Trials);
                        
                        %This is what normalizes the test days
                        %if the sound level is either 0dB or 80dB, then the
                        %code will continue to read the mouse response,
                        %otherwise, the code will ignore this trial
                        if soundlevel==0 || soundlevel==80
                            %Translates the behavioral response into words for array
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
                            %makes a trial counter specifically for test
                            %days 
                            trial080counter=trial080counter+1;
                        end
                    end
                    
                %if the file is just a training day (no 't_' or 'to_') then
                %the code contunies here
                else
                    %loops through all the training trials for this file
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %Translates the behavioral response into words for array
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
            end
            
            %% Plots based off testing type
            
            %if the day contained a sound only test day, the code continues here
            if testcount==1
                %resets the counter to be used for the next unique day
                testcount=0;
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter
                scatter(ax1,day,pHit,'filled')
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limit
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA,'filled')
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limit
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA rate
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,day,dpri,'filled')
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over Days")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                %creates a scatter
                scatter(ax4,day,percorr,'filled')
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                %sets the y limits
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all plots
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            
            %if the day contained a sound and odor test day, the code continues here
            elseif testcounto==1
                %resets the counter to be used for the next unique day
                testcounto=0;
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter ('d' makes the marker a diamond to
                %specify these specific test days)
                scatter(ax1,day,pHit,'filled','d')
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA,'filled','d')
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA rate
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,day,dpri,'filled','d')
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over Days")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                %creates a scatter
                scatter(ax4,day,percorr,'filled','d')
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                %sets the y limit
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all plots
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
                
            %if the day contained a training day, the code continues here
            else
                %calculates the percent hit rate
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                %creates a scatter
                scatter(ax1,day,pHit)
                %labels the x axis
                xlabel(ax1,'Day #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %plots the percent false alarm rate
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                %creates a scatter
                scatter(ax2,day,pFA)
                %labels the x axis
                xlabel(ax2,'Day #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounterarray+GoMissCounterarray);
                %calculates the distraction number of pFA rate
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,day,dpri)
                %labels the x axis
                xlabel(ax3,'Day #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over Days")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(sum(alltrialcounter,'all'));
                %creates a scatter
                scatter(ax4,day,percorr)
                %labels the x axis
                xlabel(ax4,'Day #')
                %labels the y axis
                ylabel(ax4,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax4,0:0.2:1)
                %sets the y limits
                ylim(ax4,[0 1])
                %creates a title
                title(ax4,'Total Percent Correct')
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %creates an overall title for all graphs
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            end
            
            %% Adds data to the performance report
            
            %adds mouse number
            performancearray(1,i)="Mouse "+convertCharsToStrings(mousenum);
            %adds day number
            performancearray(2,i)="Day "+convertCharsToStrings(day);
            %adds pHit
            performancearray(3,i)="pHit="+convertCharsToStrings(pHit);
            %add pFA
            performancearray(4,i)="pFA="+convertCharsToStrings(pFA);
            %addsd prime
            performancearray(5,i)="d'="+convertCharsToStrings(dpri);
            %adds entire percent correct
            performancearray(6,i)="% Correct="+convertCharsToStrings(percorr);
            
            %creates a criteria for the mouse to see if they performed well
            %enough for that day
            %if the mouse's dprime is greater than 2 and its entire percent
            %correct is above 80
            if dpri>=2 && percorr>=.8
                %marks if the mouse passed that day
                performancearray(7,i)='PASSED';
            %if either case is not met
            elseif dpri<2 || percorr<.8
                %marks if the mouse failed that day
                performancearray(7,i)='FAILED';
            end
        end
        
        hold(ax3,'on')
        %creates a scatter with the same icon in black as the plotted data
        reg_trial=scatter(1,100,'ok','DisplayName','Regular Trials');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_trial=scatter(1,100,'sk','filled','DisplayName','Sound Only Tests');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_odr_trial=scatter(1,100,'dk','filled','DisplayName','Odor + Sound Tests');
        %makes the legend 
        legend(ax3,[reg_trial snd_trial snd_odr_trial],'location','southoutside')
        %this writes the performance report
        
        writematrix(performancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
end

end