%{
patch.Spikes (imported) # spike waveforms and statistics
-> patch.Ephys
spk_id : int                # index of a spike

-----
spk_ts : float              # timestamp of spike in seconds, with same t=0 same as patch.Ephys
spk_isvalid : boolean       # true if spike is a valid spike
spk_wf : blob               # segmented spike waveform (-50:+100 samples)
spk_thresh = NULL : float   # spike threshold (mV)
spk_peak = NULL : float     # spike peak (mV)
spk_height = NULL : float   # threshold to peak height (mV)
spk_width = NULL : float    # peak width at half height (ms)
spk_ahp = NULL : float      # After-hyperpolarization magnitude (mV)

spikes_ts = CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Spikes < dj.Relvar & dj.AutoPopulate    
    properties
        popRel = patch.Ephys;
        wfWin = [-50:150]; % (-50:+150 samples around spike peak)
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            [vt,vm,fs] = patch.utils.cleanVm(key);
            dt = 1/fs;
            
            patch_type = fetch1(patch.Cell & key, 'patch_type');
            spkInd = patch.utils.spkDetect(vt,vm, patch_type);
            
            
            
            for i=1:length(spkInd)
                tuple = key;
                tuple.spk_isvalid=1;
                
                tuple.spk_ts = vt(spkInd(i));
                ind = spkInd(i) + self.wfWin;
                if any(ind<1) || any(ind>length(vm))
                    continue
                end
                
                wf = vm(ind);
                
                [~,threshInd] = max(diff(diff(wf)));
                thresh = wf(threshInd);
                peakInd = -1*self.wfWin(1) + 1;
                peak = wf(peakInd);
                hh = (peak - thresh)/2;
                try
                    pwhh(1) = find(wf(1:peakInd) <= thresh + hh, 1, 'last');
                    pwhh(2) = find(wf(peakInd:end) <= thresh + hh, 1, 'first') + peakInd - 1;
                    pwhh = diff(pwhh) * dt;
                catch
                    warning('Could not calculate spike width')
                    pwhh=nan;
                    tuple.spk_isvalid=0;
                end
                
                % sanity checks
                if patch.utils.isWholeCell(key) && (peak < -.040 || pwhh > .004 || pwhh < .0008 || peak-thresh < .004)
                    tuple.spk_isvalid=0;
                elseif pwhh > .004 || pwhh < .0008 || peak-thresh < .004
                    tuple.spk_isvalid=0;
                end
                
                tuple.spk_id = i;
                tuple.spk_wf = single(wf * 1000);
                tuple.spk_thresh = thresh * 1000;
                tuple.spk_peak = peak * 1000;
                tuple.spk_height = [peak-thresh] * 1000;
                tuple.spk_width = pwhh * 1000;

                self.insert(tuple);
            end
            
        end
    end
end
