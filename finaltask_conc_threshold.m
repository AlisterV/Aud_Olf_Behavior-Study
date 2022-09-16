function [odorthresh] = finaltask_conc_threshold(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)


%the following initialize arrays that have the number of rows of the input
%x, and have the number of columns of the length of the files selected

%nogomissarrayodor=zeros(numel(x_conc),length(theFiles));
trialcounterarray=zeros(x_conc_size,length(theFiles));
%trialcounterarrayodor=zeros(numel(x_conc),length(theFiles));   
thresholdarray=zeros(1,length(theFiles));

holdx = x_conc;

%loops through every file
for k = 1 : length(theFiles)
    x_conc = holdx;
    gohitarray=zeros(x_conc_size,1);
    %gohitarrayodor=zeros(numel(x_conc),length(theFiles));
    nogohitarray=zeros(x_conc_size,1);
    %nogohitarrayodor=zeros(numel(x_conc),length(theFiles));
    gomissarray=zeros(x_conc_size,1);
    %gomissarrayodor=zeros(numel(x_conc),length(theFiles));
    nogomissarray=zeros(x_conc_size,1);
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
  
  %% Calculates Psychometric curve and plots all data from above
  
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
  
  thresholdarray(1,k) = threshold;
end

%inverts the percent correct array for no odor and saves it as y
thresh=thresholdarray';

%calculates the standard deviation of the percent correct array for no odor
sdcorr=std(thresholdarray,0,2);

%finds the size of the percent correct array for no odor
[row,column]=size(thresholdarray);

%calculates the standard error from the standard deviation for no odor and
%divides it by the column variable (the number of files selected with no
%odor)
stecorr=sdcorr./(sqrt(column));

figure()
sess_array = {};%zeros(1,length(theFiles));
for p = 1:length(theFiles)
    %selects the kth file
    fullFileName = theFiles(p).name;
    %reads the h5 file of the kth file
    Data=h5read(fullFileName,'/Trials');
    sess = "Sess: " + string(Data.session(1));
    sess_array(1,p) = {sess};
    scatter(1,thresholdarray(p))
    hold on
    %cellfun(@convertCharsToStrings,sess)
end
hold on
legend(sess_array)
errorbar(1, mean(thresholdarray),stecorr,'b')
xlim([0 2])
xticks([0 1 2])
xlabel('Odor Threshold')
ylabel('Concentration')
title('Concentration Thresholds by Session')
end