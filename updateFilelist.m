function updateFilelist(newFiles)
% updateFilelist adds any new files to list
%   reads txt file stored on disk and updates it with new additions
%   recognises files by their absolute path, so the same file in a new
%   location counts as a different file
global fileList;

filelist_txt = fopen(getPathToFilelist, 'r');

existingFiles = textscan(filelist_txt, '%s', 'Delimiter', '\n');

fL = vertcat(existingFiles{1}, newFiles);

fileList = unique(fL);

delete(getPathToFilelist);

%write the updated file list to disk
formatSpec = '%s\n';

fl_txt_new = fopen(getPathToFilelist, 'wt');
for i = 1:numel(fileList)
    file = fileList{i};
    fprintf(fl_txt_new, formatSpec, file);
end
fclose(fl_txt_new);

%update the active trackArray
new_entries = setdiff(newFiles, existingFiles{1});
trackArray = getTrackArray;

for i = 1:numel(new_entries)
    trackpath = new_entries{i};
    trackData = TrackData(trackpath);
    trackArray = trackArray.put(trackData);
end

setTrackArray(trackArray);


