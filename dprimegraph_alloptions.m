%% Last edit made by Alister Virkler 6/17/2021
%This code calls two others to determine whether the user wants to separate
%the data for d prime and % correct graphs by session or by day

function dprimegraph_alloptions()
%propmts the user if they would like to separate data by day or session
answer=questdlg('Would you like data plotted by Day or by Session?','Option 1','Day','Session','Day');
switch answer
    %if the user clicks 'Day'
    case 'Day'
        %this function is called and the code procedes there
        filechoice_normalized_days()
    %if the user clicks 'Session'
    case 'Session'
        %this function is called and the code procedes there
        filechoice_normalized_sessions()
end