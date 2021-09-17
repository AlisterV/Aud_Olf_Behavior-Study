function normalizetestingoption_day()

answer=questdlg('Normalize Test Days? (show only 0/80 dB go trials)','Option 2');
switch answer
    case 'Yes'
        filechoice_normalized_days()
    case 'No'
        filechoice_not_normalized_days()
end
end
