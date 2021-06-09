%% Last edit made by Alister Virkler 6/4/2021
%This function, has nested functions within. The overal goal of this
%function is to display, Go Hit, False Alarm, d', and overall percent
%correct graphs for the files selected. Also, a performance report
%spreadsheet is made.

function dprimegraph_alloptions()
answer=questdlg('Would you like data plotted by Day or by Session?','Option 1','Day','Session','Day');
switch answer
    case 'Day'
        normalizetestingoption_day()
    case 'Session'
        normalizetestingoption_session()
end