%{
patch.PeriLedTrial (computed) # my newest table
->patch.PeriLedTrialSet
->psy.Trial
-----
peri_led_win    :  tinyblob    # positive peri window durations [w1 w2](-w1:+w2) in sec
peri_led_spk    :  longblob    # binary spike train around led onset
peri_led_thres  :  double      # spike threshold of the cell
peri_led_vm     :  longblob    # voltage values around led onset
peri_led_vm_baseline : double  # vm baseline at the stimulus onset
peri_led_vm_to_thresh: double  # the distance between the vm onset and the threshold (vm_onset - threshold), in volts
peri_led_vm_norm:  longblob    # vm extracted baseline
peri_led_stat   :  tinyint     # status of led, on or off 
peri_led_led    :  longblob    # binary time series indicating led status: 1 = led on, 0 = led off
peri_led_time   :  longblob    # new time, 0 for LED starting point, in sec
peri_led_onset  :  double      # absolute time of trial onset, on the visual stimuli clock, in s
peri_led_dur    :  double      # duration of LED stimulation, in s
peri_led_delay  :  double      # delay time between LED and the onset of visual stimulus, in s
peri_led_ori    :  double      # orientation of visual stimulus on this trial
peri_led_mean_vel : double     # mean velocity of the ball during this trial
peri_led_dt     :  double      # time step
%}

classdef PeriLedTrial < dj.Relvar
    
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
            win = [0.7,0.7];
            dur = 0.02;
            record_type = fetch1(patch.Cell & key, 'patch_type');
            [ball_time, ball_vel] = fetch1(patch.Ball & key, 'ball_time','ball_vel');
            
            for tuple = fetch(patch.Sync*psy.Trial & key & 'trial_idx between first_trial and last_trial')'
                [flipTimes,direction,trial_dur, led_stat,delay] = fetch1(psy.Trial*psy.Grating & tuple, 'flip_times','direction','trial_duration','second_photodiode','second_photodiode_time');
                
                
                
                if led_stat == -1
                    % indices
                    id = ts2ind(flipTimes(2),vist,dt,'nan');
                    id_led_on = ts2ind(flipTimes(2)+delay,vist,dt,'nan');
                    id_led_off = ts2ind(flipTimes(2)+delay+dur,vist,dt,'nan');
                    id1 = ts2ind(flipTimes(2)+delay-win(1),vist,dt,'nan');
                    id2 = ts2ind(flipTimes(2)+delay+win(2),vist,dt,'nan');

                    if ~any(isnan(id)) && ~any(isnan(id_led_on)) && ~any(isnan(id_led_off)) && ~any(isnan(id1)) && ~any(isnan(id2))
                        tuple.peri_led_win = win;
                        tuple.peri_led_spk = spk(id1:id2);
                        tuple.peri_led_vm = vLow(id1:id2);
                        if any(isnan(tuple.peri_led_vm))
                            continue
                        end
                        tuple.peri_led_vm_baseline = vLow(id_led_on);
                        tuple.peri_led_vm_norm = tuple.peri_led_vm - tuple.peri_led_vm_baseline;
                        if strcmp(record_type, 'whole cell')
                            thresh = fetch1(patch.Threshold & key, 'threshold');
                            tuple.peri_led_thres = thresh;
                            tuple.peri_led_vm_to_thresh = tuple.peri_led_vm_baseline-thresh;
                        else
                            tuple.peri_led_thres = 0;
                            tuple.peri_led_vm_to_thresh = 0;
                        end
                        ball_vel_rel = ball_vel(ball_time > vt(id1) & ball_time < vt(id2));
                        tuple.peri_led_mean_vel = mean(ball_vel_rel);
                        tuple.peri_led_stat = led_stat;
                        tuple.peri_led_led = zeros(size(tuple.peri_led_spk));
                        tuple.peri_led_led(id_led_on:id_led_off) = 1;
                        tuple.peri_led_time = vist(id1:id2) - vist(id_led_on);
                        tuple.peri_led_onset = vt(id);
                        tuple.peri_led_delay = delay;
                        tuple.peri_led_ori = direction;
                        tuple.peri_led_dur = dur;
                        tuple.peri_led_mean_vel = mean(abs(ball_vel_rel));
                        tuple.peri_led_dt = dt;

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
                    id1 = ts2ind(ledOn-win(1),vt,dt,'nan');
                    id2 = ts2ind(ledOn+win(2),vt,dt,'nan');

                    if ~any(isnan(id)) && ~any(isnan(id_led_on)) && ~any(isnan(id_led_off)) && ~any(isnan(id1)) && ~any(isnan(id2)) 
                        tuple.peri_led_win = win;
                        tuple.peri_led_spk = spk(id1:id2);
                        tuple.peri_led_vm = vLow(id1:id2);
                        if any(isnan(tuple.peri_led_vm))
                            continue
                        end
                        tuple.peri_led_vm_baseline = vLow(id_led_on);
                        
                        tuple.peri_led_vm_norm = tuple.peri_led_vm - tuple.peri_led_vm_baseline;
                        if strcmp(record_type, 'whole cell')
                            thresh = fetch1(patch.Threshold & key,'threshold');
                            tuple.peri_led_thres = thresh;
                            tuple.peri_led_vm_to_thresh = tuple.peri_led_vm_baseline-thresh;
                        else
                            tuple.peri_led_thres = 0;
                            tuple.peri_led_vm_to_thresh = 0;
                        end
                        ball_vel_rel = ball_vel(ball_time < ledOn + win(2) & ball_time > ledOn - win(1));
                        
                        if isempty(ball_vel_rel)
                            ball_vel_rel = 0;
                        end
                        
                        tuple.peri_led_stat = led_stat;
                        tuple.peri_led_led = zeros(size(tuple.peri_led_spk));
                        tuple.peri_led_led(id_led_on:id_led_off) = 1;
                        tuple.peri_led_time = vt(id1:id2) - vt(id_led_on);
                        tuple.peri_led_onset = vt(id);
                        tuple.peri_led_delay = delay;
                        tuple.peri_led_ori = direction;
                        tuple.peri_led_dur = dur;
                        tuple.peri_led_mean_vel = nanmean(abs(ball_vel_rel));
                        tuple.peri_led_dt = dt;

                        self.insert(tuple)
                    end 
                end
            end
             
		end
	end

end