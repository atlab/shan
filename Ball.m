%{
patch.Ball (imported) # ball velocity and timestamps
-> patch.Recording
-----
ball_raw         : longblob # raw ball velocity
ball_vel         : longblob # ball velocity integrated over 100ms bins in cm/sec
ball_time        : longblob # timestamps of each sample in seconds, with same t=0 as patch and camera data
ball_cmsec_factor  : float # factor used to convert to cm/2
ball_ts = CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Ball < dj.Relvar
    
    properties(Constant)
        table = dj.Table('patch.Ball');
    end
    
    methods
        function makeTuples(self, key, ballRaw, ballT)
            
            % Used for encoder position after 2014-03-28 08:00 (file version >=6)
            tuple = key;
            tuple.ball_raw = unwrap(ballRaw,2^31);
            tuple.ball_raw = tuple.ball_raw - tuple.ball_raw(1);
            tuple.ball_time = ballT;
            bins100ms = ballT(1):.1:ballT(end);
            distPerBin = [0 diff(interp1(ballT,tuple.ball_raw,bins100ms))]; % integrated distance per 100ms bin
            tuple.ball_cmsec_factor = .09; %(71.8168 cm circumference of 9inch wheel generates 8000 encoder counts = ~.009cm per count * 10 100ms bins per second)
            tuple.ball_vel = interp1(bins100ms,distPerBin * tuple.ball_cmsec_factor,ballT);
            tuple.ball_vel(isnan(tuple.ball_vel))=0;
            
            % Used for optical mouse velocity prior to 2014-03-28 08:00 (file version < 6)
            %         ballDist = ballRaw*median(diff(ballT)); % multiply by bin size to get distance traveled
            %
            %         bins100ms = ballT(1):.1:ballT(end);
            %         cs = cumsum(ballDist);
            %         cs = interp1(ballT,cs,bins100ms); % integrated distance per 100ms bin
            %         bv = interp1(bins100ms,[diff(cs) 0],ballT,'nearest') .* 10; % net distance/sec
            %         multFactor = 2; % worst-case scenario scaling factor to convert to cm/sec
            %         bv = bv*multFactor;
            %         tuple.ball_vel = bv;
            %         tuple.ball_cmsec_factor = multFactor;
            
            self.insert(tuple);
        end
    end
end


