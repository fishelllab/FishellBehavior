function varargout = GF_AMAversiveControl(varargin)
% GF_AMAVERSIVECONTROL MATLAB code for GF_AMAversiveControl.fig
%      GF_AMAVERSIVECONTROL, by itself, creates a new GF_AMAVERSIVECONTROL or raises the existing
%      singleton*.
%
%      H = GF_AMAVERSIVECONTROL returns the handle to a new GF_AMAVERSIVECONTROL or the handle to
%      the existing singleton*.
%
%      GF_AMAVERSIVECONTROL('CALLBACK',hObj,event,h,...) calls the local
%      function named CALLBACK in GF_AMAVERSIVECONTROL.M with the given input arguments.
%
%      GF_AMAVERSIVECONTROL('Property','Value',...) creates a new GF_AMAVERSIVECONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GF_AMAversiveControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GF_AMAversiveControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GF_AMAversiveControl

% Last Modified by GUIDE v2.5 10-May-2019 12:06:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GF_AMAversiveControl_OpeningFcn, ...
                   'gui_OutputFcn',  @GF_AMAversiveControl_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before GF_AMAversiveControl is made visible.
function GF_AMAversiveControl_OpeningFcn(hObj, event, h, varargin)
% Choose default command line output for GF_AMAversiveControl
h.output = hObj;

% Update h structure
guidata(hObj, h);

% --- Outputs from this function are returned to the command line.
function varargout = GF_AMAversiveControl_OutputFcn(hObj, event, h) 
% Get default command line output from h structure
varargout{1} = h.output;

NOGOs = getpref('GF_AMAversiveControl','NOGOs',[2 6]);
h.edit_MinConsGoTrials.String = NOGOs(1);
h.edit_MaxConsGoTrials.String = NOGOs(2);

h.stayOnTop.Value = getpref('GF_AMAversiveControl','stayOnTop',false);
stay_on_top(h.stayOnTop);


function update(h)
global RUNTIME PRGMSTATE

persistent goodVals


% stop if the program state has changed
if ismember(PRGMSTATE,{'ERROR','STOP'}), stop(timerObj); return; end


if isempty(goodVals), goodVals = [2 6]; end

NOGOs = [str2double(h.edit_MinConsGoTrials.String) str2double(h.edit_MaxConsGoTrials.String)];

i = isnan(NOGOs);

NOGOs(i) = goodVals(i);

h.edit_MinConsGoTrials.String = NOGOs(1);
h.edit_MaxConsGoTrials.String = NOGOs(2);

if any(i), return; end

goodVals = NOGOs;

setpref('GF_AMAversiveControl','NOGOs',NOGOs);

RUNTIME.TRIALS.UserData.ConsecutiveNOGOs = NOGOs;



function reminder_trial(hObj)
global RUNTIME

f = hObj.Parent;

if hObj.Value == 0 % Cancel reminder trial and restore last trial structure
    RUNTIME.TRIALS.UserData.ReminderTrial = false;

    hObj.BackgroundColor = [0.1 0.6 1];
    f.BackgroundColor = [0.94 0.94 0.94];
    vprintf(0,'Reminder trial inactived!')
    
else % Store trial structure and setup reminder trial
    if ~isfield(RUNTIME.TRIALS,'activeTrials')
        hObj.Value = 0;
        return
    end
    RUNTIME.TRIALS.UserData.ReminderTrial = true;
    
    
    hObj.BackgroundColor = [1 0.4 0.4];
    f.BackgroundColor = [1 0.4 0.4];
    vprintf(0,'Reminder trial actived!')
end




