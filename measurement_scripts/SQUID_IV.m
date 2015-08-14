%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
nidaq = NIdaq('DL', 'Z:/data/montana_b69/Squid_Tests/150928/'); %save path

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain        = 500;
nidaq.p.lpf0        = 10;
nidaq.p.mod_curr    = 0;
nidaq.p.mod_biasr   = 2.5e3;
nidaq.p.rate        = 3; %0.1 < rate < 2 857 142.9
nidaq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10
nidaq.p.src_amp_I   = 20e-6; % current in amps
nidaq.p.src_numpts  = 1000;
nidaq.p.squid_biasr = 2.5e3 + 3e3; %1.0k + 1.5k cold, 3k warm
nidaq.p.T           = 4.3;
nidaq.p.Terr        = .013;
nidaq.p.scantime    = 0;

nidaq.notes = 'testing at 7k';

%% Setup scan

nidaq.addinput_A ('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID V (sense)');
nidaq.addinput_A ('Dev1', 4, 'Voltage', nidaq.p.range, 'unused');
nidaq.addoutput_A('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID I (source)');
nidaq.addoutput_A('Dev1', 1, 'Voltage', nidaq.p.range, 'unused');

nidaq.setrate    (nidaq.p.rate);

%% Setup data
desout = {nidaq.p.src_amp_I * nidaq.p.squid_biasr * sin(linspace(0,2*pi,nidaq.p.src_numpts)),...
          nidaq.p.mod_curr * nidaq.p.mod_biasr *    linspace(1,1   ,nidaq.p.src_numpts)  ...
         };
nidaq.setoutputdata(0,desout{1});
nidaq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nidaq.run();

%% Plot
plot(desout{1}/nidaq.p.squid_biasr*1e6, data(:,1)/nidaq.p.gain);
hold on
title({['param = ', CSUtils.parsefnameplot(nidaq.lastparamsave)], ...
       ['data  = ', CSUtils.parsefnameplot(nidaq.lastdatasave)],  ...
       ['gain=',           num2str(nidaq.p.gain),                 ...
       ', lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       ', hz, rate =',    num2str(nidaq.p.rate),                 ...
       ', hz r_{bias} = ' num2str(nidaq.p.squid_biasr),            ...
       ', T = '           num2str(nidaq.p.T)                     ...
       ]});
xlabel('I_{bias} = V_{bias}/R_{bias} (\mu A)','fontsize',20);
ylabel('V_{squid} (V)','fontsize',20);

nidaq.delete();




