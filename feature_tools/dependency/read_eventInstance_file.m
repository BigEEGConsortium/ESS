function [eventCode, eventLatency, eventHEDString] = readEventInstanceFile(eventFilePath)

fid=fopen(eventFilePath);
eventCode = {};
eventLatency = [];
eventHEDString = {};
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    c = textscan(tline, '%s\t%s\t%s\n');
    eventCode(end+1) = c{1};
    eventLatency(end+1) =  str2double(cell2mat(c{2}));
    eventHEDString{end+1} = tline((length(eventCode{end}) + length(cell2mat(c{2}))+3):end);
end
fclose(fid);