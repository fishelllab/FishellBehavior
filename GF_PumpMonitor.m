function varargout = GF_PumpMonitor(varargin)
%GF_PUMPMONITOR MATLAB code file for GF_PumpMonitor.fig
%      GF_PUMPMONITOR, by itself, creates a new GF_PUMPMONITOR or raises the existing
%      singleton*.
%
%      H = GF_PUMPMONITOR returns the handle to a new GF_PUMPMONITOR or the handle to
%      the existing singleton*.
%
%      GF_PUMPMONITOR('Property','Value',...) creates a new GF_PUMPMONITOR using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GF_PumpMonitor_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GF_PUMPMONITOR('CALLBACK') and GF_PUMPMONITOR('CALLBACK',hObj,...) call the
%      local function named CALLBACK in GF_PUMPMONITOR.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GF_PumpMonitor

% Last Modified by GUIDE v2.5 08-May-2019 17:27:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GF_PumpMonitor_OpeningFcn, ...
                   'gui_OutputFcn',  @GF_PumpMonitor_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GF_PumpMonitor is made visible.
function GF_PumpMonitor_OpeningFcn(hObj, event, h, varargin)
% Choose default command line output for GF_PumpMonitor
h.output = hObj;

% Update h structure
guidata(hObj, h);



% --- Outputs from this function are returned to the command line.
function varargout = GF_PumpMonitor_OutputFcn(hObj, event, h)
% Get default command line output from h structure
varargout{1} = h.output;

sot = getpref('GF_PumpMonitor','stayOnTop',false);
h.stayOnTop.Value = sot;
stay_on_top(h.stayOnTop);

% Generate a new timer object and then start it
h.GTIMER = ep_GenericGUITimer(h.GF_PumpMonitor);
h.GTIMER.TimerFcn = @GUITimerRunTime;
h.GTIMER.StartFcn = @GUITimerSetup;

start(h.GTIMER);

guidata(h.GF_PumpMonitor,h);


function GUITimerSetup(~,~,f)
global RUNTIME

% instantiate connection to pump and store handle with the global RUNTIME
% variable
RUNTIME.PUMP = GF_PumpControl;
if isempty(RUNTIME.PUMP), return; end

pause(1); % wait for pump to initialize

h = guidata(f);

% set pump rate
update_pump_rate(h.pumpRate);


function GUITimerRunTime(timerObj,~,f)
global RUNTIME PRGMSTATE
if isempty(RUNTIME.PUMP), return; end


% persistent variables hold their values across calls to this function
persistent lastupdate

% stop if the program state has changed
if ismember(PRGMSTATE,{'ERROR','STOP'}), stop(timerObj); return; end

% number of trials is length of
ntrials = RUNTIME.TRIALS.DATA(end).TrialID;

if isempty(ntrials)
    ntrials = 0;
    lastupdate = 0;
end

    
% escape timer function until a trial has finished
if ntrials == lastupdate,  return; end
lastupdate = ntrials;
% `````````````````````````````````````````````````````````````````````````

h = guihandles(f);
volume = GF_PumpVolume(RUNTIME.PUMP);
h.volumeDelivered.String = num2str(volume,'%.3f');


function update_pump_rate(hObj)
global RUNTIME
persistent pumpVal
if isempty(RUNTIME.PUMP), return; end

if isempty(pumpVal), pumpVal = 1; end
s = hObj.String;
newRate = str2double(s);
if isnan(newRate)
    hObj.String = num2str(pumpVal,3);
    h = guidata(hObj);
    sot = h.stayOnTop.Value;
    h.stayOnTop.Value = 0;
    stay_on_top(h.stayOnTop); drawnow
    errordlg(sprintf('Invalid entry: %s',s),'Invalid Error','modal');
    h.stayOnTop.Value = sot;
    stay_on_top(h.stayOnTop);
    return
end

GF_PumpRate(RUNTIME.PUMP,newRate);
