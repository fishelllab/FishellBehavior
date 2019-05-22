function volume = GF_PumpVolume(hPump)

%Written by ML Caras 7.25.2016
%Modified by DJS 5.8.2019

%Wait for pump to finish water delivery
pause(0.06)
    
%Flush the pump's input buffer
flushinput(hPump);

%Query the total dispensed volume
fprintf(hPump,'DIS');
tic
[volume,~] = fscanf(hPump,'%s',10);
if toc > 0.5
    vprintf(0,1,'WARNING: Reading pump volume took a loooong time! Pump may not be connected!')
end

idx = find(volume=='I',1,'last');
volume = str2double(volume(idx+1:end));
% %Pull out the digits and display in GUI
% ind = regexp(volume,'\.');
% 
% %Return volume as string embedded in handles structure (online runtime, 
% %or as a double (for final saving).
% volume = volume(ind-1:min(ind+3,length(volume))); %kp 2017-10 fixed error when V only returns with 2 decimal places

