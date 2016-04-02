function trackData = getTrackDataFromName( trackName )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

trackArray = getTrackArray;
tCount = numel(trackArray);
trackData = [];

for i=1:tCount
    thisTrack = trackArray(i).TrackData;
    thisName = thisTrack.TrackName;
    if(strcmp(thisName, trackName))
        trackData = thisTrack;
    end
end

