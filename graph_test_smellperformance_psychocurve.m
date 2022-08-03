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

function [y, yodor, FAarray, FAarrayodor, xsig, xsigodor, ysig, ysigodor, threshold, odorthreshold, gohitarray, gohitarrayodor, gomissarray, gomissarrayodor, nogohitarray, nogohitarrayodor, nogomissarray, nogomissarrayodor, trialcounterarray, trialcounterarrayodor] = graph_test_smellperformance_psychocurve()

%% Initializes Files and organizes them 
%clears all previous data variables
%clear all
%closes all previous figures
%close all
%specifies the folder
myFolder = 'C:\VoyeurData';

%x = [0.0000 0.000001 0.00001 0.00010 0.00100 0.01000 0.10000];
x = [0.0000 0.00010 0.00100 0.01000 0.10000];
%x = [0 1 2 3 4 5 6];
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

%% Initialization
%the following initialize arrays that have the number of rows of the input
%x, and have the number of columns of the length of the files selected
gohitarray=zeros(numel(x),length(theFiles));

nogohitarray=zeros(numel(x),length(theFiles));

gomissarray=zeros(numel(x),length(theFiles));

nogomissarray=zeros(numel(x),length(theFiles));

trialcounterarray=zeros(numel(x),length(theFiles));
  

%% Loops through every File and organizes data based on sound level and odor/no odor


%% Calculates all necessary performance data based on the data stored above

%calculates the percent correct for no odor
%percorrarray=gohitarray./(gohitarray+gomissarray);

percorrarray = [0 0; 0.2 0.15; 0.3 0.25; 0.8 0.75; 0.99 0.8];
%percorrarray = [0 0; 0.1 0.15; 0.2 0.22; 0.3 0.35; 0.7 0.75; 0.8 0.85; 0.9 0.95];

%calculates the false alarm percent for no odor
%FAarray=nogomissarray./(nogomissarray+nogohitarray);

FAarray = [0.099 0.125; 0 0; 0 0; 0 0; 0 0;];

%only takes the top row of false alarm data for no odor (only works for 0dB
%as no go trial)
FAarray=FAarray(1,:);


%takes everything besides the first row of the percent correct no odor(this is to
%remove the zeros where the FA data was)
percorrarray=percorrarray(2:end,:);

y=percorrarray';
%inverts the percent correct array for odor and save it as yodor
% yodor=percorrarrayodor';

%calculates the mean of the rows of the percent correct array for no odor
meanpercorr=mean(percorrarray,2);

%calculates the standard deviation of the percent correct array for no odor
sdcorr=std(percorrarray,0,2);

%finds the size of the percent correct array for no odor
[row,column]=size(percorrarray);
%calculates the standard error from the standard deviation for no odor and
%divides it by the column variable (the number of files selected with no
%odor)
stecorr=sdcorr./(sqrt(column));
%acalculates the standard deviation of the False alarm array
sdFA=std(FAarray);

%calculates the standard error by dividing the standard deviation of the
%false alarm with no odor by the number of columns of files with sound only
steFA=sdFA/(sqrt(column));


%% Calculates Psychometric curve and plots all data from above

%initializes a figure
hfig = figure();
%creates an axis position for the figure (can change if graph does not fit)
%axes('position',[.1,.25,.8,.7])
%makes these values the limits of the x axis
xlim([log10(x(2)) log10(max(x))])
%xlim([0 4])
%sets the xtick of the figure to be the largest and smallest number of the
%input sound levels
xticks(log10(x))
%set(hfig,'xscale','log')

%plots error bars for the first sound level (can be changed if zero is not
%the first sound level and it is not the nogo trial) and the average of the
%false alarm for no odor and its standard error

%e1=errorbar(x(1),mean(FAarray),steFA,'or');
%e25 = semilogx(x(1),mean(FAarray),'ok');
e2 = yline(mean(FAarray),'r','LineWidth',1.5);
f1 = yline(mean(FAarray)+steFA,'r','LineWidth',1.5);
f2 = yline(mean(FAarray)-steFA,'r','LineWidth',1.5);
vert = [log10(x(2)) mean(FAarray)-steFA; log10(x(2)) mean(FAarray+steFA); log10(max(x+1)) mean(FAarray)+steFA; log10(max(x+1)) mean(FAarray)-steFA];
f = [1 2 3 4];
patch('Faces',f,'Vertices',vert,'FaceColor','red','FaceAlpha',0.25)
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
e3=errorbar(log10(x),meanpercorr',stecorr,'or');
%e4=semilogx(x,meanpercorr','ok');
hold on

%labels the x axis
xlabel('Log[Conc]')
%creates y tick marks ranging from zero to one by 0.1 increments
yticks(0:0.1:1)
%set the y axis limits from zero to one
ylim([0 1])
%labels the y axis
ylabel('Hit rate')
%creates a title using the last file's mouse number(if using multiple mice
%date then comment out '+convertCharsToStrings(mousenum)+'
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

x=log10(x);
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
convert_threshold = 10^threshold;
%e5=semilogx(xsig,ysig,'r','LineWidth',2);
title("Combined Performance of Mouse on Odor Concentrations")
hold on
%creates a vertical line at the threshold value and gives this threshold a
%name
e6=xline(threshold,'--r','DisplayName',"Threshold = "+convertCharsToStrings(threshold));%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')

eleg=legend([e6],'location','best');

end