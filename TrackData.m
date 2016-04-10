classdef TrackData
    %Represents a song and its derived features
    %   PROPS - 
    %   OriginalPath the absolute path to the file from which info has been
    %       calculated
    %   TrackName the name on disk of the file, without location info 
    %   Tempo the calculated tempo, also stored on disk as '<trackname>_TMP.mat'
    %   SimilarTracks

    properties
       OriginalPath
       TrackName
       PathToInfoDir
       ActGenre
       Tempo
       BestBar
       BestBarLoc
       Amplitude
       AutoCorrelation
       SimilarTracks
       TrackWaveform
    end
    
    properties (Dependent)
       AutoCorExists
       AmplitudeExists
       BestBarExists
       TempoExists
    end

    methods
        %constructor takes a path to a track and constructs an empty
        %   directory to hold its analysis files
        %No features are computed upon construction
        function tr = TrackData(originalpath)
            if(nargin > 0)
                tr.OriginalPath = originalpath;
                [~, name, ~] = fileparts(originalpath);
                tr.TrackName = name;
                mkdir(tr.PathToInfoDir);
                
                %read the genre from filepath - only for testing purposes
                [~, ind] = regexp(originalpath, 'DATA/');
                tr.ActGenre = originalpath(ind+1:ind+3);
            end
        end
        
        
        function track_info_dir = get.PathToInfoDir(obj)
            trackname = obj.TrackName;
            track_info_dir = [getPathToInfo trackname '/'];
        end
                    
        function exists = get.TempoExists(obj)
            exists = exist([obj.PathToInfoDir obj.TrackName '_TMP.mat'], 'file');
        end
        
        function exists = get.BestBarExists(obj)
            exists = exist([obj.PathToInfoDir obj.TrackName '_BAR.mat'], 'file');
        end

        function exists = get.AmplitudeExists(obj)
            exists = exist([obj.PathToInfoDir obj.TrackName '_AMPL.mat'], 'file');
        end 
        
        function exists = get.AutoCorExists(obj)
            exists = exist([obj.PathToInfoDir obj.TrackName '_COR.mat'], 'file');
        end
        
        function  tempo = get.Tempo(obj)
            pathToTempo = [obj.PathToInfoDir obj.TrackName '_TMP.mat'];
            if ~obj.TempoExists
                tempo = 0;
            else
                tempo = importdata(pathToTempo);
            end
        end
                
        function  bestbar = get.BestBar(obj)
            pathToBestBar = [obj.PathToInfoDir obj.TrackName '_BAR.mat'];
            bestbar = importdata(pathToBestBar);
        end
        
        function bbloc = get.BestBarLoc(obj)
            times = get(obj.BestBar, 'Time');
            times = times{1,1}{1,1};
            bbloc = [times(1) times(end)];
        end
            
        function  ampl = get.Amplitude(obj)
            pathToAmplitude = [obj.PathToInfoDir obj.TrackName '_AMPL.mat'];
            ampl = importdata(pathToAmplitude);
        end
        
        function  autoc = get.AutoCorrelation(obj)
            pathToAutoCor = [obj.PathToInfoDir obj.TrackName '_COR.mat'];
            autoc = importdata(pathToAutoCor);
        end
        
        
        function sim = get.SimilarTracks(obj)
            pathToSimTracks = [obj.PathToInfoDir obj.TrackName '_SIM.mat'];
            sim = importdata(pathToSimTracks);
        end
        

    end
end

