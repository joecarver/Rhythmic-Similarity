classdef ActiveTrack
    %ACTIVETRACK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TrackName
        TrackPath
        Tempo
        Amplitude
        AutoCorrelation
        SimilarTracks
        SelectedFeature
    end
    
    methods
        function at = ActiveTrack(trackData)
            if(nargin > 0)
                if(isa(trackData, 'TrackData'))
                    at.TrackName = trackData.TrackName;
                    at.TrackPath = trackData.OriginalPath;
                    at.Tempo = trackData.Tempo;
                    at.Amplitude = trackData.AmplitudeData;
                    at.AutoCorrelation = trackData.AutoCorData;
                elseif(isa(trackData, 'ActiveTrack'))
                    at = trackData;
                end
                    
            end
        end
        
        function obj = set.SelectedFeature(obj, feature_string)
            if ~any([(strcmp(feature_string, 'Amplitude Envelope')) ...
                    (strcmp(feature_string, 'Autocorrelation'))])
                error('feature name not valid');
            else
                obj.SelectedFeature = feature_string;
                setActiveTrack(obj);
            end
        end
        
        function obj = set.SimilarTracks(obj, track_list)
            obj.SimilarTracks = track_list;
            setActiveTrack(obj);
        end
        
        function env_indexes = getBestCluster(obj)
            allChannels = obj.Amplitude;
            [cIDs, cVals] = kmeans(allChannels, 5, 'Replicates', 5);

            [clustCounts, indexes] = sort(histcounts(cIDs), 'Descend');

            env_indexes = [];

            for i = 1:size(cIDs)
                if cIDs(i) == indexes(1)
                    env_indexes = [env_indexes i];
                end
            end
        end
    end
    
end

