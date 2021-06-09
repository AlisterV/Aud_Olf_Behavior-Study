function all_sound_performance()
ask=inputdlg('How many mice do you have?');
ind=string(ask);
ind=str2double(ind);
for i=1:ind
    figure(i)
    mousenum=string(inputdlg("Please Enter the ID# of mouse " +convertCharsToStrings(i)));
    mousexten=append('*',mousenum,'t*.h5');
    myFolder = 'C:\VoyeurData';
    filePattern = fullfile(myFolder,mousexten); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    theFiles=struct2table(theFiles);
    theFiles.datenum=datestr(theFiles.datenum,'mm/dd/yyyy');
    theFiles=sortrows(theFiles,'datenum');
    theFiles=table2struct(theFiles);
    
    trialcounter0=zeros(1,length(theFiles));
    trialcounter10=zeros(1,length(theFiles));
    trialcounter30=zeros(1,length(theFiles));
    trialcounter50=zeros(1,length(theFiles));
    trialcounter60=zeros(1,length(theFiles));
    trialcounter70=zeros(1,length(theFiles));
    trialcounter80=zeros(1,length(theFiles));
    %sound levels tested [0,10,30,50,60,70,80]
    percorr0array=zeros(1,length(theFiles));
    percorr10array=zeros(1,length(theFiles));
    percorr30array=zeros(1,length(theFiles));
    percorr50array=zeros(1,length(theFiles));
    percorr60array=zeros(1,length(theFiles));
    percorr70array=zeros(1,length(theFiles));
    percorr80array=zeros(1,length(theFiles));
    
    %initializes a counter to keep track of all the trials continually through
    for k = 1 : length(theFiles)
        %figure(k)
        %selects the kth file
        gohit0=0;
        nogohit0=0;
        gomiss0=0;
        nogomiss0=0;
        
        gohit10=0;
        nogohit10=0;
        gomiss10=0;
        nogomiss10=0;
        
        gohit30=0;
        nogohit30=0;
        gomiss30=0;
        nogomiss30=0;
        
        gohit50=0;
        nogohit50=0;
        gomiss50=0;
        nogomiss50=0;
        
        gohit60=0;
        nogohit60=0;
        gomiss60=0;
        nogomiss60=0;
        
        gohit70=0;
        nogohit70=0;
        gomiss70=0;
        nogomiss70=0;
        
        gohit80=0;
        nogohit80=0;
        gomiss80=0;
        nogomiss80=0;
        fullFileName = theFiles(k).name;
        %reads the file and keeps the data in this variable
        %baseFileName = theFiles(k).name;
        %fullFileName = fullfile(theFiles(k).folder, baseFileName);
        Data=h5read(fullFileName,'/Trials');
        %Determines the number of trials for this particular file
        NumTrials = length(Data.trialNumber);
        %mousenum=Data.mouse(1:3,1)';
        sessionnum=Data.session(1);
        %Our sampling frequency is 1000Hz.
        Fs = 1000;
        s0response=zeros(1,NumTrials);
        s10response=zeros(1,NumTrials);
        s30response=zeros(1,NumTrials);
        s50response=zeros(1,NumTrials);
        s55response=zeros(1,NumTrials);
        s60response=zeros(1,NumTrials);
        s65response=zeros(1,NumTrials);
        s70response=zeros(1,NumTrials);
        s75response=zeros(1,NumTrials);
        s80response=zeros(1,NumTrials);
        
        for Trials=1:NumTrials
            mouseresponse=Data.response(Trials);
            level=Data.sound_level(Trials);
            if level==0
                s0response(Trials)=mouseresponse;
            elseif level==10
                s10response(Trials)=mouseresponse;
            elseif level==30
                s30response(Trials)=mouseresponse;
            elseif level==50
                s50response(Trials)=mouseresponse;
            elseif level==55
                s55response(Trials)=mouseresponse;
            elseif level==60
                s60response(Trials)=mouseresponse;
            elseif level==65
                s65response(Trials)=mouseresponse;
            elseif level==70
                s70response(Trials)=mouseresponse;
            elseif level==75
                s75response(Trials)=mouseresponse;
            elseif level==80
                s80response(Trials)=mouseresponse;
            end
        end
        
        
        for r=1:length(s0response)
            if s0response(r) == 1
                gohit0=gohit0+1;
            elseif s0response(r) == 2
                nogohit0=nogohit0+1;
            elseif s0response(r) == 3
                gomiss0=gomiss0+1;
            elseif s0response(r) == 4
                nogomiss0=nogomiss0+1;
            else
            end
        end
        percorr0=((nogomiss0)/(nogohit0+nogomiss0))*100;
        percorr0array(k)=percorr0;
        trialcounter0(k)=numel((find(s0response)~=0));
        
        for r=1:length(s10response)
            if s10response(r) == 1
                gohit10=gohit10+1;
            elseif s10response(r) == 2
                nogohit10=nogohit10+1;
            elseif s10response(r) == 3
                gomiss10=gomiss10+1;
            elseif s10response(r) == 4
                nogomiss10=nogomiss10+1;
            else
            end
        end
        percorr10=((gohit10)/(gohit10+gomiss10))*100;
        percorr10array(k)=percorr10;
        trialcounter10(k)=numel((find(s10response)~=0));
        
        for r=1:length(s30response)
            if s30response(r) == 1
                gohit30=gohit30+1;
            elseif s30response(r) == 2
                nogohit30=nogohit30+1;
            elseif s30response(r) == 3
                gomiss30=gomiss30+1;
            elseif s30response(r) == 4
                nogomiss30=nogomiss30+1;
            else
            end
        end
        percorr30=((gohit30)/(gohit30+gomiss30))*100;
        percorr30array(k)=percorr30;
        trialcounter30(k)=numel((find(s30response)~=0));
        
        for r=1:length(s50response)
            if s50response(r) == 1
                gohit50=gohit50+1;
            elseif s50response(r) == 2
                nogohit50=nogohit50+1;
            elseif s50response(r) == 3
                gomiss50=gomiss50+1;
            elseif s50response(r) == 4
                nogomiss50=nogomiss50+1;
            else
            end
        end
        percorr50=((gohit50)/(gohit50+gomiss50))*100;
        percorr50array(k)=percorr50;
        trialcounter50(k)=numel((find(s50response)~=0));
        
        for r=1:length(s55response)
            if s55response(r) == 1
                gohit55=gohit55+1;
            elseif s55response(r) == 2
                nogohit55=nogohit55+1;
            elseif s55response(r) == 3
                gomiss55=gomiss55+1;
            elseif s55response(r) == 4
                nogomiss55=nogomiss55+1;
            else
            end
        end
        
        for r=1:length(s60response)
            if s60response(r) == 1
                gohit60=gohit60+1;
            elseif s60response(r) == 2
                nogohit60=nogohit60+1;
            elseif s60response(r) == 3
                gomiss60=gomiss60+1;
            elseif s60response(r) == 4
                nogomiss60=nogomiss60+1;
            else
            end
        end
        percorr60=((gohit60)/(gohit60+gomiss60))*100;
        percorr60array(k)=percorr60;
        trialcounter60(k)=numel((find(s60response)~=0));
        
        for r=1:length(s65response)
            if s65response(r) == 1
                gohit65=gohit65+1;
            elseif s65response(r) == 2
                nogohit65=nogohit65+1;
            elseif s65response(r) == 3
                gomiss65=gomiss65+1;
            elseif s65response(r) == 4
                nogomiss65=nogomiss65+1;
            else
            end
        end
        
        for r=1:length(s70response)
            if s70response(r) == 1
                gohit70=gohit70+1;
            elseif s70response(r) == 2
                nogohit70=nogohit70+1;
            elseif s70response(r) == 3
                gomiss70=gomiss70+1;
            elseif s70response(r) == 4
                nogomiss70=nogomiss70+1;
            else
            end
        end
        percorr70=((gohit70)/(gohit70+gomiss70))*100;
        percorr70array(k)=percorr70;
        trialcounter70(k)=numel((find(s70response)~=0));
        
        for r=1:length(s75response)
            if s75response(r) == 1
                gohit75=gohit75+1;
            elseif s75response(r) == 2
                nogohit75=nogohit75+1;
            elseif s75response(r) == 3
                gomiss75=gomiss75+1;
            elseif s75response(r) == 4
                nogomiss75=nogomiss75+1;
            else
            end
        end
        
        for r=1:length(s80response)
            if s80response(r) == 1
                gohit80=gohit80+1;
            elseif s80response(r) == 2
                nogohit80=nogohit80+1;
            elseif s80response(r) == 3
                gomiss80=gomiss80+1;
            elseif s80response(r) == 4
                nogomiss80=nogomiss80+1;
            else
            end
        end
        percorr80=((gohit80)/(gohit80+gomiss80))*100;
        percorr80array(k)=percorr80;
        trialcounter80(k)=numel((find(s80response)~=0));
    end
    
    meanpercorr0=mean(percorr0array);
    meanpercorr10=mean(percorr10array);
    meanpercorr30=mean(percorr30array);
    meanpercorr50=mean(percorr50array);
    meanpercorr60=mean(percorr60array);
    meanpercorr70=mean(percorr70array);
    meanpercorr80=mean(percorr80array);
    
    y=[meanpercorr0 meanpercorr10 meanpercorr30 meanpercorr50 meanpercorr60 meanpercorr70 meanpercorr80];
    
    std0=std(percorr0array,1);
    std10=std(percorr10array,1);
    std30=std(percorr30array,1);
    std50=std(percorr50array,1);
    std60=std(percorr60array,1);
    std70=std(percorr70array,1);
    std80=std(percorr80array,1);
    
    ste0=std0/(sqrt(length(theFiles)));
    ste10=std10/(sqrt(length(theFiles)));
    ste30=std30/(sqrt(length(theFiles)));
    ste50=std50/(sqrt(length(theFiles)));
    ste60=std60/(sqrt(length(theFiles)));
    ste70=std70/(sqrt(length(theFiles)));
    ste80=std80/(sqrt(length(theFiles)));
    
    answer=questdlg('Plot # of Trials?');
    switch answer
        case 'Yes'
            axes('position',[.1,.25,.8,.7])
            hold on
            errorbar(0,meanpercorr0,ste0)
            hold on
            errorbar(10,meanpercorr10,ste10)
            hold on
            errorbar(30,meanpercorr30,ste30)
            hold on
            errorbar(50,meanpercorr50,ste50)
            hold on
            errorbar(60,meanpercorr60,ste60)
            hold on
            errorbar(70,meanpercorr70,ste70)
            hold on
            errorbar(80,meanpercorr80,ste80)
            hold on
            scatter(0,meanpercorr0)
            hold on
            scatter(10,meanpercorr10)
            hold on
            scatter(30,meanpercorr30)
            hold on
            scatter(50,meanpercorr50)
            hold on
            %     percorr55=((gohit55)/(gohit55+gomiss55))*100;
            %     scatter(55,percorr55)
            %     hold on
            
            scatter(60,meanpercorr60)
            hold on
            %     percorr65=((nogohit65)/(nogohit65+nogomiss65))*100;
            %     scatter(65,percorr65)
            %     hold on
            
            scatter(70,meanpercorr70)
            hold on
            %     percorr75=((nogohit75)/(nogohit75+nogomiss75))*100;
            %     scatter(75,percorr75)
            %     hold on
            
            scatter(80,meanpercorr80)
            hold on
            %xticks([0 50 55 60 65 70 75 80])
            
            xticks(0:10:80)
            xlim([0 80])
            xlabel('Sound Intensities (dB)')
            yticks(0:10:100)
            ylim([0 100])
            ylabel('% Licks')
            title("Combined Performance on each Sound Level for Mouse "+convertCharsToStrings(mousenum))
            
            %ax1=nexttile
            %sound_levels_used={'0','10','30','50','60','70','80'};
            %trialcounter=[trialcounter0,trialcounter10,trialcounter30,trialcounter50,trialcounter60,trialcounter70,trialcounter80];
            holdnames={'Sound Level: ','# of Trials: '};
            hold0=[0,sum(trialcounter0,'all')];
            hold10=[10,sum(trialcounter10,'all')];
            hold30=[30,sum(trialcounter30,'all')];
            hold50=[50,sum(trialcounter50,'all')];
            hold60=[60,sum(trialcounter60,'all')];
            hold70=[70,sum(trialcounter70,'all')];
            hold80=[80,sum(trialcounter80,'all')];
            T=table(holdnames',hold0',hold10',hold30',hold50',hold60',hold70',hold80');
            tableCell = table2cell(T);
            tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
            tableChar = splitapply(@strjoin,pad(tableCell),[1;2]);
            % Add axes (not visible) & text (use a fixed width font)
            hold on
            axes('position',[.1,0,2,.1], 'Visible','off')
            t=text(.225,.95,tableChar,'VerticalAlignment','cap','HorizontalAlignment','center','FontName','Consolas');
            t.FontSize=7.5;
            hold off
            % LastName = {'Sanchez','Johnson','Danz'};
            % Age = [38,43,40];
            % Height = [71, 69, 71];
            % T = table(LastName',Age',Height','VariableNames',{'LastName','Age','Height'});
            % % plot some data in the main axes
            % % Convert Table to cell to char array
            % tableCell = [T.Properties.VariableNames; table2cell(T)];
            % tableCell(cellfun(@isnumeric,tableCell)) = cellfun(@num2str, tableCell(cellfun(@isnumeric,tableCell)),'UniformOutput',false);
            % tableChar = splitapply(@strjoin,pad(tableCell),[1;2;3;4]);
            % % Add axes (not visible) & text (use a fixed width font)
            % axes('position',[.1,.1,.8,.2], 'Visible','off')
            % text(.2,.95,tableChar,'VerticalAlignment','Top','HorizontalAlignment','Left','FontName','Consolas');
        case 'No'
            errorbar(0,meanpercorr0,ste0)
            hold on
            errorbar(10,meanpercorr10,ste10)
            hold on
            errorbar(30,meanpercorr30,ste30)
            hold on
            errorbar(50,meanpercorr50,ste50)
            hold on
            errorbar(60,meanpercorr60,ste60)
            hold on
            errorbar(70,meanpercorr70,ste70)
            hold on
            errorbar(80,meanpercorr80,ste80)
            hold on
            scatter(0,meanpercorr0)
            hold on
            scatter(10,meanpercorr10)
            hold on
            scatter(30,meanpercorr30)
            hold on
            scatter(50,meanpercorr50)
            hold on
            %     percorr55=((gohit55)/(gohit55+gomiss55))*100;
            %     scatter(55,percorr55)
            %     hold on
            
            scatter(60,meanpercorr60)
            hold on
            %     percorr65=((nogohit65)/(nogohit65+nogomiss65))*100;
            %     scatter(65,percorr65)
            %     hold on
            
            scatter(70,meanpercorr70)
            hold on
            %     percorr75=((nogohit75)/(nogohit75+nogomiss75))*100;
            %     scatter(75,percorr75)
            %     hold on
            
            scatter(80,meanpercorr80)
            hold on
            %xticks([0 50 55 60 65 70 75 80])
            
            xticks(0:10:80)
            xlim([0 80])
            xlabel('Sound Intensities (dB)')
            yticks(0:10:100)
            ylim([0 100])
            ylabel('% Licks')
            title("Combined Performance on each Sound Level for Mouse "+convertCharsToStrings(mousenum))
            hold off
            x=[0 10 30 50 60 70 80];
    end
end
end