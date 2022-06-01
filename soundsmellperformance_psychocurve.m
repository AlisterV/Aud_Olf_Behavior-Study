%% Last edit made by Alister Virkler on 6/17/2021
%This code shows the Psychometric Curves for a mouse for a Go/NoGo behavioral odor task based on sound levels.
%It takes in a specified set of x data that are sound levels. Next, the
%user is allowed to select thetest files they would like to analyze for a
%specific mouse. After, the code goes through these files, and organizes
%them by date. If a file's date is prior to the start date of odor testing
%(the tests for sound only/no odor), Matlab removes the option for odor
%from the h5 data files. Then, after separating the data from each file
%based on sound level and the presence of odor/no odor, it calculates the
%performance data (% correct, false alarm rate, mean, std, ste...) and fits
%a psychometric curve using fitLogGrid while also plotting the number of
%trials for each trial type (odor/no odor).

function [y, yodor, FAarray, FAarrayodor, xsig, xsigodor, ysig, ysigodor, threshold, odorthreshold, gohitarray, gohitarrayodor, gomissarray, gomissarrayodor, nogohitarray, nogohitarrayodor, nogomissarray, nogomissarrayodor, trialcounterarray, trialcounterarrayodor] = soundsmellperformance_psychocurve()

%% Initializes Files and organizes them 
%clears all previous data variables
clear all
%closes all previous figures
close all
%specifies the folder
myFolder = 'C:\VoyeurData';

%This can be uncommented to allow the user to input the desired sound
%levels
answer=inputdlg('Enter Sound Levels Used: ');
x=str2num(answer{1});

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

%% Sound Detection
%  
% %creates a cell array to hold each files sound level
% soundhold = {};
% %loops through to grab each files sound level
% for s = 1 : length(theFiles)
%     %holds the file name
%     filehold = theFiles(s).name;
%     %reads the data in the current file
%     snd = h5read(filehold, '/Trials');
%     %gets the sound level data and find only the unique elements
%     %(eliminates repeats)
%     sl = {unique(snd.sound_level)};
%     %holds onto the sound levels for that file
%     soundhold(s) = sl;
% end
% %creates a matrix to hold the sound levels
% sound = [];
% %loops through every file and makes each element in the cell array into one
% %joined matrix
% for l = 1: length(theFiles)
%     %converts the current element of the sound cell array into a matrix
%     snmat = cell2mat(soundhold(l));
%     %if the iteration is after the first loop enter
%     if l > 1
%         %adds the current sound levels onto the matrix 
%         sound = [sound;snmat];
%     %if it is the first loop enter
%     else
%         %the holding matrix becomes the first set of sound levels
%         sound = snmat;
%     end
% end
% %finds any repeats of sound levels between the files and only takes the
% %unique ones, creating a matrix that combines all sound levels from each
% %trial
% x = unique(sound)';    
% 
% %loops through to find the longest group of sound levels
% len = 0;
% for t = 1:length(theFiles)
%     curr_len = length(cell2mat(soundhold(t)));
%     if curr_len > len
%         len = curr_len;
%     elseif curr_len < len
%         len = len;
%     end
% end
% 
% %loops through to create a matrix of all sounds levels, and equalizes their
% %size to match the largest (attaches NaN to end if too short)
% sounds = zeros(length(theFiles),len);
% for d = 1:length(theFiles)
%     curr_lev = cell2mat(soundhold(d))';
%     if length(curr_lev) == len
%         sounds(d,:) = curr_lev;
%     else
%         C = abs(length(curr_lev) - len);
%         for da = 1:C
%             curr_lev = [curr_lev NaN];
%         end
%         sounds(d,:) = curr_lev;
%     end
% end
% 
% 
% min_snd = zeros(length(theFiles),1);
% for r = 1:length(theFiles)
%     file_sound = sounds(r,:);
%     min_sound = min(file_sound(file_sound>0));
%     min_snd(r) = min_sound;
% end
% 
% minimum_sound = min(min_snd);
% ord_sound = []; %zeros(length(theFiles), len);
% 
% if range(min_snd) ~= 0
%     
% end

        
        

% for r = 1:numel(sounds)
%     elem = sounds(r);
%     if r == 1
%         old_elem = elem + 1;
%     end
%     if old_elem == elem
%         continue
%     else
%         fin = sounds == elem;
%         grp = sounds(fin);
%         ord_sound(:,r) = grp;
%     end
%     old_elem = elem;
% end
%% Initialization
%the following initialize arrays that have the number of rows of the input
%x, and have the number of columns of the length of the files selected
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

%% Loops through every File and organizes data based on sound level and odor/no odor

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
  %gets the current mouse's ID#, only works if all files are from the
  %same mouse
  mousenum=Data.mouse(1:3,1)';
  %Determines the number of trials for this particular file
  NumTrials = length(Data.trialNumber);
  %if statement says that if the date of the file is before the cutof
  %date then change all odorvalves to the no odor valve (5)
  if compare<=cutoff
    %runs through every trial
    for set=1:NumTrials
      %changes the odorvalve to 5
      %Data.odorvalve(set,1)=5;
      Data.odorvalve(set,1)=10;
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
      elseif level==x(e) && odor==12
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
    gohitodor=0;
    gomissodor=0;
    nogohitodor=0;
    nogomissodor=0;
    %loops through all the trials to save each response
    for w=1:NumTrials
      %takes the current response
      response=soundresponseodor(p,w);
      %compares the response to all response types
      if response == 1
        gohitodor=gohitodor+1;
      elseif response == 2
        nogohitodor=nogohitodor+1;
      elseif response == 3
        gomissodor=gomissodor+1;
      elseif response == 4
        nogomissodor=nogomissodor+1;
      else
      end
    end
    %saves the counters into their respective arrays
    gohitarrayodor(p,k)=gohitodor;
    gomissarrayodor(p,k)=gomissodor;
    nogohitarrayodor(p,k)=nogohitodor;
    nogomissarrayodor(p,k)=nogomissodor;
  end
end

%% Calculates all necessary performance data based on the data stored above

%calculates the percent correct for no odor
percorrarray=gohitarray./trialcounterarray;
%calculates the percent correct for odor
percorrarrayodor=gohitarrayodor./trialcounterarrayodor;

%calculates the false alarm percent for no odor
FAarray=nogomissarray./trialcounterarray;
%calculates the false alarm percent for odor
FAarrayodor=nogomissarrayodor./trialcounterarrayodor;
%only takes the top row of false alarm data for no odor (only works for 0dB
%as no go trial)
FAarray=FAarray(1,:);
%only takes the top row of false alarm data for odor (only works for 0dB as
%no go trial)
FAarrayodor=FAarrayodor(1,:);
%takes out all NaNs in the array (this happens when sound only tests are
%selected before odor tests)
FAarrayodor=FAarrayodor(~isnan(FAarrayodor));

%takes everything besides the first row of the percent correct no odor(this is to
%remove the zeros where the FA data was)
percorrarray=percorrarray(2:end,:);
%takes everything besides the first row of the percent correct odor (this is to
%remove the zeros where the FA data was)
percorrarrayodor=percorrarrayodor(2:end,:);

%creates a counter
columncounter=0;
%determines the size of the percent correct array for odor
[m,n]=size(percorrarrayodor);
%loops through the number of columns that percent correct array for odor
%has, and for all the columns that contain NaN, a counter is added
for v=1:n
  %seems if the column contains NaN
  if isnan(percorrarrayodor(:,v))
    %adds one to the counter if the column contains NaN
    columncounter=columncounter+1;
  end
end

%takes out all NaN (only a problem if sound only trials are selected)
percorrarrayodor=percorrarrayodor(~isnan(percorrarrayodor));
%reshapes the percent correct array for odor to have the original number of
%rows but with the orignal number of columns minus the counter from the
%previous loop
percorrarrayodor=reshape(percorrarrayodor,m,n-columncounter);

%inverts the percent correct array for no odor and saves it as y
y=percorrarray';
%inverts the percent correct array for odor and save it as yodor
yodor=percorrarrayodor';

%calculates the mean of the rows of the percent correct array for no odor
meanpercorr=mean(percorrarray,2);
%calculates the mean of the rows of the percent correct array for odor
meanpercorrodor=mean(percorrarrayodor,2);

%calculates the standard deviation of the percent correct array for no odor
sdcorr=std(percorrarray,0,2);
%calculate the standard deviation of the percent correct array for odor
sdcorrodor=std(percorrarrayodor,0,2);

%finds the size of the percent correct array for no odor
[row,column]=size(percorrarray);
%calculates the standard error from the standard deviation for no odor and
%divides it by the column variable (the number of files selected with no
%odor)
stecorr=sdcorr./(sqrt(column));

%finds the size of the percent corect array for odor
[row,columnodor]=size(percorrarrayodor);
columnodor
%calculates the standard error from the standard deviation for odor and
%divides it by the column variable (the number of files selected with
%odor)
stecorrodor=sdcorrodor./sqrt((columnodor));

%calculates the standard deviation of the False alarm array
sdFA=std(FAarray);
%calculates the standard deviation of the false alarm array for odor
sdFAodor=std(FAarrayodor);
%calculates the standard error by dividing the standard deviation of the
%false alarm with no odor by the number of columns of files with sound only
steFA=sdFA/(sqrt(column));
%calculates the standard error by dividing the standard deviation of the
%false alarm with odor by the number of columns of files with odor
steFAodor=sdFAodor/(sqrt(columnodor));

%% Calculates Psychometric curve and plots all data from above

%initializes a figure
figure();
%creates an axis position for the figure (can change if graph does not fit)
axes('position',[.1,.25,.8,.7])
%sets the xtick of the figure to be the largest and smallest number of the
%input sound levels
xticks(min(x):10:max(x))
%makes these values the limits of the x axis
xlim([min(x) max(x)])

%plots error bars for the first sound level (can be changed if zero is not
%the first sound level and it is not the nogo trial) and the average of the
%false alarm for no odor and its standard error
e1=errorbar(x(1),mean(FAarray),steFA,'or');
hold on
%plots error bars for the first sound level (can be changed if zero is not
%the first sound level and it is not the nogo trial) and the average of the
%false alarm for odor and its standard error
e2=errorbar(x(1),mean(FAarrayodor),steFAodor,'ob');
hold on

%creates a holder to store original x (sound levels)
holdx=x;
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

%plots error bars for the sound levels without zero and the average of the
%mean percent correct no odor along with the standard error
e3=errorbar(x,meanpercorr',stecorr,'or');
hold on
%plots error bars for the sound levels without zero and the average of the
%mean percent correct odor along with the standard error
e4=errorbar(x,meanpercorrodor',stecorrodor,'ob');

hold on
%labels the x axis
xlabel('Sound Intensities (dB)')
%creates y tick marks ranging from zero to one by 0.1 increments
yticks(0:0.1:1)
%set the y axis limits from zero to one
ylim([0 1])
%labels the y axis
ylabel('Hit rate')
%creates a title using the last file's mouse number(if using multiple mice
%date then comment out '+convertCharsToStrings(mousenum)+'
title("Combined Performance of Mouse "+convertCharsToStrings(mousenum)+" on each Sound Level by Odor")
hold on

%holds onto current value of x
x1=x;
%finds the size of the y data for no odor
[m,n]=size(y);
%makes x into the same size as the y data
for i=1:m
  %for the first number, x equals itself
  if i==1
    x=x;
  %after the first index, x1 gets added as a row to the current value of x
  else
    x=[x;x1];
  end
end

%calls fitLogGrid using all the data from both x and y for no odor
[params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(x(:),y(:));
%creates 100 data points ranging from the smallest to the largest value in
%the x data
xf=linspace(min(x(:)),max(x(:)),100);
hold on
%plots the x line data and uses the model from fitLogGrid, the parameters
%from fitLogGrid and the x line data
xsig = xf;
ysig = mdl(params,xf);
e5=plot(xsig,ysig,'r');
%e5=plot(xf,mdl(params,xf),'r');
hold on
%creates a vertical line at the threshold value and gives this threshold a
%name
e6=xline(threshold,'--r','DisplayName',"Threshold = "+convertCharsToStrings(threshold)+" dB");%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')

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
%creates 100 data points ranging from the smallest to the largest value in
%the x data
xfodor=linspace(min(x(:)),max(x(:)),100);
hold on
%plots the x line odor data and uses the model from fitLogGrid, the odor parameters
%from fitLogGrid and the x line odor data
xsigodor = xfodor;
ysigodor = odormdl(odorparams,xfodor);
e7=plot(xsigodor,ysigodor,'b');
%e7=plot(xfodor,odormdl(odorparams,xfodor),'b');
hold on
%creates a vertical line at the odor threshold value and gives this threshold a
%name
e8=xline(odorthreshold,'--b','DisplayName',"Odor Threshold = "+convertCharsToStrings(odorthreshold)+" dB");%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
%creates a legend for the figure but only shows variables e6(threshold no
%odor) and e8(threshold odor) and places it at the best location
eleg=legend([e6 e8],'location','best');

%% Creates a table that gets added to the bottom of the graph for number of trials

%sums the trial counter for no odor across all rows
NumberofTrials=sum(trialcounterarray,2);
%sums the trial counter for odor across all rows
NumberofTrialsodor=sum(trialcounterarrayodor,2);
%creates a variable using all the sound levels (including zero)
SoundLevels = holdx';

%creates a table from the sound level data, and both numbers of trials for
%each condition odor and no odor
T = table(SoundLevels,NumberofTrials,NumberofTrialsodor);
%makes the table into a cell array
tableCell = table2cell(T);
%calls the table property of variable names and sets them while also
%padding them with space on each side so they are centered
T.Properties.VariableNames=pad({'Sound Level: ','# of Trials no odor: ','# of Trials w/odor: '},'both');
%joins the variable names from the table to the cell array
tableCell=[T.Properties.VariableNames;tableCell];
%makes sure that if there are any numbers in the tableCell that they are
%converted to cells
tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
hold on

%creates the axis position for this table and makes sure that it is not
%visible so only the table is seen
axes('position',[.1,0,2,.1], 'Visible','off')
%converts the table cell array into a string and also inverts it
tableCell=string(tableCell');
%splits the table and joins everything while also adding padding inbetween
%the numbers of the table
tableChar = splitapply(@strjoin,pad(tableCell,5),[1;2;3]);
%allows the table to be plotted as a text point, specifying the data point,
%and also font, and where on the axis the table appears (can be changed if
%data does not fit)
t=text(.2,1.25,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
%sets the font size of the text (can be made smaller if data does not fit)
t.FontSize=10;

end