%% Initialize
% clear all
% close all


%% Create NI daq object
nidaq = NIdaq('Z:/home/david/logs/trashlogs/');

%% Set parameters to be used / saved by LoggableObj
% Add and set parameters here! not in the code! if you want more params
% add them here  All of these 'should' be saved ;)
nidaq.p.gain       = 500;
nidaq.p.lpf0       = 100;
nidaq.p.mod_curr   = 0e-6;
nidaq.p.rate       = 100;
nidaq.p.range      = 5; % options: 0.1, 0.2, 0.5, 1, 2, 5, 10
nidaq.p.src_amp    = .2;
nidaq.p.src_numpts = 100;
nidaq.p.mod_biasr  = 3e3;
nidaq.p.T          = 4.2;
nidaq.p.Terr       = .012;

nidaq.notes = 'Testing code using 3k from in to out';


%% Setup scan
nidaq.setrate(nidaq.p.rate);
nidaq.addinput_A ('Dev1', 0, 'Voltage', nidaq.p.range, 'measurement');
nidaq.addinput_A ('Dev1', 4, 'Voltage', nidaq.p.range, 'unused');
nidaq.addoutput_A('Dev1', 0, 'Voltage', nidaq.p.range, 'measurement');
nidaq.addoutput_A('Dev1', 1, 'Voltage', nidaq.p.range, 'bias');

%% Setup data
desout = {nidaq.p.src_amp * sin(linspace(0,2*pi,nidaq.p.src_numpts)),...
          nidaq.p.mod_curr *    linspace(1,1   ,nidaq.p.src_numpts)  ...
         };
nidaq.setoutputdata(0,desout{1});
nidaq.setoutputdata(1,desout{2});

%% Run / collect data
[data, time] = nidaq.run();

%% Plot
plot(desout{1}/nidaq.p.mod_biasr, data(:,1));
hold on
title(['gain=',           num2str(nidaq.p.gain),                 ...
       ', lp f_0 =',      num2str(nidaq.p.lpf0),                 ...
       ', hz, rate =',    num2str(nidaq.p.rate),                 ...
       ', hz r_{bias} = ' num2str(nidaq.p.mod_biasr),            ...
       ', T = '           num2str(nidaq.p.T)                     ...
       ]);
xlabel('I_{bias} = V_{bias}/R_{bias} (A)','fontsize',20);
ylabel('V_{mod} (V)','fontsize',20);

nidaq.delete();





%% Brian's old code

% %% Set up session and input/ouput channels
% % devices = daq.getDevices;         % Shows list of available devices, not necessary to run code
% s = daq.createSession('ni');  % creates data acquisition session for NI device
% 
% s.Rate = 150; %Hz
% % s.DurationInSeconds = 1;
% 
% in_bias  = addAnalogInputChannel(s,'Dev1',0,'Voltage'); %(session, device name (from daq.getDevices), channel no., measurement type)
% out_bias = addAnalogOutputChannel(s,'Dev1',0,'Voltage');
% in_mod  = addAnalogInputChannel(s,'Dev1',4,'Voltage'); %(session, device name (from daq.getDevices), channel no., measurement type)
% out_mod = addAnalogOutputChannel(s,'Dev1',1,'Voltage');
% 
% r = 2; %Set range limits; options are: 0.1, 0.2, 0.5, 1, 2, 5, 10; see this from in0.Device.Subsystems(1).RangesAvailable
% in_bias.Range  = [-r, r]; %set input range -r V to +r V
% in_mod.Range   = [-r, r];
% 
% %% Set up signals
% 
% A = 0.2;        % V
% num_pts = 1000; % Number of data points taken
% qp = num_pts/4; % quarter period of data points
% 
% % output_signal = A*sin(linspace(0,2*pi,1000)'); %one period of output signal, array transposed to make it a column
% % qp used to mean "quarter period" and now it doesn't lalalalala
% output_signal = A*cat(1,linspace(0,qp, qp)'/qp, ones(qp,1), 1-linspace(0,2*qp, 2*qp)'/qp, -1*ones(qp,1), -1+linspace(0,qp, qp)'/qp); %Crude triangle wave
% mod_signal = mod_current_ua/100*ones(size(output_signal)); %100 uA = 1 V
% 
% % output_signal = A*cat(1,linspace(0,num_pts, num_pts)'/num_pts,1-linspace(0,num_pts, num_pts)'/num_pts);
% queueOutputData(s, [output_signal mod_signal])
% 
% %% Collect data
% % s.startBackground(); %Get cho data, yo!
% [data,time] = s.startForeground; %Get cho data, yo!
% bias_data = data(:,1);
% mod_data = data(:,2);
% 
% %% Futzing with data
% bias_data = bias_data - bias_data(1);
% mod_data = mod_data - mean(mod_data);
% 
% %% Plot dat data vs time
% % figure()
% % plot(time, output_signal/100, 'k');
% % hold on
% % plot(time, bias_data, 'r');
% % legend('output signal', 'voltage across squid')
% 
% % plot(time, mod_data, 'k');
% % legend('bias data','mod data');
% 
% % xlabel('t');
% % ylabel('V');
% 
% %% Plot dat data vs output
% 
% plot(output_signal/3000*1000000, bias_data/gain);
% hold on
% xlabel('V_{bias}/R_{bias} (\mu A)','fontsize',20);
% ylabel('V_{SQUID} (V)','fontsize',20);
% 
% % figure()
% % plot(output_signal/10000*1000000, mod_data/gain)
% % hold on
% % xlabel('I (\mu A)')
% % ylabel('V_{mod}')
% % xlabel('V_{bias}/R_{bias} (\mu A)','fontsize',20);
% % ylabel('V_{SQUID} (V)','fontsize',20);