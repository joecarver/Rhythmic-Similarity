classdef TrackArray
    %TRACKARRAY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        TrackData
    end
    
    methods
        %TrackArray constructor
        %  - initialise with a n x 1 array of strings (char cells)
        %  - returns a TrackArray object where each entry is a TrackData
        %   object
        function obj = TrackArray(track_paths)
            if(nargin > 0)
               tCount = numel(track_paths); 
               obj(tCount, 1) = TrackArray;

               for i = 1:tCount
                   track_loc = track_paths(i);
                   trackObj = TrackData(track_loc{1});
                   obj(i).TrackData = trackObj;
               end
            end
        end
        
        %takes a TrackData object and inserts it into the TrackArray,
        % returning it
        function obj = put(obj, new_track)
            if (nargin > 0)
                old_size = numel(obj);
                obj(old_size+1).TrackData = new_track;
            else
                error('Error inserting into trackArray - no track specified');
            end
        end
    end
    
end

