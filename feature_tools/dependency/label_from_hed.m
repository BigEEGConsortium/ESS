function labels = label_from_hed(hedStrings)
 % labels = label_from_hed(hedStrings)
 % hedStrings is HED cell array containing HED string or a single HED string.

if ischar(hedStrings)
    hedStrings = {hedStrings};
end;

l = 'Event/Label/';
ll = length(l);
startIds = strfind(hedStrings, l);
labels = cell(length(hedStrings), 1);

for i=1:length(labels)
    if isempty(startIds{i})
        labels{i} = '';
    else
        hedStrings{i} = hedStrings{i}((startIds{i}(1) + ll):end);
        commaLocation = strfind(hedStrings{i}, ',');
        if isempty(commaLocation)
            labels{i} = hedStrings{i};
        else
            labels{i} = hedStrings{i}(1:(commaLocation-1));
        end;
    end;
end;