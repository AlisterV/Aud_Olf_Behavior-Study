function finaltask_soundvsconc(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)

%% SOUND VS. ODOR

holdx = x_conc;

for v = 1:x_sound_size
    curr_snd = x_sound(v);
    x_conc = holdx;
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
            if sound == curr_snd
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
    %FAarray=nogomissarray./(nogohitarray+nogomissarray);
    %only takes the top row of false alarm data for no odor (only works for 0dB
    %as no go trial)
    %FAarray=FAarray(1,:);
    
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
    %sdFA=std(FAarray);
    %calculates the standard error by dividing the standard deviation of the
    %false alarm with no odor by the number of columns of files with sound only
    %steFA=sdFA/(sqrt(column));
    
    %% Calculates Psychometric curve and plots all data from above
    
    [odorthresh] = finaltask_odoronly(x_conc, x_conc_size,theFiles);
    hold on
    %creates an axis position for the figure (can change if graph does not fit)
    %axes('position',[.1,.25,.8,.7])
    %sets the xtick of the figure to be the largest and smallest number of the
    %input sound levels
    %xticks(min(x_sound):10:max(x_sound))
    %makes these values the limits of the x axis
    %xlim([min(x_sound(2)) max(x_sound)])
    
    %plots error bars for the first sound level (can be changed if zero is not
    %the first sound level and it is not the nogo trial) and the average of the
    %false alarm for no odor and its standard error
%     e2 = yline(mean(FAarray),'r','LineWidth',1.5);
%     f1 = yline(mean(FAarray)+steFA,'r','LineWidth',1.5);
%     f2 = yline(mean(FAarray)-steFA,'r','LineWidth',1.5);
%     vert = [x_sound(2) mean(FAarray)-steFA; x_sound(2) mean(FAarray+steFA); max(x_sound+1) mean(FAarray)+steFA; max(x_sound+1) mean(FAarray)-steFA];
%     f = [1 2 3 4];
%     patch('Faces',f,'Vertices',vert,'FaceColor','red','FaceAlpha',0.25)
%     hold on
    
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
    hold on
    e3=errorbar(log10(x_conc),meanpercorr',stecorr,'ob');
    
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
    title("Concentration Trials w/ Sound " +convertCharsToStrings(curr_snd) + " for Mouse: "+convertCharsToStrings(mousenum) + "; " + "Session: " + convertCharsToStrings(Data.session(1)));
    hold on
    
    %holds onto current value of x
    x2=x_conc;
    %finds the size of the y data for no odor
    [m,n]=size(y_conc);
    %makes x into the same size as the y data
    for i=1:m
        %for the first number, x equals itself
        if i==1
            x_conc=x_conc;
            %after the first index, x1 gets added as a row to the current value of x
        else
            x_conc=[x_conc;x2];
        end
    end
    
    %calls fitLogGrid using all the date from both x and y for odor
    [params,mdl,odorthreshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(log10(x_conc(:)),y_conc(:));
    %creates 100 data points ranging from the smallest to the largest value in
    %the x data
    xf=linspace(min(log10(x_conc(:))),max(log10(x_conc(:))),100);
    hold on
    %plots the x line odor data and uses the model from fitLogGrid, the odor parameters
    %from fitLogGrid and the x line odor data
    xsig = xf;
    ysig = mdl(params,xf);
    e7=plot(xsig,ysig,'b');
    %e7=plot(xfodor,odormdl(odorparams,xfodor),'b');
    hold on
    %creates a vertical line at the odor threshold value and gives this threshold a
    %name
    odor_thresh_array(1,v) = odorthreshold;
    e8=xline(odorthreshold,'--b','DisplayName',"Threshold = "+convertCharsToStrings(odorthreshold));%,'LabelHorizontalAlignment','right','LabelVerticalAlignment','bottom')
    %creates a legend for the figure but only shows variables e6(threshold no
    %odor) and e8(threshold odor) and places it at the best location
    eleg=legend([e8 odorthresh],'location','best');
end
end