%{
slicepatch.Recording (manual) # VC or CC recording
->slicepatch.Cell
recording_id                 : smallint                   # recording number
-----
recording_type="Unknown"     : enum('Unknown','VC','CC')  # voltage or current clamp
voltage=-70                  : float                      # (mV) holding potential
stim_num=0                   : smallint                   # number of light stimulation
psc_amp=0                    : float                      # (pA) amplitude of EPSC or IPSC
psp_amp=0                    : float                      # (mV) amplitude of EPSP and IPSP, 
latency=0                    : float                      # (ms) latency of the light response
rise_time=0                  : float                      # (ms) time to peak
decay_time=0                 : float                      # (ms)
ppr=0                        : float                      # paired pulse ratio
record_ts=CURRENT_TIMESTAMP  : timestamp                  # automatic
%}

classdef Recording < dj.Relvar

	properties(Constant)
		table = dj.Table('slicepatch.Recording')
	end
end
