%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
nidaq = NIdaq('DL', 'Z:/data/montana_b69/Squid_Tests/151011/codetests/'); %save path

nidaq.addinput_A ('Dev1', 0, 'Voltage', 1, 'SQUID V (sense)');
nidaq.addinput_A ('Dev1', 4, 'Voltage', 1, 'unused');
nidaq.addoutput_A('Dev1', 0, 'Voltage', 1, 'SQUID I (source)');
nidaq.addoutput_A('Dev1', 1, 'Voltage', 1, 'unused');

nidaq.setrate    (100);

%% Setup data
desout = {zeros(1,100),...
          zeros(1,100)...
         };
nidaq.setoutputdata(0,desout{1});
nidaq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nidaq.run(0); % do not log

nidaq.delete();




