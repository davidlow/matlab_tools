% sweeps through mod current and squid current and plots 2D
% x axis = squid current, y axis = mod coil current, color = squid voltage

% change log
% 15 09 29: davidlow create


%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
path = ['Z:/data/montana_b69/Squid_Tests/150928/codetests/'];
nq = NIdaq('DL', path); %save path 

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nq.p.gain        = 500;
nq.p.rate        = 1000; %0.1 < rate < 2 857 142.9

nq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10

nq.notes = 'Making sure different number of inputs / outputs works.';

%% Setup scan

nq.addinput_A ('Dev1', 0, 'Voltage', nq.p.range, 'SQUID V (sense)');
nq.addoutput_A('Dev1', 0, 'Voltage', nq.p.range, 'SQUID I (source)');
nq.addoutput_A('Dev1', 1, 'Voltage', nq.p.range, 'unused (source)');

nq.setrate    (nq.p.rate);

input = [0, 0, 1, 0, 0];
%input = [1, 1, 0, 1, 1];
nq.setoutputdata(0, input);
nq.setoutputdata(1, input);

[data, ~] = nq.run();

figure;
subplot(2,2,1);
plot(data,'bs');
xlabel('time');
ylabel('sense');
subplot(2,2,2); 
plot(input, 'bs');
xlabel('time');
ylabel('source');
subplot(2,2,3);
plot(input,data, 'bo');
xlabel('source');
ylabel('sense');

nq.delete();




