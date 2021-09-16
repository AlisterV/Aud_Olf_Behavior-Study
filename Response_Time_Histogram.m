%% Last edit made by Alister Virkler 6/17/2021
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .xlsx file
% for later analysis, or use the following code to interpret the data in
% MATLAB. The program also takes this data and recreates the Go/NoGo Trial
% performance.

function Response_Time_Histogram()

close all;
clear all;

%sets the folder
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
%prompts the user
answer = questdlg('Would you like: ','Option 3','All Files for mouse','Choose files','All Files for mouse');

if strcmp(answer, 'All Files for mouse')
    mousenum=input('Enter Mouse Number: ', 's');
    %creates an extension that contains the mouse number
    mousexten=append('*',mousenum,'*.h5');
    %creates the file pattern from the folder and extension
    filePattern = fullfile(myFolder,mousexten);
    %goes to the directory and gets all of the files that match the
    %file pattern
    theFiles = dir(filePattern);
elseif strcmp(answer, 'Choose files')
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
end
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


goresponsetimearray=[];
nogoresponsetimearray=[];
oldgoresponsetimearray=[];
oldnogoresponsetimearray=[];

for k=1:length(theFiles)
    %selects the kth file
    fullFileName = theFiles(k).name;
    current_date=datetime(theFiles(k).Date,'InputFormat','MM/dd/yyyy');
    if current_date < datetime('06/30/2021','InputFormat','MM/dd/yyyy')
        continue
    elseif current_date >= datetime('07/08/2021','InputFormat','MM/dd/yyyy')
        %reads the file into matlab
        Data=h5read(fullFileName,'/Trials');
        %Determines the number of trials for this particular file
        NumTrials = length(Data.trialNumber);
        %finds the files mouse number
        mousenum=Data.mouse(1:3,1)';
        %finds the files session number
        sessionnum=Data.session(1);
        %finds the number of trials
        %loops through every trial from the file for response times
        for Trials = 1:NumTrials
            response=Data.response(Trials);
            % response time is equal to the time of the first lick minus the time
            % of the odor valve onset.
            responseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials));
            % if the response time is negative then just set it equal to zero.
            if responseTime < 0
                responseTime = 0;
            end
            if response == 1
                goresponsetimearray(Trials,k)=responseTime;
            elseif response == 4
                nogoresponsetimearray(Trials,k)=responseTime;
            end
        end
    else
        %reads the file into matlab
        Data=h5read(fullFileName,'/Trials');
        %Determines the number of trials for this particular file
        NumTrials = length(Data.trialNumber);
        %finds the files mouse number
        mousenum=Data.mouse(1:3,1)';
        %finds the files session number
        sessionnum=Data.session(1);
        %finds the number of trials
        %loops through every trial from the file for response times
        for Trials = 1:NumTrials
            response=Data.response(Trials);
            % response time is equal to the time of the first lick minus the time
            % of the odor valve onset.
            oldresponseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials));
            % if the response time is negative then just set it equal to zero.
            if oldresponseTime < 0
                oldresponseTime = 0;
            end
            %if the response was a go hit then hold onot this loops old
            %response
            if response == 1
                oldgoresponsetimearray(Trials,k)=oldresponseTime;
            %if the response was a nogo miss then hold onto this loops old
            %response
            elseif response == 4
                oldnogoresponsetimearray(Trials,k)=oldresponseTime;
            end
        end
    end
end

%create a figure
figure(1)
%this reshapes the go response array
rego=reshape(goresponsetimearray,[],1);
%this reshapes the nogo response array
renogo=reshape(nogoresponsetimearray,[],1);
%creates the histogram for the go trials, sets 300 bins, makes them blue,
%and sets the limits
histogram(rego,300,'FaceColor','b','BinLimits',[1 1250])%,'Normalization','probability');
hold 'on'
%creates the histogram for the nogo trials, sets 300 bins, makes them red,
%and sets the limits
histogram(renogo,300,'FaceColor','r','BinLimits',[1 1250])%,'Normalization','probability');
hold 'on'
%creates a title with the mouse number
title("Mouse"+" "+string(mousenum)+":  " +"Response Time Distribution")
%    title("Response Time for All Mice")
%creates a legend for the graph
legend("Go Hit Response Times","False Alarm Response Times")
hold 'off'

%if there is old data, then this will plot that as well
if oldgoresponsetimearray > 0
    %creates figure 2
    figure(2)
    %reshapes the old go response array
    oldrego=reshape(oldgoresponsetimearray,[],1);
    %reshapes the old nogo response array
    oldrenogo=reshape(oldnogoresponsetimearray,[],1);
    %creates a histogram for the go trials, sets 300 bins, makes them blue,
    %and sets the limits
    histogram(oldrego,300,'FaceColor','b','BinLimits',[1 2500])%,'Normalization','probability');
    hold 'on'
    %creates a histogram for the nogo trials, sets 300 bins, makes them
    %red, and sets the limits
    histogram(oldrenogo,300,'FaceColor','r','BinLimits',[1 2500])%,'Normalization','probability');
    hold 'on'
    %creates a title
    title("Mouse"+" "+string(mousenum)+":  " +"Response Time Distribution, old paradigm")
    %creates a legend
    legend("Go Hit Response Times","False Alarm Response Times")
end
end