%% Last edit made by Alister Virkler on 6/17/2021
%This code runs through a user made range of sound levels and mouseID #'s
%to calculate their thresholds between sound only test and sound+odor tests 
%for a go/nogo behavioral task.

function JND()

%% Initializes the Files, sound levels, and Mice ID#'s
%clears all variables
clear all
%closes all figures
close all

%allows for the user to input the number of mice
% numofmice=inputdlg('How many mice would you like to compare?');
% numofmice=string(numofmice);
% numofmice=str2double(numofmice);
% thresholdnoodor=zeros(1,numel(numofmice));
% thresholdodor=zeros(1,numel(numofmice));

%hard coded number of mice
numofmice=3;
%initializes arrays
thresholdnoodor=zeros(1,numofmice);
thresholdodor=zeros(1,numofmice);
micenum=zeros(1,numofmice);

%loops through each mouse and calculates their threshold with odor and
%without odor
for i=1:numofmice
    %hard coded sound levels
    x=[0 10 30 50 60 70 80];
    
    %allows the user to enter the mouse's ID
    %mousenum=string(inputdlg("Enter ID# of Mouse " +convertCharsToStrings(i)));
    %hard coded mice ID
    
    mousenums=["043","044","045"];
    %selects the the ith mouse
    mousenum=mousenums(i);
    %saves the mouse id into an array
    micenum(1,i)=mousenum;
    %creates an extension with the mouse ID for all tests
    mousexten=append('*',mousenum,'t*.h5');
    %specifies the folder
    myFolder = 'C:\VoyeurData';
    %gets the file from the folder and the extension
    filePattern = fullfile(myFolder,mousexten);
    %uses the pattern in the directory
    theFiles = dir(filePattern);
    %makes the files into a table
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
    %initializes arrays and counters
    gohitarray=zeros(numel(x),length(theFiles));
    gohitarrayodor=zeros(numel(x),length(theFiles));
    nogohitarray=zeros(numel(x),length(theFiles));
    nogohitarrayodor=zeros(numel(x),length(theFiles));
    gomissarray=zeros(numel(x),length(theFiles));
    gomissarrayodor=zeros(numel(x),length(theFiles));
    nogomissarray=zeros(numel(x),length(theFiles));
    nogomissarrayodor=zeros(numel(x),length(theFiles));
    trialcounterarray=zeros(numel(x),length(theFiles));
    trialcounterarrayodor=zeros(numel(x),length(theFiles));
    
    %loops through every file 
    for k = 1 : length(theFiles)
        %selects the kth file
        fullFileName = theFiles(k).name;
        %selects the kth file date and turns it into this format
        compare=datetime(theFiles(k).Date,'InputFormat','MM/dd/yyyy');
        %this is the cut off date, after this date, odor trials were started!
        %This can be changed if previous odor trials want to be reset to sound
        %only
        cutoff=datetime('06/10/2021','InputFormat','MM/dd/yyyy');
        %reads the h5 file of the kth file
        Data=h5read(fullFileName,'/Trials');
        %Determines the number of trials for this particular file
        NumTrials = length(Data.trialNumber);
        %if statement says that if the date of the file is before the cutof
        %date then change all odorvalves to the no odor valve (5)
        if compare<=cutoff
            %runs through every trial
            for set=1:NumTrials
                %changes the odorvalve to 5
                Data.odorvalve(set,1)=5;
            end
        end
        %initializes four more arrays to save data
        soundresponse=zeros(numel(x),NumTrials);
        soundresponseodor=zeros(numel(x),NumTrials);
        trialcounter=zeros(numel(x),NumTrials);
        trialcounterodor=zeros(numel(x),NumTrials);
        
        %for loop that saves the mouse's response depending on the sound level
        %and the presence of odor
        for Trials=1:NumTrials
            %finds the sound level for kth file and trial
            level=Data.sound_level(Trials);
            %odor for the kth file and trial
            odor=Data.odorvalve(Trials);
            %mouse's response for the kth file and trial
            mouseresponse=Data.response(Trials);
            %loops through every sound level to compare the current sound level
            %with and to see if there is odor or not for this trial
            for e=1:numel(x)
                %if the current sound level is equal to the looped sound level,
                %and if it is equal to the no odor condition
                if level==x(e) && odor==5
                    %saves the mouse's current response
                    soundresponse(e,Trials)=mouseresponse;
                    %adds one to the counter
                    trialcounter(e,Trials)=1;
                %if the current sound level is equal to the looped sound level,
                %and if it is equal to the odor condition
                elseif level==x(e) && odor==8
                    %saves the mouse's current response for odor
                    soundresponseodor(e,Trials)=mouseresponse;
                    %adds one to the counter for odor
                    trialcounterodor(e,Trials)=1;
                end
            end
        end
        %sums up the trial counter and adds it to the trial counter holder
        trialcounterarray(:,k)=sum(trialcounter,2);
        trialcounterarrayodor(:,k)=sum(trialcounterodor,2);
        
        %loops through each sound level with no odor and determines how many of
        %each trial there were
        for p=1:numel(x)
            %initializes counter for each response type
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
            gohitarray(p,k)=gohit;
            gomissarray(p,k)=gomiss;
            nogohitarray(p,k)=nogohit;
            nogomissarray(p,k)=nogomiss;
        end
        
        %loops through all the no odor responses to tally them
        for p=1:numel(x)
            %initializes counter for each response type with odor
            gohit=0;
            gomiss=0;
            nogohit=0;
            nogomiss=0;
            %loops through all the trials to save each response
            for w=1:NumTrials
                %takes the current response
                response=soundresponseodor(p,w);
                %compares the response to all response types
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
            gohitarrayodor(p,k)=gohit;
            gomissarrayodor(p,k)=gomiss;
            nogohitarrayodor(p,k)=nogohit;
            nogomissarrayodor(p,k)=nogomiss;
        end
    end
    
    %calculates the percent correct for no odor
    percorrarray=gohitarray./trialcounterarray;
    %calculates the percent correct for odor
    percorrarrayodor=gohitarrayodor./trialcounterarrayodor;
    %takes everything besides the first row of the percent correct no odor(this is to
    %remove the zeros where the FA data was)
    percorrarray=percorrarray(2:end,:);
    %takes everything besides the first row of the percent correct odor (this is to
    %remove the zeros where the FA data was)
    percorrarrayodor=percorrarrayodor(2:end,:);
    %inverts the percent correct array for no odor and saves it as y
    y=percorrarray';
    %inverts the percent correct array for odor and save it as yodor
    yodor=percorrarrayodor';
    
    %for loop that takes out the zero sound level since we do not want to
    %include that in our threshold calculations (works only if zero is the no
    %go trial)
    for o=1:numel(x)
        %if there is zero in the sound levels then take it out
        if x(o)==0
            %takes out the zero
            x(o)=[];
            %whenever zero is detected, the for loop is stopped
            break
        end
    end
    
    %holds onto current value of x
    x1=x;
    %makes x into the same size as the y data
    for z=1:length(theFiles)
        %for the first number, x equals itself
        if z==1
            x=x;
        %after the first index, x1 gets added as a row to the current value of x
        else
            x=[x;x1];
        end
    end
    
    %calls fitLogGrid using all the data from both x and y for no odor
    [params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(x(:),y(:));
    %finds the size of the y data for odor
    [m,n]=size(yodor);
    %loops through the number of rows from the size of the y data for odor
    %so the x data will have the same dimensions as yodor
    for t=1:m
        %if the index equals one then the x data variable will be reset to
        %the original sound level vector without zero
        if t==1
            x=x1;
            %after the first index, x1 gets added as a row to the current value of
            %x
        else
            x=[x;x1];
        end
    end
    
    %calls fitLogGrid using all the date from both x and y for odor
    [odorparams,odormdl,odorthreshold,odorsensitivity,odorfmcon,odorminfun,odorpthresh] = fitLogGrid(x(:),yodor(:));
    %saves the sound only threshold into the array
    thresholdnoodor(1,i)=threshold;
    %saves the sound and odor threshold into the array
    thresholdodor(1,i)=odorthreshold;
end

%combines both thresholds into one matrix
threshold=[thresholdnoodor;thresholdodor];
%initializes a figure
figure();
%sets an axis position
axes('position',[.1,.25,.8,.7])
hold on

%loops through each mouse and plots their threshold values
for a=1:numofmice
    num=num2str(micenum(a));
    plot([1 2],threshold(:,a),'-o','DisplayName',"Mouse 0"+num)
    hold on
end
%legend shows the 'DisplayName' for each data set
legend('show')
%sets the x limits
xlim([0.25 2.75])
%sets the x tick marks
xticks([0 1 2 3])
%labels the x ticks
xticklabels({'','JND: Sound Only','JND: Sound+Odor',''})
%sets y limits
ylim([(min(threshold,[],'all')-5) (5+max(threshold,[],'all'))])
%creates a title
title('JND between Sound Only Trials and Sound with Odor Trials')
%labels the x axis
xlabel('JND')
%labels the y axis
ylabel('Threshold Values')

%creates an array
perdiff=zeros(1,length(thresholdodor));
%loops through each threshold and calculates the percent difference
for g=1:length(thresholdodor)
    perdiff(1,g)=((threshold(1,g)-threshold(2,g))/threshold(1,g))*100;
end

%creates a table from the mice numbers and the percent differences
T = table(micenum',perdiff');
%makes the table a cell array
tableCell = table2cell(T);
%creates variable names for the table and pads them on either side
T.Properties.VariableNames=pad({'Mouse #: ','% Difference: '},'both');
%combines the variable names with the data
tableCell=[T.Properties.VariableNames;tableCell];
%%makes sure that if there are any numbers in the tableCell that they are
%converted to cells
tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
hold on
%creates an axis position for the table and makes sure the axis are
%invisible
axes('position',[.1,0,2,.1], 'Visible','off')
%makes the table cell into a string
tableCell=string(tableCell');
%splits the table and joins everything while also adding padding inbetween
%the numbers of the table
tableChar = splitapply(@strjoin,pad(tableCell,'both'),[1;2]);
%allows the table to be plotted as a text point, specifying the data point,
%and also font, and where on the axis the table appears (can be changed if
%data does not fit)
t=text(.2,1.25,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
%sets the font size of the text (can be made smaller if data does not fit)
t.FontSize=10;
end