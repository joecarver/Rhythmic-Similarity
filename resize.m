
function resized = resize(comp_feature, size)
  %resample each comparison feature to length of query feature
                %   necessary whenever feature is over a single bar (i.e. each track
                %   has diff length)
    x = 1:numel(comp_feature);
    xp = linspace(x(1), x(end), size);
    resized = interp1(x, comp_feature, xp);
end