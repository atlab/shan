%{
patch.OriTuning (computed)      # orientation tuning
-> patch.Sync
-> patch.Ephys
-----
oris        : tinyblob          # grating directions
vm_tuning   : mediumblob        # oris x samples of mean low-pass membrane voltage during trials
spk_tuning  : mediumblob        # oris x samples of summed spikes during trials
orituning_ts = current_timestamp  : timestamp         # automatic
%}

classdef OriTuning < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('patch.OriTuning');
        popRel = patch.Sync * patch.Ephys & (patch.Recording);
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
            
            oriTrials = fetch(patch.Trial & key,'*');
            
            oris = unique([oriTrials.direction]);
            vMat=cell(length(oris),1);
            spkMat=cell(length(oris),1);
            
            for i=1:length(oriTrials)
                start = ts2ind(oriTrials(i).trial_onset,vt,dt);
                stop = ts2ind(oriTrials(i).trial_onset + oriTrials(i).trial_duration,vt,dt);
                
                k = size(vMat{find(oris==oriTrials(i).direction)},1);
                
                if ~all(isnan(vLow))
                    vMat{find(oris==oriTrials(i).direction)}(k+1,1:stop-start+1) = vLow(start:stop)-vLow(start);
                else
                    vMat{find(oris==oriTrials(i).direction)}(k+1,1:stop-start+1) = zeros(size(start:stop));
                end
                
                k = size(spkMat{find(oris==oriTrials(i).direction)},1);
                spkMat{find(oris==oriTrials(i).direction)}(k+1,1:stop-start+1) = spk(start:stop);
            end
            len = round(min(cellfun(@length,vMat))*.95);
            clear m
            for i=1:length(vMat)
                tuple.vm_tuning(i,:)=nanmean(vMat{i}(:,1:len),2);
                tuple.spk_tuning(i,:)=nansum(spkMat{i}(:,1:len),2);
            end
            tuple.oris = oris;
            self.insert(tuple);
        end
    end
end
