function tempo = process_tempo(trackData)

display('COMPUTING TEMPO');

trackWF = trackData.TrackWaveform;
wf = trackWF.Waveform;

sr = get(wf, 'Sampling');
tempoRes = tempo2(mirgetdata(wf),sr{1});

tempo_est = tempoRes(1:2)';

tempo_cand = mirtempo(wf, 'Total', 3);
tempo_cand = mirgetdata(tempo_cand);

trackData.TempoCands = tempo_cand;
trackData.updateDiskData;

if (numel(tempo_cand) > 1)
    dists = pdist2(tempo_cand, tempo_est);
    [mn, ind] = min(dists(:));

    tpos = mod(ind, numel(tempo_cand));
    if tpos == 0
        tpos = 3;
    end
    
    tempo = tempo_cand(tpos);
else
    tempo = tempo_cand;
end

if tempo < 100
    tempo = tempo*2;
end
display('TEMPO DONE');

end