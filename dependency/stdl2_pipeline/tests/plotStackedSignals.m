
function signalStackedPlot(signals, g)
% Plot specified signals slice of visData using bFunction's colors
[g, ~] = getStructureParameters(g, 'channels', []);
[g, ~] = getStructureParameters(g, 'clippingon', true);
[g, ~] = getStructureParameters(g, 'clippingtolerance', 0.05);
[g, ~] = getStructureParameters(g, 'colors', {[0.7, 0.7, 0.7], [1, 0, 0]});
[g, ~] = getStructureParameters(g, 'signallabel', '{\mu}V');
[g, ~] = getStructureParameters(g, 'signalscale', 3);
[g, ~] = getStructureParameters(g, 'srate', 1);
[g, ~] = getStructureParameters(g, 'timescale', []);
[g, ~] = getStructureParameters(g, 'trimpercent', 0);

myFigure = figure('Name', 'Signal Stacked Plot');
mainAxes = axes('Parent', myFigure, ...
    'Box', 'on', 'ActivePositionProperty', 'Position', ...
    'Units', 'normalized', ...
    'YDir', 'reverse', ...
    'Tag', 'stackedSignalAxes', 'HitTest', 'on');
hold (mainAxes, 'on');
displayPlot(mainAxes, signals, g);
hold (mainAxes, 'off');

    function colors = getColors(signals, g)
        % Returns the signal colors from the plot
        colors = repmat(g.colors{1}, [size(signals,1), 1]);
        for a = 1:length(g.channels)
            colors(g.channels(a),:) = g.colors{2};
        end
    end
    function displayPlot(mainAxes, signals, g)
        % Plot the signals stacked one on top of another
        nSamples = size(signals, 2);
        xLimOffset = (1 - 1)*nSamples/g.srate;
        if ~isempty(g.timescale)
            timeUnits = 'ms';
            xValues = 1000*g.timescale;
        else
            timeUnits = 's';
            xValues = xLimOffset + ...
                (0:(size(signals, 2) - 1))/g.srate;
        end
        colors = getColors(signals, g);
        data = signals;
        lineWidthUnselected = 0.5;
        numPlots = size(signals, 1);
        if numPlots == 0
            warning('signalStackedPlot:NaNValues', ...
                'No signals to plot');
            return;
        end
        % Take care of trimming based on scope
        
        [tMean, tStd, tLow, tHigh] = ...
            getTrimValues(g.trimpercent, signals);
        
        
        scale = g.signalscale;
        if isempty(scale)
            scale = 1;
        end
        plotSpacing = double(scale)*tStd;
        if isnan(plotSpacing)
            warning('signalStackedPlot:NaNValues', ...
                'No signals to plot');
            return;
        end
        if plotSpacing == 0;
            plotSpacing = 0.1;
        end
        data(data < tLow) = tLow;
        data(data > tHigh) = tHigh;
        
        
        data = data - tMean;
        
        %y-axis reversed, so must plot the negative of the signals
        eps = plotSpacing*g.clippingtolerance;
        hitList = cell(1, numPlots + 1);
        hitList{1} = mainAxes;
        for k = 1:numPlots
            signals =  - data(k, :) + k*plotSpacing;
            if g.clippingon
                signals = min((numPlots + 1)*plotSpacing - eps, max(eps, signals));
            end
            hp = plot(mainAxes, xValues, signals, ...
                'Color', colors(k, :), ...
                'Clipping','on', 'LineWidth', lineWidthUnselected);
            set(hp, 'Tag', num2str(k));
            hitList{k + 1} = hp;
        end
        yTickLabels = cell(1, numPlots);
        yTickLabels{1} = '1';
        yTickLabels{numPlots} = num2str(numPlots);
        xStringBase = ['Channels 1:',num2str(size(data,1))];
        xString = ['Time(' timeUnits ') [' xStringBase ']'];
        xString = sprintf('%s (Scale: %g %s)', ...
            xString, plotSpacing, g.signallabel);
        yString = 'Channel';
        set(mainAxes,  'YLimMode', 'manual', ...
            'YLim', [0, plotSpacing*(numPlots + 1)], ...
            'YTickMode', 'manual', 'YTickLabelMode', 'manual', ...
            'YTick', plotSpacing:plotSpacing:numPlots*plotSpacing, ...
            'YTickLabel', yTickLabels, ...
            'XTickMode', 'auto', ...
            'XLim', [xValues(1), xValues(end)], 'XLimMode', 'manual', ...
            'XTickMode', 'auto');
        xLab = get(mainAxes, 'XLabel');
        set(xLab, 'String', xString);
        yLab = get(mainAxes, 'YLabel');
        set(yLab, 'String', yString);
    end % displayPlot

    function [tMean, tStd, tLow, tHigh] = getTrimValues(percent, data)
        % Return trim mean, trim std, trim low cutoff, trim high cutoff
        myData = data(:);
        if isempty(percent) || percent <= 0 || percent >= 100
            tLow = min(myData);
            tHigh = max(myData);
        else
            tValues = prctile(myData, [percent/2, 100 - percent/2]);
            tLow = tValues(1);
            tHigh = tValues(2);
            myData(myData < tLow | myData > tHigh) = [];
        end
        tMean = mean(myData);
        tStd = std(myData, 1);
    end % getTrimValues


end % signalStackedPlot
