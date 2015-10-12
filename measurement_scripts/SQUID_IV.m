%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
nq = NIdaq('DL', 'Z:/data/montana_b69/Squid_Tests/151011/'); %save path

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nq.p.gain        = 500;
nq.p.lpf0        = 100;
nq.p.rate        = 100; %0.1 < rate < 2 857 142.9
nq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10

nq.p.squid.I_cntr= 0e-6;  % center current in amps
nq.p.squid.I_span= 40e-6; % total span in amps
nq.p.squid.I_step= .01e-6;  % current step in amps
nq.p.squid.biasr = 2.5e3; %1.0k + 1.5k cold

nq.p.mod.curr    = 0;
nq.p.mod.biasr   = 2.5e3;

nq.p.T           = 4.3;
nq.p.Terr        = .013;
nq.p.scantime    = 0;

nq.notes = 'Testing autoplotting for use with google slides and longer scan to see if still hysteretic';

%% Setup scan

nq.addinput_A ('Dev1', 0, 'Voltage', nq.p.range, 'SQUID V (sense)');
nq.addinput_A ('Dev1', 4, 'Voltage', nq.p.range, 'unused');
nq.addoutput_A('Dev1', 0, 'Voltage', nq.p.range, 'SQUID I (source)');
nq.addoutput_A('Dev1', 1, 'Voltage', nq.p.range, 'unused');

nq.setrate    (nq.p.rate);

numpts = nq.p.squid.I_span / nq.p.squid.I_step;

%% Setup data
desout = {nq.p.squid.I_span * nq.p.squid.biasr * ...
            sin(linspace(0,2*pi,numpts)) + ...
          nq.p.squid.I_cntr * nq.p.squid.biasr,...
          nq.p.mod.curr * nq.p.mod.biasr *  ...  
            linspace(1,1,numpts)  ...
         };
nq.setoutputdata(0,desout{1});
nq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nq.run();

%% Plot
plot(desout{1}/nq.p.squid.biasr*1e6, data(:,1)/nq.p.gain);
hold on
title({['param = ', CSUtils.parsefnameplot(nq.lastparamsave)], ...
       ['data  = ', CSUtils.parsefnameplot(nq.lastdatasave)],  ...
       ['gain=',           num2str(nq.p.gain),                 ...
       ', lp f_0 =',      num2str(nq.p.lpf0),                 ...
       ', hz, rate =',    num2str(nq.p.rate),                 ...
       ', hz r_{bias} = ' num2str(nq.p.squid.biasr),            ...
       ', T = '           num2str(nq.p.T)                     ...
       ]});
xlabel('I_{bias} = V_{bias}/R_{bias} (\mu A)','fontsize',20);
ylabel('V_{squid} (V)','fontsize',20);
mfilename
print('-dpng', [nq.savedir,'autoplots/',LoggableObj.timestring(),'_', mfilename,'.png']);
nq.delete();




