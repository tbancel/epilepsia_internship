X1=1:100;
Y1=sqrt(X1);
figure;
% 2 by 2 Axes
h(1)=subplot(2,2,4);
 
% 6 by 4 Axes
h(2)=subplot(6,4,18);
h(3)=subplot(6,4,22);
 
% 3 by 4 Axes
h(4)=subplot(3,4,1);
h(5)=subplot(3,4,2);
h(6)=subplot(3,4,3);
h(7)=subplot(3,4,4);
h(8)=subplot(3,4,5);
h(9)=subplot(3,4,6);
 
% 3 by 8 Axes
h(10)=subplot(3,8,17);
h(11)=subplot(3,8,18);
 
% 6 by 2 Axes
h(12)=subplot(6,2,6);
 
for i=1:2
   plot(h(i),X1,Y1);
end