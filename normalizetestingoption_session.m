function normalizetestingoption_session()

answer=questdlg('Normalize Test Days? (show only 0/80 dB go trials)','Option 2');
switch answer
    case 'Yes'
        filechoice_normalized_sessions()
    case 'No'
        filechoice_not_normalized_sessions()
end
end
