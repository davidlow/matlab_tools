name = 'test_LoggableObject';
l = LoggableObj_test(name, 'testout/');
l.notes = 7;
l.p.param = 1;
l.p.lifeistough = 9e10;


data = [1,2,3; 4,5,6; 7,8,9];

[paramname, savename] = l.savetestdata(data);

% l.delete()
% 
% clearvars -except paramname savename name
% 
% 
% 
% load(paramname)
% errors = 0;
% ctr    = 1;
% 
% if((name).notes ~= 7)
%     errors = bitor(errors, ctr);
% end
% ctr = bitshift(ctr,1);
% if(p.param ~= 1)
%     errors = bitor(errors, ctr);
% end
% ctr = bitshift(ctr,1);
% if(p.lifeistough ~= 9e10)
%     errors = bitor(errors, ctr);
% end
% ctr = bitshift(ctr,1);
% if(newprop ~= 10)
%     errors = bitor(errors, ctr);
% end
% ctr = bitshift(ctr,1);
% 
% data1 = csvread(savename);
% if(sum(sum(data1 ~= [1,2,3;4,5,6;7,8,9])))
%     errors = bitor(errors,ctr);
% end
% ctr = bitshift(ctr,1);
% 
% errors