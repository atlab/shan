%{
patch.PeriOriTrial (imported) # Peri-LED activity
-> patch.OriTrial
-> patch.Ephys
-----
peri_ori_vm :       longblob    # vm trace around led onset
peri_ori_spk :      blob        # int8 binary spike train around led onset
peri_ot_ts = CURRENT_TIMESTAMP : timestamp     # automatic
%}

classdef PeriOriTrial < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('patch.PeriOriTrial')
        popRel = patch.Ephys & patch.OriTrial;
    end
    
    methods(Access=protected)
        function makeTuples(self, K)
            
            for key = K
                vt = fetch1(patch.Ephys & key,'ephys_time');
                dt = median(diff(vt));
                
%                 if patch.utils.isWholeCell(fetch(patch.Ephys & key))
%                     vm = fetch1(patch.CleanEphys & key,'vm');
%                 else
%                     vm = fetch1(patch.CleanEphys & key,'vm_high');
%                 end
                vm = patch.utils.cleanVm(key);
                spkTs = fetchn(patch.Spikes & key,'spk_ts');
                spk = zeros(size(vt),'int8');
                spk(ts2ind(spkTs,vt,dt))=1;
                
                [oriOn,oriDur,preblank] = fetchn(patch.OriTrial & key,'ori_on','ori_dur','preblank');
                oriOff = oriOn + oriDur;
                
                key = fetch(patch.OriTrial * patch.Ephys & key);
                
                for i=1:length(key)
                    tuple = key(i);
                    
                    ind = ts2ind(oriOn(i)-preblank(i),vt,dt,'nan'):ts2ind(oriOff(i)+preblank(i),vt,dt,'nan');
                    if any(isnan(ind))
                        %tuple.peri_ori_vm=nan(size(ind));
                        %tuple.peri_ori_spk=nan(size(ind));
                    else
                        tuple.peri_ori_vm=vm(ind);
                        tuple.peri_ori_spk=spk(ind);
                        self.insert(tuple);
                    end
                end
            end
        end
    end
end