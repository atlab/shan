%{
patch.PeriLed (imported) # Peri-LED activity
-> patch.Led
-> patch.Ephys
-----
peri_led_win :      tinyblob    # positive peri window durations [w1 w2] (-w1:+w2)
peri_led_vm :       longblob    # vm trace around led onset
peri_led_spk :      blob        # int8 binary spike train around led onset
peri_led_led :      blob        # int8 binary time series indicaating led status: 1 = led on, 0 = led off
peri_led_ts = CURRENT_TIMESTAMP : timestamp     # automatic
%}

classdef PeriLed < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = patch.Ephys & patch.Led;
    end
    
    methods(Access=protected)
        function makeTuples(self, K)
            
            for key = K
                [vt,vm,fs] = patch.utils.cleanVm(key);
                dt = 1/fs;
                [spkTs, spkWin] = fetchn(patch.Spikes & key,'spk_ts','spk_width');
                spk = zeros(size(vt),'int8');
                spk(ts2ind(spkTs,vt,dt))=1;
                
                vm = patch.utils.deSpike(vt,vm,spkTs,spkWin);
                
                led = zeros(size(vt),'int8');
                
                [ledOn,ledDur] = fetchn(patch.Led & key,'led_on','led_dur');
                ledOff = ledOn + ledDur;
                
                for i=1:length(ledOn)
                    pStart = ts2ind(ledOn(i),vt,dt);
                    pEnd = ts2ind(ledOff(i),vt,dt);
                    led(pStart:pEnd)=1;
                end
                
                key = fetch(patch.Led * patch.Ephys & key);
                
                for i=1:length(key)
                    tuple = key(i);
                    
                    win = round(round(ledDur(i)/.1)*.1 + 1);
                    tuple.peri_led_win = [win win];
                    
                    ind = ts2ind(ledOn(i)-win,vt,dt,'nan'):ts2ind(ledOn(i)+win,vt,dt,'nan');
                    if any(isnan(ind))
                        %tuple.peri_led_vm=nan(size(ind));
                        %tuple.peri_led_spk=nan(size(ind));
                        %tuple.peri_led_led=nan(size(ind));
                    else
                        tuple.peri_led_vm=vm(ind);
                        tuple.peri_led_spk=spk(ind);
                        tuple.peri_led_led=led(ind);
                        self.insert(tuple);
                    end
                end
            end
        end
    end
end

