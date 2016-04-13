classdef ActiveTrack
    %ACTIVETRACK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TrackData
        BestBarOffset
        SimilarTracks
        SelectedFeature
    end
    
    methods
        function at = ActiveTrack(trackData)
            if(nargin > 0)
                if(isa(trackData, 'TrackData'))
                    at.TrackData = trackData;
                    at.BestBarOffset = 0;
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
        
        function bestbarnudge(obj, offset)
            obj.BestBarOffset = obj.BestBarOffset + offset;
            setActiveTrack(obj);
        end
    end
    
end

