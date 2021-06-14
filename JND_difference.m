function JND_difference()
clear all
close all
% numofmice=inputdlg('How many mice would you like to compare?');
% numofmice=string(numofmice);
% numofmice=str2double(numofmice);
% thresholdnoodor=zeros(1,numel(numofmice));
% thresholdodor=zeros(1,numel(numofmice));
numofmice=3;
thresholdnoodor=zeros(1,numofmice);
thresholdodor=zeros(1,numofmice);
micenum=zeros(1,numofmice);
for i=1:numofmice
    myFolder = 'C:\VoyeurData';
    %CAN CHANGE
    x=[0 10 30 50 60 70 80];
    mousenum=string(inputdlg("Enter ID# of Mouse " +convertCharsToStrings(i)));
    %mousenums=["043","044","045"];
%     for q=1:length(mousenums)
%         mousenum=mousenums(q);
    micenum(1,i)=mousenum;
    mousexten=append('*',mousenum,'t*.h5');
    myFolder = 'C:\VoyeurData';
    filePattern = fullfile(myFolder,mousexten); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    theFiles=struct2table(theFiles);
    theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
    theFiles=sortrows(theFiles,'datenum');
    theFiles=table2struct(theFiles);    
    
    %trialcounterarray=zeros(numel(x),length(theFiles));
    %percorrarray=zeros(numel(x),length(theFiles));
    %FAarray=zeros(numel(x),length(theFiles));
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
    
    for k = 1 : length(theFiles)
        fullFileName = theFiles(k).name;
        %reads the file and keeps the data in this variable
        %baseFileName = theFiles(k).name;
        %fullFileName = fullfile(theFiles(k).folder, baseFileName);
        compare=datetime(theFiles(k).datenum,'InputFormat','MM/dd/yyyy');
        date=datetime('06/10/2021','InputFormat','MM/dd/yyyy');
        Data=h5read(fullFileName,'/Trials');
        %Determines the number of trials for this particular file
        NumTrials = length(Data.trialNumber);
        if compare<=date
            for set=1:NumTrials
                Data.odorvalve(set,1)=5;
            end
        end
        mousenum=Data.mouse(1:3,1)';
        sessionnum=Data.session(1);
        %Our sampling frequency is 1000Hz.
        Fs = 1000;
        soundresponse=zeros(numel(x),NumTrials);
        soundresponseodor=zeros(numel(x),NumTrials);
        trialcounter=zeros(numel(x),NumTrials);
        trialcounterodor=zeros(numel(x),NumTrials);
        
        for Trials=1:NumTrials
            level=Data.sound_level(Trials);
            odor=Data.odorvalve(Trials);
            mouseresponse=Data.response(Trials);
            for e=1:numel(x)
                if level==x(e) && odor==5
                    soundresponse(e,Trials)=mouseresponse;
                    trialcounter(e,Trials)=1;
                elseif level==x(e) && odor==8
                    soundresponseodor(e,Trials)=mouseresponse;
                    trialcounterodor(e,Trials)=1;
                end
            end
        end
        trialcounterarray(:,k)=sum(trialcounter,2);
        trialcounterarrayodor(:,k)=sum(trialcounterodor,2);
        
        for p=1:numel(x)
            gohit=0;
            gomiss=0;
            nogohit=0;
            nogomiss=0;
            for w=1:NumTrials
                response=soundresponse(p,w);
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
            gohitarray(p,k)=gohit;
            gomissarray(p,k)=gomiss;
            nogohitarray(p,k)=nogohit;
            nogomissarray(p,k)=nogomiss;
        end
        for p=1:numel(x)
            gohit=0;
            gomiss=0;
            nogohit=0;
            nogomiss=0;
            for w=1:NumTrials
                response=soundresponseodor(p,w);
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
            gohitarrayodor(p,k)=gohit;
            gomissarrayodor(p,k)=gomiss;
            nogohitarrayodor(p,k)=nogohit;
            nogomissarrayodor(p,k)=nogomiss;
        end
    end
    
    percorrarray=gohitarray./trialcounterarray;
    percorrarrayodor=gohitarrayodor./trialcounterarrayodor;
    FAarray=nogomissarray./trialcounterarray;
    FAarrayodor=nogomissarrayodor./trialcounterarrayodor;
    FAarray=FAarray(1,:);
    FAarrayodor=FAarrayodor(1,:);
    percorrarray=percorrarray(2:end,:);
    percorrarrayodor=percorrarrayodor(2:end,:);
    y=percorrarray';
    yodor=percorrarrayodor';

    holdx=x;
    for o=1:numel(x)
        if x(o)==0
            x(o)=[];
            break
        end
    end
    
    x1=x;
    for z=1:length(theFiles)
        if z==1
            x=x;
        else
            x=[x;x1];
        end
    end
    
    [params,mdl,threshold,sensitivity,fmcon,minfun,pthresh] = fitLogGrid(x(:),y(:));
    [odorparams,odormdl,odorthreshold,odorsensitivity,odorfmcon,odorminfun,odorpthresh] = fitLogGrid(x(:),yodor(:));
    thresholdnoodor(1,i)=threshold;
    thresholdodor(1,i)=odorthreshold;
    %end
end

% figure();
% xticks(0:1:3)
% yticks(0:numofmice)
% xlabel('JND')
% ylabel('Mouse #')
% scatter(1,thresholdnoodor)
% hold on
% scatter(2,thresholdnoodor)
threshold=[thresholdnoodor;thresholdodor];
figure();
hold on
for a=1:numofmice
    num=num2str(micenum(a));
    plot([1 2],threshold(:,a),'-o','DisplayName',"Mouse 0"+num)
    hold on
end
legend('show')
xlim([0.25 2.75])
xticks([0 1 2 3])
xticklabels({'','JND: Sound Only','JND: Sound+Odor',''})
ylim([(min(threshold,[],'all')-5) (5+max(threshold,[],'all'))])
title('JND between Sound Only Trials and Sound with Odor Trials')
xlabel('JND')
ylabel('Threshold Values')

% NumberofTrials=sum(trialcounterarray,2);
% NumberofTrialsodor=sum(trialcounterarrayodor,2);
% SoundLevels = holdx';
% T = table(SoundLevels,NumberofTrials,NumberofTrialsodor);
% tableCell = table2cell(T);
% T.Properties.VariableNames=pad({'Sound Level: ','# of Trials no odor: ','# of Trials w/odor: '},'both');
% tableCell=[T.Properties.VariableNames;tableCell];
% tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
% 
% % % % Add axes (not visible) & text (use a fixed width font)
% hold on
% axes('position',[.1,0,2,.1], 'Visible','off')
% tableCell=string(tableCell');
% tableChar = splitapply(@strjoin,pad(tableCell,5),[1;2;3]);
% t=text(.2,1.25,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
% t.FontSize=10;
end