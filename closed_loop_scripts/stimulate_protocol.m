function output = stimulate_protocol(epoch_start, data, Master8, seizures, wave_positions, stim_params)
	% timers = timerfind('Running', 'on');

	% get last epoch value
	% see if last data is a seizure
	% compute position of waves in the last epoch
	% predict position of the wave in the current epoch
	% see if those position have been stimulated (get all timers)
	% if not, plan a trigger.

	output = get_wave_positions_epochs()


end


% private functions necessary for the stimulation protocol:

function t = createStimulationTimer(Master8, stimulation_time)
	t = timer;
	user_data.Master8 = Master8;
	user_data.stimulation_time = stimulation_time;
	user_data.executed_stimulation_time =  0;

	t.ExecutionMode = 'singleShot';
	t.StartFcn = @sendStimulation;
	t.UserData = user_data;

	if planned_stimuation_time - toc > 0.01
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
	if abs(min(toc - executed_stimulation_time)) < 0.100
		Master8.Trigger(3)
		exec_time = toc
		executed_stimulation_times = [executed_stimulation_times exec_time]
		user_data.executed_stimulation_time = exec_time;
	end
end

