function similar_tracks = process_similarTracks(activeTrack, selectedFeatures, smartSelect)
%GET_SIMILAR_TRACKS Summary of this function goes here
%   Detailed explanation goes here

trackArray = getTrackArray;
tCount = numel(trackArray);

track_distances = cell(tCount, 2);

display(['Calculating distances for ' activeTrack.TrackName]);

switch activeTrack.SelectedFeature
    case 'Autocorrelation'
        feature = activeTrack.AutoCorrelation;

        for i = 1:tCount
            trackData_comp = trackArray(i).TrackData;
            feature_comp = trackData_comp.AutoCorData;
            track_name = trackData_comp.TrackName;

            feature = normalized(feature, 0, 1);
            feature_comp = normalized(feature_comp, 0, 1);

            if ~isequal(size(feature,1),size(feature_comp,1))
                ft_len = numel(feature);
                feature_comp = resize(feature_comp, ft_len);
                feature_comp = feature_comp';
            end
            dist = norm(feature - feature_comp);
            %dnum = mirgetdata(dist);

            display(strcat('distance to ', track_name, ' = ', num2str(dist)));

            track_distances(i, 1) = {track_name};
            track_distances(i, 2) = {dist};
        end
        display('Done');
    case 'Amplitude Envelope'
        feature = activeTrack.Amplitude;
        
        %take the mean of all specified channels to generate a vector for
        %comparison
        feature = mean(feature(selectedFeatures, :));
        
        for i = 1:tCount
            trackData_comp = trackArray(i).TrackData;
            feature_comp = trackData_comp.AmplitudeData;
            track_name = trackData_comp.TrackName;
            
            if(smartSelect)
                best_envs = trackData_comp.getBestCluster;
                feature_comp = mean(feature_comp(best_envs, :));
            else
                feature_comp = mean(feature_comp(selectedFeatures, :));
            end
            
            if ~isequal(size(feature,2), size(feature_comp, 2))
                ft_len = numel(feature);
                feature_comp = resize(feature_comp, ft_len);
            end
            
            dist = norm(feature - feature_comp);
            
            %display(['distance to ' track_name ' = ' num2str(dist)]);
            
            track_distances(i, 1) = {track_name};
            track_distances(i, 2) = {dist};
        end
end

similar_tracks = track_distances;
end

function resized = resize(comp_feature, size)
  %resample each comparison feature to length of query feature
                %   necessary whenever feature is over a single bar (i.e. each track
                %   has diff length)
    x = 1:numel(comp_feature);
    xp = linspace(x(1), x(end), size);
    resized = interp1(x, comp_feature, xp);
end

%[thspks, thsloc] = findpeaks(env_dat(i,:), 'NPeaks', 8, 'SortStr', 'Descend', 'MinPeakProminence', 2);

