function similar_tracks = process_similarTracks(activeTrack, selectedFeatures)
%GET_SIMILAR_TRACKS Summary of this function goes here
%   Detailed explanation goes here

trackArray = getTrackArray;
tCount = numel(trackArray);
trackData = activeTrack.TrackData;


track_distances = cell(tCount, 2);


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
            dist = norm(feature - feature_comp);
            %dnum = mirgetdata(dist);

            display(strcat('distance to ', track_name, ' = ', num2str(dist)));

            track_distances(i, 1) = {track_name};
            track_distances(i, 2) = {dist};
        end
        display('Done');
    case 'Amplitude Envelope'
        amplitude = trackData.Amplitude;
        
        feature = createfeaturevector(amplitude, selectedFeatures);
        
        for i = 1:tCount
            trackData_comp = trackArray(i).TrackData;
            amplitude_comp = trackData_comp.Amplitude;
            track_name = trackData_comp.TrackName;
            
            feature_comp = createfeaturevector(amplitude_comp, selectedFeatures);
            
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

function featurevec = createfeaturevector(amplitude, selectedFeatures)

    featuredims = size(selectedFeatures,2);
    featurelength = size(amplitude,2);
    minpkdist = featurelength/20;
        
    %divide the feature into 16 equal measures 
    sections = linspace(0, featurelength, 16);
    featurevec = zeros(featuredims, 16);

    %for every channel thats been selected
    for i = 1:featuredims
        ampdata = amplitude(selectedFeatures(i),:);
        %identify the defining peaks in the amplitude envelope
        [pks, locs] = findpeaks(ampdata, 'MinPeakHeight', max(ampdata)/2, 'MinPeakDistance', minpkdist);
        %compute its relative position in the 16 bit feature vector
        for l = 1:numel(locs)
            [~, pos] = min(abs(sections - locs(l)));
            featurevec(i, pos) = 1;
        end
    end
end
