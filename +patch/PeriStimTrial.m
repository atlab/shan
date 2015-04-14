%{
patch.PeriStimTrial (computed) # isolate the trials with respect to the onset of the visual stimuli
->patch.PeriStimTrialSet
->psy.Trial
-----
peri_stim_win    :  tinyblob    # positive peri window durations [w1 w2](-w1:+w2) in sec
peri_stim_spk    :  longblob    # binary spike train around led onset
peri_stim_thres  :  double      # spike threshold of the cell
peri_stim_vm     :  longblob    # voltage values around led onset
peri_stim_vm_baseline : double  # vm baseline at the stimulus onset
peri_stim_vm_to_thresh: double  # the distance between the vm onset and the threshold (vm_onset - threshold), in volts
peri_stim_vm_norm:  longblob    # vm extracted baseline
peri_stim_stat   :  tinyint     # status of led, on or off 
peri_stim_led    :  longblob      # led trace or persumable led trace during the trial
peri_stim_time   :  longblob    # new time, 0 for LED starting point, in sec
peri_stim_dur    :  double      # duration of the grating on this trial
peri_stim_onset  :  double      # absolute time of trial onset, on the visual stimuli clock, in s
peri_stim_ori    :  double      # orientation of visual stimulus on this trial
peri_stim_dt     :  double      # time step
%}

classdef PeriStimTrial < dj.Relvar
    
	methods

		function makeTuples(self, key)
			
            ephysKey = fetch(patch.Ephys & key);
            vist= fetch1(patch.Sync * patch.Ephys & ephysKey(1),'vis_time');
            
            [spkts,spkwid] = fetchn(patch.Spikes & key,'spk_ts','spk_width');
            vm = patch.utils.cleanVm(ephysKey);
            vt = fetch1(patch.Ephys & key,'ephys_time');
           
            vLow = patch.utils.deSpike(vt,vm,spkts,spkwid);
            vLow = ezfilt(vLow,55,10000,'low');
                      
            dt = median(diff(vist));
            spk=zeros(size(vt));
            spk(ts2ind(spkts,vt,dt))=1;
            
            % some constants
            win = [0.4,0.7];
            dur = 0.02;
            record_type = fetch1(patch.Cell & key, 'patch_type');
            
            for tuple = fetch(patch.Sync*psy.Trial & key & 'trial_idx between first_trial and last_trial')'
                [flipTimes,direction,trial_dur, led_stat, delay] = fetch1(psy.Trial*psy.Grating & tuple, 'flip_times','direction','trial_duration','second_photodiode','second_photodiode_time');
                
                if led_stat == -1
                    % indices
                    id = ts2ind(flipTimes(2),vist,dt,'nan');
                    id_led_on = ts2ind(flipTimes(2)+delay,vist,dt,'nan');
                    id_led_off = ts2ind(flipTimes(2)+delay+dur,vist,dt,'nan');
                    id1 = ts2ind(flipTimes(2)-win(1),vist,dt,'nan');
                    id2 = ts2ind(flipTimes(2)+win(2),vist,dt,'nan');

                    if ~any(isnan(id)) && ~any(isnan(id1)) && ~any(isnan(id2))
                        tuple.peri_stim_win = win;
                        tuple.peri_stim_spk = spk(id1:id2);
                        tuple.peri_stim_vm = vLow(id1:id2);
                        if any(isnan(tuple.peri_stim_vm))
                            continue
                        end
                        tuple.peri_stim_vm_baseline = vLow(id);
                        tuple.peri_stim_vm_norm = tuple.peri_stim_vm - tuple.peri_stim_vm_baseline;
                        if strcmp(record_type, 'whole cell')
                            thresh = fetch1(patch.Threshold & key, 'threshold');
                            tuple.peri_stim_thres = thresh;
                            tuple.peri_stim_vm_to_thresh = tuple.peri_stim_vm_baseline-thresh;
                        else
                            tuple.peri_stim_thres = 0;
                            tuple.peri_stim_vm_to_thresh = 0;
                        end
                        tuple.peri_stim_stat = led_stat;
                        tuple.peri_stim_led = zeros(size(tuple.peri_stim_spk));
                        tuple.peri_stim_led(id_led_on:id_led_off) = 1;
                        tuple.peri_stim_time = vist(id1:id2) - vist(id);
                        tuple.peri_stim_onset = vt(id);
                        tuple.peri_stim_ori = direction;
                        tuple.peri_stim_dur = diff(flipTimes([2 end]));
                        tuple.peri_stim_dt = dt;

                        self.insert(tuple)
                    end
                else
                   % indices
                    id = ts2ind(flipTimes(2),vist,dt);
                    trial_onset = vt(id);
                    trial_offset = trial_onset+trial_dur;
                    [ledOn,ledDur] = fetchn(patch.Led & key & ['led_on>' num2str(trial_onset)] & ['led_on<' num2str(trial_offset)],'led_on','led_dur');
                    
                    if isempty(ledOn)
                        continue
                    end
                    ledOn = ledOn(1);
                    ledDur = ledDur(1);
                    ledOff = ledOn + ledDur;
                    id_led_on = ts2ind(ledOn,vt,dt,'nan');
                    id_led_off = ts2ind(ledOff,vt,dt,'nan');
                    id1 = ts2ind(flipTimes(2)-win(1),vt,dt,'nan');
                    id2 = ts2ind(flipTimes(2)+win(2),vt,dt,'nan');

                    if ~any(isnan(id)) && ~any(isnan(id1)) && ~any(isnan(id2)) 
                        tuple.peri_stim_win = win;
                        tuple.peri_stim_spk = spk(id1:id2);
                        tuple.peri_stim_vm = vLow(id1:id2);
                        if any(isnan(tuple.peri_stim_vm))
                            continue
                        end
                        tuple.peri_stim_vm_baseline = vLow(id);
                        
                        tuple.peri_stim_vm_norm = tuple.peri_stim_vm - tuple.peri_stim_vm_baseline;
                        if strcmp(record_type, 'whole cell')
                            thresh = fetch1(patch.Threshold & key,'threshold');
                            tuple.peri_stim_thres = thresh;
                            tuple.peri_stim_vm_to_thresh = tuple.peri_stim_vm_baseline-thresh;
                        else
                            tuple.peri_stim_thres = 0;
                            tuple.peri_stim_vm_to_thresh = 0;
                        end
                        tuple.peri_stim_stat = led_stat;
                        tuple.peri_stim_led = zeros(size(tuple.peri_stim_spk));
                        tuple.peri_stim_led(id_led_on:id_led_off) = 1;
                        tuple.peri_stim_time = vt(id1:id2) - vt(id);
                        tuple.peri_stim_onset = vt(id);
                        tuple.peri_led_ori = direction;
                        tuple.peri_led_dur = dur;
                        tuple.peri_led_dt = dt;

                        self.insert(tuple)
                    end 
                end
            end
             
		end
	end

end