function [eventCode, eventLatency, eventHEDString] = readEventInstanceFile(eventFilePath)

fid=fopen(eventFilePath);
eventCode = {};
eventLatency = [];
eventHEDString = {};
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    parts = strsplit(tline, sprintf('\t'));
    eventCode(end+1) = parts(1);
    eventLatency(end+1) = str2double(parts{2});
    eventHEDString(end+1) = parts(3);
end
fclose(fid);