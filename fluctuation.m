function prominent = fluctuation(wf_seg)
%FLUCTUATION
%returns the most prominent bar of a track based on a fluctuation measure
%   based on spectrogram computation transformed by auditory modeling
%   and then a spectrum estimation in each band
%   (Pampalk et al., 2002).
%   detaills on mirtoolbox user manual p85


%Compute power spectogram on audio
%using default hop rate of 80Hzrt
% disp('Calculating Spectrum')
% s = mirspectrum(wf_seg, 'Frame', 0.023,'Power', 'Terhardt','Bark', 'Mask', 'dB');
% 
% disp('Calculating Fluctuation')
% %Compute FFT on each band
% %Using default frequency min, max and resolution (0-10Hz), 0.1Hz
% f = mirspectrum(s, 'AlongBands', 'Resonance', 'Fluctuation', 'NormalLength');

% barfluc = mirsum(f);

barfluc = mirfluctuation(wf_seg, 'Summary');

prominent = mircluster(wf_seg,barfluc, 5);

end