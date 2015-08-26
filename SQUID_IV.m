%% Initialize
% clear all
% close all

%% Parameters
gain = 1000;
mod_current_ua = 0;

%% Set up session and input/ouput channels
% devices = daq.getDevices;         % Shows list of available devices, not necessary to run code
s = daq.createSession('ni');  % creates data acquisition session for NI device

s.Rate = 150; %Hz
% s.DurationInSeconds = 1;

in_bias  = addAnalogInputChannel(s,'Dev1',0,'Voltage'); %(session, device name (from daq.getDevices), channel no., measurement type)
out_bias = addAnalogOutputChannel(s,'Dev1',0,'Voltage');
in_mod  = addAnalogInputChannel(s,'Dev1',4,'Voltage'); %(session, device name (from daq.getDevices), channel no., measurement type)
out_mod = addAnalogOutputChannel(s,'Dev1',1,'Voltage');

r = 2; %Set range limits; options are: 0.1, 0.2, 0.5, 1, 2, 5, 10; see this from in0.Device.Subsystems(1).RangesAvailable
in_bias.Range  = [-r, r]; %set input range -r V to +r V
in_mod.Range   = [-r, r];

%% Set up signals

A = 0.2;        % V
num_pts = 1000; % Number of data points taken
qp = num_pts/4; % quarter period of data points

% output_signal = A*sin(linspace(0,2*pi,1000)'); %one period of output signal, array transposed to make it a column
% qp used to mean "quarter period" and now it doesn't lalalalala
output_signal = A*cat(1,linspace(0,qp, qp)'/qp, ones(qp,1), 1-linspace(0,2*qp, 2*qp)'/qp, -1*ones(qp,1), -1+linspace(0,qp, qp)'/qp); %Crude triangle wave
mod_signal = mod_current_ua/100*ones(size(output_signal)); %100 uA = 1 V

% output_signal = A*cat(1,linspace(0,num_pts, num_pts)'/num_pts,1-linspace(0,num_pts, num_pts)'/num_pts);
queueOutputData(s, [output_signal mod_signal])

%% Collect data
% s.startBackground(); %Get cho data, yo!
[data,time] = s.startForeground; %Get cho data, yo!
bias_data = data(:,1);
mod_data = data(:,2);

%% Futzing with data
bias_data = bias_data - bias_data(1);
mod_data = mod_data - mean(mod_data);

%% Plot dat data vs time
% figure()
% plot(time, output_signal/100, 'k');
% hold on
% plot(time, bias_data, 'r');
% legend('output signal', 'voltage across squid')

% plot(time, mod_data, 'k');
% legend('bias data','mod data');

% xlabel('t');
% ylabel('V');

%% Plot dat data vs output

plot(output_signal/3000*1000000, bias_data/gain);
hold on
xlabel('V_{bias}/R_{bias} (\mu A)','fontsize',20);
ylabel('V_{SQUID} (V)','fontsize',20);

% figure()
% plot(output_signal/10000*1000000, mod_data/gain)
% hold on
% xlabel('I (\mu A)')
% ylabel('V_{mod}')
% xlabel('V_{bias}/R_{bias} (\mu A)','fontsize',20);
% ylabel('V_{SQUID} (V)','fontsize',20);