% save all figures

figlist = findobj('type','figure')
n_fig = size(figlist, 1);

for i=1:n_fig
    saveas(figlist(i), strcat(figlist(i).('Name'),'Figure_', num2str(figlist(i).('Number')),'.png'), 'png')
end

close all;