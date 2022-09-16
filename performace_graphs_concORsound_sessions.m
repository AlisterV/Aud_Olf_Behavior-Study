%% Last edit made by Alister Virkler on 9/16/2022
%Shows performance graphs for training on concentration OR sound (percent
%correct, hit rate, FA, d_prime, etc.)

function performace_graphs_concORsound_sessions()

%% Initializes Files and organizes them 
%clears all previous data variables
clear all
%closes all previous figures
close all
%specifies the folder
myFolder = 'C:\VoyeurData';

%This can be uncommented to allow the user to input the desired sound
%levels
%answer=inputdlg('Enter Sound Levels Used: ');
%x=str2num(answer{1});

%hard coded sound level
%x=[0 50 55 60 65 70];

%allows user to choose folder if current folder is not found
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
%initializes a counter
structrow=0;
%if there is more than one file selected
if length(theFile)>1
  %loops through the length of the files and adds a row each time
  for m=1:length(theFile)
    structrow=structrow+1;
    theFiles(structrow)=dir(theFile(m));
  end
  %if there is only one file selected
else
  theFiles(1)=dir(theFile(1));
end
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

%% Loops through every File and organizes data by testing type and then plots it

% gohitarray_odor = zeros(length(theFiles));
% gohitarray_sound = zeros(length(theFiles));
% gomissarray_odor = zeros(length(theFiles));
% gomissarray_sound = zeros(length(theFiles));

%loops through every file
for k = 1 :length(theFiles)
    %selects the kth file
    fullFileName = theFiles(k).name;
    %reads the file into matlab
    Data=h5read(fullFileName,'/Trials');
    %Determines the number of trials for this particular file
    NumTrials = length(Data.trialNumber);
    
    gohitcounter_odor = 0;
    gomisscounter_odor = 0;
    gohitcounter_sound = 0;
    gomisscounter_sound = 0;
    nogohitcounter = 0;
    nogomisscounter = 0;

    Data.concentration = []';
    odors = string(Data.odorant');
    for g = 1:length(Data.trialNumber)
        conc_str = extractAfter(odors(g),'_');
        conc1 = str2double(conc_str);
        if isnan(conc1)
            conc1 = 0;
        end
        flows = [Data.air_flow(g) Data.nitrogen_flow(g)];
        conc2 = flows(2)/(flows(1)+flows(2));
        conc = conc1*conc2;
        Data.concentration(g) = conc;
    end
    Data.concentration = Data.concentration';
    
    conc = Data.concentration;
    snd = Data.sound_level;
    
    %loops through all the trials in this training file
    for Trials = 1:NumTrials
        % Get the animal's response for this trial.
        mouseResponse = Data.response(Trials);
        %gets the session number
        sessionnum=Data.session(1);
        %Translates the behavioral response into words for array
        % if the mouse response is 1 then trial was a Go Hit
        if mouseResponse == 1
            
            if conc(Trials)>0 && snd(Trials)==0
                gohitcounter_odor = gohitcounter_odor +1;
            elseif conc(Trials)==0 && snd(Trials)>0
                gohitcounter_sound = gohitcounter_sound +1;
            end
            
        elseif mouseResponse == 2
                
            nogohitcounter = nogohitcounter +1;
            
            % if the mouse response is 3 then trial was a Go Miss
        elseif mouseResponse == 3
            
            if conc(Trials)>0 && snd(Trials)==0
                gomisscounter_odor = gomisscounter_odor +1;
            elseif conc(Trials)==0 && snd(Trials)>0
                gomisscounter_sound = gomisscounter_sound +1;
            end
            
            % if the mouse response is 4 then trial was a NoGo Miss
        elseif mouseResponse == 4
            
            %adds one to the counter for NoGo Miss
            nogomisscounter = nogomisscounter + 1;
            
        end
        
    end
    %calculates the percent hit rate
    pHitodor=gohitcounter_odor/(gohitcounter_odor+gomisscounter_odor);
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
    pHitsound=gohitcounter_sound/(gohitcounter_sound+gomisscounter_sound);
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
    pHit=(gohitcounter_sound+gohitcounter_odor)/(gohitcounter_sound+gomisscounter_sound+gohitcounter_odor+gomisscounter_odor);
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
    pFA=nogomisscounter/(nogomisscounter+nogohitcounter);
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
    nTargetodor= (gohitcounter_odor+gomisscounter_odor);
    %calculates the distraction number of pFA
    nDistract=(nogohitcounter+nogomisscounter);
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
    nTargetsound= (gohitcounter_sound+gomisscounter_sound);
    %calculates the distraction number of pFA
    nDistract=(nogohitcounter+nogomisscounter);
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
    nTarget= (gohitcounter_odor+gomisscounter_odor+gohitcounter_sound+gomisscounter_sound);
    %calculates the distraction number of pFA
    nDistract=(nogohitcounter+nogomisscounter);
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
    percorrodor=(gohitcounter_odor+nogohitcounter)/NumTrials;
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
    percorrsound=(gohitcounter_sound+nogohitcounter)/NumTrials;
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
    percorr=(gohitcounter_odor+gohitcounter_sound+nogohitcounter)/NumTrials;
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