function downbeat = process_downbeat(wf)

for w = 0:30
        sec = miraudio(wf, 'Extract', w*5, (w*5)+10);
        lp = mirfilterbank(sec, 'NbChannels', 3, 'Channel', 1);
        energy = mirrms(lp);
        
        if mirgetdata(energy) > 0.019
            
            %measure kick drum attack duration
            %subtract it from the peak position
            
            %otherwise tracks who's
            ons = mironsets(lp, 'Detect', 'Peaks', 'Threshold', 0.2, 'Attacks');
            beats = get(ons, 'AttackPosUnit');
            beats = beats{1,1}{1,1};
            downbeat = beats{1};
            downbeat = downbeat(1);
            downbeat = downbeat - 0.02;
            break;
        end
end
end

