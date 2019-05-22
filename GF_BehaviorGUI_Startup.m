function GF_BehaviorGUI_Startup
global AX

% launch the main generic gui
ep_GenericGUI;


% AM aversive specific control panel
GF_AMAversiveControl;


% launch the pump monitor
GF_PumpMonitor;


% launch online monitor - pass RPvds parameter tag names
ep_GenericOnlinePlot(AX, ...
    {'!TrialDelivery','~InTrial_TTL','~DelayPeriod', ...
    '~RespWindow','~LickSmoothed','~Spout_TTl','~ShockOn','~SoundOn'});

