function hPump = GF_PumpControl
% hPump = GF_PumpControl
%
% Custom function for SanesLab epsych
% 
% This function sets and controls a New Era-1000 Syringe Pump.
%
% Outputs:
%   varargout{1}: serial port object associated with hPump
%
%
% Daniel.Stolzberg@gmail.com 2014. Edited by MLC 4/5/17.


%Close and delete all open serial ports
out = instrfind('Status','open');
if ~isempty(out)
    fclose(out);
    delete(out);
end

%Create a serial connection to the hPump
hPump = serial('com1','BaudRate',19200,'DataBits',8,'StopBits',1,'TimerPeriod',0.1);
try
    fopen(hPump);
catch me
    hPump = me;
    vprintf(-1,me); % log the actual error message
    vprintf(0,1,'Unable to connect pump.\n\t%s\n\t%s!!!\n',me.identifier,me.message)
    return
end

warning('off','MATLAB:serial:fscanf:unsuccessfulRead')
set(hPump,'Terminator','CR','Parity','none','FlowControl','none','timeout',0.1);


%Set up hPump parameters. Obtain diameter, min and max rates from the last
%page of the NE-1000 Syringe Pump User Manual.
fprintf(hPump,'DIA%0.1f\n',23.7); % set inner diameter of syringe (mm)
fprintf(hPump,'RAT%s\n','MM');    % set rate units to mL/min
fprintf(hPump,'RAT%0.1f\n',20);   % set rate
fprintf(hPump,'INF\n');           % set to infuse
fprintf(hPump,'VOL%0.2f\n',0);    % set unlimited volume to infuse (==0)
fprintf(hPump,'TRGLE\n');         % set trigger type

vprintf(1,'Connected to pump.')
