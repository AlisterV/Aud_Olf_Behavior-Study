%% Initializes Files and organizes them 
%clears all previous data variables
clear all
%closes all previous figures
close all
%specifies the folder
myFolder = 'C:\VoyeurData';
key = '070lt';
valveConc = [5,8,9; 0,0.01,0.00001];
% Get a list of all files in the folder with the desired file name pattern.
files = dir(myFolder);
selection = struct;
for i=1:length(files)
    if contains(files(i).name, key) && (~contains(files(i).name, 'Interpreted'))
        selection(end+1).name = files(i).name;
        selection(end).date = files(i).date;
        selection(end).days = day(datetime(files(i).date), 'dayofyear');
    end
end
selectionT = struct2table(selection);  %convert structure to table
nonEmpty = selectionT(2:end,:);   %remove empty row
sorted = sortrows(nonEmpty,3); 
theFiles = table2struct(sorted);

%% loops through every file
GoHitRates = zeros(1,length(theFiles));
FalseAlarmRates = zeros(1,length(theFiles));
for i = 1:length(theFiles)
    %reads the file into matlab
    Data = h5read(theFiles(i).name,'/Trials');
    %output = arrayfun(@(x,y) x*y, A,B);
    airDilution = Data.nitrogen_flow/1000;
    liquidDilution = odorconcData.odorvalve
    trialConc = arrayfun(@(airDilution,liquid) air*liquid, 
    GoHit = sum(Data.response==1);
    NoGoHit = sum(Data.response==2);
    GoMiss = sum(Data.response==3);
    NoGoMiss = sum(Data.response==4);
    GoNum = sum(Data.trial_type_id==1);
    NoGoNum = sum(Data.trial_type_id==0);
    Pauses = find(Data.response==0);
    for trial = Pauses
        if Data.trial_type_id(trial)==0
            NoGoNum = NoGoNum-1;
        elseif Data.trial_type_id(trial)==1
            GoNum = GoNum-1;
        end
    end
    GoHitRates(i) = GoHit/GoNum;
    FalseAlarmRates(i) = NoGoMiss/NoGoNum;
end