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

% Last Modified by GUIDE v2.5 01-Apr-2016 14:01:49

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

channel_count = 10;

pathToInfo = [pwd '/Analysis Files/'];
pathToFilelist = [pwd '/test.txt'];

setPathToInfo(pathToInfo);
setPathToFilelist(pathToFilelist);
setActiveTrack();

set(handles.feature_buttongroup, 'Visible', 'off');
set(handles.similar_tracks_button, 'Visible', 'off');
set(handles.frequency_buttongroup, 'Visible', 'off');
set(handles.replot_ampl_button, 'Visible', 'off');
set(handles.smart_select_button, 'Visible', 'off');
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
amplitudes = [];
autocors = [];

%for every track path in filelist
for i = 1:tCount
    trackData = trackArray(i).TrackData;
    
    titles = [titles; {trackData.TrackName}];
    locations = [locations; {trackData.OriginalPath}];
    calc_tempos = [calc_tempos; trackData.Tempo];
    amplitudes = [amplitudes; trackData.AmplitudeExists];
    autocors = [autocors; trackData.AutoCorExists];
end

%pad string info fields to make all entries equal length
titles = char(titles);
locations = char(locations);

%tabledata in correct format for insertion
tData = [ cellstr(titles) cellstr(locations) num2cell(calc_tempos(:)) num2cell(amplitudes(:)) num2cell(autocors(:)) ];

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

guidata(hObject, handles);

%get the track highlighted in the table
function trackData = get_selected_track(handles)
row = handles.sel_row;
col = handles.sel_col;

trackArray = getTrackArray;

trackData = trackArray(row).TrackData;

% --- Executes on button press in calc_selected_track_button.
function calc_selected_track_button_Callback(hObject, eventdata, handles)
% hObject    handle to calc_selected_track_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

trackData = get_selected_track(handles);

existingfeatures = [trackData.TempoExists, trackData.BestBarExists, ...
                    trackData.AmplitudeExists, trackData.AutoCorExists];

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
        trackData.BestBarData = process_bestbar(trackData);
    end
    if(~existingfeatures(3))
        trackData.AmplitudeData = process_amplitude(trackData);
    end
    if(~existingfeatures(4))
        trackData.AutoCorData = process_autocor(trackData);
    end

    %clear the waveform object once features are computed
    trackData.TrackWaveform = [];
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
                    trackData.AmplitudeExists, trackData.AutoCorExists];

    
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
            trackData.BestBarData = process_bestbar(trackData);
        end
        if(~existingfeatures(3))
            trackData.AmplitudeData = process_amplitude(trackData);
        end
        if(~existingfeatures(4))
            trackData.AutoCorData = process_autocor(trackData);
        end

        %clear the waveform object once features are computed
        trackData.TrackWaveform = [];
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
    act_tr = getActiveTrack;
    set(handles.display_panel, 'Title', act_tr.TrackName);
    set(handles.feature_buttongroup, 'Visible', 'on');
    act_tr.SelectedFeature = handles.feature_buttongroup.SelectedObject.String;
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
        if i==1
            checkbox.Value = 1;
        end

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

selectedTrack = getActiveTrack;
auto_cor = selectedTrack.AutoCorrelation;

set(handles.feature_panel, 'XLabel', xlabel('Time Lag'));
set(handles.feature_panel, 'YLabel', ylabel('Correlation'));

plot(auto_cor);
        
function plotAmplitude(handles)
axes(handles.feature_panel);

freq_bg = handles.frequency_buttongroup;

freq_bg.Visible = 'on';
set(handles.replot_ampl_button, 'Visible', 'on');
set(handles.smart_select_button, 'Visible', 'on');
cla;

selected_track = getActiveTrack;
all_channels = selected_track.Amplitude;

sample_count = size(all_channels, 2);
x_label = xlabel(['Sample pos in bar (total = ' num2str(sample_count) ')']);
y_label = ylabel('Energy Increase (Normalised)');

set(handles.feature_panel, 'XLim', [0 sample_count]);
set(handles.feature_panel, 'XLabel', x_label);
set(handles.feature_panel, 'YLabel', y_label);

all_freqs = flipud(freq_bg.Children);


for i=1:size(all_freqs,1) 
    if(all_freqs(i).Value == all_freqs(i).Max)
        hold on;
        plot(all_channels(i,:));
    end
end

% --- Executes when selected object is changed in feature_buttongroup.
function feature_buttongroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in feature_buttongroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

freq_bg = handles.frequency_buttongroup;
act_tr = getActiveTrack;

switch(get(eventdata.NewValue, 'Tag'))
    case 'autocor_button'
        freq_bg.Visible = 'off';
        set(handles.replot_ampl_button, 'Visible', 'off');
        set(handles.smart_select_button, 'Visible', 'off');
        act_tr.SelectedFeature = 'Autocorrelation';
        plotAutoCor(handles);
    case 'amplitude_button'
        act_tr.SelectedFeature = 'Amplitude Envelope';
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


% --- Executes on button press in smart_select_button.
function smart_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to smart_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected_track = getActiveTrack;
channel_buttons = flipud(handles.frequency_buttongroup.Children);
axes(handles.feature_panel);

env_indexes = selected_track.getBestCluster;

for i = 1:size(channel_buttons)
    channel_button = channel_buttons(i);
    channel_button.Value = channel_button.Min;

    if ismember(i, env_indexes)
        channel_button.Value = channel_button.Max;
    end
end        


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
    case 'Autocorrelation'
        hold on;
        plot(activeTrack.AutoCorrelation);
        plot(selTrackData.AutoCorData);
end

% --- Executes on button press in similar_tracks_button.
function similar_tracks_button_Callback(hObject, eventdata, handles)
% hObject    handle to similar_tracks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selected_track = getActiveTrack;
display_box = handles.sim_tracks_box;

selected_channels = [];

%if we are using the amplitude envelope, detect which channel buttons are
%   ticked
if(strcmp(selected_track.SelectedFeature, 'Amplitude Envelope'))
    all_freqs = flipud(handles.frequency_buttongroup.Children);
    for i=1:size(all_freqs,1) 
        if(all_freqs(i).Value == all_freqs(i).Max)
            selected_channels = [selected_channels i];
        end
    end
end 
    
similar_tracks = process_similarTracks(selected_track, selected_channels, false);
similar_tracks = sortrows(similar_tracks, 2);


set(display_box, 'String', similar_tracks(:,1));
selected_track.SimilarTracks = similar_tracks(:,1);
populate_table(handles);

% --- Executes on button press in playbar_button.
function playbar_button_Callback(hObject, eventdata, handles)
% hObject    handle to playbar_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
actTrackData = getTrackDataFromName(activeTrack.TrackName);

mirplay(actTrackData.BestBarData);


% --- Executes on button press in edittrack_button.
function edittrack_button_Callback(hObject, eventdata, handles)
% hObject    handle to edittrack_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

activeTrack = getActiveTrack;
actTrackData = getTrackDataFromName(activeTrack.TrackName);

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

actTrackData.Tempo = newtempo;
actTrackData.BestBarData = newbestbar;
actTrackData.AmplitudeData = process_amplitude(actTrackData);

setActiveTrack(actTrackData);

