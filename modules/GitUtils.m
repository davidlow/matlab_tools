classdef GitUtils
    %GITUTILS Collection of static utilities used with git
    
    % Change log:
    % 15 09 17: UNTESTED DO NOT USE YET (DL)
    
    methods(Static)
        function g = git(dir, author, message) 
        % git(): run this to get status, add, commit, and record version
        % parameters: dir, message = strings
        % returns:    struct with parameters including version hash
            status_old       = GitUtils.gitstatus(dir);
            add_cli_reply    = GitUtils.gitadd(dir);
            commit_cli_reply = GitUtils.gitcommit(dir, [author, ': ', message]);
            status_new       = GitUtils.gitstatus(dir);
            version_hash     = GitUtils.gitrevhash(dir);
            g = struct('dir',                dir, ...
                       'status_old',         status_old,...
                       'add_cli_reply',      add_cli_reply,...
                       'commit_cli_reply',   commit_cli_reply,...
                       'status_new',         status_new,...
                       'version_hash',       version_hash...
                       );        
        end
        
        function str = gitrevhash(dir)
            old = cd(dir);
            [~, str] = system('git rev-parse HEAD');
            cd(old);
        end
        
        function str = gitstatus(dir)
            old = cd(dir);
            [~, str] = system('git status -s');
            cd(old);
        end
        
        function str = gitcommit(dir, message)
            old = cd(dir);
            [~, ~  ] = system(['cd ' dir]);
            [~, str] = system(['git commit -m "', message, '"']);
            cd(old);
        end
        
        function str = gitadd(dir)
            old = cd(dir);
            [~, ~  ] = system(['cd ' dir]);
            [~, str] = system(['git add ', dir]); %. works in subdirs
            cd(old);
        end
        
        function str = workingdir()
            str = 
        end
    end
    
end

