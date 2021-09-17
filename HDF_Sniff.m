%% Last edit made by Kyle Mabry on 3/30/2020
% This is a script that takes HDF formatted experimental data and converts
% it into a data type that's understandable by MATLAB. From there we can export behavorial data to a .csv file
% for later analysis, or use the following code to interpret the data in
% MATLAB. This code also does some preliminary pre-processing of the data
% by totaling the number of trials, correct vs. incorrect responces etc... 

function HDF_Sniff()

close all;
clear all;
clc;

windowSize = 10; % Setting parameters/window of the moving filter that happens later on, in ms. Try to keep to a range of 5-50ms based on literature.
Scanner = 0;   %Was the data recorded in the MRI scanner? This will effect which plots are generated later on. Set to 1 or 0.

%  NameFile= [input('What is the name of the HDF5 file):  ','s') '.h5'];
FileNameInput = input('What is the name of the HDF5 file: ','s');  % Get the file name without the .hd5 (useful later on when saving excel file.
NameFile = append(FileNameInput, '.h5');  % combine the two strings so we can find the file.
Data =  h5read(NameFile,'/Trials');
% mouse = input("What is the number of this mouse? ");
NumTrials = length(Data.trialNumber); %Determine the number of trials in this experiment in order to get the sniff data later on.
Fs = 1000; %Our sampling frequency is 1000Hz.

%%  Take the behavorial data and output it to a .csv file.
% Get the animal's response time in miliseconds by subtracting their first lick by the odor valve onset.
% for each tiral in the experiment.

for Trials = 1:NumTrials
    % response time is equal to the time of the first lick minus the time
    % of the odor valve onset.
    responseTime = (Data.first_lick(Trials) - Data.final_valve_onset(Trials));
    % if the response time is negative then just set it equal to zero.
    if responseTime < 0
        responseTime = 0;
    end
    % save the response time into a string array.
    behavorialResponseArray(1,Trials) = "Trial number:  " + Trials;
    behavorialResponseArray(2,Trials) = "Response Time (ms)";
    behavorialResponseArray(3,Trials) = responseTime;
end

% Initialize behavorial response arrays that tally the total number of
% responses of each type to be output into the final excel sheet later on. 
LeftHitCounter = 0;
RightHitCounter = 0;
LeftMissCounter = 0;
RightMissCounter = 0;
LeftNoResponseCounter = 0;
RightNoResponseCounter = 0;
% Behavorial response array.
behavorialResponseArray(8, 2) = "Left hit";
behavorialResponseArray(9, 2) = "Right hit";
behavorialResponseArray(10, 2) = "Left miss";
behavorialResponseArray(11, 2) = "Right miss";
behavorialResponseArray(12, 2) = "Left no response";
behavorialResponseArray(13, 2) = "Right no response";
% Determine whether behavior of mouse was correct for the given trial.
% 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss
% 5 = Left no response -- 6 = Right no response
for Trials = 1:NumTrials
    % Get the animal's response for this trial.
    mouseResponse = Data.response(Trials);
    % Label which trial this is.
    behavorialResponseArray(4, Trials) = "Mouse's behavior";
    % Save the numerical result of this mouses' behavorial for the trial.
    behavorialResponseArray(5, Trials) = mouseResponse;
    % Translate the animals response for the trial.
    if mouseResponse == 1
        behavorialResponseArray(6, Trials) = "Left hit";
        LeftHitCounter = LeftHitCounter + 1;
        behavorialResponseArray(8, 1) = LeftHitCounter;
    elseif mouseResponse == 2
        behavorialResponseArray(6, Trials) = "Right hit";
        RightHitCounter = RightHitCounter + 1;
        behavorialResponseArray(9, 1) = RightHitCounter;
    elseif mouseResponse == 3
        behavorialResponseArray(6, Trials) = "Left miss";
        LeftMissCounter = LeftMissCounter + 1;
        behavorialResponseArray(10, 1) = LeftMissCounter;
    elseif mouseResponse == 4
        behavorialResponseArray(6, Trials) = "Right miss";
        RightMissCounter = RightMissCounter + 1;
        behavorialResponseArray(11, 1) = RightMissCounter;
    elseif mouseResponse == 5
        behavorialResponseArray(6, Trials) = "Left no response";
        LeftNoResponseCounter = LeftNoResponseCounter + 1;
        behavorialResponseArray(12, 1) = LeftNoResponseCounter;
    elseif mouseResponse == 6
        behavorialResponseArray(6, Trials) = "Right no response";
        RightNoResponseCounter = RightNoResponseCounter + 1;
        behavorialResponseArray(13, 1) = RightNoResponseCounter;
    end
end

% Also indicate the total number of trials for this training session. 
behavorialResponseArray(15, 1) = NumTrials;
behavorialResponseArray(15, 2) = 'Total number of trials';

% save the response time data and the behavorial response data to an excel file.
writematrix(behavorialResponseArray, ("Interpreted_Data_" + convertCharsToStrings(FileNameInput)), 'FileType', 'spreadsheet');
% writematrix(behavorialResponseArray, ("Interpreted Data Mouse " + mouse + " " + datestr(now,'yyyy_mm_dd') + datestr(now)), 'FileType', 'spreadsheet');
%format:  writematrix(dataset, "title of file", 'FileType', 'spreadsheet')

%  KJM commented out 4/7/2020
% %% Start looking at the sniffing data.
% % Get the sniff data all into one cell array.
for Trials = 1:NumTrials
    CurrentTrial = Data.trialNumber(Trials); %Becasue for whatever reason some trials are missing in HDF, this makes sure we don't input a trial that doesn't exist.
    % for the first 9 trials.
    if CurrentTrial < 10
        LessThan10 = CurrentTrial;
        TimeAxis{CurrentTrial} = h5read(NameFile,(['/Trial000'   num2str(LessThan10) '/Events']));

        PacketTime1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.packet_sent_time);
        PacketTime = cell2mat(PacketTime1(CurrentTrial));
        SniffSamples1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.sniff_samples);
        SniffSamples = cell2mat(SniffSamples1(CurrentTrial));


        for x = 1:length(PacketTime)
            for y = 1:(SniffSamples(x)-1) %There is a -1 here because the first value for each packettime already exists and this loop would recreate the first value each time otherwise.
                PacketTime(x, y+1) = PacketTime(x) - y; %This updates the time vector into an NxN array.
            end
        end

        %         PacketTime = fliplr(PacketTime); % reorients the data properly.


    end

    SniffData{CurrentTrial} = h5read(NameFile,(['/Trial000'   num2str(LessThan10) '/sniff']));
    TriggerData{CurrentTrial} = h5read(NameFile,(['/Trial000'   num2str(LessThan10) '/mri']));

    % for trials 10-99
    if CurrentTrial >=10  &&  CurrentTrial < 100
        Between10and100 = CurrentTrial;
        TimeAxis{CurrentTrial} = h5read(NameFile,(['/Trial00'   num2str(Between10and100)  '/Events']));


        PacketTime1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.packet_sent_time);
        PacketTime = cell2mat(PacketTime1(CurrentTrial));
        SniffSamples1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.sniff_samples);
        SniffSamples = cell2mat(SniffSamples1(CurrentTrial));

        for x = 1:length(PacketTime)
            for y = 1:(SniffSamples(x)-1)
                PacketTime(x, y+1) = PacketTime(x) - y;

            end
        end


        %         PacketTime = fliplr(PacketTime);

        SniffData{CurrentTrial} = h5read(NameFile,(['/Trial00'   num2str(Between10and100)  '/sniff']));
        TriggerData{CurrentTrial} = h5read(NameFile,(['/Trial00'   num2str(Between10and100)  '/mri']));
    end
    % for trials 100+
    if  CurrentTrial >= 100

        GreaterThan100 = CurrentTrial;
        TimeAxis{CurrentTrial} = h5read(NameFile,(['/Trial0'   num2str(GreaterThan100)  '/Events']));


        PacketTime1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.packet_sent_time);
        PacketTime = cell2mat(PacketTime1(CurrentTrial));
        SniffSamples1{CurrentTrial} = double(TimeAxis{1,CurrentTrial}.sniff_samples);
        SniffSamples = cell2mat(SniffSamples1(CurrentTrial));

        for x = 1:length(PacketTime)
            for y = 1:(SniffSamples(x)-1)
                PacketTime(x, y+1) = PacketTime(x) - y;

            end
        end


        %          PacketTime = fliplr(PacketTime);

        SniffData{CurrentTrial} = h5read(NameFile,(['/Trial0'  num2str(GreaterThan100)    '/sniff']));
        TriggerData{CurrentTrial} = h5read(NameFile,(['/Trial0'  num2str(GreaterThan100)    '/mri']));



    end
    PacketTime2{Trials} = PacketTime; %Creates the final storage cell for the timepoints collected for time axis.
    SniffSamples2{Trials} = SniffSamples; %Each of these two lines stores the data into a cell array after the first run of the "Trials" for loop, this way it won't be written over in the next run of the loop.
end

%% Trying to concatinate the time axis. Trouble in this section.
EntireAxisFinal = 0; %Setting the first value equal to zero so we can vertically concatinate later on. We'll get rid of this zero later as well.
for i = 1:length(PacketTime2)
    EntireAxis = cat(1, PacketTime2{i});

    A = flip(EntireAxis,2);
    EntireAxis2 = reshape(A', 1, size(EntireAxis,1) * size(EntireAxis,2));
    EntireAxis2 = EntireAxis2(EntireAxis2~=0)';
    EntireAxisFinal = vertcat(EntireAxisFinal, EntireAxis2);  % We need this last step to make a final concatination of the vectors into a single array.
end

EntireAxisFinal = EntireAxisFinal(EntireAxisFinal~=0);      %finds the zeros and only takes values that aren't equal to zero.


%%
EntireSniff = cat(1, SniffData{:}); %Combines all of the cell arrays into a single cell array
EntireSniff2 = cell2mat(EntireSniff);  %Combines the final cell array into a single vector.

EntireSniff2 = -EntireSniff2; %This flips the signal so that the inhale goes up and exhale goes down.

EntireTrigger = cat(1, TriggerData{:});
EntireTrigger = cell2mat(EntireTrigger);

EntireTrigger = EntireTrigger - (windowSize/2);

%% Making sure that EntireAxisFinal is equal in length to EntireSniff2, if it's not we can't proceed.
% If they're not equal in length this loop will add NaNs to the end of the
% shorter vector until they are equal in length.

if length(EntireSniff2) ~= length(EntireAxisFinal)
    if (length(EntireSniff2) - length(EntireAxisFinal)) > 0
        for i = 1:(length(EntireSniff2) - length(EntireAxisFinal))
            EntireAxisFinal(end+1) = NaN;
        end
    elseif (length(EntireSniff2) - length(EntireAxisFinal)) < 0
        for i = 1:abs((length(EntireSniff2) - length(EntireAxisFinal)))
            EntireSniff2(end+1) = NaN;
        end
    end
end


%% Filling in the missing gaps with NaN for sniff data (because some of the data wasn't recorded).
CorrAxis = (EntireAxisFinal(1) : EntireAxisFinal(end))';
Index = zeros((EntireAxisFinal(end)-EntireAxisFinal(1)),1);


figure(55)
hold on
title('This figure should have a continuous slope of 1 if our time axis is recorded without any gaps.');
plot(EntireAxisFinal) %This figure should have a continuous slope of 1 if our time axis is recorded without any gaps.
slopem = diff(EntireAxisFinal);
aa = find(slopem ~= 1);
hold off

newvecSniff = nan(size(CorrAxis));
newvecSniff(ismember(CorrAxis,EntireAxisFinal))=EntireSniff2;

figure(56)
hold on
title('This figure will show gaps in the sniff data where it was not recorded');
plot(CorrAxis,newvecSniff)
hold off
%% Setting parameters of the moving filter.
% windowSize = 50; %This line happens at the top of the script now.
b = (1/windowSize)*ones(1,windowSize);
a = 1;

movFiltered = filter(b,a,newvecSniff);

for numdeletions = 1:(windowSize/2) %Shift the signal by half of the window so that the timing of the filtered and raw signal align.
    movFiltered(numdeletions) = [];
end

for i = 1:(windowSize/2)
    movFiltered(end + 1) = NaN; %Puts NaNs at the end of the sniff data to make sure the vector will align with the time axis vector later on.
end

%% Get Data for trial starting and ending.
for TrialSE = 1:NumTrials
    Trial_Start(TrialSE) = Data.trial_start(TrialSE) - (windowSize/2);
    Trial_End(TrialSE) = Data.trial_end(TrialSE) - (windowSize/2);
end



%% Get Data for Licking to plot above the sniff.
for Licks = 1:NumTrials
    Lick_start(Licks) =  Data.first_lick(Licks) - (windowSize/2);
    if Lick_start(Licks) ~= 0  %Making sure that the current tiral had a lick in it.
        for Extend = 1:1000 %The last number will be the length of the lick signal in ms.
            Lick_extended(Licks, Extend) = (Lick_start(Licks) + Extend); %Makes the sniff data point longer for visualization.
        end
    end
end

%% Get data for final valve opening
for Valve = 1:NumTrials
    Valveopen(Valve) =  Data.final_valve_onset(Valve) - (windowSize/2);
    if Valveopen(Valve) ~= 0 || -(windowSize/2)  %Making sure that the current tiral had a lick in it.
        for Extend = 1:1000 %The last number will be the length of the lick signal in ms.
            Valve_Extend(Valve, Extend) = (Valveopen(Valve) + Extend); %Makes the sniff data point longer for visualization.
        end
    end
end

%% Get data for results of trial, correct, incorrect, left miss etc...
for Responses = 1:NumTrials
    ResponseType(Responses) = Data.response(Responses);
end

% 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss
% 5 = Left no response -- 6 = Right no response

%% Getting parameters recieved time
for Parameters = 1:NumTrials
    Parms(Parameters) = Data.parameters_received_time(Parameters);
end



%% Figures

if Scanner ~= 1
    %Raw data
    figure(3)
    plot(CorrAxis,movFiltered,'r')
    hold on
    title('filtered signal whole trace')
    hold off

    figure(1)
    % Account for the shifted data after filtering by deleting first number of trials based on the window size.
    plot(CorrAxis,newvecSniff,'b') % Plot of the raw data before filtering.
    hold on
    xlim([1 8*length(newvecSniff)/Fs]);
    xlabel('Time in ms') % Assuming our sampling frequency is 1000Hz and is correct.
    title('Sniff Signal filtered vs. not filtered');
    plot(CorrAxis,movFiltered,'r') %Plot the filtered and shifted signal.
    for LickExtend = 1: size(Lick_extended,1)
        x = Lick_extended(LickExtend,:);
        y = ones(1,length(Lick_extended));
        if x ~=0
            plot(x,y,'r')
            hold on
            %         ylim([-50 50])
        end
    end
    hold off

    figure(2)
    plot(CorrAxis,movFiltered,'r')
    hold on
    xlabel('Time in ms')
    xlim([1 3*length(newvecSniff)/Fs]);
    title('filtered signal scaled better with licking')
    for LickExtend = 1: size(Lick_extended,1)
        x = Lick_extended(LickExtend,:);
        y = ones(1,length(Lick_extended));
        if x ~=0
            plot(x,y,'r')
            hold on
            %         ylim([-50 50])
        end
    end
    hold off

    %Plotting raw data vs. cleaned data with triggers and start/end times
    figure(99)
    plot(CorrAxis,newvecSniff,'r')
    hold on
    title('raw data vs. cean data with triggers')
    plot(CorrAxis,movFiltered,'b')
    for LickExtend = 1: size(Lick_extended,1)
        x = Lick_extended(LickExtend,:);
        y = ones(1,length(Lick_extended));
        if x ~=0
            plot(x,y,'blue')
            hold on
            plot([x(1) x(1)],[-10,10],'blue') %Marks the beginning of the recorded licking response.
            ylim([-50 50])
        end
    end
    for Valveextend = 1: size(Valve_Extend,1)
        x = Valve_Extend(Valveextend,:);
        y = zeros(1,length(Valve_Extend));
        if Valveopen(Valveextend) ~= -(windowSize/2)
            %         plot(x,y,'r')
            hold on
            plot([Valveopen(Valveextend) Valveopen(Valveextend)],[-19,19],'r') %Marks the valve opening.
            ylim([-50 50])
        end
    end
    for PArameters = 1: length(Parms)
        x = double(Parms(PArameters));
        if x ~=0
            plot(x,'yellow')
            hold on
            plot([x(1) x(1)],[-15,15],'yellow') %Marks the valve opening.
            ylim([-50 50])
        end
    end
    for Trigger = 1: length(EntireTrigger)
        x = double(EntireTrigger(Trigger));
        if x ~=0
            plot(x,'green')
            hold on
            plot([x(1) x(1)],[-15,15],'green') %Marks the trigger.
            ylim([-50 50])
        end
    end
    for TStart = 1:size(Trial_Start,2)
        xx = double(Trial_Start(TStart));
        zz = Trial_End(TStart);
        yy = sprintf('%d',ResponseType(TStart));
        if xx && zz ~= 0
            plot([xx xx],[-25,25],'black') %Marks the Start of the trial.
            hold on
            plot([zz zz],[-25,25],'black') %Marks the end of the trial.
            text((xx-2500), 7 ,['Trial Number: ' num2str(TStart)], 'FontSize',8,'Color','black'); %Plots the current trial number to the left of the trial starting line.
            text((xx-2500), 5 ,['Response: ' yy], 'FontSize',8,'Color','black'); %Plots the animals response. 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss -- 5 = Left no response -- 6 = Right no response
            ylim([-50 50])
        end
    end
    hold off

    % Plot a graph with the licking and the sniff signal.
    figure(4)
    plot(CorrAxis,movFiltered,'b')
    hold on
    title('filtered signal whole trace')
    for LickExtend = 1: size(Lick_extended,1)
        x = Lick_extended(LickExtend,:);
        y = ones(1,length(Lick_extended));
        if x ~= 0
            plot(x,y,'blue')
            hold on
            plot([Lick_start(LickExtend) Lick_start(LickExtend)],[-10,10],'blue') %Marks the beginning of the recorded licking response.
            ylim([-50 50])
        end
    end
    for Valveextend = 1: size(Valve_Extend,1)
        x = Valve_Extend(Valveextend,:);
        y = zeros(1,length(Valve_Extend));
        if Valveopen(Valveextend) ~= -(windowSize/2)
            %         plot(x,y,'r')
            hold on
            plot([Valveopen(Valveextend) Valveopen(Valveextend)],[-19,19],'r') %Marks the valve opening.
            ylim([-50 50])
        end
    end
    for TStart = 1:size(Trial_Start,2)
        xx = double(Trial_Start(TStart));
        zz = Trial_End(TStart);
        yy = sprintf('%d',ResponseType(TStart));
        if xx && zz ~= 0
            plot([xx xx],[-25,25],'black') %Marks the Start of the trial.
            hold on
            plot([zz zz],[-25,25],'black') %Marks the end of the trial.
            text((xx-2500), 7 ,['Trial Number: ' num2str(TStart)], 'FontSize',8,'Color','black'); %Plots the current trial number to the left of the trial starting line.
            text((xx-2500), 5 ,['Response: ' yy], 'FontSize',8,'Color','black'); %Plots the animals response. 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss -- 5 = Left no response -- 6 = Right no response
            ylim([-50 50])
        end
    end
    for Trigger = 1: length(EntireTrigger)
        x = double(EntireTrigger(Trigger));
        if x ~=0
            plot(x,'green')
            hold on
            plot([x(1) x(1)],[-15,15],'green') %Marks the trigger.
            ylim([-50 50])
        end
    end
    hold off
end

%% Make a plot for analysing data that comes from the MRI scanner

if Scanner == 1
    % Plot a graph with the licking and the sniff signal.
    figure(100)
    plot(CorrAxis,movFiltered,'b')
    hold on
    title('filtered signal whole trace: viewing MRI data')
    for LickExtend = 1: size(Lick_extended,1)
        x = Lick_extended(LickExtend,:);
        y = ones(1,length(Lick_extended));
        if x ~= 0
            plot(x,y,'blue')
            hold on
            plot([Lick_start(LickExtend) Lick_start(LickExtend)],[-400,400],'blue') %Marks the beginning of the recorded licking response.
            ylim([-600 600])
        end
    end
    for Valveextend = 1: size(Valve_Extend,1)
        x = Valve_Extend(Valveextend,:);
        y = zeros(1,length(Valve_Extend));
        if Valveopen(Valveextend) ~= -(windowSize/2)
            %         plot(x,y,'r')
            hold on
            plot([Valveopen(Valveextend) Valveopen(Valveextend)],[-425,425],'r') %Marks the valve opening.
            ylim([-600 600])
        end
    end
    for TStart = 1:size(Trial_Start,2)
        xx = double(Trial_Start(TStart));
        zz = Trial_End(TStart);
        yy = sprintf('%d',ResponseType(TStart));
        if xx && zz ~= 0
            plot([xx xx],[-450,450],'black') %Marks the Start of the trial.
            hold on
            plot([zz zz],[-450,450],'black') %Marks the end of the trial.
            text((xx-2500), 7 ,['Trial Number: ' num2str(TStart)], 'FontSize',8,'Color','black'); %Plots the current trial number to the left of the trial starting line.
            text((xx-2500), 5 ,['Response: ' yy], 'FontSize',8,'Color','black'); %Plots the animals response. 1 = left hit -- 2 = right hit -- 3 = left miss -- 4 = right miss -- 5 = Left no response -- 6 = Right no response
            ylim([-600 600])
        end
    end
    for Trigger = 1: length(EntireTrigger)
        x = double(EntireTrigger(Trigger));
        if x ~=0
            plot(x,'green')
            hold on
            plot([x(1) x(1)],[-425,425],'green') %Marks the trigger.
            ylim([-600 600])
        end
    end
    hold off
end

%% figuring out where the sniff is with regard to odor onset.

for OdorON = 1:double(length(Valveopen))
    if double(Valveopen(OdorON)) ~= -(windowSize/2) && (double(Valveopen(OdorON))) < length(newvecSniff)
        SniffMagnitude(OdorON) = newvecSniff(double(Valveopen(OdorON))); %Using raw signal
    end
end

figure(10)
histogram(SniffMagnitude)
hold on
title('Sniff Magnitude when odor is triggered')
hold off

%% Make a new figure where we plot the slope of the sniff line at the time
% of the final valve triggering. Use diff function and slope should be
% positive for a triggering at the inhale. Exhale = neg slope / Inhale =
% pos slope.

derivSniff = diff(newvecSniff);


for OdorON2 = 1:double(length(Valveopen))
    if double(Valveopen(OdorON2)) ~= -(windowSize/2) && (double(Valveopen(OdorON2))) < length(newvecSniff)
        SniffSlope(OdorON2) = derivSniff(double(Valveopen(OdorON2))); %Taking the derivative of the sniff signal at the timepoint when the odor valve is opened.
    end
end

figure(15)
histogram(SniffSlope);
hold on
title('Slope of the sniff when final valve is opened'); %Slope should be neg for exhale and positive for inhale
hold off

%% Calculating time between most recent trigger and final valve opening

for i =1: length(Valveopen)
    MRIindex(i) = find(abs((double(EntireTrigger)-double(Valveopen(i)))) < 500,1);
    EntireTrigger = double(EntireTrigger);  %This just converts the current trigger data into a double so that we can compare it with other double formated data.
    MRITimeDiff(i) = double(Valveopen(i)) - EntireTrigger(MRIindex(i));
end

figure(17)
histogram(MRITimeDiff);
hold on
title('difference in time between trigger and valve opening, pos number means valve opens after trigger');
xlabel('number of trials');
hold off

figure(18)
plot(MRITimeDiff);
hold off
title('difference in time between trigger and valve opening, pos number means valve opens after trigger');
xlabel('number of trials');
hold off


end

