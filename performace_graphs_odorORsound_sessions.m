%% Last edit made by Alister Virkler on 6/17/2021
%This function gets called by dprimegraph_alloptions. This code plots
%either all of the files for a certain mouse or allows specific files to be
%selected. The plot contains Percent correct on Go trials, False alarm
%rate, d prime, and total percent correct. Also, the testing day files are
%normalized based on sound level which can be changed (since training days
%are for sound levels 0dB and 80 dB, the testing day percentages and
%dprimes are only calculated using the responses for 0dB and 80dB).

function performace_graphs_odorORsound_sessions()

%% Prompts USer
%clears all previous data variables
clear all
%closes all previous figures
close all
%Sets the default folder that Matlab will look into
myFolder = 'C:\VoyeurData';

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
ax5=nexttile;
ax6=nexttile;
ax7=nexttile;
ax8=nexttile;
ax9=nexttile;
ax10=nexttile;

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
    
    %initializes a counter for the NoGo Hits
    NoGoHitCounter = 0;
    %initializes a counter for the NoGo Misses
    NoGoMissCounter = 0;
    
    odors = string(Data.odorant');
    valves = string(Data.odorvalve);
    unique_odors = unique(odors);
    unique_valves = unique(valves);
    odor_link = [unique_odors unique_valves];
    stim_block = [Data.sound_level Data.odorvalve];
    
    odor_comp = strcmp(odors, unique_odors(1));
    odor_place = find(odor_comp==1);
    first_odor_index = odor_place(1);
    odor_response = Data.response(first_odor_index);
    
    if odor_response == 1 || odor_response == 3
        odor_go = str2double(unique_valves(1));
    else
        odor_go = str2double(unique_valves(2));
    end
    
    
    sounds = Data.sound_level;
    unique_sounds = unique(sounds);
    if unique_sounds(1) == 0
        sound_comp = Data.sound_level == unique_sounds(2);
        sound_place = find(sound_comp==1);
        first_sound_index = sound_place(1);
        sound_response = Data.response(first_sound_index);
        if sound_response == 1 || sound_response == 3
            sound_go = unique_sounds(2);
        else
            sound_go = unique_sounds(1);
        end
    else
        sound_comp = Data.sound_level == unique_sounds(1);
        sound_place = find(sound_comp==1);
        first_sound_index = sound_place(1);
        sound_response = Data.response(first_sound_index);
        if sound_response == 1 || sound_response == 3
            sound_go = unique_sounds(1);
        else
            sound_go = unique_sounds(2);
        end
    end
    

    
    
    for o = 1:NumTrials
        if stim_block(o,1) == 0
            stim_block(o,1) = stim_block(o,2);
        end
    end
    
    stim_block(:,2) = [];
    
    
    
    gomisscounterodor = 0;
    gohitcounterodor = 0;
    gomisscountersound = 0;
    gohitcountersound = 0;
    
    %loops through all the trials in this training file
    for Trials = 1:NumTrials
        % Get the animal's response for this trial.
        mouseResponse = Data.response(Trials);
        %gets the session number
        sessionnum=Data.session(1);
        %Translates the behavioral response into words for array
        % if the mouse response is 1 then trial was a Go Hit
        if mouseResponse == 1
            if stim_block(Trials) == odor_go
                gohitcounterodor = gohitcounterodor +1;
            elseif stim_block(Trials) == sound_go
                gohitcountersound = gohitcountersound +1;
            end
        elseif mouseResponse == 2
            NoGoHitCounter = NoGoHitCounter +1;
            % if the mouse response is 3 then trial was a Go Miss
        elseif mouseResponse == 3
            if stim_block(Trials) == odor_go
                gomisscounterodor = gomisscounterodor +1;
            elseif stim_block(Trials) == sound_go
                gomisscountersound = gomisscountersound +1;
            end
            % if the mouse response is 4 then trial was a NoGo Miss
        elseif mouseResponse == 4
            %adds one to the counter for NoGo Miss
            NoGoMissCounter = NoGoMissCounter + 1;
        end
    end
    %calculates the percent hit rate
    pHitodor=gohitcounterodor/(gohitcounterodor+gomisscounterodor);
    %creates a scatter
    scatter(ax1,sessionnum,pHitodor)
    %labels the x axis
    xlabel(ax1,'Session #')
    %labels the y axis
    ylabel(ax1,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax1,0:.2:1)
    %sets the y limits
    ylim(ax1,[0 1])
    %creates a title
    title(ax1,'Go Hit Percentage odor')
    
    %calculates the percent hit rate
    pHitsound=gohitcountersound/(gohitcountersound+gomisscountersound);
    %creates a scatter
    scatter(ax2,sessionnum,pHitsound)
    %labels the x axis
    xlabel(ax2,'Session #')
    %labels the y axis
    ylabel(ax2,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax2,0:.2:1)
    %sets the y limits
    ylim(ax2,[0 1])
    %creates a title
    title(ax2,'Go Hit Percentage sound')
    
    %calculates the percent hit rate
    pHit=(gohitcountersound+gohitcounterodor)/(gohitcountersound+gomisscountersound+gohitcounterodor+gomisscounterodor);
    %creates a scatter
    scatter(ax3,sessionnum,pHit)
    %labels the x axis
    xlabel(ax3,'Session #')
    %labels the y axis
    ylabel(ax3,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax3,0:.2:1)
    %sets the y limits
    ylim(ax3,[0 1])
    %creates a title
    title(ax3,'Go Hit Percentage both')
    
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the percent false alarm rate
    pFA=NoGoMissCounter/(NoGoHitCounter+NoGoMissCounter);
    %creates a scatter
    scatter(ax4,sessionnum,pFA)
    %labels the x axis
    xlabel(ax4,'Session #')
    %labels the y axis
    ylabel(ax4,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax4,0:.2:1)
    %sets the y limits
    ylim(ax4,[0 1])
    %creates a title
    title(ax4,'False Alarm Percentage')
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the target number of pHit rate
    nTargetodor= (gohitcounterodor+gomisscounterodor);
    %calculates the distraction number of pFA
    nDistract=(NoGoHitCounter+NoGoMissCounter);
    %calls the dprime function to calculate it
    [dpri]=dprime(pHitodor,pFA,nTargetodor,nDistract);
    %creates a scatter
    scatter(ax5,sessionnum,dpri)
    %labels the x axis
    xlabel(ax5,'Session #')
    %labels the y axis
    ylabel(ax5,"d'")
    %creates a title
    title(ax5,"d' over Sessions odor")
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the target number of pHit rate
    nTargetsound= (gohitcountersound+gomisscountersound);
    %calculates the distraction number of pFA
    nDistract=(NoGoHitCounter+NoGoMissCounter);
    %calls the dprime function to calculate it
    [dpri]=dprime(pHitsound,pFA,nTargetsound,nDistract);
    %creates a scatter
    scatter(ax6,sessionnum,dpri)
    %labels the x axis
    xlabel(ax6,'Session #')
    %labels the y axis
    ylabel(ax6,"d'")
    %creates a title
    title(ax6,"d' over Sessions sound")
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the target number of pHit rate
    nTarget= (gohitcounterodor+gomisscounterodor+gohitcountersound+gomisscountersound);
    %calculates the distraction number of pFA
    nDistract=(NoGoHitCounter+NoGoMissCounter);
    %calls the dprime function to calculate it
    [dpri]=dprime(pHit,pFA,nTarget,nDistract);
    %creates a scatter
    scatter(ax7,sessionnum,dpri)
    %labels the x axis
    xlabel(ax7,'Session #')
    %labels the y axis
    ylabel(ax7,"d'")
    %creates a title
    title(ax7,"d' over Sessions both")
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the entire percent correct
    percorrodor=(gohitcounterodor+NoGoHitCounter)/NumTrials;
    %creates a scatter
    scatter(ax8,sessionnum,percorrodor)
    %labels the x axis
    xlabel(ax8,'Session #')
    %labels the y axis
    ylabel(ax8,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax8,0:0.2:1)
    %sets the y limits
    ylim(ax8,[0 1])
    %creates a title
    title(ax8,'Total Percent Correct odor')
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the entire percent correct
    percorrsound=(gohitcountersound+NoGoHitCounter)/NumTrials;
    %creates a scatter
    scatter(ax9,sessionnum,percorrsound)
    %labels the x axis
    xlabel(ax9,'Session #')
    %labels the y axis
    ylabel(ax9,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax9,0:0.2:1)
    %sets the y limits
    ylim(ax9,[0 1])
    %creates a title
    title(ax9,'Total Percent Correct sound')
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %calculates the entire percent correct
    percorr=(gohitcounterodor+gohitcountersound+NoGoHitCounter)/NumTrials;
    %creates a scatter
    scatter(ax10,sessionnum,percorr)
    %labels the x axis
    xlabel(ax10,'Session #')
    %labels the y axis
    ylabel(ax10,'Percentage')
    %makes the y tick marks from zeros to one by 0.2
    yticks(ax10,0:0.2:1)
    %sets the y limits
    ylim(ax10,[0 1])
    %creates a title
    title(ax10,'Total Percent Correct both')
    %holds onto all plots
    hold([ax1,ax2,ax3,ax4,ax5,ax6,ax7,ax8,ax9,ax10],'on')
    
    %gets the mouse id number
    mousenum=Data.mouse(1:3,1)';
    %creates an overall title for all graphs
    sgtitle("Performance of Mouse "+convertCharsToStrings(mousenum)+" Odor or Sound")
end
end