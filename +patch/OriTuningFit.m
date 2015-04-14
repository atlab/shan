%{
patch.OriTuningFit (computed) # fit the tuning with von mise2
-> patch.OriTuningOptoOnOff
-----
base       : double     # base firing, spk/trial 
small_peak : double     # small peak firing, spk/trial
big_peak   : double     # big peak firing, spk/tiral
sharpeness : double     # correspond to tuning width
pref_dir   : double     # prefered direction, in degs
%}

classdef OriTuningFit < dj.Relvar & dj.AutoPopulate
	
    properties
        popRel = patch.OriTuningOptoOnOff 
    end
    methods(Access = protected)

		function makeTuples(self, key)
            spk_tuning_on = fetch1(patch.OriTuningOptoOnOff & key,'spk_tuning_on');
            spk_tuning_on = horzcat(spk_tuning_on{:});
            spk_tuning_on_mean = nanmean(spk_tuning_on);
            
            f = fit(ne7.rf.VonMises2, spk_tuning_on_mean');
            key.base = f.w(1);
            key.big_peak = f.w(2);
            key.small_peak = f.w(3);
            key.sharpeness = f.w(4);
            key.pref_dir = f.w(5)*180/pi;
            
            self.insert(key)
		end
	end

end