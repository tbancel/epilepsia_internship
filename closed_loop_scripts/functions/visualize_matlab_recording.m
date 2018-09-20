function f = visualize_matlab_recording(seizure)
	n_figures=size(findobj('type','figure'), 1);
    f=figure(n_figures+1);
    f.Name = seizure.filename;

    plot(seizure.realtime, seizure.realdata);
    xlabel("Time (s)");
	title(strcat("ECoG ", num2str(seizure.filename)));

	% epoch_starts = seizure.epoch_starts;
	% for j=1:numel(seizure.epoch_starts)
	% 	vline(epoch_starts(j,1), 'r');
	% end
end