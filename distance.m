function dists = distances()

test = fopen('test.txt');
pathsToTracks = textscan(test, '%s', 'Delimiter', '\n');
pathsToTracks = pathsToTracks{1};

count = numel(pathsToTracks);

autocors = [];

for i = 1:count
    track_path = pathsToTracks(i);
    [~, track_name, ~] = fileparts(track_path{1});
    pathToAutoCor = strcat(getPathToInfo, track_name, '/', track_name, '_COR.mat');    

    ac = importdata(pathToAutoCor);
    data = get(ac, 'Data');
    data = data{1}{1};
    
    autocors = [autocors data];
end
    
distances = [];

display('Calculating distances');
for i = 1:fileCount
    
    data1 = values(i);    
    iDist = [];
    
    for j = 1:fileCount
        data2 = values(j);
        dist = mirdist(data1, data2);
        dVal = mirgetdata(dist);
        
        iDist = [iDist; dVal];
    end
    distances = [distances, iDist];
end


display('Writing to File');

csvwrite(outputloc, distances,1,1);

display('DONE');

end