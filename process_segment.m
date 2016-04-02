function segs = process_segment(wf, tempo)
%SEGMENT an audio file into bars
%   based on start point, bar length, 
%   parameters - waveform is miraudio representation of track
%                tempo of track (double) computed from miraudio 

%beats-in-bar -- almost always 4 for DJ-oriented music
bib = 4.0;
%compute beats-per-second, seconds-per-beat, and bar Length
bps = tempo/60;
spb = 1/bps;
barL = spb * bib;
%length of track
trackL = mirgetdata(mirlength(wf));

%rough amt of bars in track
barcount = ceil((trackL / barL) + barL);

%vector to hold start times of each segment 
times = zeros(barcount, 1);

%start time 
%   TODO - improve to recognise first beat of track (mironsets)

pos = get(wf, 'Pos');
pos = pos{1};

time = pos{1}(1);

while time < trackL
    times = [times; time];
    time = time + barL;
end

segs = mirsegment(wf, times);
end


