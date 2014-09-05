%{
patch.Ephys (imported) # current, voltage, and patch quality
-> patch.Recording
-> patch.Cell
-----
current          : longblob     # patch current (nA)
vm               : longblob     # patch voltage (mV)
v_gain           : int          # voltage gain setting (V/V)
v_highpass       : decimal(7,2) # voltage low pass corner freq (Hz)
v_lowpass        : int          # voltage low pass corner freq (Hz)
current_gain     : decimal(4,1) # current gain setting (V/nA)
current_lowpass  : int          # current low pass corner freq (Hz)
ephys_fs=null               : float                         # mean sampling rate
ephys_dt_deviation=null     : float                         # maximum deviation (in seconds) from mean dt
ephys_time_deviation=null   : float                         # total time deviation
ephys_time       : longblob     # timestamps of each sample in seconds, with same t=0 as ball and camera data
ephys_ts = CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Ephys < dj.Relvar

    methods
        function makeTuples(self, key, i, v, vt, sets)
            tuple = key;
            tuple.current = i;
            tuple.vm = v;
            tuple.ephys_time = vt;
            tuple.current_gain = sets.iGain;
            tuple.v_gain = sets.vGain;
            tuple.v_highpass = sets.vHighPass;
            tuple.v_lowpass = sets.vLowPass;
            tuple.current_lowpass = sets.iLowPass;
            
            dt = diff(vt);
            fs = 1/mean(dt);
            tuple.ephys_fs = fs;
            tuple.ephys_dt_deviation = max(abs(dt-1/fs));
            
            uniVt = min(vt):mean(dt):max(vt);
            
            if length(vt) == length(uniVt)
                tuple.ephys_time_deviation = max(abs(vt' - uniVt));
            else
                resampledVt = interp1(vt,1:length(uniVt));
                tuple.ephys_time_deviation = max(abs(resampledVt'-uniVt));
            end
            
            self.insert(tuple);
        end
    end
end


