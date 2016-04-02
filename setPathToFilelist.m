function setPathToFilelist(path)

if not (exist(path, 'file'))
    f = fopen(path, 'wt');
    fclose(f);
end
global pathToFilelist;
pathToFilelist = path;
