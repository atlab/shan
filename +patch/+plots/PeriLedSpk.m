function varargout = PeriLedSpk(varargin)
% h = PeriLedSpk(key)
%
% Plots mean spiking response to LED pulses of different lengths
%% Parse input
modPairs = lowercase({...
    'boxcarSmooth',...
    });

modSingles = lowercase({...
    });

[key, mods] = parseMods(varargin,modPairs,modSingles);

%% Get data
[s,led,dur,win] = fetchn(patch.PeriLed * patch.Led - patch.OriTrial & key,'peri_led_spk','peri_led_led','led_dur','peri_led_win');

dur = round(dur/.005)*.005;

cond = unique(dur);
fs = 10000;
dt = 1/fs;

C = colormap(['jet(' num2str(length(cond)) ')']);

h=[];
for i=1:length(cond)
    ix = dur==cond(i);
    sMat = cellfun(@(x) x(1:min(cellfun(@length,s(ix)))),s(ix),'uniformoutput',0);
    sMat = [sMat{:}];
    
    ledMat = cellfun(@(x) x(1:min(cellfun(@length,led(ix)))),led(ix),'uniformoutput',0);
    ledMat = [ledMat{:}];
    
    len = size(sMat,1);
    
    % remove any trials with preceeding LED pulses
    badInd = any(ledMat(1:floor(len/2)-10,:));
    sMat(:,badInd)=[];
    ledMat(:,badInd)=[];
    
    N=size(sMat,2);
    
    ix = find(ix,1,'first');
    
    %% Apply mods
    for j=1:length(mods)
        switch(mods(j).name)
            case 'boxcarsmooth'
                winLen = round(mods(j).value / dt);
                sMat = conv(mean(sMat'),ones(1,winLen) / winLen * fs,'same')';
                otherwise
                sMat = mean(sMat,2);
        end
    end
    
    h(i) = plot(linspace(-win{ix}(1),win{ix}(2),len),sMat,'color',C(i,:));
    
    L{i} = [num2str(cond(i)) 'sec (n=' num2str(N) ')'];
    hold on
    yL = [min(sMat) max(sMat)];
    plot(linspace(-win{ix}(1),win{ix}(2),len),ledMat*diff(yL) + yL(1),'color',C(i,:));
end

if ishandle(h)
    legend(h, L)
    if nargout
        varargout{1}=h;
    end
end


