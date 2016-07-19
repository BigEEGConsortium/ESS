function [eventCode, eventHEDString, eventCount, tag, tagEventCode, tagEventCount]= analyze_event_instances(originalEventCode, originalEventLatency, originalEventHEDString);
% [eventCode eventHEDString eventCount tag tagEventCode tagEventCount uniqueTag uniqueTagId originTagIds] = analyze_event_instances(originalEventCode, originalEventLatency, originalEventHEDString);

% get unique combinations of event code and hed strings
randomString = getUuid;
combined = strcat(originalEventCode, randomString, originalEventHEDString);
[dummy uniqueStringId originIds] = unique(combined, 'stable');
eventCode = originalEventCode(uniqueStringId);
eventHEDString = originalEventHEDString(uniqueStringId);


tag = {};
tagEventCode = {};
tagEventCount = [];

for i=1:length(uniqueStringId)
    eventCount = sum(originIds == i);
    % create all the sub-tags, then see which ones happen in more than one event code
    [uniqueTagForUniqueEvent, uniqueTagCount, originalHedStringId] = hed_tag_count(strrep(strrep(eventHEDString(i), '(', ''), ')', ''));
    tag = [tag uniqueTagForUniqueEvent'];
    tagEventCode((length(tagEventCode)+1):length(tag)) = eventCode(i);
    tagEventCount((length(tagEventCount)+1):length(tag)) = eventCount;
end;

if nargout > 6    
    [uniqueTag uniqueTagId originTagIds] = unique(tag, 'stable');
    tagText = {};
    for i=1:length(uniqueTag)
        tagText{i} = ['tag: ' uniqueTag{i} ', '];
        codeId = find(originTagIds == i);
        uniqueTagEventCodes{i} =  tagEventCode(codeId);
        uniqueTagEventCodeCounts{i} =  tagEventCount(codeId);
        p =  uniqueTagEventCodes{i} / sum(uniqueTagEventCodes{i});       
        uniqueTagEntropy(i) = sum(p.*log(p));
        for j=1:length(codeId)
            tagText{i} = [tagText{i} 'event ' tagEventCode{codeId(j)} '(' num2str(tagEventCount(codeId(j))) '),'];
        end
    end;
end;