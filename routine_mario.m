% Routine Mario

x = 1:100; %signal à filtrer;
T = length(x);
y = x; % signal filtré de taille égal à celle d’x
y = zeros(size(x));
f = 0.1 % par ex.  (esta es la freqüência d'interes, pero tiene que estar normalizada entre 0 y 0.5)
BW = 0.001 % par ex. (esta es el ancho de banda, pero tiene que estar normalizada entre 0 y 0.5)


R = 1-3*BW;
K = (1-2*R*cos(2*pi*f)+R*R)/(2-2*cos(2*pi*f)); 
a0 = 1-K;
a1 = 2*(K-R)*cos(2*pi*f);
a2= R*R-K;
b1 = 2*R*cos(2*pi*f);
b2 = -R*R;

for n=3:T
y(n)=a0*x(3)+a1*x(n-1)+a2*x(n-2)+b1*y(n-1)+b2*y(n-2);
end

figure, plot(x); hold on; plot(y,'r');

%%%%%%%%%%%%
%  OTRO EJEMPLO

F0 = 10;
Fs = 100;
x = cos(2*pi*F0*[0:(1/Fs):5]);
 
 
T = length(x);
x = x + 0.5*randn(1,T);
y = zeros(1,T);
f = F0/Fs;
BW = 0.5/Fs;
 
R = 1-3*BW;
K = (1-2*R*cos(2*pi*f)+R*R)/(2-2*cos(2*pi*f)); 
a0 = 1-K;
a1 = 2*(K-R)*cos(2*pi*f);
a2= R*R-K;
b1 = 2*R*cos(2*pi*f);
b2 = -R*R;
 
for n=3:T
y(n)=a0*x(3)+a1*x(n-1)+a2*x(n-2)+b1*y(n-1)+b2*y(n-2);
end
figure, plot(x); hold on; plot(y,'r');
