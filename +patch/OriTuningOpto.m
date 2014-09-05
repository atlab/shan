%{
patch.OriTuningOpto (computed)      # orientation tuning with LED stimulation
-> patch.Sync
-> patch.Ephys
-----
oris            : tinyblob          # grating directions
vm_tuning_on    : mediumblob        # oris x samples of mean low-pass membrane voltage during trials, with LED on
vm_tuning_off   : mediumblob        # oris x samples of mean low-pass membrane voltage during trials, with LED off
spk_tuning_on   : mediumblob        # oris x samples of summed spikes during trials, with LED on
spk_tuning_off  : mediumblob        # oris x samples of summed spikes during trials, with LED off
orituning_ts = current_timestamp  : timestamp         # automatic
%}

classdef OriTuningOpto < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('patch.OriTuning');
        popRel = patch.Sync * patch.Ephys & (patch.Recording & 'has_led=true');
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            tuple=key;
            
            %[vLow,spkts] = fetch1(patch.CleanEphys & key,'vm_low','spk_ts'); 
            vm = patch.utils.cleanVm(key);
            
            spkts = fetchn(patch.Spikes & key,'spk_ts');
            vt = fetch1(patch.Ephys & key,'ephys_time');

            vLow = patch.utils.deSpike(vt,vm,spkts);
            vLow = ezfilt(vLow,55,10000,'low');
            
            dt = median(diff(vt));
            fs = 1/dt;

            spk=zeros(size(vt));
            spk(ts2ind(spkts,vt,dt))=1;
            
            oriTrials_on = fetch(patch.Trial & key & 'led_stat=1','*');
            oriTrials_off = fetch(patch.Trial & key & 'led_stat=-1','*');
            
            oris = unique([oriTrials_on.direction]);
            vMat_on   =cell(length(oris),1);
            vMat_off  =cell(length(oris),1);
            spkMat_on =cell(length(oris),1);
            spkMat_off=cell(length(oris),1);
            
            for i=1:length(oriTrials_on)
                start = ts2ind(oriTrials_on(i).trial_onset,vt,dt);
                stop = ts2ind(oriTrials_on(i).trial_onset + oriTrials_on(i).trial_duration,vt,dt);
                
                k = size(vMat_on{find(oris==oriTrials_on(i).direction)},1);
                
                if ~all(isnan(vLow))
                    vMat_on{find(oris==oriTrials_on(i).direction)}(k+1,1:stop-start+1) = vLow(start:stop)-vLow(start);
                else
                    vMat_on{find(oris==oriTrials_on(i).direction)}(k+1,1:stop-start+1) = zeros(size(start:stop));
                end
                
                k = size(spkMat_on{find(oris==oriTrials_on(i).direction)},1);
                spkMat_on{find(oris==oriTrials_on(i).direction)}(k+1,1:stop-start+1) = spk(start:stop);
            end
            len = round(min(cellfun(@length,vMat_on))*.95);
            clear m
            for i=1:length(vMat_on)
                tuple.vm_tuning_on(i,:)=nanmean(vMat_on{i}(:,1:len),2);
                tuple.spk_tuning_on(i,:)=nansum(spkMat_on{i}(:,1:len),2);
            end
            for i=1:length(oriTrials_off)
                start = ts2ind(oriTrials_off(i).trial_onset,vt,dt);
                stop = ts2ind(oriTrials_off(i).trial_onset + oriTrials_off(i).trial_duration,vt,dt);
                
                k = size(vMat_off{find(oris==oriTrials_off(i).direction)},1);
                
                if ~all(isnan(vLow))
                    vMat_off{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = vLow(start:stop)-vLow(start);
                else
                    vMat_off{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = zeros(size(start:stop));
                end
                
                k = size(spkMat_off{find(oris==oriTrials_off(i).direction)},1);
                spkMat_off{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = spk(start:stop);
            end
            len = round(min(cellfun(@length,vMat_off))*.95);
            clear m
            for i=1:length(vMat_off)
                tuple.vm_tuning_off(i,:)=nanmean(vMat_off{i}(:,1:len),2);
                tuple.spk_tuning_off(i,:)=nansum(spkMat_off{i}(:,1:len),2);
            end
            tuple.oris = oris;
            self.insert(tuple);
        end
    end
end
