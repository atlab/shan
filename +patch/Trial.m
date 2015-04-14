%{
patch.Trial (imported) # Visual presentation of single grating orientation
-> patch.TrialSet
-> psy.Trial
---
trial_onset                 : float                         # trial start time in patch.Ephys ephys_time not including preblank (sec)
trial_duration              : decimal(6,3)                  # actual duration of trial not including preblank (sec)
direction                   : float                         # direction of the stimulus on this trial
led_stat                    : tinyint                       # led on this trial is on or off
oritrial_ts=CURRENT_TIMESTAMP: timestamp                    # automatic
%}

classdef Trial < dj.Relvar    
    
    methods
        function makeTuples(self, key)
            ephysKey = fetch(patch.Ephys & key);
            [vist, vt]= fetch1(patch.Sync * patch.Ephys & ephysKey(1),'vis_time','ephys_time');
            dt = median(diff(vist));
            for key = fetch(patch.Sync*psy.Trial & key & 'trial_idx between first_trial and last_trial')'
                [flipTimes,direction,led_stat] = fetch1(psy.Trial*psy.Grating & key, 'flip_times','direction','second_photodiode');
                
                id = ts2ind(flipTimes(2),vist,dt);
                if ~isnan(id)
                    key.trial_onset = vt(id);
                    key.trial_duration = diff(flipTimes([2 end]));
                    key.direction = direction;
                    key.led_stat = led_stat;
                    self.insert(key)
                end
            end
        end
    end
end
