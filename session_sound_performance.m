%% Last edit made by Alister Virkler on 6/17/2021
%This code shows theperformance for the Go/NoGo behavioral task based on sound levels.
%It takes in a specified set of x data that are sound levels. Next, the
%user is allowed to select the test files they would like to analyze for a
%specific mouse. After separating the data from each file
%based on sound level, it calculates the performance on each sound level for each file,
%plots the mean and connects the data with a line.

function session_sound_performance()

%% Initializes Files and organizes them 
%clears all previous data variables
clear all
%closes all previous figures
close all
%specifies the folder
myFolder = 'C:\VoyeurData';

%This can be uncommented to allow the user to input the desired sound
%levels
% answer=inputdlg('Enter Sound Levels Used: ');
% x=str2num(answer{1});

%hard coded sound level
x=[0 10 30 50 60 70 80];

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

%the following initialize arrays that have the number of rows of the input
%x, and have the number of columns of the length of the files selected
gohitarray=zeros(numel(x),1);
nogohitarray=zeros(numel(x),1);
gomissarray=zeros(numel(x),1);
nogomissarray=zeros(numel(x),1);
trialcounterarray=zeros(numel(x),1);

%% Loops through every File and organizes data based on sound level and odor/no odor

%loops through every file
for k = 1 : length(theFiles)
  %selects the kth file
  fullFileName = theFiles(k).name;
  %reads the h5 file of the kth file
  Data=h5read(fullFileName,'/Trials');
  %Determines the number of trials for this particular file
  NumTrials = length(Data.trialNumber);
  %gets the current mouse's ID#, only works if all files are from the
  %same mouse
  mousenum=Data.mouse(1:3,1)';
  %gets the current session number
  sessionnum=Data.session(1);
  %initializes holder arrays for each file 
  soundresponse=zeros(numel(x),NumTrials);
  trialcounter=zeros(numel(x),NumTrials);

  %for loop that saves the mouse's response depending on the sound level
  for Trials=1:NumTrials
    %finds the sound level for kth file and trial
    level=Data.sound_level(Trials);
    %mouse's response for the kth file and trial
    mouseresponse=Data.response(Trials);
    %loops through every sound level to compare to the current sound level
    for e=1:numel(x)
      %if the current sound level is equal to the looped sound level,
      if level==x(e)
        %saves the mouse's response in the same row as the current sound
        %level that is used to index it
        soundresponse(e,Trials)=mouseresponse;
        %adds one to the trial counter for each sound level
        trialcounter(e,Trials)=1;
      end
    end
  end
  %sums up the trial counter and adds it to the trial counter holder
  trialcounterarray(:,k)=sum(trialcounter,2);
  
  %loops through each sound level and determines how many of
  %each trial there were
  for p=1:numel(x)
    %initializes counters for each response type
    gohit=0;
    gomiss=0;
    nogohit=0;
    nogomiss=0;
    %loops through all the trials to save each response
    for w=1:NumTrials
      %takes the current response
      response=soundresponse(p,w);
      %compares the current response to all response types
      if response == 1
        gohit=gohit+1;
      elseif response == 2
        nogohit=nogohit+1;
      elseif response == 3
        gomiss=gomiss+1;
      elseif response == 4
        nogomiss=nogomiss+1;
      else
      end
    end
    %saves the counters into their respective arrays
    gohitarray(p,1)=gohit;
    gomissarray(p,1)=gomiss;
    nogohitarray(p,1)=nogohit;
    nogomissarray(p,1)=nogomiss;
  end
  %calculates the percent correct
  percorr=gohitarray./sum(trialcounter,2);
  %takes everything besides the first row of the percent correct (this is to remove the zeros where the FA data was)
  percorr=percorr(2:end,:);
  %calculates the false alarm percent
  FAarray=nogomissarray./sum(trialcounter,2);
  %only takes the top row of false alarm data (only works for 0dB as no go trial)
  FAarray=FAarray(1,:);
  %saves the y data as a whole from this file
  y=[FAarray;percorr];
  %makes a scatter plot from this data
  scatter(x,y')
  %creates a line connecting this scatter
  q=line(x,y','color',rand(1,3),'DisplayName',"Test from Session "+num2str(sessionnum));
  hold on
end

%sets the xtick of the figure to be the largest and smallest number of the
%input sound levels
xticks(min(x):10:max(x))
%makes these values the limits of the x axis
xlim([min(x) max(x)])
%creates y tick marks ranging from zero to one by 0.1 increments
yticks(0:0.1:1)
%set the y axis limits from zero to one
ylim([0 1])
%creates a title
title('Session Sound Level Performance for Mouse '+convertCharsToStrings(mousenum))
%creates a y label
ylabel('Hit Rate')
%creates an x label
xlabel('Sound Intensities (dB)')
%creates a legend
legend('show','location','bestoutside')

%% Creates a table that gets added to the bottom of the graph for number of trials

% %sums the trial counter across all rows
% NumberofTrials=sum(trialcounterarray,2);
% %creates a variable using all the sound levels (including zero)
% SoundLevels = holdx';
% 
% %creates a table from the sound level data, and the numbers of trials
% T = table(SoundLevels,NumberofTrials);
% %makes the table into a cell array
% tableCell = table2cell(T);
% %calls the table property of variable names and sets them while also
% %padding them with space on each side so they are centered
% T.Properties.VariableNames=pad({'Sound Level: ','# of Trials: '},'both');
% %joins the variable names from the table to the cell array
% tableCell=[T.Properties.VariableNames;tableCell];
% %makes sure that if there are any numbers in the tableCell that they are
% %converted to cells
% tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
% hold on
% 
% %creates the axis position for this table and makes sure that it is not
% %visible so only the table is seen
% axes('position',[.1,0,2,.1], 'Visible','off')
% %converts the table cell array into a string and also inverts it
% tableCell=string(tableCell');
% %splits the table and joins everything while also adding padding inbetween
% %the numbers of the table
% tableChar = splitapply(@strjoin,pad(tableCell,5),[1;2]);
% %allows the table to be plotted as a text point, specifying the data point,
% %and also font, and where on the axis the table appears (can be changed if
% %data does not fit)
% t=text(.2,1.25,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
% %sets the font size of the text (can be made smaller if data does not fit)
% t.FontSize=10;
% 
end
