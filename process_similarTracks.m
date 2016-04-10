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

switch activeTrack.SelectedFeature
    case 'Autocorrelation'
        feature = trackData.AutoCorrelation;
        for i = 1:tCount
            trackData_comp = trackArray(i).TrackData;
            feature_comp = trackData_comp.AutoCorrelation;
            track_name = trackData_comp.TrackName;

            feature = normalized(feature, 0, 1);
            feature_comp = normalized(feature_comp, 0, 1);

            if ~isequal(size(feature,1),size(feature_comp,1))
                ft_len = numel(feature);
                feature_comp = resize(feature_comp, ft_len);
                feature_comp = feature_comp';
            end
            dist = corrcoef(feature, feature_comp);
            dist = dist(2);
            %dnum = mirgetdata(dist);

            %display(strcat('distance to ', track_name, ' = ', num2str(dist)));

            track_distances(i+1, 1) = {track_name};
            track_distances(i+1, 2) = {dist};
        end
        display('Done');
    case 'Amplitude Envelope'
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
end

similar_tracks = track_distances;


function resized = resize(comp_feature, size)
  %resample each comparison feature to length of query feature
                %   necessary whenever feature is over a single bar (i.e. each track
                %   has diff length)
    x = 1:numel(comp_feature);
    xp = linspace(x(1), x(end), size);
    resized = interp1(x, comp_feature, xp);
end

end
