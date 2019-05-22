function TRIALS = GF_AM_Aversive_TrialFcn(TRIALS)
% TRIALS = GF_AM_Aversive_TrialFcn(TRIALS)
% 
%   
% 
% NextTrialID is the next schedule index, that is the row selected 
%             from the TRIALS.trials matrix
% 
% 
% Custom trial selection functions can be written to add more complex,
% dynamic programming to the behavior paradigm.  For example, a custom
% trial selection function can be used to create an adaptive threshold
% tracking paradigm to efficiently track audibility of tones across sound
% level.
% 
% The goal of any trial selection function is to return an integer pointing
% to a row in the TRIALS.trials matrix which is generated using the
% ep_ExperimentDesign GUI (or by some other method).
% 
% The function must have the same call syntax as this default function. 
%       ex:
%           function TRIALS = MyCustomFunction(TRIALS)
% 
% TRIALS is a structure which has many subfields used during an experiment.
% Below are some important subfields:
% 
% TRIALS.activeTrials ... Determines which trials are active
% TRIALS.TrialIndex  ... Keeps track of each completed trial
% TRIALS.trials      ... A cell matrix in which each column is a different
%                        parameter and each row is a unique set of
%                        parameters (called a "trial")
% TRIALS.readparams  ... Parameter tag names for reading values from a
%                        running TDT circuit. The position of the parameter
%                        tag name in this array is the same as the position
%                        of its corresponding parameters (column) in
%                        TRRIALS.trials.
% TRIALS.writeparams ... Parameter tag names writing values from a
%                        running TDT circuit. The position of the parameter
%                        tag name in this array is the same as the position
%                        of its corresponding parameters (column) in
%                        TRIALS.trials.
% TRIALS.TrialCount  ... This field is an Nx1 integer array with N unique
%                        trials. Indices get incremented each time that
%                        trial is run.
% TRIALS.NextTrialID ... Update this field with a scalar index to indicate
%                        which trial to run next.
%
%
% See also, SelectTrial
% 
% Daniel.Stolzberg@gmail.com 2014

% updated DJS 3/15/2019

persistent NOGO_TRIAL_BLOCK_LENGTH % How many GO trials to present





% [minimum maximum] GO trials
if ~isfield(TRIALS,'USERDATA') || ~isfield(TRIALS,'UserData.ConsecutiveNOGOs')
    TRIALS.UserData.ConsecutiveNOGOs = [3 5];
end

if isempty(NOGO_TRIAL_BLOCK_LENGTH)
    NOGO_TRIAL_BLOCK_LENGTH = randi(TRIALS.UserData.ConsecutiveNOGOs,1);
end



if TRIALS.TrialIndex == 1
    % THIS INDICATES THAT WE ARE ABOUT TO BEGIN THE FIRST TRIAL.
    % THIS IS A GOOD PLACE TO TAKE CARE OF ANY SETUP TASKS LIKE PROMPTING
    % THE USER FOR CUSTOM PARAMETERS, ETC.
    
    % Add in the activeTrials field which is useful for determining which
    % trials to use from a GUI
    TRIALS.activeTrials = [false(1,size(TRIALS.trials,1)-1) true];   
    
    TRIALS.UserData.ReminderTrial = false;
    
elseif TRIALS.UserData.ReminderTrial
    
    AMind = ismember(TRIALS.writeparams,'AMdepth');
    ind = [TRIALS.trials{:,AMind}] == 1; % 100% AM modulation depth
    TRIALS.activeTrials = ind;
    
else
    
    % TrialType: GO = 0; NO GO = 1;
    NOGO = 1;
    TTind = ismember(TRIALS.writeparams,'TrialType');
    NOGOtrials = [TRIALS.trials{:,TTind}] == NOGO;
    
    
    
    
    % look at trial history to determine how many more GO trials to present
    NOGOind = [TRIALS.DATA.TrialType] == NOGO;
    
    
    
    
    
    % Determine if we are in a block of NOGO trials
    if TRIALS.TrialIndex < TRIALS.UserData.ConsecutiveNOGOs(1)
        nNOGO = sum(NOGOind);
        
    elseif NOGOind(end) == 1 % last trial was a NOGO trial
        idx = find(NOGOind(2:end) > NOGOind(1:end-1),1,'last'); % onset of recent block of GO trials
        if isempty(idx),idx = 1; end
        nNOGO = sum(NOGOind(idx:end)); % count of recent NOGO trials
        
    else
        nNOGO = inf;
    end
    
    
    if nNOGO == NOGO_TRIAL_BLOCK_LENGTH
        % make sure the next trial is a GO trial
        TRIALS.activeTrials = ~NOGOtrials;
        NOGO_TRIAL_BLOCK_LENGTH = randi(TRIALS.UserData.ConsecutiveNOGOs,1);
        
    else
        % continue presenting NOGO trials
        TRIALS.activeTrials = NOGOtrials;
    end
    
    
end




% find the least used trials for the next trial index
% * limit the trials based on the activeTrials field
actIdx = find(TRIALS.activeTrials);
m      = min(TRIALS.TrialCount(actIdx));
actIdx = actIdx(TRIALS.TrialCount(actIdx) == m);


% The TRIALS.NextTrialID determins which column is selected from the
% TRIALS.trials matrix
TRIALS.NextTrialID = actIdx(randi(length(actIdx),1));








