%% Last edit made by Alister Virkler on 6/17/2021
%This code takes a text file of the same name as a data file, and uses that
%to form a histogram of the licking data that was collected.
%Note: the text file needs to be in the same folder as the data file!

function lick_psth()

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
x=[0 50 55 60 65 70];

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
gohitarray=zeros(numel(x),length(theFiles));
nogohitarray=zeros(numel(x),length(theFiles));
gomissarray=zeros(numel(x),length(theFiles));
nogomissarray=zeros(numel(x),length(theFiles));
trialcounterarray=zeros(numel(x),length(theFiles));

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
    
    %cleans up the hd5 file name to get to the text file name
    lickfilename=extractBefore(fullFileName,'_D');
    lickfilename=append(lickfilename,'.txt');

    %reads the text file and separates the strings by new lines
    new=strsplit(fileread(lickfilename), '\n');
    %finds the size of this new file
    [rowsnew,colsnew]=size(new);
    %takes the firt entry of the text file and separates it by commas
    this=split(new(1),',')';
    %finds the size of this entry
    [rowsthis,colsthis]=size(this);
    %creates a new array of zeros with the number of rows equaling the
    %number of columns from 'new' and with the number of columns equaling the
    %number of columns from 'this'
    newarray=string(zeros(colsnew,colsthis));
    %loop through and separates all the data in their respective columns
    %and rows
    for i=1:length(new)
        %splits and transposes each line of new
        new_line=split(new(i),',')';
        %puts these separated strings into newarray
        newarray(i,:)=new_line;
    end
    %this finds the places where a lick has occured and holds onto their
    %positions
    actual_licks=find(~strcmp(newarray(:,1),'None'));
    %creates a string whos length is the number of licks, and has three
    %columns because of the way the data is stored in the text file
    lick_time=string(zeros(length(actual_licks),1));
    %loops through and separates the lick length variable from the text
    %file into its own variable
    for r=1:length(actual_licks)
        %gets the rth position of a lick
        pos=actual_licks(r);
        %takes the row that the lick has occured in and holds it
        hold_lick_time=newarray(pos,1);
        %puts those variables in a new variable
        lick_time(r,:)=hold_lick_time;
    end
    %grabs just the needed data 
    %string_lick_length=lick_time(:,2);
    %these separate the string with the data so only the required numbers
    %are left
    sep_lick_length1=strrep(lick_time,'[',' ');
    sep_lick_length2=strrep(sep_lick_length1,']',' ');
    %creates a cell array 
    lick_length_cell=cell(length(sep_lick_length2),1);
    %loops through to put lick length variables into a cell array
    for l=1:length(sep_lick_length2)
        %uses textscan to separate each data value and puts it into the
        %cell array
        lick_length_cell(l,1)=textscan(sep_lick_length2(l,1),'%f','delimiter',' ');
    end
    %removes the first entry(header info) and the last entry(empty row)
    lick_length_cell=lick_length_cell(2:end-1,:);
    %creates a matrix of zeros
    lick_length_mat=zeros(length(lick_length_cell),3);
    %loops through to turn each element of the cell array into the same
    %element of a matrix
    next=0;
    for f=1:length(lick_length_cell)
        if isempty(lick_length_cell{f})
            continue;
        else
            next=next+1;
            lick_length_mat(next,:)=cell2mat(lick_length_cell(f,1));
        end
    end
    %gets the raw lick data in matrix form
    lick_length_mat=lick_length_mat(:,2:3);
    %selects just the licks
    licks = lick_length_mat(:,1);
    %gets the start time data
    starts = double(Data.trial_start);
    %edges = -.5:.005:6;
    %sets edges for the bins
    edges = 0:0.05:1.3;
    
    %calls on the make PSTH function to make psths out of the lick and
    %start data, data multiplied by 1e-3 since data is in milliseconds
    [PSTH,raster,trials] = makePSTH(licks*1e-3,starts*1e-3,edges);
    %creates a figure
    figure(1);
    hold on
    %makes a raster plot
    scatter(raster,trials,'r.')
    hold off

    
    %imagesc(PSTH)
    %go_psth = mean(PSTH(go_trials==true,:))
    %scatter(raster,trials,'k.')
    
    %joins the PSTH with the mouse's response per trial
    psth=[PSTH double(Data.response)];
    %creates empty vectors and counters
    psthgo=[];
    psthfa=[];
    next_line_go = 0;
    next_line_fa = 0;
    %finds the size of the psth
    [row col]=size(psth);
    
    %loops through and separates go trials and false alarm trials and makes
    %their own psths
    for g=1:row
        if psth(g,end) == 1
            next_line_go = next_line_go+1;
            psthgo(next_line_go,:)=psth(g,:);
        elseif psth(g,end) == 4
            next_line_fa = next_line_fa+1;
            psthfa(next_line_fa,:)=psth(g,:);
        end
    end
    
    %psthgomean=mean(psthgo(:,1:end-1));
    %psthfamean=mean(psthfa(:,1:end-1));
    psthgo=psthgo(:,1:end-1);
    psthgomean=mean(psthgo);
    psthfa=psthfa(:,1:end-1);
    psthfamean=mean(psthfa);
    
    %time = -0.5:.005:6;
    time = 0:0.05:1.3;
    time=time(1:end-1);
    
    figure(2)
    hold on
    plot(time,psthgomean,'b')
    hold on
    plot(time,psthfamean,'r')
    legend("Go Hit Licks","False Alarm Licks")
    title("Lick Timing")
    hold off
    
    
    %do stats, reaction time graph, avg rx time per trial type per mouse,
    %avg total licks time per type and mouse; average them over trials,
    %sessions; what is peak lick time for trial type, 
    
    
end
end
