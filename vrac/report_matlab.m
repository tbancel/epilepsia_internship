import mlreportgen.report.*
 
report = Report('Report variable threshold');

titlepg = TitlePage;
titlepg.Title = 'Giving a baseline to algorithms';
titlepg.Author = 'Thomas BANCEL';
add(report,titlepg);

% chapter = Chapter();
% chapter.Title = 'Figure Example';
% add(report, chapter);

f=figure();
x=1:30;
y=sin(x);
plot(x,y);
fig = Figure(f);
add(report, fig);
clf;

close(report);
rptview(report);