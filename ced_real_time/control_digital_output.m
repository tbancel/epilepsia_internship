% set digital output on a regular basis, to stimulate puffs:

res=matced64c('cedOpenX',0);
res=matced64c('cedResetX');
matced64c('cedLdX','C:\1401Lang\','DIGTIM');

matced64c('cedSendString', 'DIG, O, 1, 0';)

for i=1:10
    matced64c('cedSendString', '')
    pause(1)
end

% at the end of the script
res=matced64c('cedCloseX');

digital_input=dec2base(58367, 2, 16) % = 1110001111111111