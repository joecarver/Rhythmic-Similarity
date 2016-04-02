function amplitude_allchannels = process_amplitude(trackData)
% Identify the prominent bars in a track, grouped by first order derivative
% of amplitude envelope (i.e. energy variation)

display('COMPUTING AMPLITUDE');

pathToAmpl = [trackData.PathToInfoDir trackData.TrackName '_AMPL.mat'];

wf = trackData.BestBarData;
fb = mirfilterbank(wf);

% extract, differentiate, half-wave rectify the amplitude envelope
%    gives a precise description of variation of energy produced by 
%    each note event from different auditory channels
envs = mirenvelope(fb, 'Diff', 'Halfwave');
%summed = mirsum(envs)

env_dat = mirgetdata(envs);
cCount = size(env_dat,3);
sCount = size(env_dat,1);
amplitude_allchannels = zeros(cCount, sCount);

%for every channel
for i = 1:cCount
    %get all the amplitude envelope data and transpose so bars are rows
    %   then replace all NaN values with 0 so kmeans works
    channel_data = env_dat(:,:,i)'; 
    channel_data(isnan(channel_data)) = 0;
    
    amplitude_allchannels(i,:) = channel_data;
    
end
    %Notes 29 Feb
    %   amplitude envelope does not capture start of the bar in many cases
    %   - this is due to inaccurate bar delimitation as a result of
    %   imperfect tempo and missing bar phase information

save(pathToAmpl, 'amplitude_allchannels');
display('AMPLITUDE DONE');

end
    
    
