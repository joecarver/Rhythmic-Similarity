function bestbar = process_bestbar(trackData)
% Identify the prominent bars in a track, grouped by first order derivative
% of amplitude envelope (i.e. energy variation)

display('COMPUTING BEST BAR');

trackWF = trackData.TrackWaveform;
wf = trackWF.Waveform;
tempo = trackData.Tempo;   

wf_seg = process_segment(wf, tempo);
wf_seg_fb = mirfilterbank(wf_seg, 'NbChannels', 3);

% % extract, differentiate, half-wave rectify the amplitude envelope
% %    gives a precise description of variation of energy produced by 
% %    each note event from different auditory channels
envs = mirenvelope(wf_seg_fb, 'Diff', 'Halfwave');

%get all the amplitude envelope data and transpose so bars are rows
    %   then replace all NaN values with 0 so kmeans works
env_dat = mirgetdata(envs);
cCount = size(env_dat,3);
sCount = size(env_dat,1);


lowpatterns = [];
medpatterns = [];
highpatterns = [];

%collect every feature vector that starts with a beat
for i = 2:size(env_dat, 2)
    amp_allchannels = zeros(cCount, sCount);
    amp_allchannels(1,:) = env_dat(:, i, 1);
    amp_allchannels(2,:) = env_dat(:, i, 2);
    amp_allchannels(3,:) = env_dat(:, i, 3);
    
    lowft = createfeaturevector(amp_allchannels, 1); %create a feature vector from just the low frequency components
    if(lowft(1))
        lowpatterns = [lowpatterns ; lowft];
        
        midhighft = createfeaturevector(amp_allchannels, [2 3]);
        medpatterns = [medpatterns ; midhighft(1,:)];
        highpatterns = [highpatterns ; midhighft(2,:)];
    end
end

%mean these and set beats at all  sq's above threshold
repr_rhythm = summarise_patterns(lowpatterns, medpatterns, highpatterns);

barmatches = zeros(size(lowpatterns,1), 2);

%calculate the distance of each bar to the template rhythm 
for i = 1:size(lowpatterns,1)
    barmatches(i, 1) = i;
    
    lowdist = pdist2(repr_rhythm(1,:), lowpatterns(i,:), 'Hamming');
    meddist = pdist2(repr_rhythm(2,:), medpatterns(i,:), 'Hamming');
    highdist = pdist2(repr_rhythm(3,:), highpatterns(i,:), 'Hamming');
    barmatches(i, 2) = lowdist + meddist + highdist;
end
  
%get the position of the closest bar to the template and save it as bestbar
barmatches(1,:) = [];
barmatches = sortrows(barmatches, 2);
bestbarind = barmatches(1,1);
barpositions = get(wf_seg, 'FramePos');
barpositions = barpositions{1};
bestbarloc = barpositions{bestbarind};
bestbar = miraudio(wf, 'Excerpt', bestbarloc(1), bestbarloc(2));

display('BEST BAR DONE');
end
    
function repr_rhythm = summarise_patterns(lowpatterns, medpatterns, highpatterns)
    low_rhythm = mean(lowpatterns);
    low_rhythm( (low_rhythm >= 0.3) ) = 1;
    low_rhythm( (low_rhythm < 0.3) ) = 0;
    
    med_rhythm = mean(medpatterns);
    med_rhythm( (med_rhythm >= 0.3) ) = 1;
    med_rhythm( (med_rhythm < 0.3) ) = 0;
    
    high_rhythm = mean(highpatterns);
    high_rhythm( (high_rhythm >= 0.3) ) = 1;
    high_rhythm( (high_rhythm < 0.3) ) = 0;
    
    repr_rhythm = [low_rhythm ; med_rhythm ; high_rhythm];
end
