function similar_tracks = process_similarTracks(activeTrack, selectedChannels)
%GET_SIMILAR_TRACKS Summary of this function goes here
%   Detailed explanation goes here

trackArray = getTrackArray;
tCount = numel(trackArray);
trackData = activeTrack.TrackData;

track_distances = cell(tCount, 2);
track_distances(1, 1) = {activeTrack.SelectedFeature};
track_distances(1, 2) = {selectedChannels};

display(['Calculating distances for ' trackData.TrackName]);

amplitude = trackData.Amplitude;

feature = createfeaturevector(amplitude, selectedChannels);

for i = 1:tCount
    trackData_comp = trackArray(i).TrackData;
    amplitude_comp = trackData_comp.Amplitude;
    track_name = trackData_comp.TrackName;

    feature_comp = createfeaturevector(amplitude_comp, selectedChannels);
    dists = zeros(size(feature,1), 1);
    for c=1:size(feature,1)
        dists(c) = gdm(feature(c,:), feature_comp(c,:), @gdf);
    end

    dist = mean(dists);
    %display(['distance to ' track_name ' = ' num2str(dist)]);

    track_distances(i+1, 1) = {track_name};
    track_distances(i+1, 2) = {dist};

end

similar_tracks = track_distances;

end
