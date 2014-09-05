function varargout = PeriLedVm(varargin)
% h = PeriLedVm(key)
%
% Plots mean Vm response to LED pulses of different lengths

%% Parse input
modPairs = lowercase({...
    'rmSpikes',...
    'filtLow',...
    'filtHigh',...
    'filtPass',...
    'hilbertRatio',...
    'subtractBaseline',...
    'PPL',...
    'spectrogram'...
    });

modSingles = lowercase({...
    'hilbertAmp',...
    'stdErrorBars',...
    'semErrorBars'});

[key, mods] = parseMods(varargin,modPairs,modSingles);

%% Get data
[v,led,dur,win] = fetchn(patch.PeriLed * patch.Led - patch.OriTrial & key,'peri_led_vm','peri_led_led','led_dur','peri_led_win');

dur = round(dur/.005)*.005;
cond = unique(dur);

fs = 10000;
dt = 1/fs;

h=[];
for i=1:length(cond)
    ix = dur==cond(i);
    vMat = cellfun(@(x) x(1:min(cellfun(@length,v(ix)))),v(ix),'uniformoutput',0);
    vMat = [vMat{:}];
    if abs(nanmedian(vMat)<1)
        vMat = vMat * 1000;
    end
    
    ledMat = cellfun(@(x) x(1:min(cellfun(@length,led(ix)))),led(ix),'uniformoutput',0);
    ledMat = [ledMat{:}];
    
    len = size(vMat,1);
    
    % remove any trials with preceeding LED pulses
    badInd = any(ledMat(1:floor(len/2)-10,:));
    vMat(:,badInd)=[];
    ledMat(:,badInd)=[];
    
    ix = find(ix,1,'first');
    
    %% apply mods
    for j=1:length(mods)
        switch(mods(j).name)
            case 'rmspikes'
                vMat = min(vMat,mods(j).value);
            case 'filtlow'
                vMat = ezfilt(vMat,mods(j).value,fs,'low');
            case 'filthigh'
                vMat = ezfilt(vMat,mods(j).value,fs,'high');
            case 'filtpass'
                vMat = ezfilt(vMat,mods(j).value,fs,'pass');
            case 'hilbertamp'
                vMat = abs(hilbert(vMat));
            case 'hilbertratio'
                low = abs(hilbert(ezfilt(vMat,mods(j).value(1:2),fs,'pass')));
                high = abs(hilbert(ezfilt(vMat,mods(j).value(3:4),fs,'pass')));
                high = ezfilt(high,mods(j).value(2),fs,'low')+1;
                vMat = low./high;
            case 'subtractbaseline'
                vMat = bsxfun(@minus, vMat, nanmean(vMat(floor(len/2)-round(mods(j).value / dt):floor(len/2),:)));
            case 'ppl'
                pMat = angle(hilbert(vMat));
                ppl = calcPPLHist(pMat',mods(j).value)';
                pad = round(length(ppl)/10);
                ppl(1:pad)=0; ppl(end-pad:end)=0;
                vMat = repmat(ppl,size(vMat(1,:)));
        end
    end
    
    %% plot
    if ismember('spectrogram',{mods(:).name})
        params.Fs=fs;
        params.fpass=mods(j).value;
        params.tapers=[3 5];
        params.trialave=1;
        [S,t,f]=mtspecgramc(vMat,[.4 .05],params);
        imagesc(t,f,10*log10(abs(S))');set(gca,'ydir','normal');
        %[S,f,t]=spectrogram(mean(vMat'),4096,3000,[1:5:55],fs);
        %imagesc(t,f,10*log10(abs(S)));set(gca,'ydir','normal');
        %plot(mean(S(:,1:7),2)./mean(S(:,9:end),2))
%         clear p
%         for j=1:size(vMat,2)
%             [p(j,:),f]=pwelch(vMat(:,j),[],[],1:50,10000);
%         end
    else
        
        C = colormap(['jet(' num2str(length(cond)) ')']);
        h(i) = plot(linspace(-win{ix}(1),win{ix}(2),len),nanmean(vMat'),'color',C(i,:));
        hold on
        if ismember('stderrorbars',[mods(:).name])
            plot(linspace(-win{ix}(1),win{ix}(2),len),nanmean(vMat')+nanstd(vMat'),'color',C(i,:),'linestyle','--');
            plot(linspace(-win{ix}(1),win{ix}(2),len),nanmean(vMat')-nanstd(vMat'),'color',C(i,:),'linestyle','--');
        end
        
        if ismember('semerrorbars',[mods(:).name])
            plot(linspace(-win{ix}(1),win{ix}(2),len),nanmean(vMat')+nanstd(vMat')/sqrt(size(vMat,2)),'color',C(i,:),'linestyle','--');
            plot(linspace(-win{ix}(1),win{ix}(2),len),nanmean(vMat')-nanstd(vMat')/sqrt(size(vMat,2)),'color',C(i,:),'linestyle','--');
        end
        
        yL = [min(mean(vMat')) max(mean(vMat'))];
        plot(linspace(-win{ix}(1),win{ix}(2),len),ledMat*diff(yL) + yL(1),'color',C(i,:));
        
        L{i} = [num2str(cond(i)) 'sec (n=' num2str(size(vMat,2)) ')'];
    end
end

if ishandle(h)
    legend(h, L)
    if nargout
        varargout{1}=h;
    end
end


