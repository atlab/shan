function h = OriTuningSpk(varargin)
%h = OriTuningSpk(key)
%
% Plots orientation tuning of spikes for OriTrials

keys = fetch(patch.OriTuning & varargin);

for iKey = keys'
    
    [oris, spk_tuning] = fetch1(patch.OriTuning & iKey, 'oris','spk_tuning');
    
    oris = oris*pi/180;
    oris(length(oris)+1) = oris(1);
    spk_tuning = cellfun(@mean,spk_tuning)';
    spk_tuning(length(spk_tuning)+1) = spk_tuning(1);
    figure;
    polar(oris, spk_tuning);
    

end