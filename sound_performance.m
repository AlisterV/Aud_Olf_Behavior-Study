%% Last edit made by Alister Virkler on 6/4/2021
%This function provides the user with a choice between a combined
%performance or separate graph performance for a mouse and the sound levels
%used. For the combined, it will plot the standard error among all trials
%selected as well.

function sound_performance()

%clears all previous data variables
clear all
%closes all previous figures
close all

%prompts the user
answer = questdlg('Would you like: ','Option','Combined Sound Performance Graph','Separate Sound Performance Graphs','Combined Sound Performance Graph');
% takes user response and changes into a value for the following if
% statement, switches the variable 'answer' from yes/no to 1/2 respectively
switch answer
    case 'Combined Sound Performance Graph'
        combined_sound_performance()
    case 'Separate Sound Performance Graphs'
        separate_sound_performance()
end
end