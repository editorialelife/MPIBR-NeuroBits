%% WidgetNeuroTree
% test script and example usage
%
% Aug 2017
% 
clc
clear variables
close all

addpath([pwd,filesep,'..',filesep]);


%% test callbacks on figure
obj = WidgetNeuroTree();

%{
x = rand(6, 1);
y = rand(6, 1);

xl = linspace(min(x),max(x),64);
yl = interp1(x,y,xl);

t = [0;cumsum(diff(x).^2 + diff(y).^2)];
ti = linspace(0,t(end),1000);
xi = pchip(t,x,ti);
yi = pchip(t,y,ti);

figure('color','w');
hold on;
plot(x,y,'k*');
plot(xl,yl,'r');
plot(xi,yi,'g');

for k = 1 : length(x)
    
    text(x(k),y(k),sprintf('%d',k));
end

hold off;
%}