% play with tables
% https://fr.mathworks.com/help/matlab/matlab_prog/create-a-table.html
% https://fr.mathworks.com/help/matlab/ref/table.html
clc; clear; close all;

load patients
T = table(Gender,Smoker,Height,Weight);
plot(T(1:5,:));


% f = figure;
% t = uitable(f);
% t.Data = T(1:5,:);