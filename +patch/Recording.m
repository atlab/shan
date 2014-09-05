%{
patch.Recording (imported) # my newest table
-> patch.Patch
file_num                    : smallint              # number of file appended to hd5 basename (excluding trailing 0)
-----
filename                    : varchar(255)          # filename for this recording
total_time                  : int                   # total recording time (in seconds)
is_dualpatch                : boolean               # true if this recording includes data from two pipettes
has_led                     : boolean               # true if this recording includes LED stimulation
has_vis                     : boolean               # true if this recording includes visual stimulation
has_estim                   : boolean               # true if this recording includes electrical stimulation
has_ball                    : boolean               # true if this recording includes ball velocity
has_whisking                : boolean               # true if this recording has an associated whisking video
has_eyetracking             : boolean               # true if this recording has an associated eyetracking video
has_scan                    : boolean               # true if this recording has an associated 2P imaging file
recording_ts=CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef Recording < dj.Relvar & dj.AutoPopulate
    properties
        popRel = patch.Patch
    end
    
	methods(Access=protected)
        function makeTuples(self, key)
            p = fetch1(patch.Session & key,'path');
            f = fetch1(patch.Patch & key,'filebase');
            localpath = getLocalPath([p '/' f]);
            w = dir([localpath '*']);                
            disp(['Found ' num2str(length(w)) ' file(s)']);
            % for each file recorded from this patch
            for i=1:length(w)
                tuple=key;
                
                fileNumStr = decell(regexp(w(i).name, [f '(\d{1,2})0.h5'],'tokens'));
                if isempty(fileNumStr)
                    continue
                elseif length(fileNumStr) == 1
                    fileNumStr = ['00' fileNumStr];
                elseif length(fileNumStr) == 2
                    fileNumStr = ['0' fileNumStr];
                end
                
                key.file_num = str2num(fileNumStr);
                tuple.file_num = str2num(fileNumStr);
                tuple.filename = w(i).name
                
                [dat, sets] = patch.utils.readPatchStimHD5(getLocalPath([p '/' tuple.filename]));
                
                
                %%
                [datT, datStart] = patch.utils.ts2sec(dat.ts);
                tuple.total_time = floor(max(datT));
                tuple.is_dualpatch = length(fetch(patch.Cell & key))-1;
                tuple.has_led = any(dat.led > 3);
                
                [~, detectedFlipNums] = ne7.dsp.FlipCode.whichFlips(dat.syncPd, 1/median(diff(datT)));
                if all(isnan(detectedFlipNums))
                    tuple.has_vis = 0;
                else
                    tuple.has_vis = 1;
                end
                tuple.has_ball = ~isempty(dat.ball);
                tuple.has_whisking =~isempty(dat.cam1ts);
                tuple.has_eyetracking = ~isempty(dat.cam2ts);
                tuple.has_scan = any(~cellfun('isempty',(regexp({w(i).name},['scan' fileNumStr '.tif$|scan' fileNumStr '_\d{3}.tif$']))));
                
                
                tuple.has_estim = 0;
                if ~isempty(fetch(patch.Cell & key & 'amp=1')) && ~strcmp(fetch1(patch.Cell & key & 'amp=1','patch_type'),'none')
                    tuple.has_estim = anyEstim(dat.i1,datT);
                end
                if ~isempty(fetch(patch.Cell & key & 'amp=2')) && ~strcmp(fetch1(patch.Cell & key & 'amp=2','patch_type'),'none')
                    tuple.has_estim = tuple.has_estim || anyEstim(dat.i2,datT);
                end
                
                self.insert(tuple);
                
                %% put camera, ephys and ball on same timebase
                
                if tuple.has_ball
                    [ballT, ballStart] = patch.utils.ts2sec(dat.ball(:,2));
                else
                    ballT=nan; ballStart=nan;
                end
                
                if tuple.has_whisking
                    [whiskT, whiskStart] = patch.utils.ts2sec(dat.cam1ts);
                else
                    whiskT=nan; whiskStart=nan;
                end
                
                if tuple.has_eyetracking
                    [eyeT, eyeStart] = patch.utils.ts2sec(dat.cam2ts);
                else
                    eyeT=nan; eyeStart=nan;
                end
                
                minStart = min([datStart ballStart whiskStart eyeStart]);
                datT = datT + datStart - minStart;
                ballT = ballT + ballStart - minStart;
                whiskT = whiskT + whiskStart - minStart;
                eyeT = eyeT + eyeStart - minStart;
                
                %% populate subtables
                if tuple.has_vis
                    disp('Making Sync tuples...');
                    makeTuples(patch.Sync, key, dat.syncPd, datT)
                    
                end
                
                if tuple.has_led
                    disp('Making Led tuples...');
                    makeTuples(patch.Led, key, dat.led, datT)
                end
                
                if tuple.has_ball
                    disp('Making Ball tuples...');
                    makeTuples(patch.Ball, key, dat.ball(:,1), ballT);
                end
                
                if tuple.has_whisking
                    disp('Making Whisking tuples...');
                    makeTuples(patch.Whisker, key, whiskT);
                end
                
                if tuple.has_eyetracking
                    disp('Making Eyetracking tuples...');
                    makeTuples(patch.Eye, key, eyeT);
                end
                
                if ~isempty(fetch(patch.Cell & key & 'amp=1')) 
                    key.amp=1;
                    disp('Making Ephys tuples for amplifier 1...');
                    makeTuples(patch.Ephys, key, dat.i1, dat.v1, datT, sets(1));
                    %makeTuples(patch.Quality, key, dat.i1, dat.v1, datT);
                    if tuple.has_estim
                        disp('Making Estim tuples for amplifier 1...');
                        makeTuples(patch.Estim, key, dat.i1, dat.v1, datT);
                    end
                    key = rmfield(key,'amp');
                end
                if ~isempty(fetch(patch.Cell & key & 'amp=2')) 
                    key.amp=2;
                    disp('Making Ephys tuples for amplifier 2...');
                    makeTuples(patch.Ephys, key, dat.i2, dat.v2, datT, sets(2));
                    %makeTuples(patch.Quality, key, dat.i2, dat.v2, datT);
                    if tuple.has_estim
                        disp('Making Estim tuples for amplifier 2...');
                        makeTuples(patch.Estim, key, dat.i2, dat.v2, datT);
                    end
                    key = rmfield(key,'amp');
                end
                disp('Finished file...')
            end
        end
    end
end


function hasEstim = anyEstim(I,ts)
% arguments: I, current signal; ts, time in sec
% returning: hasEstim, 1 is has electrical stimulation, 0 is not.
% detect whether there are current pulses.
diffI = diff(I);
thresh = 6*std(diffI);
fs = 1/median(diff(ts));
burstWin = 1/10; % 10Hz

% find onsets and offsets of current pulses
onInd = find(diffI>thresh);
offInd = find(diffI<-thresh);

% remove sequential samples
onInd(diff(onInd)==1)=[];
offInd(diff(offInd)==1)=[];

% make sure we still have some
if isempty(offInd) || isempty(onInd)
    hasEstim=0;
    return
end

% remove any preceeding offs
while offInd(1) < onInd(1)
    offInd(1)=[];
    if isempty(offInd) 
        hasEstim=0;
        return
    end
end

% only keep matched offs and ons
k=1;on=[];off=[];
for i=1:length(onInd)
    if i<length(onInd)
        next = onInd(i+1);
    else
        next = length(diffI);
    end
    offs = offInd(offInd > onInd(i) & offInd < next);
    if length(offs) == 1
        on(k) = onInd(i);
        off(k) = offs;
        k=k+1;
    elseif length(offs) > 1
        on(k) = onInd(i);
        off(k) = offs(1);
        k=k+1;
    end
end

% remove any offs and ons separated by less than 1ms
shorts = find(ts(off)-ts(on)<.001);
on(shorts)=[];
off(shorts)=[];

hasEstim = ~isempty(on);
end

