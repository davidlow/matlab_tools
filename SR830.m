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
    a
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

    this.init();
    this.a=1;
end

function delete(this)
%full clean close, including cleaning par
    this.close();
    delete(this.visa);
    clear this.par;
    clear this.visa;
end

%%%%%%% Measurement Methods
function x = snapshot(this)
    fprintf('SR830.snapshot: start\n');
    try
        fprintf(this.visa, 'SNAP?3,4\n');
        x = fscanf(this.visa, '%f,%f');
    catch ME
        fprintf('SR830.snapshot: Error write or read\n');
        rethrow(ME);
    end
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
    try
        fprintf(this.visa, ['SENS ',num2str(level),'\n']);
    catch ME
        fprintf('SR830.sensitivity: Cannot write to SR830?\n')
        this.close();
        rethrow(ME);
    end
end


%%%%%%% Helper Methods
function init(this)
%Call me to init.  Has try catch safety
    try
        fopen(this.visa);
    catch ME
        fprintf('SR830.init: visa already open\n');
        this.close();
        rethrow(ME);
    end

    try
        fprintf(this.visa, 'OUTX1\n'); 
        fprintf(this.visa, '*RST\n');  %initialize lockin
        fprintf(this.visa, 'FAST0\n'); %disables fast 
        fprintf(this.visa, 'REST\n');  %clears data buffer
    catch ME
        fprintf('SR830.init: write error?\n');
        this.close();
        rethrow(ME);
    end
        
end

function close(this)
    fclose(this.visa);
    fprintf('SR830.close: closed\n');
end

function getparams(this)
%copied from getparameters_SR830.m from moler lab 
%(matlab_measure/scanning/getparameters_SR830.m)
%has try catch safety with clean exit

try
    fprintf(this.visa, '*IDN?\n');
    this.par.id = fscanf(this.visa);
            
    fprintf(this.visa, 'PHAS?\n');
    this.par.phase = fscanf(this.visa);
                    
    fprintf(this.visa, 'FMOD?\n');
    this.par.internal_ref = fscanf(this.visa);
                            
    fprintf(this.visa, 'FREQ?\n');
    this.par.freq = fscanf(this.visa, '%f');
                                    
    fprintf(this.visa, 'HARM?\n');
    this.par.harmonic = fscanf(this.visa, '%i');
                                            
    fprintf(this.visa, 'SLVL?\n');
    this.par.vOutRMS = fscanf(this.visa, '%f');
                                                   
    fprintf(this.visa, 'ISRC?\n');
    this.par.in_config = fscanf(this.visa, '%i');
                                                            
    fprintf(this.visa, 'IGND?\n');
    this.par.in_shield_gnd = fscanf(this.visa, '%i');
                                                                    
    fprintf(this.visa, 'ICPL?\n');
    this.par.in_coup_dc = fscanf(this.visa, '%i');
                                                                            
    fprintf(this.visa, 'ILIN?\n');
    this.par.in_notch = fscanf(this.visa, '%i');
    
    fprintf(this.visa, 'SENS?\n');
    i = fscanf(this.visa, '%i');

    switch rem(i, 3)
    case 0
         this.par.sens = 2;
    case 1 
         this.par.sens = 5;
    case 2
         this.par.sens = 10; 
    end;

    this.par.sens = this.par.sens * 10^(fix(i/3)-9);
    
    fprintf(this.visa, 'OEXP? 1\n');
    this.par.oexp = fscanf(this.visa);
    
    fprintf(this.visa, 'RMOD?\n');
    this.par.reserve = fscanf(this.visa);
    
    fprintf(this.visa, 'OFLT?\n');
    i = fscanf(this.visa, '%i');
    switch rem(i, 2)
    case 0
         this.par.timeconst = 1;
    case 1 
         this.par.timeconst = 3;
    end;

    this.par.timeconst = this.par.timeconst * 10^(fix(i/2)-5);

    fprintf(this.visa, 'OFSL?\n');
    this.par.slope = 6 * fscanf(this.visa, '%i') + 6;

    fprintf(this.visa, 'SYNC?\n');
    this.par.sync = fscanf(this.visa, '%i');

    fprintf(this.visa, 'SENS?\n');
    this.par.sensitivity = fscanf(this.visa,'%i');
catch ME
    fprintf('SR830.getparams: error, exiting\n');
    this.close();
    rethrow(ME);
end
end

end % } END methods

end % } ENE class 
% END OF FILE
