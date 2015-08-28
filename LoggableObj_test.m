classdef LoggableObj_test < LoggableObj

properties (Access = public)
    newprop 
    newprop2
end

methods (Access = public)
    function this = LoggableObj_test(name, dir)
        this = this@LoggableObj(name, dir);
        this.newprop = 10;
        this.newprop = 11;
    end

    function delete(this)
        this.delete@LoggableObj();
        clear this.newprop;
    end 

    function [paramname, savename] = savetestdata(this, data)
        paramname = this.saveparams({'newprop','newprop2'});
        savename  = this.savedata  (data);
    end
end
end



