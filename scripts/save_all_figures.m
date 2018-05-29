% save all figures

figlist = findobj('type','figure')
n_fig = size(figlist, 1);

str = date;

for i=1:n_fig
    saveas(figlist(i), strcat(figlist(i).('Name'),'Figure_', num2str(figlist(i).('Number')), '_', str,'.svg'), 'svg')
end

close all;