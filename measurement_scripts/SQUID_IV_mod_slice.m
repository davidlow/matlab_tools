% Sits at constant current and sweeps mod coil current

% change log
% 15 09 22: davidlow create


%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
nidaq = NIdaq('DL', 'Z:/data/montana_b69/Squid_Tests/150918/'); %save path

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain        = 500;
nidaq.p.lpf0        = .3;
nidaq.p.rate        = .1; %0.1 < rate < 2 857 142.9
nidaq.p.T           = 4.38;
nidaq.p.Terr        = .013;

nidaq.p.mod_curr    = 2*(77e-6); %max and min
nidaq.p.mod_step    = 0.5e-6;
nidaq.p.mod_biasr   = 2.5e3 + 10e3; %1.0 + 1.5 cold, 10k warm

nidaq.p.src_amp_I   = 13e-6; % current in amps
nidaq.p.squid_biasr = 2.5e3 + 3e3; %1.0k + 1.5k cold, 3k warm

nidaq.p.src_numpts  = nidaq.p.mod_curr * 2 / nidaq.p.mod_step;
nidaq.p.range       = 5; % options: 0.1, 0.2, 0.5, 1, 5, 10

nidaq.notes = 'Scanning again to show 1hz speed';

%% Setup scan

nidaq.addinput_A ('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID V (sense)');
nidaq.addinput_A ('Dev1', 4, 'Voltage', nidaq.p.range, 'Unused');
nidaq.addoutput_A('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID I (source)');
nidaq.addoutput_A('Dev1', 1, 'Voltage', nidaq.p.range, 'MOD I (source)');

nidaq.setrate    (nidaq.p.rate);


%%


%% Setup data
desout = {nidaq.p.src_amp_I * nidaq.p.squid_biasr * linspace( 1,1, nidaq.p.src_numpts),...
          nidaq.p.mod_curr  * nidaq.p.mod_biasr   * linspace(-1,1, nidaq.p.src_numpts) ...
         };
nidaq.setoutputdata(0,desout{1});
nidaq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nidaq.run();


%% Plot
hold on
plot(desout{2}/nidaq.p.mod_biasr*1e6, data(:,1)/nidaq.p.gain);

title({['param = ', CSUtils.parsefnameplot(nidaq.lastparamsave)], ...
       ['data  = ', CSUtils.parsefnameplot(nidaq.lastdatasave)],  ...
       ['gain=',           num2str(nidaq.p.gain),                 ...
       ', step = '        num2str(nidaq.p.mod_step),              ...
       ' A, lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       ' hz, rate =',    num2str(nidaq.p.rate),                 ...
       ' hz r_{bias} = ', num2str(nidaq.p.squid_biasr),            ...
       ', squid curr = ', num2str(nidaq.p.src_amp_I),             ...
       ', T = '           num2str(nidaq.p.T)                     ...
       ]});
xlabel('I_{mod} = V_{mod}/R_{mod} (\mu A)','fontsize',20);
ylabel('V_{squid} (V)','fontsize',20);

nidaq.delete();




