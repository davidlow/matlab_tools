classdef LoggableObj < handle % {

properties (Access = public)
    notes   % NOTES to save
    p       % Parameters to save
end

properties (Access = protected)
    git
    namestring
    savedir
end

methods (Access = public)% {

    function this = LoggableObj(name, savedirectory)
        this.git   = '';
        this.notes = '';
        this.namestring = name;
        this.savedir = savedirectory;
    end

    function delete(this)
        clear this.git;
        clear this.notes;
        clear this.p;
        clear this.namestring;
        clear this.savedir;
    end

end 

methods (Access = protected)

    function filename = saveparams(this, keys)
        this.populategit();
        parameters = struct(this.namestring, struct());
        keys = [keys, {'git', 'namestring', 'notes', 'p'}];
        for i = 1:length(keys)
            parameters.(this.namestring).(keys{i}) = this.(keys{i});
        end
        filename = [this.savedir, this.paramstring()];
        save(filename, '-struct', 'parameters');
    end

    function filename = savedata(this, datamatrix)
        filename = [this.savedir, this.datastring()];
        csvwrite(filename, datamatrix);
    end

end 

methods (Access = private)
    function datastr = datastring(this)
        datastr = [this.timestring, '_', ... 
                   this.namestring, '_', ...
                   'data.csv'];
    end

    function paramstr = paramstring(this)
        paramstr = [this.timestring, '_', ...
                    this.namestring, '_', ...
                    'params.mat'];
    end

   

    function populategit(this)
        this.git = 'No git or improperly installed';
        try 
            this.git = [system('git rev-parse HEAD'), '\n', ... 
                        system('git status -s')];
        catch
            
        end 
    end

end % }end private methods

methods (Static)
     function str = timestring()
        str = char(datetime('now','TimeZone','local','Format',...
                                'yyyyMMdd_HHmmss_z'));
     end
end

end % }end of classdef
