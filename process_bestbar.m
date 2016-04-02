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

%clusters envelope data over all channels
%for every bar in the biggest cluster, checks its distance to cluster data
%   gets start and end times of the closest few bars
%   extracts the audio at this point

% % extract, differentiate, half-wave rectify the amplitude envelope
% %    gives a precise description of variation of energy produced by 
% %    each note event from different auditory channels
envs = mirenvelope(wf_seg, 'Diff', 'Halfwave');
%get all the amplitude envelope data and transpose so bars are rows
    %   then replace all NaN values with 0 so kmeans works
env_dat = mirgetdata(envs);
env_dat = env_dat';
env_dat(isnan(env_dat)) = 0;

k = 5;
%cID contains the cluster index for each bar
    %cVals contains the value at each sample (~5000) for each k cluster
[cIDs, cVals] = kmeans(env_dat, k, 'Replicates', 5);

%get sorted counts of clusters
[clustCounts, indexes] = sort(histcounts(cIDs), 'Descend');

%holds the indexes of all bars in the biggest cluster
suggBars_ind = zeros(clustCounts(1),2);
j=1;

for i = 1:numel(cIDs)
    if(cIDs(i) == indexes(1))
        suggBars_ind(j,1) = i;
        suggBars_ind(j,2) = norm(cVals(1,:) - env_dat(i, :));
        j=j+1;
    end
end

suggBars_ind = sortrows(suggBars_ind, 2);
bestbarind = suggBars_ind(1,1);
barpositions = get(wf_seg, 'FramePos');
barpositions = barpositions{1};
bestbarloc = barpositions{bestbarind};
bestbar = miraudio(wf, 'Excerpt', bestbarloc(1), bestbarloc(2));

%silhouette shows that each cluster is not very distinctive - i.e. a lot of
    %   overlap between them. This is not an issue as you would expect all bars in
    %   a song to be fairly similar. 
%More important is the progression of clusters across the data - as this
    %   is a continuous, ordered dataset. Looking for distinctly separated
    %   blocks of homologous cluster IDs
    %[sild, silp] = silhouette(bar_datas, cID);

%Notes 29 Feb
%   amplitude envelope does not capture start of the bar in most cases
%   - this is due to inaccurate bar delimitation as a result of
%   imperfect tempo and missing bar phase information

save(pathToBestBar, 'bestbar');

display('BEST BAR DONE');
end
    
    
