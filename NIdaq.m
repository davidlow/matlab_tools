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


classdef NIdaq < LoggableObj % {
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

properties (Access = public)
    session     %session object
    inputs      %array of input  channels structs
    outputs     %array of output channels structs
                % structs defined only in addinput() or addoutput()
end

methods (Access = public) % {


function this = NIdaq(savedir)
% NAME
%       NIdaq()
% SYNOPSIS
%       NIdaq objecthandle = NIdaq();
% RETURN
%       Returns a NIdaq object that extends handle.  
%       Handle is used to pass a refere
    this = this@LoggableObj('NIdaq',savedir);
    this.session = daq.createSession('ni');
end

function delete(this)
%full clean close, including cleaning par
    this@delete();
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
    this.outputs = CSUtils.sortnumname(this.outputs, 'channelnumber');
end

function setoutputdata(this, channelnumber, data)
%data has 1 more entry at the end than necessary to cope with weirdness
%with data taking 
%TODO (need to check this to make sure it works!!!!)
    i = CSUtils.findnumname(this.outputs, 'channelnumber', channelnumber);
    this.outputs(i).data = zeros(length(data)+1,1);
    for j = 1:length(data)
        this.outputs(i).data(j) = data(j)
    end
    this.outputs(i).data(length(data)+1) = data(length(data));
end

%%%%%%% Measurement Methods
function data, time = run(this)
    datalist = [];
    for i = 1:length(this.outputs)
        datalist = [datalist this.outputs(i).data];
    end
    this.session.queueOutputData(datalist);
    [data, time] = this.session.startForeground;

    data = data(end,:) = []; %removes last row

    this.saveparams(['inputs','outputs']);
    this.savedata  ([date, time]);
end

end % } END methods

end % } ENE class 
% END OF FILE
