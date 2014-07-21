function x = dirsize(path)
    s = dir(path);
    name = {s.name};
    isdir = [s.isdir] & ~strcmp(name,'.') & ~strcmp(name,'..');
    this_size = sum([s(~isdir).bytes]);
    sub_f_size = 0;
    if(~all(isdir == 0))
        subfolder = strcat(path, filesep(), name(isdir));
        sub_f_size = sum([cellfun(@dirsize, subfolder)]);
    end
    x = this_size + sub_f_size;
end % dirsize 