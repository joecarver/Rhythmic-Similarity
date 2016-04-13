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
       TempoCands
       BestBar
       BestBarLoc
       Amplitude
       SimilarTracks
       TrackWaveform
    end
    
    properties (Dependent)
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
                
                if tr.TempoExists
                    tr.Tempo = tr.getFromDisk('_TMP.mat');
                else
                    tr.Tempo = 0;
                end
                
                if tr.BestBarExists
                    tr.BestBar = tr.getFromDisk('_BAR.mat');
                end
                
                if tr.AmplitudeExists
                    tr.Amplitude = tr.getFromDisk('_AMPL.mat');
                end
                
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
       
        function bbloc = get.BestBarLoc(obj)
            times = get(obj.BestBar, 'Time');
            times = times{1,1}{1,1};
            bbloc = [times(1) times(end)];
        end
           
        function obj = updateDiskData(obj)
            pathToInfoFiles = [obj.PathToInfoDir obj.TrackName];
            
            tempo = obj.Tempo;
            tempocand = obj.TempoCands;
            bestbar = obj.BestBar;
            amplitude = obj.Amplitude;
            
            %update any details that have values entere
            if tempo
                save([pathToInfoFiles '_TMP.mat'], 'tempo');
            end
            if ~isempty(tempocand)
                save([pathToInfoFiles '_TMPCAND.mat'], 'tempocand');
            end
            if ~isempty(bestbar)
                save([pathToInfoFiles '_BAR.mat'], 'bestbar');
            end
            if ~isempty(amplitude)
                save([pathToInfoFiles '_AMPL.mat'], 'amplitude');
            end
        end

        function data = getFromDisk(obj, suffix)
            pathToFile = [obj.PathToInfoDir obj.TrackName suffix];
            
            data = importdata(pathToFile);
        end
    end
end

