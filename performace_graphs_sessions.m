%% Last edit made by Alister Virkler on 6/17/2021
%This function gets called by dprimegraph_alloptions. This code plots
%either all of the files for a certain mouse or allows specific files to be
%selected. The plot contains Percent correct on Go trials, False alarm
%rate, d prime, and total percent correct. Also, the testing day files are
%normalized based on sound level which can be changed (since training days
%are for sound levels 0dB and 80 dB, the testing day percentages and
%dprimes are only calculated using the responses for 0dB and 80dB). 

function performace_graphs_sessions()

%% Prompts USer
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
        %turns the file table back into the structure
        theFiles=table2struct(theFiles);
        for h=1:length(theFiles)
            if strcmp(theFiles(h).Date,'06/30/2021')
                shiftright=extractBefore(theFiles(h).name,'_D');
                shift=extractAfter(shiftright,'sess');
                break
            end
        end
        %initializes the plots
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        
        %% Loops through every File and organizes data by testing type and then plots it
        
        %loops through every file
        for k = 1 :length(theFiles)
            %selects the kth file
            fullFileName = theFiles(k).name;
            %reads the file into matlab
            Data=h5read(fullFileName,'/Trials');
            %Determines the number of trials for this particular file
            NumTrials = length(Data.trialNumber);
            %initializes a counter for the Go Hits
            GoHitCounter = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounter = 0;
            %initializes a counter for the Go Misses
            GoMissCounter = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounter = 0;
            %initializes a trial counter for test files
            trial080counter=0;
            
            %if the file contains that it is a sound only test session
            %the code continues here
            if contains(fullFileName,'t_')==1
                %loops through all the trials in this sound only test
                %file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %finds the session number for this file
                    sessionnum=Data.session(1);
                    %gets the sound level for this trial
                    soundlevel=Data.sound_level(Trials);
                    
                    %This is what normalizes the test days
                    %if the sound level is either 0dB or 80dB, then the
                    %code will continue to read the mouse response,
                    %otherwise, the code will ignore this trial
                    if soundlevel==0 || soundlevel==80
                        %Translates the behavioral response into words for array
                        % if the mouse response is 1 then trial was a Go Hit
                        if mouseResponse == 1
                            %adds one to the counter for Go Hit
                            GoHitCounter = GoHitCounter + 1;
                            % if the mouse response is 2 then trial was a NoGo Hit
                        elseif mouseResponse == 2
                            %adds one to the counter for NoGo Hit
                            NoGoHitCounter = NoGoHitCounter + 1;
                            % if the mouse response is 3 then trial was a Go Miss
                        elseif mouseResponse == 3
                            %adds one to the counter for Go Miss
                            GoMissCounter = GoMissCounter + 1;
                            % if the mouse response is 4 then trial was a NoGo Miss
                        elseif mouseResponse == 4
                            %adds one to the counter for NoGo Miss
                            NoGoMissCounter = NoGoMissCounter + 1;
                        end
                        %makes a trial counter specifically for test
                        %days
                        trial080counter=trial080counter+1;
                    end
                end
                
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter
                scatter(ax1,sessionnum,pHit,'filled')
                %labels the x axis
                xlabel(ax1,'Session #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA,'filled')
                %labels the x axis
                xlabel(ax2,'Session #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri,'filled')
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d' value")
                %creates a title
                title(ax3,"d' over sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/(trial080counter);
                %creates a scatter
                scatter(ax4,sessionnum,percorr,'filled')
                %labels the x axis
                xlabel(ax4,'Session #')
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
                %gets the mouse id number
                mousenum=Data.mouse(1:3,1)';
                %creates an overall title for all graphs
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            
            %if the file contains that it is a sound and odor test session
            %the code continues here
            elseif contains(fullFileName,'to_')==1
                %loops through all the trials in this sound and odor test
                %file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %finds the session number
                    sessionnum=Data.session(1);
                    %gets the currectn sound level for this trial
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
                            GoHitCounter = GoHitCounter +1;
                            % if the mouse response is 2 then trial was a NoGo Hit
                        elseif mouseResponse == 2
                            %adds one to the array counter for NoGoHit
                            NoGoHitCounter = NoGoHitCounter +1;
                            % if the mouse response is 3 then trial was a Go Miss
                        elseif mouseResponse == 3
                            %adds one to the array counter for Go Miss
                            GoMissCounter = GoMissCounter + 1;
                            % if the mouse response is 4 then trial was a NoGo Miss
                        elseif mouseResponse == 4
                            %adds one to the counter for NoGo Miss
                            NoGoMissCounter = NoGoMissCounter + 1;
                        end
                        %creates a test counter specifically for the
                        %test day
                        trial080counter=trial080counter+1;
                    end
                end
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter('d' makes the marker a diamond to
                %specify this test type)
                scatter(ax1,sessionnum,pHit,'filled','d')
                %labels the x axis
                xlabel(ax1,'Session #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA,'filled','d')
                %labels the x axis
                xlabel(ax2,'Session #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri,'filled','d')
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d' value")
                %creates a title
                title(ax3,"d' over sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/(trial080counter);
                %creates a scatter
                scatter(ax4,sessionnum,percorr,'filled','d')
                %labels the x axis
                xlabel(ax4,'Session #')
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
                %gets the mouse id number
                mousenum=Data.mouse(1:3,1)';
                %creates an overall title for all plots
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            
            %if the file is just a training day (no 't_' or 'to_') then
            %the code contunies here
            else
                %loops through all the trials in this training file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %gets the session number
                    sessionnum=Data.session(1);
                    %Translates the behavioral response into words for array
                    % if the mouse response is 1 then trial was a Go Hit
                    if mouseResponse == 1
                        %adds one to the array counter for Go Hit
                        GoHitCounter = GoHitCounter +1;
                        % if the mouse response is 2 then trial was a NoGo Hit
                    elseif mouseResponse == 2
                        %adds one to the array counter for NoGoHit
                        NoGoHitCounter = NoGoHitCounter +1;
                        % if the mouse response is 3 then trial was a Go Miss
                    elseif mouseResponse == 3
                        %adds one to the array counter for Go Miss
                        GoMissCounter = GoMissCounter + 1;
                        % if the mouse response is 4 then trial was a NoGo Miss
                    elseif mouseResponse == 4
                        %adds one to the counter for NoGo Miss
                        NoGoMissCounter = NoGoMissCounter + 1;
                    end
                end
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter
                scatter(ax1,sessionnum,pHit)
                %labels the x axis
                xlabel(ax1,'Session #')
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
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA)
                %labels the x axis
                xlabel(ax2,'Session #')
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
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri)
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/NumTrials;
                %creates a scatter
                scatter(ax4,sessionnum,percorr)
                %labels the x axis
                xlabel(ax4,'Session #')
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
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            end
            %% Adds data to the performance report
            
            %gets the session number
            sessionnum=Data.session(1);
            %adds mouse number
            performancearray(1,k)="Mouse "+convertCharsToStrings(mousenum);
            %adds session number
            performancearray(2,k)="Session "+convertCharsToStrings(sessionnum);
            %adds pHit
            performancearray(3,k)="pHit="+convertCharsToStrings(pHit);
            %adds pFA
            performancearray(4,k)="pFA="+convertCharsToStrings(pFA);
            %adds d prime
            performancearray(5,k)="d'="+convertCharsToStrings(dpri);
            %adds entire percent correct
            performancearray(6,k)="% Correct="+convertCharsToStrings(percorr);
            
            %creates a criteria for the mouse to see if they performed well
            %enough for that session
            %if the mouse's dprime is greater than 2 and its entire percent
            %correct is above 80
            if dpri>=2 && percorr>=.8
                %mark that the mouse passed the session
                performancearray(7,k)='PASSED';
                %if either case is not met
            elseif dpri<2 || percorr<.8
                %mark that the mouse failed the session
                performancearray(7,k)='FAILED';
            end
        end
        %plots the session where the paradigm shift occured
        xline(ax1,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax2,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax3,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax4,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        
        hold(ax3,'on')
        %creates a scatter with the same icon in black as the plotted data
        reg_trial=scatter(1,100,'ok','DisplayName','Regular Trials');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_trial=scatter(1,100,'sk','filled','DisplayName','Sound Only Tests');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_odr_trial=scatter(1,100,'dk','filled','DisplayName','Odor + Sound Tests');
        %creates a line with the same icon in black as the plotted data
        parshift=xline(-1,'--k','DisplayName','Paradigm Shift');
        %makes the legend
        legend(ax3,[reg_trial snd_trial snd_odr_trial parshift],'location','southoutside')

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
        %initializes the plots
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        
        %% Organize the Files
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
        %turns the file table back into the structure
        theFiles=table2struct(theFiles);
        for h=1:length(theFiles)
            if strcmp(theFiles(h).Date,'06/30/2021')
                shiftright=extractBefore(theFiles(h).name,'_D');
                shift=extractAfter(shiftright,'sess');
                break
            end
        end

        %% Loops through every File and organizes data by testing type and then plots it
        
        %loops through every file
        for k = 1 :length(theFiles)
            %selects the kth file
            fullFileName = theFiles(k).name;
            %reads the file into matlab
            Data=h5read(fullFileName,'/Trials');
            %Determines the number of trials for this particular file
            NumTrials = length(Data.trialNumber);
            %initializes a counter for the Go Hits
            GoHitCounter = 0;
            %initializes a counter for the NoGo Hits
            NoGoHitCounter = 0;
            %initializes a counter for the Go Misses
            GoMissCounter = 0;
            %initializes a counter for the NoGo Misses
            NoGoMissCounter = 0;
            %initializes a trial counter for test files
            trial080counter=0;
            
            %if the file contains that it is a sound only test session
            %the code continues here
            if contains(fullFileName,'t_')==1
                %loops through all the trials in this sound only test
                %file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %finds the session number for this file
                    sessionnum=Data.session(1);
                    %gets the sound level for this trial
                    soundlevel=Data.sound_level(Trials);
                    
                    %This is what normalizes the test days
                    %if the sound level is either 0dB or 80dB, then the
                    %code will continue to read the mouse response,
                    %otherwise, the code will ignore this trial
                    if soundlevel==0 || soundlevel==80
                        %Translates the behavioral response into words for array
                        % if the mouse response is 1 then trial was a Go Hit
                        if mouseResponse == 1
                            %adds one to the counter for Go Hit
                            GoHitCounter = GoHitCounter + 1;
                            % if the mouse response is 2 then trial was a NoGo Hit
                        elseif mouseResponse == 2
                            %adds one to the counter for NoGo Hit
                            NoGoHitCounter = NoGoHitCounter + 1;
                            % if the mouse response is 3 then trial was a Go Miss
                        elseif mouseResponse == 3
                            %adds one to the counter for Go Miss
                            GoMissCounter = GoMissCounter + 1;
                            % if the mouse response is 4 then trial was a NoGo Miss
                        elseif mouseResponse == 4
                            %adds one to the counter for NoGo Miss
                            NoGoMissCounter = NoGoMissCounter + 1;
                        end
                        %makes a trial counter specifically for test
                        %days
                        trial080counter=trial080counter+1;
                    end
                end
                
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter
                scatter(ax1,sessionnum,pHit,'filled')
                %labels the x axis
                xlabel(ax1,'Session #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA,'filled')
                %labels the x axis
                xlabel(ax2,'Session #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri,'filled')
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d' value")
                %creates a title
                title(ax3,"d' over sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/(trial080counter);
                %creates a scatter
                scatter(ax4,sessionnum,percorr,'filled')
                %labels the x axis
                xlabel(ax4,'Session #')
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
                %gets the mouse id number
                mousenum=Data.mouse(1:3,1)';
                %creates an overall title for all graphs
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            
            %if the file contains that it is a sound and odor test session
            %the code continues here
            elseif contains(fullFileName,'to_')==1
                %loops through all the trials in this sound and odor test
                %file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %finds the session number
                    sessionnum=Data.session(1);
                    %gets the currectn sound level for this trial
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
                            GoHitCounter = GoHitCounter +1;
                            % if the mouse response is 2 then trial was a NoGo Hit
                        elseif mouseResponse == 2
                            %adds one to the array counter for NoGoHit
                            NoGoHitCounter = NoGoHitCounter +1;
                            % if the mouse response is 3 then trial was a Go Miss
                        elseif mouseResponse == 3
                            %adds one to the array counter for Go Miss
                            GoMissCounter = GoMissCounter + 1;
                            % if the mouse response is 4 then trial was a NoGo Miss
                        elseif mouseResponse == 4
                            %adds one to the counter for NoGo Miss
                            NoGoMissCounter = NoGoMissCounter + 1;
                        end
                        %creates a test counter specifically for the
                        %test day
                        trial080counter=trial080counter+1;
                    end
                end
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter('d' makes the marker a diamond to
                %specify this test type)
                scatter(ax1,sessionnum,pHit,'filled','d')
                %labels the x axis
                xlabel(ax1,'Session #')
                %labels the y axis
                ylabel(ax1,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax1,0:.2:1)
                %sets the y limits
                ylim(ax1,[0 1])
                %creates a title
                title(ax1,'Go Hit Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the percent false alarm rate
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA,'filled','d')
                %labels the x axis
                xlabel(ax2,'Session #')
                %labels the y axis
                ylabel(ax2,'Percentage')
                %makes the y tick marks from zeros to one by 0.2
                yticks(ax2,0:.2:1)
                %sets the y limits
                ylim(ax2,[0 1])
                %creates a title
                title(ax2,'False Alarm Percentage')
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the target number of pHit rate
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it 
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri,'filled','d')
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d' value")
                %creates a title
                title(ax3,"d' over sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/(trial080counter);
                %creates a scatter
                scatter(ax4,sessionnum,percorr,'filled','d')
                %labels the x axis
                xlabel(ax4,'Session #')
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
                %gets the mouse id number
                mousenum=Data.mouse(1:3,1)';
                %creates an overall title for all plots
                sgtitle("Performance for Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            
            %if the file is just a training day (no 't_' or 'to_') then
            %the code contunies here
            else
                %loops through all the trials in this training file
                for Trials = 1:NumTrials
                    % Get the animal's response for this trial.
                    mouseResponse = Data.response(Trials);
                    %gets the session number
                    sessionnum=Data.session(1);
                    %Translates the behavioral response into words for array
                    % if the mouse response is 1 then trial was a Go Hit
                    if mouseResponse == 1
                        %adds one to the array counter for Go Hit
                        GoHitCounter = GoHitCounter +1;
                        % if the mouse response is 2 then trial was a NoGo Hit
                    elseif mouseResponse == 2
                        %adds one to the array counter for NoGoHit
                        NoGoHitCounter = NoGoHitCounter +1;
                        % if the mouse response is 3 then trial was a Go Miss
                    elseif mouseResponse == 3
                        %adds one to the array counter for Go Miss
                        GoMissCounter = GoMissCounter + 1;
                        % if the mouse response is 4 then trial was a NoGo Miss
                    elseif mouseResponse == 4
                        %adds one to the counter for NoGo Miss
                        NoGoMissCounter = NoGoMissCounter + 1;
                    end
                end
                %calculates the percent hit rate
                pHit=GoHitCounter/(GoHitCounter+GoMissCounter);
                %creates a scatter
                scatter(ax1,sessionnum,pHit)
                %labels the x axis
                xlabel(ax1,'Session #')
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
                pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
                %creates a scatter
                scatter(ax2,sessionnum,pFA)
                %labels the x axis
                xlabel(ax2,'Session #')
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
                nTarget=(GoHitCounter+GoMissCounter);
                %calculates the distraction number of pFA
                nDistract=(NoGoHitCounter+NoGoMissCounter);
                %calls the dprime function to calculate it
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                %creates a scatter
                scatter(ax3,sessionnum,dpri)
                %labels the x axis
                xlabel(ax3,'Session #')
                %labels the y axis
                ylabel(ax3,"d'")
                %creates a title
                title(ax3,"d' over Sessions")
                %holds onto all plots
                hold([ax1,ax2,ax3,ax4],'on')
                %calculates the entire percent correct
                percorr=(GoHitCounter+NoGoHitCounter)/NumTrials;
                %creates a scatter
                scatter(ax4,sessionnum,percorr)
                %labels the x axis
                xlabel(ax4,'Session #')
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
                %gets the mouse id number
                mousenum=Data.mouse(1:3,1)';
                %creates an overall title for all graphs
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Sessions")
            end
            
            %% Adds data to the performance report
            
            %gets the session number
            sessionnum=Data.session(1);
            %adds mouse number
            performancearray(1,k)="Mouse "+convertCharsToStrings(mousenum);
            %adds session number
            performancearray(2,k)="Session "+convertCharsToStrings(sessionnum);
            %adds pHit
            performancearray(3,k)="pHit="+convertCharsToStrings(pHit);
            %adds pFA
            performancearray(4,k)="pFA="+convertCharsToStrings(pFA);
            %adds d prime
            performancearray(5,k)="d'="+convertCharsToStrings(dpri);
            %adds entire percent correct
            performancearray(6,k)="% Correct="+convertCharsToStrings(percorr);
            
            %creates a criteria for the mouse to see if they performed well
            %enough for that session
            %if the mouse's dprime is greater than 2 and its entire percent
            %correct is above 80
            if dpri>=2 && percorr>=.8
                %mark that the mouse passed the session
                performancearray(7,k)='PASSED';
                %if either case is not met
            elseif dpri<2 || percorr<.8
                %mark that the mouse failed the session
                performancearray(7,k)='FAILED';
            end
        end
        %plots the session where the paradigm shift occured
        xline(ax1,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax2,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax3,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        xline(ax4,str2double(shift),'--r')%'DisplayName',"Paradigm Shift",'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
        
        hold(ax3,'on')
        %creates a scatter with the same icon in black as the plotted data
        reg_trial=scatter(1,100,'ok','DisplayName','Regular Trials');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_trial=scatter(1,100,'sk','filled','DisplayName','Sound Only Tests');
        hold on
        %creates a scatter with the same icon in black as the plotted data
        snd_odr_trial=scatter(1,100,'dk','filled','DisplayName','Odor + Sound Tests');
        %creates a line with the same icon in black as the plotted data
        parshift=xline(-1,'--k','DisplayName','Paradigm Shift');
        %makes the legend 
        legend(ax3,[reg_trial snd_trial snd_odr_trial parshift],'location','southoutside')

        %this writes the performance report
        writematrix(performancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
end

end