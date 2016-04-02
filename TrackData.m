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
       Tempo
       BestBarData
       BestBarLoc
       AmplitudeData
       AutoCorData
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
                
        function  bestbar = get.BestBarData(obj)
            pathToBestBar = [obj.PathToInfoDir obj.TrackName '_BAR.mat'];
            bestbar = importdata(pathToBestBar);
        end
        
        function bbloc = get.BestBarLoc(obj)
            times = get(obj.BestBarData, 'Time');
            times = times{1,1}{1,1};
            bbloc = [times(1) times(end)];
        end
            
        function  ampl = get.AmplitudeData(obj)
            pathToAmplitude = [obj.PathToInfoDir obj.TrackName '_AMPL.mat'];
            ampl = importdata(pathToAmplitude);
        end
        
        function  autoc = get.AutoCorData(obj)
            pathToAutoCor = [obj.PathToInfoDir obj.TrackName '_COR.mat'];
            autoc = importdata(pathToAutoCor);
        end
        
        
        function sim = get.SimilarTracks(obj)
            pathToSimTracks = [obj.PathToInfoDir obj.TrackName '_SIM.txt'];
            if exist(pathToSimTracks, 'file')
                sim = importdata(pathToSimTracks);
            else
                simtrack_map = process_similarTracks(obj);
                sim = sortrows(simtrack_map, 2);
                save(pathToSimTracks, 'sim');
            end
        end
        
        function obj = set.SimilarTracks(obj, newtracks)
            obj.SimilarTracks = newtracks;
        end
        
        function env_indexes = getBestCluster(obj)
            allChannels = obj.AmplitudeData;
            [cIDs, cVals] = kmeans(allChannels, 5, 'Replicates', 5);

            [clustCounts, indexes] = sort(histcounts(cIDs), 'Descend');

            env_indexes = [];

            for i = 1:size(cIDs)
                if cIDs(i) == indexes(1)
                    env_indexes = [env_indexes i];
                end
            end
        end

    end
end

