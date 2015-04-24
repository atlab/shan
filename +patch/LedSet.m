%{
patch.LedSet (imported) # overall LED trace
-> patch.Recording
-----
led_trace :             longblob                # pulse start time (sec)
led_time  :             longblob                # time stamp, same as ephys time
%}

classdef LedSet < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = patch.Recording & 'has_led'
    end

    methods(Access=protected)
        function makeTuples(self, key)
                
            DEFAULT_ANALOG_PACKET_LENGTH=2000;
            tuple=key;
            
            % get path
            p = fetch1(patch.Session & key,'path');
            [filename, has_ball, has_whisking, has_eyetracking] = fetch1(patch.Recording & key, 'filename','has_ball','has_whisking','has_eyetracking');
            dat = patch.utils.readPatchStimHD5(getLocalPath([p '/' filename]));
            

            %% Populate recording tuple

            % Timestamps
            if isfield(dat,'analogPacketLen')
                packetLen = dat.analogPacketLen;
            else
                packetLen = DEFAULT_ANALOG_PACKET_LENGTH;
            end

            [datT, datStart] = patch.utils.ts2sec(dat.ts,packetLen);


            %% put cameras, ephys and ball on same timebase with t(1)=0 for whichever comes first
            
            if has_ball
                [~, ballStart] = patch.utils.ts2sec(dat.ball(:,2));
            else
                ballStart=nan;
            end

            if has_whisking
                [~, whiskStart] = patch.utils.ts2sec(dat.cam1ts);
            else
                whiskStart=nan;
            end

            if has_eyetracking
                [~, eyeStart] = patch.utils.ts2sec(dat.cam2ts);
            else
                eyeStart=nan;
            end

            minStart = min([datStart ballStart whiskStart eyeStart]);
            datT = datT + datStart - minStart;

            tuple.led_trace = dat.led;
            tuple.led_time = datT;
            self.insert(tuple);

        end
    end
end


