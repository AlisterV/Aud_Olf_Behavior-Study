function [odorthresh] = finaltask_odoronly(x_conc, x_conc_size,theFiles)

%% ODOR ONLY
%the following initialize arrays that have the number of rows of the input
%x, and have the number of columns of the length of the files selected
gohitarray=zeros(x_conc_size,length(theFiles));
%gohitarrayodor=zeros(numel(x_conc),length(theFiles));
nogohitarray=zeros(x_conc_size,length(theFiles));
%nogohitarrayodor=zeros(numel(x_conc),length(theFiles));
gomissarray=zeros(x_conc_size,length(theFiles));
%gomissarrayodor=zeros(numel(x_conc),length(theFiles));
nogomissarray=zeros(x_conc_size,length(theFiles));
%nogomissarrayodor=zeros(numel(x_conc),length(theFiles));
trialcounterarray=zeros(x_conc_size,length(theFiles));
%trialcounterarrayodor=zeros(numel(x_conc),length(theFiles));   
thresholdarrayconcentrations=zeros(1,length(theFiles));

%loops through every file
for k = 1 : length(theFiles)
  %selects the kth file
  fullFileName = theFiles(k).name;
  %reads the h5 file of the kth file
  Data=h5read(fullFileName,'/Trials');
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
  %gets the current mouse's ID#, only works if all files are from the
  %same mouse
  mousenum=Data.mouse(1:3,1)';
  %Determines the number of trials for this particular file
  NumTrials = length(Data.trialNumber);
  %if statement says that if the date of the file is before the cutof
  %date then change all odorvalves to the no odor valve (5)
  %initializes four more arrays to save data
  trialcounter=zeros(x_conc_size,NumTrials);
  %trialcounterodor=zeros(numel(x_conc),NumTrials);
  odorresponse = zeros(x_conc_size,NumTrials);
  
  %for loop that saves the mouse's response depending on the sound level
  %and the presence of odor
  for Trials=1:NumTrials
    %sound level for the kth file and Trial
    sound = Data.sound_level(Trials);
    %conc for the kth file and trial
    conc = Data.concentration(Trials);
    %mouse's response for the kth file and trial
    mouseresponse=Data.response(Trials);
    %loops through every sound level to compare the current sound level
    %with and to see if there is odor or not for this trial
    if sound == 0
        for e=1:x_conc_size
            if conc == x_conc(e)
                odorresponse(e,Trials) = mouseresponse;
                trialcounter(e,Trials) = 1;
            end
        end
    end
  end
  %sums up the trial counter and adds it to the trial counter holder
  trialcounterarray(:,k)=sum(trialcounter,2);
  
  %loops through each sound level with no odor and determines how many of
  %each trial there were
  for p=1:x_conc_size
    %initializes counter for each response type
    gohit=0;
    gomiss=0;
    nogohit=0;
    nogomiss=0;
    %loops through all the trials to save each response
    for w=1:NumTrials
      %takes the current response
      response=odorresponse(p,w);
      %compares the current response to all response types
      if response == 1 || response == 5
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
end

%% Calculates all necessary performance data based on the data stored above

%calculates the percent correct for no odor
percorrarray=gohitarray./(gohitarray+gomissarray);

%calculates the false alarm percent for no odor
FAarray=nogomissarray./(nogomissarray+nogohitarray);

%only takes the top row of false alarm data for no odor (only works for 0dB
%as no go trial)
FAarray=FAarray(1,:);


%takes everything besides the first row of the percent correct no odor(this is to
%remove the zeros where the FA data was)
percorrarray=percorrarray(2:end,:);

%inverts the percent correct array for no odor and saves it as y
y_conc=percorrarray';

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

%calculates the standard deviation of the False alarm array
sdFA=std(FAarray);

%calculates the standard error by dividing the standard deviation of the
%false alarm with no odor by the number of columns of files with sound only
steFA=sdFA/(sqrt(column));

%% Calculates Psychometric curve and plots all data from above

%initializes a figure
hfig = figure();

%creates an axis position for the figure (can change if graph does not fit)
axes('position',[.1,.25,.8,.7])
%makes these values the limits of the x axis
xlim([log10(x_conc(2)) log10(max(x_conc))])
%xlim([0 4])
%sets the xtick of the figure to be the largest and smallest number of the
%input sound levels
xticks(log10(x_conc))
%set(hfig,'xscale','log')

%plots error bars for the first sound level (can be changed if zero is not
%the first sound level and it is not the nogo trial) and the average of the
%false alarm for no odor and its standard error

%e1=errorbar(x(1),mean(FAarray),steFA,'or');
%e25 = semilogx(x(1),mean(FAarray),'ok');
e2 = yline(mean(FAarray),'r','LineWidth',1.5);
f1 = yline(mean(FAarray)+steFA,'r','LineWidth',1.5);
f2 = yline(mean(FAarray)-steFA,'r','LineWidth',1.5);
vert = [log10(x_conc(2)) mean(FAarray)-steFA; log10(x_conc(2)) mean(FAarray+steFA); log10(max(x_conc+1)) mean(FAarray)+steFA; log10(max(x_conc+1)) mean(FAarray)-steFA];
f = [1 2 3 4];
patch('Faces',f,'Vertices',vert,'FaceColor','red','FaceAlpha',0.25)
hold on

%creates a holder to store original x (sound levels)
holdx=x_conc;
%for loop that takes out the zero sound level since we do not want to
%include that in our threshold calculations (works only if zero is the no
%go trial)
for o=1:numel(x_conc)
  %if there is zero in the sound levels then take it out
  if x_conc(o)==0
    %takes out the zero
    x_conc(o)=[];
    %whenever zero is detected, the for loop is stopped
    break
  end
end

%plots error bars for the sound levels without zero and the average of the
%mean percent correct no odor along with the standard error
e3=errorbar(log10(x_conc),meanpercorr',stecorr,'or');
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
x1=x_conc;
%finds the size of the y data for no odor
[m,n]=size(y_conc);
%makes x into the same size as the y data
for i=1:m
  %for the first number, x equals itself
  if i==1
    x_conc=x_conc;
  %after the first index, x1 gets added as a row to the current value of x
  else
    x_conc=[x_conc;x1];
  end
end

%calls fitLogGrid using all the data from both x and y for no odor
[params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(log10(x_conc(:)),y_conc(:));
%creates 100 data points ranging from the smallest to the largest value in
%the x data
xf=linspace(min(log10(x_conc(:))),max(log10(x_conc(:))),100);
hold on
%plots the x line data and uses the model from fitLogGrid, the parameters
%from fitLogGrid and the x line data
xsig = xf;
ysig = mdl(params,xf);
hold on
e5=plot(xsig,ysig,'r');
%e5=semilogx(xsig,ysig,'r','LineWidth',2);

% sess = zeros(1,length(theFiles));
% for f = 1:length(theFiles)
%     j = theFiles(f).name;
%     ss=h5read(j,'/Trials');
%     sess(f) = ss.session(1);
% end

num_files = numel(theFiles);
% if numel(theFiles) == 1
%     title("Odor Only Trials for Mouse "+ convertCharsToStrings(mousenum) + "; " + "Session: " + convertCharsToStrings(Data.session(1)))
% else 
%     title("Combined Odor Only Trial Data (n = " + convertCharsToStrings(num_files) + "); "+ "Mouse "+ convertCharsToStrings(mousenum))%convertCharsToStrings(Data.session(1)))
% end
    hold on
%creates a vertical line at the threshold value and gives this threshold a
%name
convert_threshold = 10^threshold;
odorthresh=xline(threshold,'--r','DisplayName',"odor Only Threshold = "+convertCharsToStrings(threshold));%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
%e60=xline(threshold,'--r','DisplayName',"Actual Threshold = "+convertCharsToStrings(convert_threshold));%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')

eleg=legend(odorthresh,'location','best');

%% Creates a table that gets added to the bottom of the graph for number of trials
% 
% %sums the trial counter for no odor across all rows
% NumberofTrials=sum(trialcounterarray,2);
% %creates a variable using all the sound levels (including zero)
% Concentrations = holdx';
% 
% %creates a table from the sound level data, and both numbers of trials for
% %each condition odor and no odor
% T = table(Concentrations,NumberofTrials);
% %makes the table into a cell array
% tableCell = table2cell(T);
% %calls the table property of variable names and sets them while also
% %padding them with space on each side so they are centered
% T.Properties.VariableNames=pad({'Concentration: ','# of Trials: '},'both');
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
% tableChar = splitapply(@strjoin,pad(tableCell,10),[1;2]);
% %allows the table to be plotted as a text point, specifying the data point,
% %and also font, and where on the axis the table appears (can be changed if
% %data does not fit)
% t=text(.2,1.25,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
% %sets the font size of the text (can be made smaller if data does not fit)
% t.FontSize=10;
% hold on

end