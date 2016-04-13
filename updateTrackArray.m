function updateTrackArray(trackData)

trackArray = getTrackArray();

trackName = trackData.TrackName;

for i = 1:numel(trackArray)
    thisTrack = trackArray(i).TrackData;
    if strcmp(thisTrack.TrackName, trackName)
        trackArray(i).TrackData = trackData;
    end
end

setTrackArray(trackArray);