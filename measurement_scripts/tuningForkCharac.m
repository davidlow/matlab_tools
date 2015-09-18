%% Initialize
clear all
%  close all


%% Create NI daq and SR830 lock-in object
nidaq = NIdaq('Z:/data/montana_b69/TuningForkChar/150915');
lockin = SR830();

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain       = 500;
nidaq.p.lpf0       = 100;
nidaq.p.mod_curr   = 70e-6;
nidaq.p.mod_biasr   = 12e3;
nidaq.p.rate       = 100; % Hz; number of data points (input or output) passed (inward or outward) per second
nidaq.p.range      = 10; % options: 0.1, 0.2, 0.5, 1, 2, 5, 10
nidaq.p.src_amp    = .001; % in Volts???
nidaq.p.src_numpts = 10; % number of data points
nidaq.p.squid_biasr  = 5e3;
nidaq.p.T          = 9.0;
nidaq.p.Terr       = .060;

nidaq.notes = 'Room temperature cured tuning fork with 2x2 Si chip test';

% Non-savable params - set here!
freq_step = .1; % Hz
freq_min = 32764; % Hz
freq_max = 32774; % Hz
timeConstant = 0.1; % s; lock-in time constant
sensitivity = 0.01; % V; lock-in sensitivity (max range of input)
expand = 1; % lock-in CH1 or 2 output voltage multiplication factor
offset = 0; % lock-in CH1 or 2 output voltage offset
sourceAmp = 0.004; % V; lock-in sine output amplitude
maxCHVoltRange = 10; % V; max range of lock-in CH1 & 2 BNC outputs
inputLockinCH1Num = 0; % DAQ input channel number for lock-in CH1 (voltage X)
inputLockinCH2Num = 1; % DAQ input channel number for lock-in CH2 (voltage Y)
%outputOpAmpBiasNum = 3; % DAQ output channel number for opamp power voltage < +/- 15 V.
dummyNum = 0; % DAQ output channel number for dummy output to control when the DAQ stops sensing input.

% freqSetVals = linspace(freq_min, freq_max, (freq_max-freq_min)/freq_step + 1) % might be better than the colon operator since will always include endpoints
freqSetVals = freq_min:freq_step:freq_max;

%% Setup scan
nidaq.setrate(nidaq.p.rate);
nidaq.addinput_A ('Dev1', inputLockinCH1Num, 'Voltage', nidaq.p.range, 'V-X');
nidaq.addinput_A ('Dev1', inputLockinCH2Num, 'Voltage', nidaq.p.range, 'V-Y');
%nidaq.addoutput_A('Dev1', outputOpAmpBiasNum, 'Voltage', nidaq.p.range, 'opAmp-Voltage');
nidaq.addoutput_A('Dev1', dummyNum, 'Voltage', nidaq.p.range, 'dummy');

%% Setup data
desout = {zeros(1,nidaq.p.src_numpts)};%,...
          %nidaq.p.mod_curr * nidaq.p.mod_biasr *    linspace(1,1   ,nidaq.p.src_numpts)  ...
         %};
%nidaq.setoutputdata(outputOpAmpBiasNum,desout{1}); % will be used for opAmp power voltage
nidaq.setoutputdata(dummyNum,desout{1}); % dummy output so that DAQ keeps reading input

%% Run / collect data

pause('on')

for i = 1:length(freqSetVals)
	lockin.setFreq(freqSetVals(i));
	pause(10*timeConstant);
	freqReadVals(i) = lockin.getFreq();
    
    [data, time] = nidaq.run();
	XVals(i) = (mean(data(:,1))/maxCHVoltRange/expand+offset)*sensitivity; % READS CH1, VX in Vrms, with appropriate proportionality constant, ON LOCK IN FROM DAQ
	YVals(i) = (mean(data(:,2))/maxCHVoltRange/expand+offset)*sensitivity; % READS CH2, VY in Vrms, with appropriate proportionality constant, ON LOCK IN FROM DAQ
    
    %pause(9999) % for debugging purposes
end


%% Plot
ampVals = sqrt(XVals.^2+YVals.^2); % in Vrms
phaseVals = atan(YVals./XVals)/pi()*180; % in degrees
[Ax, Line1, Line2] = plotyy(freqReadVals/1000, ampVals*1000, freqReadVals/1000, phaseVals);
%plot(freqReadVals/1000, ampVals)
hold on
% title(['gain=',           num2str(nidaq.p.gain),                 ...
       % ', lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       % ', hz, rate =',    num2str(nidaq.p.rate),                 ...
       % ', hz r_{bias} = ' num2str(nidaq.p.squid_biasr),            ...
       % ', T = '           num2str(nidaq.p.T)                     ...
       % ]);
xlabel('Frequency (kHz)','fontsize',20);
%ylabel('Amplitude (Vrms)','fontsize',20);
ylabel(Ax(1),'Amplitude (mVrms)','fontsize',20);
ylabel(Ax(2),'Phase (deg)','fontsize',20);

nidaq.delete();
lockin.delete();