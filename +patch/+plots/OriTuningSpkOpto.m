function h = OriTuningSpkOpto(type,varargin)
%h = OriTuningSpk(key)
%
% Plots orientation tuning of spikes for OriTrials

keys = fetch(patch.OriTuningOpto & varargin);

for iKey = keys'
    
    [oris, spk_tuning_on, spk_tuning_off] = fetch1(patch.OriTuningOpto & iKey, 'oris','spk_tuning_on','spk_tuning_off');
    
    oris = oris*pi/180;
    
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
        spk_tuning_on_mean = cellfun(@mean,spk_tuning_on)';
        spk_tuning_off_mean = cellfun(@mean,spk_tuning_off)';
        spk_tuning_on_ste = cellfun(@std,spk_tuning_on)'./sqrt(cellfun(@length,spk_tuning_on)');
        spk_tuning_off_ste = cellfun(@std,spk_tuning_off)'./sqrt(cellfun(@length,spk_tuning_off)');
        figure;
        errorbar(oris, spk_tuning_off_mean, spk_tuning_off_ste, 'k'); hold on
        errorbar(oris, spk_tuning_on_mean, spk_tuning_on_ste);
        legend('LED off','LED on');
    end

end