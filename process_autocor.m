function ac_dat = process_autocor(trackData)
%AUTO-CORRELATION
% estimate periodicity in a track through autocorrelation
% takes as input an unsegmented waveform
% returns peaks that can be compared with mirdist

display('COMPUTING AUTOCOR');

pathToAutoCor = [trackData.PathToInfoDir trackData.TrackName '_COR.mat'];
trackWF = trackData.TrackWaveform;
wf = trackWF.Waveform;
%Decompose into auditory channels and extract the envelope from each
%Differentiate & half-wave rectify to show only increases of energy
%   then sum channels back together
%  Gives a precise description of the variaton of energy produced by each
%  note event from the different auditory channels


fb = mirfilterbank(wf);
e = mirenvelope(fb, 'Diff', 'Halfwave');

s = mirsum(e);
ac_mir = mirautocor(s, 'Resonance', 'vanNoorden');
display('Done');

ac_dat = get(ac_mir, 'Data');
ac_dat = ac_dat{1}{1};

save(pathToAutoCor, 'ac_dat');
display('AUTOCOR DONE');
end

