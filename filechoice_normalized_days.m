%% Last edit made by Alister Virkler on 6/17/2021
%This function gets called by dprimegraph_alloptions. This code plots
%either all of the files for a certain mouse or allows specific files to be
%selected. The plot contains Percent correct on Go trials, False alarm
%rate, d prime, and total percent correct. Also, the testing day files are
%normalized based on sound level which can be changed (since training days
%are for sound levels 0dB and 80 dB, the testing day percentages and
%dprimes are only calculated using the responses for 0dB and 80dB).

function filechoice_normalized_days()

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
        ax1=nexttile;
        ax2=nexttile;
        ax3=nexttile;
        ax4=nexttile;
        %
        theFiles=struct2table(theFiles);
        theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
        theFiles=sortrows(theFiles,'datenum');
        %theFiles=table2struct(theFiles);
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
            trial080counter=0;
            testcount=0;
            testcounto=0;
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
                if contains(fullFileName,'t_')==1
                    testcount=1;
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %keeps track of the number of trials through all files
                        %alltrialcounter(r,Trials)=1;
                        sessionnum=Data.session(1);
                        soundlevel=Data.sound_level(Trials);
                        if soundlevel==0 || soundlevel==80
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
                            trial080counter=trial080counter+1;
                        end
                    end
                elseif contains(fullFileName,'to_')==1
                    testcounto=1;
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %keeps track of the number of trials through all files
                        %alltrialcounter(r,Trials)=1;
                        sessionnum=Data.session(1);
                        soundlevel=Data.sound_level(Trials);
                        if soundlevel==0 || soundlevel==80
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
                            trial080counter=trial080counter+1;
                        end
                    end
                else
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
            end
            if testcount==1
                testcount=0;
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
                title(ax3,"d' over days")
                hold([ax1,ax2,ax3,ax4],'on')
                
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                scatter(ax4,day,percorr,'filled')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            elseif testcounto==1
                testcounto=0;
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit,'filled','d')
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA,'filled','d')
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri,'filled','d')
                xlabel(ax3,'Day #')
                ylabel(ax3,"d'")
                title(ax3,"d' over days")
                hold([ax1,ax2,ax3,ax4],'on')
                
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                scatter(ax4,day,percorr,'filled','d')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
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
                xlabel(ax3,'Day #')
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
                sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" with Normalized Test Days")
            end
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
        writematrix(performancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
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
            testcount=0;
            testcounto=0;
            %if comp==1
            datepositions=find(comp==1);
            alltrialcounter=zeros(1,length(datepositions));
            trial080counter=0;
            for r=1:length(datepositions)
                fullFileName = string(theFiles.name(datepositions(r)));
                %fullFileName = fullfile(theFiles(k).folder, baseFileName);
                Data=h5read(fullFileName,'/Trials');
                %Determines the number of trials for this particular file
                NumTrials = length(Data.trialNumber);
                %Our sampling frequency is 1000Hz.
                Fs = 1000;
                alltrialcounter(r)=NumTrials;
                if contains(fullFileName,'t_')==1
                    testcount=1;
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %keeps track of the number of trials through all files
                        %alltrialcounter(r,Trials)=1;
                        sessionnum=Data.session(1);
                        soundlevel=Data.sound_level(Trials);
                        if soundlevel==0 || soundlevel==80
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
                            trial080counter=trial080counter+1;
                        end
                    end
                elseif contains(fullFileName,'to_')==1
                    testcounto=1;
                    for Trials = 1:NumTrials
                        % Get the animal's response for this trial.
                        mouseResponse = Data.response(Trials);
                        %keeps track of the number of trials through all files
                        %alltrialcounter(r,Trials)=1;
                        sessionnum=Data.session(1);
                        soundlevel=Data.sound_level(Trials);
                        if soundlevel==0 || soundlevel==80
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
                            trial080counter=trial080counter+1;
                        end
                    end
                else
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
            end
            if testcount==1
                testcount=0;
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
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                scatter(ax4,day,percorr,'filled')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance with Normalized Test Days")
            elseif testcounto==1
                testcounto=0;
                pHit=GoHitCounterarray/(GoHitCounterarray+GoMissCounterarray);
                scatter(ax1,day,pHit,'filled','d')
                xlabel(ax1,'Day #')
                ylabel(ax1,'Percentage')
                yticks(ax1,0:.2:1)
                ylim(ax1,[0 1])
                title(ax1,'Go Hit Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                pFA=NoGoMissCounterarray/(NoGoHitCounterarray+NoGoMissCounterarray);
                scatter(ax2,day,pFA,'filled','d')
                xlabel(ax2,'Day #')
                ylabel(ax2,'Percentage')
                yticks(ax2,0:.2:1)
                ylim(ax2,[0 1])
                title(ax2,'False Alarm Percentage')
                hold([ax1,ax2,ax3,ax4],'on')
                nTarget=(GoHitCounterarray+GoMissCounterarray); %not sure if this means the number of trials in to tla of that it is based on
                nDistract=(NoGoHitCounterarray+NoGoMissCounterarray);
                [dpri]=dprime(pHit,pFA,nTarget,nDistract);
                scatter(ax3,day,dpri,'filled','d')
                xlabel(ax3,'Day #')
                ylabel(ax3,"d'")
                title(ax3,"d' over Days")
                hold([ax1,ax2,ax3,ax4],'on')
                percorr=(GoHitCounterarray+NoGoHitCounterarray)/(trial080counter);
                scatter(ax4,day,percorr,'filled','d')
                xlabel(ax4,'Day #')
                ylabel(ax4,'Percentage')
                yticks(ax4,0:0.2:1)
                ylim(ax4,[0 1])
                title(ax4,'Total Percent Correct')
                hold([ax1,ax2,ax3,ax4],'on')
                sgtitle("Performance with Normalized Test Days")
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
                xlabel(ax3,'day #')
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
                sgtitle("Performance with Normalized Test Days")
            end
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
        
        writematrix(performancearray,"Performance Data_ChosenFiles.xlsx",'FileType','spreadsheet')
        
end

end