%% Initialize
clear all
close all

%% Add all paths
mainrepopath = '../';
addpath([mainrepopath, 'instrument_drivers']);
addpath([mainrepopath, 'measurement_scripts']);
addpath([mainrepopath, 'modules']);


%% Create NI daq object
nq = NIdaq('DL', 'Z:/data/montana_b69/Squid_Tests/151023/'); %save path

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nq.p.gain        = 250;
nq.p.lpf0        = 100;
nq.p.rate        = 90; %0.1 < rate < 2 857 142.9
nq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10

nq.p.squid.I_cntr= 0e-6;  % center current in amps
nq.p.squid.I_span= 60e-6; % total span in amps
nq.p.squid.I_step= .1e-6;  % current step in amps
nq.p.squid.biasr = 2.5e3 + 99e3; %1.0k + 1.5k cold, 10k warm, 99k warm

nq.p.ramppts     = 10;

nq.p.mod.curr    = 0;
nq.p.mod.biasr   = 2.5e3;

nq.p.T           = 4.3;
nq.p.Terr        = .013;
nq.p.scantime    = 0;

nq.notes = 'slow squid IV with 99k warm bias open all other ports to make sure no shorts.';

%% Setup scan

nq.addinput_A ('Dev1', 0, 'Voltage', nq.p.range, 'SQUID V (sense)');
nq.addoutput_A('Dev1', 0, 'Voltage', nq.p.range, 'SQUID I (source)');
nq.addoutput_A('Dev1', 1, 'Voltage', nq.p.range, 'unused');

nq.setrate    (nq.p.rate);
     
squidVsraw = nq.p.squid.biasr * MathUtils.span2array(nq.p.squid.I_cntr,... 
                                                     nq.p.squid.I_span,...
                                                     nq.p.squid.I_step);
squidVs = MathUtils.smoothrmp_lo2hi(squidVsraw, nq.p.ramppts);

modVs =   nq.p.mod.curr * nq.p.mod.biasr * linspace(1,1,length(squidVs));

CSUtils.currentcheck(squidVs / nq.p.squid.biasr, 100e-6);
CSUtils.currentcheck(modVs   / nq.p.mod.biasr, 300e-6);

nq.setoutputdata(0,squidVs);
nq.setoutputdata(1,modVs);

%% Run / collect data
[rawdata, time] = nq.run();

%% Plot

dataf = MathUtils.striprmp_1(rawdata, nq.p.ramppts, length(squidVsraw));
datab = MathUtils.striprmp_2(rawdata, nq.p.ramppts, length(squidVsraw));

dataf = dataf / nq.p.gain;
datab = datab / nq.p.gain;
datainf = squidVsraw           / nq.p.squid.biasr*1e6;
datainb = squidVsraw(end:-1:1) / nq.p.squid.biasr*1e6;

hold on
plot(datainf, dataf, 'ro-');
plot(datainb, datab, 'bs-');
legend('low to high', 'high to low', 'Location', 'northwest');

title({ ...
       ['data  = ', CSUtils.parsefnameplot(nq.lastdatasave)],  ...
       ['gain=',           num2str(nq.p.gain),                 ...
       ', lp f_0 =',      num2str(nq.p.lpf0),                 ...
       ', hz, rate =',    num2str(nq.p.rate),                 ...
       ', hz r_{bias} = ' num2str(nq.p.squid.biasr),'ohms', ...
       'T = '           num2str(nq.p.T)],...
       ['squidIstep = ' num2str(nq.p.squid.I_step), 'amps, '       ...
       'modcurr = '   num2str(nq.p.mod.curr),             ...
       ]});
xlabel('I_{bias} = V_{bias}/R_{bias} (\mu A)','fontsize',20);
ylabel('V_{squid} (V)','fontsize',20);
CSUtils.saveplots(nq.savedir, mfilename);
nq.delete();




