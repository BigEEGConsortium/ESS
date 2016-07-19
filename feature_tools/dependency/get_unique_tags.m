function [uniqueTag, uniqueTagEntropy, uniqueTagEventCodes, uniqueTagEventCodeCounts, uniqueTagText] = get_unique_tags(tag, tagEventCode, tagEventCount)

%% combine records to form unique (tag,code) tuples
randomString = getUuid;
combined = strcat(tagEventCode, '-', randomString,'-', tag);
[dummy uniqueId originIds] = unique(combined, 'stable');

for i=1:length(uniqueId)
    aggregateTagEventCount(i) = sum(tagEventCount(originIds == i));
end
tag = tag(uniqueId);
tagEventCode = tagEventCode(uniqueId);
tagEventCount = aggregateTagEventCount;
%%


[uniqueTag uniqueTagId originTagIds] = unique(tag, 'stable');
uniqueTagText = {};
for i=1:length(uniqueTag)
    uniqueTagText{i} = '';[uniqueTag{i} ': '];
    codeId = find(originTagIds == i);
    uniqueTagEventCodes{i} =  tagEventCode(codeId);
    uniqueTagEventCodeCounts{i} =  tagEventCount(codeId);
    p =  uniqueTagEventCodeCounts{i} / sum(uniqueTagEventCodeCounts{i});
    uniqueTagEntropy(i) = -sum(p.*log(p));
    for j=1:length(codeId)
        uniqueTagText{i} = [uniqueTagText{i} 'code ' tagEventCode{codeId(j)} '(' num2str(tagEventCount(codeId(j))) '),'];
    end
end;

[uniqueTagEntropy ord] = sort(uniqueTagEntropy, 'descend');
uniqueTag = uniqueTag(ord);
uniqueTagEventCodes = uniqueTagEventCodes(ord);
uniqueTagEventCodeCounts = uniqueTagEventCodeCounts(ord);
uniqueTagText = uniqueTagText(ord);
