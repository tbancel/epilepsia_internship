import mlreportgen.report.*
surf(peaks);
report = Report('peaks');
chapter = Chapter();
chapter.Title = 'Figure Example';
add(report, chapter);

fig = Figure();
fig.Snapshot.Caption = '3-D shaded surface plot';
fig.Snapshot.Height = '5in';

add(report, fig);
delete(gcf);
rptview(report);