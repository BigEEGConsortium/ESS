function matchMask = matchHED(hedStrings, queryHEDString)
% matchVector = matchHED(hedStrings, queryHEDString)
% Inputs: 
%
% hedStrings:      a cell array of input HED string we want to see whether they match a query string
% queryHEDString:  the query HED string
% Outputs:
%
% matchMask: a logical array the length of hedStrings with true valus where hedStrings matched queryHEDString
%
% Example
% >> MatchMask = matchHED({'a' 'a/b/c' 'b/d/d'}, 'b')
% >> matchMask =
% 
%      0
%      0
%      1
matchMask = false(length(hedStrings), 1);
for i=1:length(hedStrings)
    EEG.event.usertags = hedStrings{i};
    matchMask(i) = ~isempty(findTagMatchEvents(EEG, 'tags', queryHEDString));
end;