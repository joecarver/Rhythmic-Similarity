function featurevec = createfeaturevector(amplitude, selectedChannels)

    featuredims = size(selectedChannels,2);
    featurelength = size(amplitude,2);
    minpkdist = featurelength/17;
        
    %divide the feature into 16 equal measures 
    sections = linspace(0, featurelength, 16);
    featurevec = zeros(featuredims, 16);

    %for every channel thats been selected
    for d = 1:featuredims
        ampdata = amplitude(selectedChannels(d),:);
        %identify the defining peaks in the amplitude envelope
        [~, locs] = findpeaks(ampdata, 'MinPeakHeight', max(ampdata)*0.75, 'MinPeakDistance', minpkdist);
        %compute its relative position in the 16 bit feature vector
        for l = 1:numel(locs)
            [~, pos] = min(abs(sections - locs(l)));
            featurevec(d, pos) = 1;
        end
    end
end


