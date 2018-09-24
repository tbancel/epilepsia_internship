% try timer with Master 8
clear all; clc;
delete(timerfind)

global executed_stimulation_times
tic

Master8=actxserver('AmpiLib.Master8'); % Create COM Automation server
if ~(Master8.Connect)
    h=errordlg('Can''t connect to Master8!','Error');
    uiwait(h);
    delete(Master8); %Close COM
    return;
end;
% Change to paradigm7
Master8.ChangeParadigm(7);

createStimulationTimer(Master8, 5)
createStimulationTimer(Master8, 5.5)
createStimulationTimer(Master8, 8)
createStimulationTimer(Master8, 8.2)


function createStimulationTimer(Master8, stimulation_time)
	t = timer;
	user_data.Master8 = Master8;
	user_data.stimulation_time = stimulation_time;
	user_data.executed_stimulation_time =  0;

	t.ExecutionMode = 'singleShot';
	t.TimerFcn = @sendStimulation;
	t.UserData = user_data;

	if stimulation_time - toc > 0
		t.StartDelay = stimulation_time - toc;
		start(t);
	else 
		delete(t);
	end
end

function sendStimulation(mTimer, ~)
	global executed_stimulation_times

	user_data = mTimer.UserData;
	Master8 = user_data.Master8;

	% we send the stimulation only there is no other stimulation that was triggered less than 100 ms ago.
	if isempty(executed_stimulation_times) || abs(min(toc - executed_stimulation_times)) > 0.100
		Master8.Trigger(3);
		exec_time = toc;
		executed_stimulation_times = [executed_stimulation_times exec_time];
		user_data.executed_stimulation_time = exec_time;
		mTimer.UserData = user_data;
	end
end

