function tempo = process_tempo(trackData)

display('COMPUTING TEMPO');
pathToTempo = [trackData.PathToInfoDir trackData.TrackName '_TMP.mat'];

trackWF = trackData.TrackWaveform;
wf = trackWF.Waveform;

sr = get(wf, 'Sampling');
tempoRes = tempo2(mirgetdata(wf),sr{1});

tempo_est = tempoRes(2);

tempo_cand = mirtempo(wf, 'Total', 3);
tempo_cand = mirgetdata(tempo_cand);

if (numel(tempo_cand) > 1)
    [c, index] = min(abs(tempo_cand - tempo_est));
    tempo = tempo_cand(index);
else
    tempo = tempo_cand;
end

save(pathToTempo, 'tempo');
display('TEMPO DONE');

end