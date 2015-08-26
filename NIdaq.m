%  NI DAQ Matlab Drivers 
%  Copyright (C) 2015 David Low, Brian Schaefer, Nowack Lab
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


classdef NIdaq < handle % {
% NAME
%       NIdaq.m  
%
% SYNOPSIS
%       NIdaq objecthandle = NIdaq();
%
% DESCRIPTION
%       Interface for driving NIdaq 
%
%       Create this object to use the NI DAQ.  Methods you may 
%       care about are:
%
% CHANGE LOG
%       2015 08 26: dhl88: created

properties 
    session     %session object
    inputs      %input  channels structs
    outputs     %output channels structs
    notes = ''  %notes
    git   = ''  %git hash
end

methods  % {


function this = NIdaq()
% NAME
%       NIdaq()
% SYNOPSIS
%       NIdaq objecthandle = NIdaq();
% RETURN
%       Returns a NIdaq object that extends handle.  
%       Handle is used to pass a refere

    this.session = daq.createSession('ni');
end

function delete(this)
%full clean close, including cleaning par
    clear this.inputs;
    clear this.outputs;
    release(this.session);
end

%%%%%%% Setup Methods
function handle = addinput_A(this, ...
                    devicename, channelnumber, measurementtype, range,...
                    label)
    handle = addAnalogInputChannel(this.session, devicename, ...
                                   channelnumber, measurementtype);
    handle.Range = [-range, range];
    input_s = struct( ...
                'devicename',       devicename,...
                'channelnumber',    channelnumber,...
                'measurementtype',  measurementtype,...
                'range',            range,...
                'handle',           handle,...
                'label',            label...
                );
    this.inputs = [this.inputs, input_s];
end

function handle = addoutput_A(this, ...
                    devicename, channelnumber, measurementtype, range,
                    label)
    handle = addAnalogOutputChannel(this.session, devicename, ...
                                   channelnumber, measurementtype);
    handle.Range = [-range, range];
    output_s = struct( ...
                'devicename',       devicename,...
                'channelnumber',    channelnumber,...
                'measurementtype',  measurementtype,...
                'range',            range,...
                'handle',           handle,...
                'label',            label,...
                'data',             []...
                );
    this.outputs = [this.outputs, output_s];
    this.outputs = sortbychnum(this.outputs);
end

function setoutputdata(this, channelnumber, data)
    i = findchnum(this.outputs, channelnumber);
    this.outputs(i).data = data;
end

%%%%%%% Measurement Methods
function data, time = run(this)
    datalist = [];
    for i = 1:length(this.outputs)
        datalist = [datalist this.outputs(i).data];
    end
    this.session.queueOutputData(datalist);
    [data, time] = this.session.startForeground;

    csvwrite(datastring(), [date, time]);
    this.populategit();
    params = struct('inputs',    this.inputs,    ...
                    'outputs',   this.outputs,   ...
                    'notes',     this.notes,     ...
                    'git',       this.git,       ...
                    'data',      data,           ...
                    'time',      time            ...
                   );
    save(parameterstring(), 'params');
end

%%%%%%% Helper Methods
function arr = sortbychnum(arr)
    for i = 1:length(arr)
        lowest = i;
        for j = i:length(arr)
            if(arr(i).channelnumber > arr(j).channelnumber)
                lowest = j
            end
        tmp = arr(i)
        arr(i) = arr(j);
        arr(j) = tmp;
    end
end

function index = findchnum(arr, chnum)
    index = -1;
    for i = 1:length(arr)
        if(arr.channelnumber == chnum)
            index = i;
            return
    end
end

function timestr = timestring()
    timestr = char(...
        datetime('now','TimeZone','local','Format','yyyyMMdd_HH:mm:ss_z'));
end

function datastr = datastring()
    datastr = [timestring, '_data.csv'];
end

function paramstr = parameterstring()
    paramstr = [timestring, '_params.mat'];
end

function populategit(this)
    try
        this.git = [system('git rev-parse HEAD'), '\n', ...
                    system('git status -s')];
    catch ME
        this.git = 'No git or improperly installed';
    end
end

end % } END methods

end % } ENE class 
% END OF FILE
