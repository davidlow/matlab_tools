%  Keithley2400 Matlab Drivers 
%  Copyright (C) 2015 David Low, Nowack Lab
%
%   This program is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <http://www.gnu.org/licenses/>.


classdef SR830 < handle % {
% NAME
%       SR830.m  
%
% SYNOPSIS
%       SR830 objecthandle = SR830();
%
% DESCRIPTION
%       Interface for driving SR830 Lock-in Amplifier by
%       Standford Research Systems using a NI GPIB-USB-HS 
%       and the NI 488-2 drivers.  
%
%       Create this object to use the lock in.  Methods you may 
%       care about are:
%
% CHANGE LOG
%       2015 08 20: dhl88: created

properties 
    visa    %visa object initialized in constructor
    par     %SR830 parameters
end

methods  % {


function this = SR830()
% NAME
%       SR830()
% SYNOPSIS
%       SR830 objecthandle = SR830();
% RETURN
%       Returns a SR830 object that extends handle.  
%       Handle is used to pass a refere

    this.visa = visa('ni','GPIB0::8::INSTR');

    % this is from the keithley driver... I think it's necessary?
    set(this.visa, 'BoardIndex',             0);
    set(this.visa, 'ByteOrder',              'littleEndian');
    set(this.visa, 'BytesAvailableFcn',      '');
    set(this.visa, 'BytesAvailableFcnCount', 48);
    set(this.visa, 'BytesAvailableFcnMode',  'eosCharCode');
    set(this.visa, 'CompareBits',            8);
    set(this.visa, 'EOIMode',                'on');
    set(this.visa, 'EOSCharCode',            'LF');
    set(this.visa, 'EOSMode',                'read&write');
    set(this.visa, 'ErrorFcn',               '');
    set(this.visa, 'InputBufferSize',        256); %256 char SR830's max 
    set(this.visa, 'Name',                   'GPIB0-8');
    set(this.visa, 'OutputBufferSize',       2048); % 8 * 256 = 8*max out
    set(this.visa, 'OutputEmptyFcn',         '');
    set(this.visa, 'PrimaryAddress',         8);
    set(this.visa, 'RecordDetail',           'compact');
    set(this.visa, 'RecordMode',             'overwrite');
    set(this.visa, 'RecordName',             'record.txt');
    set(this.visa, 'SecondaryAddress',       0);
    set(this.visa, 'Tag',                    '');
    set(this.visa, 'Timeout',                10);
    set(this.visa, 'TimerFcn',               '');
    set(this.visa, 'TimerPeriod',            1);
    set(this.visa, 'UserData',               []);

    fprintf(this.visa, 'OUTX1'); 
end

function delete(this)
    delete(this.visa)
    clear this.visa
end

%%%%%%% Measurement Methods
function snapshot(this)
    fprintf(this.visa, 'SNAP?3,4')
    x = fscanf(this.visa, '%f,%f');
    return x;
end

function sensitivity(this, level)
    %level integer and their meanings:
    %0  2   nV or fA
    %1  5   nV or fA
    %2  10  nV or fA
    %3  20  nV or fA
    %4  50  nV or fA
    %5  100 nV or fA
    %6  200 nV or fA
    %7  500 nV or fA
    %8  1   uV or pA
    %9  2   uV or pA
    %10 5   uV or pA
    %11 10  uV or pA
    %12 20  uV or pA
    %13 50  uV or pA
    %14 100 uV or pA
    %15 200 uV or pA
    %16 500 uV or pA
    %17 1   mV or nA
    %18 2   mV or nA
    %19 5   mV or nA
    %20 10  mV or nA
    %21 20  mV or nA
    %22 50  mV or nA
    %23 100 mV or nA
    %24 200 mV or nA
    %25 500 mV or nA
    %26 1    V or uA
    fprintf(this.visa, ['SENS',num2str(level)]);
end


%%%%%%% Helper Methods
function init(this)
    fprintf(this.visa, '*RST');  %initialize lockin
    fprintf(this.visa, 'FAST0'); %disables fast 

function getparams(this)
%copied from getparameters_SR830.m from moler lab 
%(matlab_measure/scanning/getparameters_SR830.m)
    fprintf(sr830, '*IDN?')
    par.id = fscanf(sr830);
            
    fprintf(sr830, 'PHAS?')
    par.phase = fscanf(sr830, '%f');
                    
    fprintf(sr830, 'FMOD?')
    par.internal_ref = fscanf(sr830, '%i');
                            
    fprintf(sr830, 'FREQ?')
    par.freq = fscanf(sr830, '%f');
                                    
    fprintf(sr830, 'HARM?')
    par.harmonic = fscanf(sr830, '%i');
                                            
    fprintf(sr830, 'SLVL?')
    par.vOutRMS = fscanf(sr830, '%f');
                                                    
    fprintf(sr830, 'ISRC?')
    par.in_config = fscanf(sr830, '%i');
                                                            
    fprintf(sr830, 'IGND?')
    par.in_shield_gnd = fscanf(sr830, '%i');
                                                                    
    fprintf(sr830, 'ICPL?')
    par.in_coup_dc = fscanf(sr830, '%i');
                                                                            
    fprintf(sr830, 'ILIN?')
    par.in_notch = fscanf(sr830, '%i');
    
    fprintf(sr830, 'SENS?')
    i = fscanf(sr830, '%i');

    switch rem(i, 3)
    case 0
         par.sens = 2;
    case 1 
         par.sens = 5;
    case 2
         par.sens = 10; 
    end;

    par.sens = par.sens * 10^(fix(i/3)-9); 
    
    fprintf(sr830, 'OEXP? 1')
    x = fscanf(sr830, '%f, %f');
    par. exp_x = 10^x(2);
    par. off_x = x(1);
    
    fprintf(sr830, 'RMOD?')
    par.reserve = fscanf(sr830, '%i');
    
    fprintf(sr830, 'OFLT?')
    i = fscanf(sr830, '%i');
    switch rem(i, 2)
    case 0
         par.timeconst = 1;
    case 1 
         par.timeconst = 3;
    end;

    par.timeconst = par.timeconst * 10^(fix(i/2)-5);

    fprintf(sr830, 'OFSL?')
    par.slope = 6 * fscanf(sr830, '%i') + 6;

    fprintf(sr830, 'SYNC?')
    par.sync = fscanf(sr830, '%i');
end

end % } END methods

end % } ENE class 
% END OF FILE
