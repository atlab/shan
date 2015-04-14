%{
patch.OriTuningOptoOnOff (computed) # orientation tuning of the on and off period for temporal sharpening experiments
-> patch.Sync
-> patch.Ephys
-----
oris            : tinyblob          # grating directions
vm_tuning_on    : mediumblob        # oris x samples of mean low-pass membrane voltage during trials,  for visual stimuli on period, with LED off
vm_tuning_off   : mediumblob        # oris x samples of mean low-pass membrane voltage during trials, for visual stimuli off period, with LED off
spk_tuning_on   : mediumblob        # oris x samples of summed spikes during trials, with LED on
spk_tuning_off  : mediumblob        # oris x samples of summed spikes during trials, with LED off
orituning_ts = current_timestamp  : timestamp         # automatic
%}

classdef OriTuningOptoOnOff < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        popRel = patch.Sync * patch.Ephys & (patch.Recording & 'has_led=true') & (patch.RecordingNote & 'recording_purpose="temporal sharpening"');
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            tuple=key;
            
            [spkts,spkwid] = fetchn(patch.Spikes & key,'spk_ts','spk_width');
            vm = patch.utils.cleanVm(key);
            
            spkts = fetchn(patch.Spikes & key,'spk_ts');
            vt = fetch1(patch.Ephys & key,'ephys_time');
            
            recType = fetch1(patch.Cell & key, 'patch_type');
            if strcmp(recType, 'whole cell');
                vLow = patch.utils.deSpike(vt,vm,spkts,spkwid);
            else
                vLow = vm;
            end

            vLow = ezfilt(vLow,55,10000,'low');
            
            dt = median(diff(vt));
            fs = 1/dt;

            spk=zeros(size(vt));
            spk(ts2ind(spkts,vt,dt))=1;
            
            oriTrials_off = fetch(patch.Trial & key & 'led_stat=-1','*');
            
            oris = unique([oriTrials_off.direction]);
            vMat_on   =cell(length(oris),1);
            vMat_off  =cell(length(oris),1);
            spkMat_on =cell(length(oris),1);
            spkMat_off=cell(length(oris),1);
            
            for i=1:length(oriTrials_off)
                start = ts2ind(oriTrials_off(i).trial_onset,vt,dt);
                stop = ts2ind(oriTrials_off(i).trial_onset + oriTrials_off(i).trial_duration,vt,dt);
                
                k = size(vMat_on{find(oris==oriTrials_off(i).direction)},1);
                
                if ~all(isnan(vLow))
                    vMat_on{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = vLow(start:stop)-vLow(start);
                    spkMat_on{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = spk(start:stop);
                end
                
                start = ts2ind(oriTrials_off(i).trial_onset - oriTrials_off(i).trial_duration,vt,dt);
                stop = ts2ind(oriTrials_off(i).trial_onset,vt,dt);
                
                k = size(vMat_off{find(oris==oriTrials_off(i).direction)},1);
                
                if ~all(isnan(vLow))
                    vMat_off{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = vLow(start:stop)-vLow(start);
                    spkMat_off{find(oris==oriTrials_off(i).direction)}(k+1,1:stop-start+1) = spk(start:stop);
                end
                
            end
            len = round(min(cellfun(@length,vMat_on))*.95);
            clear m
            tuple.vm_tuning_on = cell(length(oris),1);
            tuple.spk_tuning_on = cell(length(oris),1);
            for i=1:length(vMat_on)
                tuple.vm_tuning_on{i}=nanmean(vMat_on{i}(:,1:len),2);
                tuple.spk_tuning_on{i}=nansum(spkMat_on{i}(:,1:len),2);
            end
            
            len = round(min(cellfun(@length,vMat_off))*.95);
            clear m
            
            tuple.vm_tuning_off = cell(length(oris),1);
            tuple.spk_tuning_off = cell(length(oris),1);
            for i=1:length(vMat_off)
                tuple.vm_tuning_off{i}=nanmean(vMat_off{i}(:,1:len),2);
                tuple.spk_tuning_off{i}=nansum(spkMat_off{i}(:,1:len),2);
            end
            tuple.oris = oris;
            self.insert(tuple);
        end
    end
end
