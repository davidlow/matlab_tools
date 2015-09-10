%% Initialize
%  clear all
%  close all


%% Create NI daq object
nidaq = NIdaq('Z:/data/montana_b69/Bad_Squid_Tests/150904');

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain       = 500;
nidaq.p.lpf0       = 100;
nidaq.p.mod_curr   = 70e-6;
nidaq.p.mod_biasr   = 12e3;
nidaq.p.rate       = 10;
nidaq.p.range      = 5; % options: 0.1, 0.2, 0.5, 1, 2, 5, 10
nidaq.p.src_amp    = .3;
nidaq.p.src_numpts = 100;
nidaq.p.squid_biasr  = 5e3;
nidaq.p.T          = 4.2;
nidaq.p.Terr       = .012;

nidaq.notes = 'First Squid test';


%% Setup scan
nidaq.setrate(nidaq.p.rate);
nidaq.addinput_A ('Dev1', 0, 'Voltage', nidaq.p.range, 'Squid V');
nidaq.addinput_A ('Dev1', 4, 'Voltage', nidaq.p.range, 'unused');
nidaq.addoutput_A('Dev1', 0, 'Voltage', nidaq.p.range, 'Squid I');
nidaq.addoutput_A('Dev1', 1, 'Voltage', nidaq.p.range, 'unused');

%% Setup data
desout = {nidaq.p.src_amp * sin(linspace(0,2*pi,nidaq.p.src_numpts)),...
          nidaq.p.mod_curr * nidaq.p.mod_biasr *    linspace(1,1   ,nidaq.p.src_numpts)  ...
         };
nidaq.setoutputdata(0,desout{1});
nidaq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nidaq.run();

%% Plot
plot(desout{1}/nidaq.p.squid_biasr*1e6, data(:,1));
hold on
title(['gain=',           num2str(nidaq.p.gain),                 ...
       ', lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       ', hz, rate =',    num2str(nidaq.p.rate),                 ...
       ', hz r_{bias} = ' num2str(nidaq.p.squid_biasr),            ...
       ', T = '           num2str(nidaq.p.T)                     ...
       ]);
xlabel('I_{bias} = V_{bias}/R_{bias} (\mu A)','fontsize',20);
ylabel('V_{mod} (V)','fontsize',20);

nidaq.delete();




