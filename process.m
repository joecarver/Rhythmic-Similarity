function res = process(filelist)
% compute various characteristics on a collection of files 
%   if the analysis has been carried out already, loads relevant .mat file
%   if not, computes feature/representation and saves output as a .mat file

%open and parse the file list into an array of strings
file = fopen(filelist, 'r');
pathsToTracks = textscan(file, '%s', 'Delimiter', '\n')

fileCount = numel(pathsToTracks{1})

%for every path in the list
for tID = 1:fileCount
    path = pathsToTracks{1}(tID);
    %get its separate parts
    [pathstr, name, ext] = fileparts(path{1});
    
    %find the relevant info directory and analysis files
    pathToInfo = strcat(pathstr, '/', name, 'INFO/');
    mkdir(pathToInfo);
    
    pathToWF = strcat(pathToInfo, name, 'WF.mat');
    pathToTempo = strcat(pathToInfo, name, 'TMP.mat');

    pathToAutocor = strcat(pathToInfo, name, 'COR.mat'
    pathToFluctuation = strcat(pathToInfo, name, 'FLUC.mat');
    pathToAmplitude = strcat(pathToInfo, name, 'AMPL.mat');
    
    a = [];
    t = [];
    fluc = [];
    ampl = [];
    autocor = [];
    
    %if it exists load it, if not compute it
    display('Searching for audio file')
    if exist(pathToWF, 'file')
        display('Audio file found - loading');
        a = importdata(pathToWF);
    else
        display('Not found - computing miraudio')
        a = miraudio(path, 'TRIM');
        save(pathToWF, 'a');
    end
    
    display('Searching for tempo file')
    if exist(pathToTempo, 'file')
        display('Tempo file found - loading from disk')
        t = importdata(pathToTempo);
    else
        display('Not found - computing mirtempo')
        t = mirtempo(a, 'Min', 80, 'Max', 160)
        save(pathToTempo, 't')
    end
   
    tempo = mirgetdata(t);
    
    display('Segmenting audio')
    segs = segment(a, tempo)
    
    display('Looking for fluctuation data file');
    if exist(pathToFluctuation, 'file')
        display('Fluctuation found - loading from disk');
        fluc = importdata(pathToFluctuation)
    else
        display('Not found - computing mirfluctuation');
        fluc = fluctuation(segs)
        display('Writing fluctuation to disk');
        save(pathToFluctuation, 'fluc')
    end
    
%     display('Looking for amplitude envelope file');
%     if exist(pathToAmplitude, 'file')
%         display('Amplitude file found - loading from disk');
%         ampl = importdata(pathToAmplitude)
%     else
%         display('Not found - computing mirenvelope');
%         ampl = amplitude(segs)
%         save(pathToAmplitude, 'ampl');
%     end
        
end

end