function f = visualize_roc_curve(performance, method_description)

	n=size(findobj('type','figure'), 1);
    f=figure(n+1);
    f.Name = "Performance of line length with varying threshold";
    plot(1-performance(:,3), performance(:,2))
    xlabel('1-specifity');
    ylabel('sensitivity');
    annotation('textbox', [.2 .5 .3 .3], 'String', method_description, 'FitBoxToText','on');
    
    str_title = strcat('ROC curve for threshold value varying between ', num2str(min(performance(:,4))), ' and ', num2str(max(performance(:,4))));
    title(str_title);
end