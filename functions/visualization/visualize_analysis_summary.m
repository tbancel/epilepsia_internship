function f = visualize_analysis_summary(FileName, labelled_crisis_info, predicted_crisis_info, accuracy, sensitivity, specificity, threshold_value)
    % Creates and returns a new figure
    % TO BE OPTIMIZED TO BE ADAPTED
    % 
    % The figures is a table with information about:
    % - the labelled seizures (number of seizures, mean duration of seizures, std of seizures)
    % - the predicted seizures (idem)
    % - the accuracy, sensitivity, specificity, the feature threshold.

    % INPUTS :
    % - filename : name of the filename
    % - labelled_crisis_info : structure containing all info about the number of crisis
    % - accuracy, sensitivity, specificity, threshold_value: 
    
    n=size(findobj('type','figure'), 1);
    f=figure(n+1);
    
    f.Name = strcat(FileName, " Summarized results");
    f.Position = [10, 10, 800, 420];
    % create table with interesting results
    RowName = ["nb of seizures"; "mean seizure duration"; "std seizure duration"; "accuracy"; "sensitivity"; "specificity"; "threshold"];
    labelled_results = [labelled_crisis_info.number_of_crisis; labelled_crisis_info.mean_crisis_time; labelled_crisis_info.std_crisis_time; "n/a"; "n/a"; "n/a"; "n/a"];
    predicted_results = [predicted_crisis_info.number_of_crisis; predicted_crisis_info.mean_crisis_time; predicted_crisis_info.std_crisis_time;  "n/a"; "n/a"; "n/a"; "n/a"];
    performance = ["n/a"; "n/a"; "n/a"; accuracy; sensitivity; specificity; threshold_value];
    T = table(RowName, labelled_results, predicted_results, performance);

    % Get the table in string form.
    TString = evalc('disp(T)');
    % Use TeX Markup for bold formatting and underscores.
    TString = strrep(TString,'<strong>','\bf');
    TString = strrep(TString,'</strong>','\rm');
    TString = strrep(TString,'_','\_');
    % Get a fixed-width font.
    FixedWidth = get(0,'FixedWidthFontName');
    % Output the table using the annotation command.
    annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
        'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);
end