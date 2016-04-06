function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.1
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 05-Apr-2016 18:59:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

warning('off', 'MATLAB:MKDIR:DirectoryExists');

channel_count = 3;

pathToInfo = [pwd '/Analysis Files/'];
pathToFilelist = [pwd '/test.txt'];

setPathToInfo(pathToInfo);
setPathToFilelist(pathToFilelist);
setActiveTrack();

set(handles.feature_buttongroup, 'Visible', 'off');
set(handles.similar_tracks_button, 'Visible', 'off');
set(handles.frequency_buttongroup, 'Visible', 'off');
set(handles.bbadjust_group, 'Visible', 'off');
set(handles.action_buttongroup, 'Visible', 'off');

initialiseFrequency_bg(handles, channel_count);


greeting = miraudio('theredshore.mp3');
t = mirautocor(greeting);
%mirplay(greeting);

loadFilelist(handles, pathToFilelist);
populate_table(handles);

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in selectfiles.
function selectfiles_Callback(hObject, eventdata, handles)
% hObject    handle to selectfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cancelled = false;

%open a file browser allowing only .mp3 files to be opened
[files path] = uigetfile('*.mp3', 'Select tracks to analyse', 'Multiselect', 'on');

%files is 0 if nothing selected
if isa(files, 'double')
    cancelled = true;
%files is of type char if only 1 file is selected
elseif isa(files, 'char')
    selected_files = {[path files]};
else
    fCount = numel(files);
    
    %initialise a structure to hold file paths
    selected_files = cell(fCount, 1);
    
    for f = 1:fCount
        file = files(f);
        file_loc = strcat(path, file);
        selected_files(f,1) = file_loc;
    end
end

if not(cancelled)
  updateFilelist(selected_files);
end
populate_table(handles);

  
function loadFilelist(handles, fl_loc)
%loadFileList called on start up and whenever updateFilelist is called
%(i.e. in select_files_cb)
%   PARAMS - handles object for gui, path to the filelist
%   No ouputs - simply sets the global TrackArray variable

%open and parse the file list into an array of strings
file = fopen(fl_loc, 'r');
pathsToTracks = textscan(file, '%s', 'Delimiter', '\n');
pathsToTracks = pathsToTracks{1};

%construct a TrackArray object from the string array of paths
%set it as the global/active trackArray
trackArray = TrackArray(pathsToTracks);
setTrackArray(trackArray);

%update the table with the latest info found on disk
%does not call any functions that perform calculations so is v quick
function populate_table(handles)

trackArray = getTrackArray;
hTable = handles.data_table;

tCount = numel(trackArray);

%structures to hold track data for input into table
titles = [];
locations = [];
calc_tempos = [];
bestbars = [];
amplitudes = [];
autocors = [];

%for every track path in filelist
for i = 1:tCount
    trackData = trackArray(i).TrackData;
    
    titles = [titles; {trackData.TrackName}];
    locations = [locations; {trackData.OriginalPath}];
    calc_tempos = [calc_tempos; trackData.Tempo];
    bestbars = [bestbars; trackData.BestBarExists];
    amplitudes = [amplitudes; trackData.AmplitudeExists];
    autocors = [autocors; trackData.AutoCorExists];
end

%pad string info fields to make all entries equal length
titles = char(titles);
locations = char(locations);

%tabledata in correct format for insertion
tData = [ cellstr(titles) cellstr(locations) num2cell(calc_tempos(:)) num2cell(bestbars(:)) num2cell(amplitudes(:)) num2cell(autocors(:)) ];

set(hTable, 'Data', tData); 

% --- Executes when selected cell(s) is changed in data_table.
function data_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to data_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%set global variables to selected cell
if (numel(eventdata.Indices) > 0)
    handles.sel_row = eventdata.Indices(1);
    handles.sel_col = eventdata.Indices(2);
end

if(handles.sel_col == 4)
    trackArray = getTrackArray;
    trackData = trackArray(handles.sel_row).TrackData;
    mirplay(trackData.BestBar);
end

guidata(hObject, handles);

%get the track highlighted in the table
function trackData = get_selected_track(handles)

trackArray = getTrackArray;
trackData = trackArray(handles.sel_row).TrackData;

% --- Executes on button press in calc_selected_track_button.
function calc_selected_track_button_Callback(hObject, eventdata, handles)
% hObject    handle to calc_selected_track_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trackData = get_selected_track(handles);

existingfeatures = [trackData.TempoExists, trackData.BestBarExists, ...
                    trackData.AutoCorExists];

%if the feature list is incomplete
if any(~existingfeatures)
    %construct a new waveform object for the track and set is as active
    trackWF = TrackWaveform(trackData.OriginalPath);
    trackData.TrackWaveform = trackWF;
    
    %check if each feature has been stored on disk, calculate it if not
    if(~existingfeatures(1))
        trackData.Tempo = process_tempo(trackData);
    end
    if(~existingfeatures(2))
        trackData.BestBar = process_bestbar(trackData);
    end
    if(~existingfeatures(3))
        trackData.AutoCorrelation = process_autocor(trackData);
    end

    %clear the waveform object once features are computed
    trackData.TrackWaveform = [];
end

if ~trackData.AmplitudeExists
    trackData.Amplitude = process_amplitude(trackData);
end
    
populate_table(handles);

% --- Executes on button press in calc_features_button.
function calc_features_button_Callback(hObject, eventdata, handles)
% hObject    handle to calc_features_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trackArray = getTrackArray;
fCount = numel(trackArray);

%wb = waitbar(0, 'One moment...', 'Name', 'Analysing tracks');

for i = 1:fCount
    trackData = trackArray(i).TrackData;
    
    %wb_msg = [name ' (' num2str(i) '/' num2str(fCount) ')'];
    %wb_ratio = i/fCount;
    
    %waitbar(wb_ratio, wb, wb_msg);

    existingfeatures = [trackData.Tempo, trackData.BestBarExists, ...
                        trackData.AutoCorExists];

    %if the feature list is incomplete
    if any(~existingfeatures)
        %construct a new waveform object for the track and set it as active
        trackWF = TrackWaveform(trackData.OriginalPath);
        trackData.TrackWaveform = trackWF;
        
        %check if each feature has been stored on disk, calculate it if not
        if(~existingfeatures(1))
            trackData.Tempo = process_tempo(trackData);
        end
        if(~existingfeatures(2))
            trackData.BestBar = process_bestbar(trackData);
        end

        if(~existingfeatures(3))
            trackData.AutoCorrelation = process_autocor(trackData);
        end

        %clear the waveform object once features are computed
        trackData.TrackWaveform = [];
    end
    
    if ~trackData.AmplitudeExists
        trackData.Amplitude = process_amplitude(trackData);
    end
   
    populate_table(handles);
end

% --- Executes on button press in load_selected_track.
function load_selected_track_Callback(hObject, eventdata, handles)
% hObject    handle to load_selected_track (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trackData = get_selected_track(handles);

%if the feature list is incomplete
if any([~trackData.AmplitudeExists,
        ~trackData.AutoCorExists,
        ~trackData.Tempo])
    error('Analysis not complete');
else
    setActiveTrack(trackData);
    activeTrack = getActiveTrack;
    set(handles.display_panel, 'Title', activeTrack.TrackData.TrackName);
    set(handles.feature_buttongroup, 'Visible', 'on');
    activeTrack.SelectedFeature = handles.feature_buttongroup.SelectedObject.String;
    set(handles.similar_tracks_button, 'Visible', 'on');                                 
    plotFeatureData(handles);
end

function initialiseFrequency_bg(handles, channel_count)

 %create a frequency checkbox for each separate channel 
bg = handles.frequency_buttongroup;
if(numel(bg.Children) < 2)
    x = 15; 
    y = 80;
    w = 85;
    h = 25;

    for i=1:channel_count

        checkbox = uicontrol(bg, 'Style', 'checkbox', ...
                                 'String', ['Channel ' num2str(i)], ...
                                 'Position', [x y w h], ...
                                 'Visible', 'on');
        checkbox.Value = 1;

        if (mod(i,3)==0)
            x = x+w+20;
            y = 80;
        else
            y = y-(h+6);
        end
    end
    guidata(flipud(bg), handles);
end

function plotFeatureData(handles)

selfeature = get(handles.feature_buttongroup, 'SelectedObject');

switch(selfeature.String)
    case 'Autocorrelation'
        plotAutoCor(handles);
    case 'Amplitude Envelope'
        plotAmplitude(handles);
end

function plotAutoCor(handles)
axes(handles.feature_panel);
cla;

activeTrack = getActiveTrack;
auto_cor = activeTrack.TrackData.AutoCorrelation;

set(handles.feature_panel, 'XLabel', xlabel('Time Lag'));
set(handles.feature_panel, 'YLabel', ylabel('Correlation'));

plot(auto_cor);
        
function plotAmplitude(handles)
axes(handles.feature_panel);

freq_bg = handles.frequency_buttongroup;

freq_bg.Visible = 'on';
set(handles.bbadjust_group, 'Visible', 'on');
set(handles.action_buttongroup, 'Visible', 'on');
cla;

activeTrack = getActiveTrack;
all_channels = activeTrack.TrackData.Amplitude;
trackData = activeTrack.TrackData;

sample_count = size(all_channels, 2);
x_label = xlabel(['Bar position in secs: ' num2str(trackData.BestBarLoc(1)) ' - ' num2str(trackData.BestBarLoc(2))]);
y_label = ylabel('Energy Increase (Normalised)');

set(handles.feature_panel, 'XLim', [0 sample_count]);
set(handles.feature_panel, 'XLabel', x_label);
set(handles.feature_panel, 'YLabel', y_label);

all_freqs = flipud(freq_bg.Children);

xvals = 1:size(all_channels,2);

%loop through each frequency band button 
% if it is ticked, plot the data for that band
for i=1:size(all_freqs,1) 
    if(all_freqs(i).Value == all_freqs(i).Max)
        hold on;
        plot(xvals+activeTrack.BestBarOffset, all_channels(i,:));
    end
end

% --- Executes when selected object is changed in feature_buttongroup.
function feature_buttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in feature_buttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

freq_bg = handles.frequency_buttongroup;
activeTrack = getActiveTrack;

switch(get(eventdata.NewValue, 'Tag'))
    case 'autocor_button'
        freq_bg.Visible = 'off';
        set(handles.bbadjust_group, 'Visible', 'off');
        set(handles.action_buttongroup, 'Visible', 'off');
        activeTrack.SelectedFeature = 'Autocorrelation';
        plotAutoCor(handles);
    case 'amplitude_button'
        activeTrack.SelectedFeature = 'Amplitude Envelope';
        plotAmplitude(handles);
end

if ~isempty(getActiveTrack)
    plotFeatureData(handles);
end
    
% --- Executes on button press in replot_ampl_button.
function replot_ampl_button_Callback(hObject, eventdata, handles)
% hObject    handle to replot_ampl_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

plotAmplitude(handles);


% --- Executes on selection change in sim_tracks_box.
function sim_tracks_box_Callback(hObject, eventdata, handles)
% hObject    handle to sim_tracks_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sim_tracks_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sim_tracks_box

axes(handles.feature_panel);
cla;

activeTrack = getActiveTrack;
seltrack_index = get(hObject, 'Value');
selTrackData = getTrackDataFromName(activeTrack.SimilarTracks(seltrack_index));

switch(activeTrack.SelectedFeature)
    case 'Amplitude Envelope'
        hold on;
        plot(mean(activeTrack.TrackData.Amplitude));
        plot(mean(selTrackData.Amplitude));
    case 'Autocorrelation'
        hold on;
        plot(activeTrack.TrackData.AutoCorrelation);
        plot(selTrackData.AutoCorrelation);
end

% --- Executes on button press in similar_tracks_button.
function similar_tracks_button_Callback(hObject, eventdata, handles)
% hObject    handle to similar_tracks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
display_box = handles.sim_tracks_box;

selected_channels = [];

%if we are using the amplitude envelope, detect which channel buttons are
%   ticked
if(strcmp(activeTrack.SelectedFeature, 'Amplitude Envelope'))
    all_freqs = flipud(handles.frequency_buttongroup.Children);
    for i=1:size(all_freqs,1) 
        if(all_freqs(i).Value == all_freqs(i).Max)
            selected_channels = [selected_channels i];
        end
    end
end 
    
similar_tracks = process_similarTracks(activeTrack, selected_channels);
similar_tracks = sortrows(similar_tracks, 2);

set(display_box, 'String', similar_tracks(:,1));
activeTrack.SimilarTracks = similar_tracks(:,1);
populate_table(handles);

% --- Executes on button press in playbar_button.
function playbar_button_Callback(hObject, eventdata, handles)
% hObject    handle to playbar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
actTrackData = activeTrack.TrackData;

mirplay(actTrackData.BestBar);

% --- Executes on button press in edittrack_button.
function edittrack_button_Callback(hObject, eventdata, handles)
% hObject    handle to edittrack_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
actTrackData = activeTrack.TrackData;
pathToBestBar = [actTrackData.PathToInfoDir actTrackData.TrackName '_BAR.mat'];
pathToTempo = [actTrackData.PathToInfoDir actTrackData.TrackName '_TMP.mat'];


prompt = {'Tempo', 'Best Bar Start Pos', 'Beats in bar'};
dlg_title = actTrackData.TrackName;
default_ans = {num2str(actTrackData.Tempo), num2str(actTrackData.BestBarLoc(1)), '4'};

newparams = inputdlg(prompt, dlg_title, 1, default_ans);

newtempo = str2double(newparams{1,1});
newbarstart = str2double(newparams{2,1});
%beats-in-bar -- almost always 4 for DJ-oriented music
bib = str2double(newparams{3,1});

%compute beats-per-second, seconds-per-beat, and bar Length
bps = newtempo/60;
spb = 1/bps;
barL = spb * bib;

newbarend = newbarstart + barL;

newbestbar = miraudio(actTrackData.OriginalPath, 'Excerpt', newbarstart, newbarend);
actTrackData.BestBar = newbestbar;
save(pathToBestBar, 'newbestbar');

actTrackData.Tempo = newtempo;
save(pathToTempo, 'newtempo');

process_amplitude(actTrackData);

setActiveTrack(actTrackData);

plotAmplitude(handles);
populate_table(handles);

% --- Executes on button press in nudgeleft_button.
function barleft_button_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeleft_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
step = size(activeTrack.TrackData.Amplitude, 2);

activeTrack.bestbarnudge(step);
plotAmplitude(handles);

% --- Executes on button press in nudgeleft_button.
function nudgeleft_button_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeleft_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

samplestep = get(handles.samplestep, 'String');
activeTrack = getActiveTrack;

activeTrack.bestbarnudge(str2double(samplestep));
plotAmplitude(handles);

% --- Executes on button press in nudgeleft_button.
function barright_button_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeleft_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
step = size(activeTrack.TrackData.Amplitude, 2);

activeTrack.bestbarnudge(-step);
plotAmplitude(handles);

% --- Executes on button press in nudgeight_button.
function nudgeright_button_Callback(hObject, eventdata, handles)
% hObject    handle to nudgeright_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

samplestep = get(handles.samplestep, 'String');

activeTrack = getActiveTrack;
activeTrack.bestbarnudge(-str2double(samplestep));

plotAmplitude(handles);


% --- Executes on button press in recalc_bestbar.
function recalc_bestbar_Callback(hObject, eventdata, handles)
% hObject    handle to recalc_bestbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
trackData = activeTrack.TrackData;

offset_pts = activeTrack.BestBarOffset;
curbestbar = trackData.BestBar;
amplitude = trackData.Amplitude;


barlen_secs = mirgetdata(mirlength(curbestbar));
barlen_pts = size(amplitude, 2);

secs_per_pt = barlen_secs / barlen_pts;
offset_secs = offset_pts * secs_per_pt;

newbarstart = trackData.BestBarLoc(1) - offset_secs;

newbestbar = miraudio(trackData.OriginalPath, 'Excerpt', newbarstart, newbarstart+barlen_secs);
pathToBestBar = [trackData.PathToInfoDir trackData.TrackName '_BAR.mat'];

trackData.BestBar = newbestbar;
save(pathToBestBar, 'newbestbar');
activeTrack.BestBarOffset = 0;
setActiveTrack(activeTrack);

process_amplitude(trackData);

plotAmplitude(handles);





