%% Last edit made by Alister Virkler on 9/16/2022
%This code creates multiple data graphs for the final behavioral task. It
%creates a psychometric curve for all combinations of stimuli. threshold
%comparisons in bar format (average) and direct comparisons between single
%stimuli and multimodal stimuli

%NOTE: does not yet work for different concentrations in different files

function [y, yodor, FAarray, FAarrayodor, xsig, xsigodor, ysig, ysigodor, threshold, odorthreshold, gohitarray, gohitarrayodor, gomissarray, gomissarrayodor, nogohitarray, nogohitarrayodor, nogomissarray, nogomissarrayodor, trialcounterarray, trialcounterarrayodor] = finaltask()

%% Initializes Files and organizes them 
%clears all previous data variables
clear all
%closes all previous figures
close all
%specifies the folder
myFolder = 'C:\VoyeurData';

%This can be uncommented to allow the user to input the desired sound
%levels
%answer=inputdlg('Enter Sound Levels Used: ');
%x=str2num(answer{1});

%hard coded sound level
%x=[0 40 45 50 55 60 65 70];

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
%% Concentration Detection
for h = 1:length(theFiles)
    hg = theFiles(h).name;
    Data=h5read(hg,'/Trials');
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
    x_conc = unique(Data.concentration)';
end

x_conc_size = numel(x_conc);


%% Sound Detection
 
%creates a cell array to hold each files sound level
soundhold = {};
%loops through to grab each files sound level
for s = 1 : length(theFiles)
    %holds the file name
    filehold = theFiles(s).name;
    %reads the data in the current file
    snd = h5read(filehold, '/Trials');
    %gets the sound level data and find only the unique elements
    %(eliminates repeats)
    sl = {unique(snd.sound_level)};
    %holds onto the sound levels for that file
    soundhold(s) = sl;
end
%creates a matrix to hold the sound levels
sound = [];
%loops through every file and makes each element in the cell array into one
%joined matrix
for l = 1: length(theFiles)
    %converts the current element of the sound cell array into a matrix
    snmat = cell2mat(soundhold(l));
    %if the iteration is after the first loop enter
    if l > 1
        %adds the current sound levels onto the matrix 
        sound = [sound;snmat];
    %if it is the first loop enter
    else
        %the holding matrix becomes the first set of sound levels
        sound = snmat;
    end
end
%finds any repeats of sound levels between the files and only takes the
%unique ones, creating a matrix that combines all sound levels from each
%trial
x_sound = double(unique(sound)');    
x_sound_size = numel(x_sound);

%loops through to find the longest group of sound levels
len = 0;
for t = 1:length(theFiles)
    curr_len = length(cell2mat(soundhold(t)));
    if curr_len > len
        len = curr_len;
    elseif curr_len < len
        len = len;
    end
end

%loops through to create a matrix of all sounds levels, and equalizes their
%size to match the largest (attaches NaN to end if too short)
sounds = zeros(length(theFiles),len);
for d = 1:length(theFiles)
    curr_lev = cell2mat(soundhold(d))';
    if length(curr_lev) == len
        sounds(d,:) = curr_lev;
    else
        C = abs(length(curr_lev) - len);
        for da = 1:C
            curr_lev = [curr_lev NaN];
        end
        sounds(d,:) = curr_lev;
    end
end

new_sound = zeros(length(theFiles), len);
%b is element and seeing where the index of the longest (min) sound level
%vector and putting it in that position in a new array
for u = 1:length(theFiles)
    row = sounds(u,:);
    if any(isnan(row))
        mat = sounds;
        mat(u,:) = [];
        for uu = 1:len
            elem = row(uu);
            if isnan(elem)
                continue
            else
                [minValue,closestIndex] = min(abs(elem-mat.'));
                new_sound(u,closestIndex) = elem;
            end
        end
    else
        new_sound(u,:) = row;
    end
end


for w = 1:length(new_sound)
    col_snd = new_sound(:,w);
    if range(col_snd) ~= 0
        for ws = 1:length(col_snd)
            el = col_snd(ws);
            if el == 0
                col_snd(ws) = NaN;
            end
        end
        new_sound(:,w) = col_snd;
    end
end


finaltask_concvssound(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)
finaltask_sound_threshold(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)
finaltask_conc_threshold(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)
finaltask_soundvsconc(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)
finaltask_thresh_comp(x_sound,x_sound_size,x_conc,x_conc_size,theFiles)


end