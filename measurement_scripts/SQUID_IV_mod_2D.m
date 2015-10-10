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
        LoggableObj.timestring(), '_mod2D/' ];
mkdir(path);
nidaq = NIdaq('DL', path); %save path 

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain        = 500;
nidaq.p.lpf0        = 1000;
nidaq.p.rate        = 700; %0.1 < rate < 2 857 142.9
nidaq.p.T           = 6.0;
nidaq.p.Terr        = .033;

nidaq.p.mod_I_cntr  = 0;      % center in amps
nidaq.p.mod_I_span  = 200e-6; % total span in amps
nidaq.p.mod_I_step  = .5e-6;   % current step in amps
nidaq.p.mod_biasr   = 2.5e3;  %1.0 + 1.5 cold

nidaq.p.squid_I_cntr= 0e-6;  % center current in amps
nidaq.p.squid_I_span= 50e-6; % total span in amps
nidaq.p.squid_I_step= .1e-6;  % current step in amps
nidaq.p.squid_biasr = 2.5e3 + 3e3; %1.0k + 1.5k cold, 3k warm
nidaq.p.ramppts     = 10;

nidaq.p.range       = 1; % options: 0.1, 0.2, 0.5, 1, 5, 10

nidaq.notes = 'Very quick scan to see if I can recover same results';

%% Setup scan

nidaq.addinput_A ('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID V (sense)');
nidaq.addoutput_A('Dev1', 0, 'Voltage', nidaq.p.range, 'SQUID I (source)');
nidaq.addoutput_A('Dev1', 1, 'Voltage', nidaq.p.range, 'MOD I (source)');

nidaq.setrate    (nidaq.p.rate);


%%


%% Setup data
% Create mod linear sweep
% Create squid linear sweep.  Ramp from 0 to start, then squid sweep, 
%                             then squid sweep backwards, then ramp to 0
% prep arrays to store data

modVs   = nidaq.p.mod_biasr *                                 ...
          linspace(nidaq.p.mod_I_cntr - nidaq.p.mod_I_span/2, ...
                   nidaq.p.mod_I_cntr + nidaq.p.mod_I_span/2, ...
                   nidaq.p.mod_I_span / nidaq.p.mod_I_step );
               
squidVsraw = nidaq.p.squid_biasr *                                   ...
             linspace(nidaq.p.squid_I_cntr - nidaq.p.squid_I_span/2, ...
                      nidaq.p.squid_I_cntr + nidaq.p.squid_I_span/2, ...
                      nidaq.p.squid_I_span / nidaq.p.squid_I_step );            
rampi   = (nidaq.p.squid_I_cntr - nidaq.p.squid_I_span/2) *  ...
           sin(linspace(0,pi/2,nidaq.p.ramppts)); %smooth, slower at end
squidVs = [rampi, squidVsraw, squidVsraw(end:-1:1), rampi(end:-1:1)];


allforw = zeros(length(modVs), length(squidVsraw));
allback = zeros(length(modVs), length(squidVsraw));

%% Run / collect data
% for all mod currents, set mod coil voltage and squid voltages.  Append
% data to correct place in data arrays

i = 1;
colormap(jet);
for mod = modVs
    modV = mod * linspace(1,1,length(squidVs));
    nidaq.setoutputdata(0, squidVs);
    nidaq.setoutputdata(1, modV);
    
    [data, ~] = nidaq.run();
    
    data = data(:,1)'; % now a row vector (0, 0, 0, 0,)
    
    forw_d = data(length(rampi)+1:...
                  length(rampi) + length(squidVsraw));
    back_d = data(length(rampi) + length(squidVsraw) + 1: ...
                  length(rampi) + length(squidVsraw) + length(squidVsraw));
    allforw(i,:) = forw_d;
    allback(i,:) = back_d;
    i = i + 1;
    imagesc(squidVsraw/nidaq.p.squid_biasr, ...
        modVs  /nidaq.p.mod_biasr  , ...
        allforw);
    colorbar;
end

CSUtils.savecsv([nidaq.savedir, nidaq.timestring(), '_forw.csv'],...
                allforw, '# row = mod coil, col = squid curr\n' ...
               );
CSUtils.savecsv([nidaq.savedir, nidaq.timestring(), '_back.csv'],...
                allback, '# row = mod coil, col = squid curr\n' ...
               );

%% Plot
close all
hold on
colormap(jet);
imagesc(squidVsraw/nidaq.p.squid_biasr, ...
        modVs  /nidaq.p.mod_biasr  , ...
        allforw);
colorbar;
title({['param = ', CSUtils.parsefnameplot(nidaq.lastparamsave)], ...
       ['data  = ', CSUtils.parsefnameplot(nidaq.lastdatasave)],  ...
       ['gain=',           num2str(nidaq.p.gain),                 ...
       ', modstep = '        num2str(nidaq.p.mod_I_step),              ...
       ' A, squidstep = '    num2str(nidaq.p.squid_I_step),              ...
       ' A, lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       ' hz, rate =',    num2str(nidaq.p.rate),                 ...
       ' hz r_{bias} = ', num2str(nidaq.p.squid_biasr),            ...
       ', T = '           num2str(nidaq.p.T)                     ...
       ]});
xlabel('I_{squid} (A)','fontsize',20);
ylabel('I_{mod} (A)','fontsize',20);

nidaq.delete();




