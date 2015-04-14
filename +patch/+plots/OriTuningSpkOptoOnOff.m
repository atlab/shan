function h = OriTuningSpkOptoOnOff(type,varargin)
%h = OriTuningSpk(key)
%
% Plots orientation tuning of spikes for OriTrials

keys = fetch(patch.Cell & patch.OriTuningOptoOnOff & varargin & (patch.RecordingNote &'recording_caveat=0' & 'recording_purpose="temporal sharpening"'));
figure; set(gcf,'Position', get(gcf,'Position').*[1,1,1,3.5]);
for kk = 1:length(keys)
    iKey = keys(kk);
    
    [oris, spk_tuning_on, spk_tuning_off] = fetchn(patch.OriTuningOptoOnOff & iKey, 'oris','spk_tuning_on','spk_tuning_off');
    
    oris = oris{1};
    if strcmp(type, 'polar')
        oris(length(oris)+1) = oris(1);
        spk_tuning_on = cellfun(@mean,spk_tuning_on)';
        spk_tuning_on(length(spk_tuning_on)+1) = spk_tuning_on(1);
        spk_tuning_off = cellfun(@mean,spk_tuning_off)';
        spk_tuning_off(length(spk_tuning_off)+1) = spk_tuning_off(1);
        figure;
        polar(oris, spk_tuning_off, 'k'); hold on
        polar(oris, spk_tuning_on);
        legend('LED off', 'LED on');
    elseif strcmp(type, 'dot')
        spk_tuning_onMat = [];
        cnt = 0;
        for ii = 1:length(spk_tuning_on)
            temp1 = spk_tuning_on{ii};
            minlen = min(cellfun(@length, temp1));
            temp1 = cellfun(@(x) patch.utils.cutArray(x,minlen), temp1, 'Un', 0);
            temp2 = horzcat(temp1{:});
            spk_tuning_onMat(cnt+1:cnt+size(temp2,1),:) = temp2;
            cnt = cnt + size(temp2,1);
            
        end
        spk_tuning_offMat = [];
        cnt = 0;
        for jj = 1:length(spk_tuning_off)
            temp1 = spk_tuning_off{ii};
            temp2 = horzcat(temp1{:});
            spk_tuning_offMat(cnt+1:cnt+size(temp2,1),:) = temp2;
            cnt = cnt + size(temp2,1);
        end
        
        spk_tuning_on_mean = nanmean(spk_tuning_onMat);
        spk_tuning_off_mean = nanmean(spk_tuning_offMat);
        spk_tuning_on_ste = nanstd(spk_tuning_onMat)'./sqrt(size(spk_tuning_onMat,1));
        spk_tuning_off_ste = nanstd(spk_tuning_offMat)'./sqrt(size(spk_tuning_offMat,1));
        
        % fit the tuning with vonmise2 function
        f = fit(ne7.rf.VonMises2, spk_tuning_on_mean');
       
        orivec = linspace(0,2*pi,50);
        fit_tuning = f.compute(orivec);
        
        subplot(7,3,kk);
        errorbar(oris, spk_tuning_off_mean, spk_tuning_off_ste, 'k'); hold on
        errorbar(oris, spk_tuning_on_mean, spk_tuning_on_ste);
        plot(orivec*180/pi,fit_tuning,'r');
        if kk==1
            legend('grating off','grating on');
        end
        
        if max(spk_tuning_on_mean)>4
            ylim([0,8]);
        else
            ylim([0,4]);
        end
        xlim([-15,375]);
    end

end