function setActiveTrack(trackData)
    global activeTrack;
    if (nargin > 0)
        activeTrack = ActiveTrack(trackData);
    else
        activeTrack = [];
    end
end
