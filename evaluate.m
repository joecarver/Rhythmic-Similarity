% evaluate script loads the similarity list for given featurename
% returns the in-genre precision for each track's top 10 recommendations

fl_loc = '/Users/josephcarver/Google Drive/My Documents/Uni/Year 3/3YP/Matlab/test.txt';
file = fopen(fl_loc, 'r');

pathsToTracks = textscan(file, '%s', 'Delimiter', '\n');
pathsToTracks = pathsToTracks{1};

featurename = 'Autocorrelation';

%construct a TrackArray object from the string array of paths
%set it as the global/active trackArray
trackArray = TrackArray(pathsToTracks);
setTrackArray(trackArray);

tCount = numel(trackArray);

trackPrecisions = cell(tCount, 2);

for i = 1:tCount
    
    trackData = trackArray(i).TrackData;
    trackGenre = trackData.ActGenre;
    
    pathToSimTracks = [trackData.PathToInfoDir trackData.TrackName '_SIM_' featurename(1:5) '_.mat'];
    simTracks = importdata(pathToSimTracks);
    simTracks(1,:) = [];
    simTracks = sortrows(simTracks, -2);
    
    correct = 0;
    incorrect = 0;
    
    %compare the genres ofthe first 10 tracks 
    %ignore first two entries (feature name and same track)
    for j=2:21
        trackData_comp = getTrackDataFromName(simTracks(j,1));
        trackGenre_comp = trackData_comp.ActGenre;
        
        if strcmp(trackGenre, trackGenre_comp)
            correct = correct + 1;
        else
            incorrect = incorrect + 1;
        end
    end
    
    precision = correct/(correct+incorrect);
    
    trackPrecisions(i,1) = {trackData.TrackName};
    trackPrecisions(i,2) = {precision};
end