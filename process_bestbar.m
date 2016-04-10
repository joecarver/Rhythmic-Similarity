function bestbar = process_bestbar(trackData)
% Identify the prominent bars in a track, grouped by first order derivative
% of amplitude envelope (i.e. energy variation)

display('COMPUTING BEST BAR');

pathToBestBar = [trackData.PathToInfoDir trackData.TrackName '_BAR.mat'];

trackWF = trackData.TrackWaveform;
wf = trackWF.Waveform;
tempo = trackData.Tempo;

%disp('Decomposing into channels')
%decompose bars into audio channels
   %n is number of channels to use - further arguments available
%filteredbars = mirfilterbank(wf,3);    

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


barfeatures = [];

%collect every feature vector that starts with a beat
for i = 2:size(env_dat, 2)
    amp_allchannels = zeros(cCount, sCount);
    amp_allchannels(1,:) = env_dat(:, i, 1);
    amp_allchannels(2,:) = env_dat(:, i, 2);
    amp_allchannels(3,:) = env_dat(:, i, 3);
    
    barft = createfeaturevector(amp_allchannels, 1); %create a feature vector from just the low frequency components
    if(barft(1))
        barfeatures = [barfeatures ; barft];
    end
end

%mean these and set beats at all  sq's above threshold
template_rhythm = mean(barfeatures);
template_rhythm( (template_rhythm >= 0.2) ) = 1;
template_rhythm( (template_rhythm < 0.2) ) = 0;

barmatches = zeros(size(barfeatures,1), 2);

%calculate the distance of each bar to the template rhythm 
for i = 1:size(barfeatures,1)
    barmatches(i, 1) = i;
    barmatches(i, 2) = pdist2(template_rhythm, barfeatures(i,:), 'Hamming');
end
  
%get the position of the closest bar to the template and save it as bestbar
barmatches(1,:) = [];
barmatches = sortrows(barmatches, 2);
bestbarind = barmatches(1,1);
barpositions = get(wf_seg, 'FramePos');
barpositions = barpositions{1};
bestbarloc = barpositions{bestbarind};
bestbar = miraudio(wf, 'Excerpt', bestbarloc(1), bestbarloc(2));

save(pathToBestBar, 'bestbar');

display('BEST BAR DONE');
end
    
    
