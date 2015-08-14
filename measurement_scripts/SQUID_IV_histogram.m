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
path = ['Z:/data/montana_b69/Squid_Tests/150928/', ...
        LoggableObj.timestring(), '_histogram/' ];
mkdir(path);
nq = NIdaq('DL', path); %save path 

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nq.p.gain        = 500;
nq.p.lpf0        = 10000;
nq.p.rate        = 9000; %0.1 < rate < 2 857 142.9
nq.p.T           = 6.0;
nq.p.Terr        = .032;

nq.p.mod.I       = 0e-6;
nq.p.mod.biasr   = 2.5e3;  %1.0 + 1.5 cold

nq.p.squid.I_cntr= 10e-6;  % center current in amps
nq.p.squid.I_span= 30e-6; % total span in amps
nq.p.squid.I_step= .01e-6;  % current step in amps
nq.p.squid.biasr = 2.5e3 + 3e3; %1.0k + 1.5k cold, 3k warm

nq.p.ramppts     = 10;

nq.p.cal.low    = 0e-6;   % calibration, when squid is superconducting
nq.p.cal.high   = 20e-6;  % calibration, after squid jumps to normal
nq.p.cal.pts    = 10;     % calibration, number of points in calibration

nq.p.hist.pts   = 1000;   % number of points in the histogram
nq.p.hist.range = .1;    % deviation from the target point for 
                             % registering successful swich from lo -> hi

nq.p.range       = 10; % options: 0.1, 0.2, 0.5, 1, 5, 10

nq.notes = 'full scan at 6K with 10% historgram.';

%% Setup scan

nq.addinput_A ('Dev1', 0, 'Voltage', nq.p.range, 'SQUID V (sense)');
nq.addinput_A ('Dev1', 4, 'Voltage', nq.p.range, 'Unused');
nq.addoutput_A('Dev1', 0, 'Voltage', nq.p.range, 'SQUID I (source)');
nq.addoutput_A('Dev1', 1, 'Voltage', nq.p.range, 'MOD I (source)');

nq.setrate    (nq.p.rate);

%% Setup data
% Create constant mod sweep
% Create squid linear sweep.  Ramp from 0 to start, then squid sweep, 
%                             then squid sweep backwards, then ramp to 0
% prep arrays to store data


               
squidVsraw = nq.p.squid.biasr *                                   ...
             linspace(nq.p.squid.I_cntr - nq.p.squid.I_span/2, ...
                      nq.p.squid.I_cntr + nq.p.squid.I_span/2, ...
                      nq.p.squid.I_span / nq.p.squid.I_step ); 
squidVs = MathUtils.smoothrmp_lo2hi(squidVsraw, nq.p.ramppts);

modVs   = nq.p.mod.I * nq.p.mod.biasr * linspace(1, 1, length(squidVs) );    

%check if current might destroy squid / mod coil!
CSUtils.currentcheck(squidVs / nq.p.squid.biasr, 100e-6);
CSUtils.currentcheck(modVs   / nq.p.mod.biasr,   300e-6);

highsw = zeros(1, nq.p.hist.pts);
lowsw  = zeros(1, nq.p.hist.pts);
           

%% Calibration
% Scan squid smoothish from cal.low to cal.high
% strip out the forward section
% find the first and last points to get calibration for low and high.
nq.scantype = 'cal';

squidVtmp   = nq.p.squid.biasr * ...
              linspace(nq.p.cal.low, nq.p.cal.high, nq.p.cal.pts);
squidVtmpsm = MathUtils.smoothrmp_lo2hi(squidVtmp, nq.p.ramppts);
modVtmp     = linspace(0, 0, length(squidVtmpsm));

%check if current might destroy squid / mod coil!
CSUtils.currentcheck(squidVtmpsm / nq.p.squid.biasr, 100e-6);
CSUtils.currentcheck(modVtmp / nq.p.mod.biasr, 300e-6);


nq.setoutputdata(0, squidVtmpsm);
nq.setoutputdata(1, modVtmp);

precalnotes = nq.notes;
nq.notes = [nq.notes, ' Calibration'];

[data, ~] = nq.run();

nq.notes = precalnotes;
data        = data(:,1)';

forw_d = MathUtils.striprmp_1(data, nq.p.ramppts, nq.p.cal.pts);
nq.p.cal.low_data   = forw_d(1);
nq.p.cal.high_data  = forw_d(end);


%% Run / collect data
% for as many times as hist.pts,
% scan up and down smoothly
% strip forward data, add switch point to high to highswitch set
% strip backwards data, add switch to low to lowswitch set
nq.scantype = '';

histrange = abs(nq.p.cal.low_data - nq.p.cal.high_data) * ...
                nq.p.hist.range;

for i = 1:nq.p.hist.pts
    nq.setoutputdata(0, squidVs);
    nq.setoutputdata(1, modVs);
    
    [data, ~] = nq.run();
    
    data = data(:,1)'; % now a row vector (0, 0, 0, 0,)
    
    forw_d = MathUtils.striprmp_1(data, ...
                                  nq.p.ramppts, length(squidVsraw));
    back_d = MathUtils.striprmp_2(data, ...
                                  nq.p.ramppts, length(squidVsraw));

    highsw(i) = squidVsraw(MathUtils.hist_detect(forw_d, ...
                                          nq.p.cal.high_data, ...
                                          histrange));
    lowsw(i)  = squidVsraw(MathUtils.hist_detect(back_d, ...
                                          nq.p.cal.low_data, ...
                                          histrange));
    histogram(highsw(1:i),50);
    title([num2str(i), ' / ' num2str(length(highsw))]);
    xlabel('I_{squid}');
end

highsw = highsw / nq.p.squid.biasr;
lowsw  = lowsw  / nq.p.squid.biasr;


CSUtils.savecsv([nq.savedir, nq.timestring(), '_highsw.csv'],...
                highsw, '# trigger current for \n' ...
               );
CSUtils.savecsv([nq.savedir, nq.timestring(), '_lowsw.csv'],...
                lowsw, '# row = mod coil, col = squid curr\n' ...
               );


%% Plot
close all
figure

subplot(1,2,1);
histogram(highsw);
title({['param = ', CSUtils.parsefnameplot(nq.lastparamsave)], ...
       ['data  = ', CSUtils.parsefnameplot(nq.lastdatasave)],  ...
       ['gain=',           num2str(nq.p.gain),                 ...
       ' A, squidstep = '    num2str(nq.p.squid.I_step),        ...
       ' A, hist.range = ' num2str(nq.p.hist.range), ...
       ', lp f_0 =',      num2str(nq.p.lpf0),                 ...
       ' hz, rate =',    num2str(nq.p.rate),                 ...
       ' hz r_{bias} = ', num2str(nq.p.squid.biasr),            ...
       ', T = '           num2str(nq.p.T)                     ...
       ]});
xlabel('I_{squid} (A)','fontsize',20);
ylabel('frequency (number)','fontsize',20);

subplot(1,2,2);
histogram(lowsw)
title('high -> low');
xlabel('I_{squid} (A)','fontsize',20);
ylabel('frequency (number)','fontsize',20);

nq.delete();




