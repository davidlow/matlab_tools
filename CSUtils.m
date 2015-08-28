classdef CSUtils
% A bunch of static functions that you can use.  add any Computer Science
% UTILitieS to this that you think do not belong with any specific class.
% try and make them as abstract as you can
methods (Static)
    function hi = kevin()
        hi = 5;
    end
    function hi = kevin2()
        hi = 6;
    end
    function index = findnumname(array, name, number)
    % int index findnumname (struct array, String name, int number): 
    % struct array: array of structs, each of which have field name that
    % is an integer.  index is the index of the array where number occurs
    % or -1 if not found
        index = -1;
        for i = 1:length(arr)
            if(obj.(name) == number)
                index = i;
                return
            end
        end
    end

    function array = sortnumname(array, name)
        for i = 1:length(array)
            lowest = i;
            for j = i:length(array)
                if(array(i).(name) > array(j).(name))
                    lowest = j;
                end
                tmp = arr(i);
                arr(i) = arr(j);
                arr(j) = tmp;
            end
        end
    end
end
end
