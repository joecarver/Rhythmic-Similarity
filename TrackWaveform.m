classdef TrackWaveform < handle
    %TRACKWAVEFORM objects are just a track name(full path)
    %   and its miraudio(wav) representation
    %   Used for analysis purposes and then deleted as soon as all analyses
    %   complete
    
    properties
        TrackPath
        Waveform
    end
    
    methods
        function tr_wf = TrackWaveform(track_path)
            if(nargin > 0)
                tr_wf.TrackPath = track_path;
                tr_wf.Waveform = miraudio(track_path);
            end
        end
    end
    
end

