function varargout = cleanVm(key)
% 
% Replace electrical stimulation artifacts and epochs where patch.Quality = 0 with nans
%
% vm = cleanVm(key)
% [vt,vm] = cleanVm(key)
% [vt,vm,fs] = cleanVm(key)


% Fetch uncleaned vm
[vt,vm,fs] = fetch1(patch.Ephys & key,'ephys_time','vm','ephys_fs');

% Fetch manual quality trace
if isempty(fetch(patch.Quality & key))
    quality=[];
else
    quality = fetch1(patch.Quality & key,'quality');
end

% Fetch any electrical stimulation pulses
if ~exist('patch.Estim', 'class')
    stimOn = [];
elseif isempty(fetch(patch.Estim & key))
    stimOn = [];
else
    [stimOn,stimDur] = fetchn(patch.Estim & key,'estim_on','estim_dur');
end

dt=1/fs;

% Replace quality = 0 epochs with nans
bad = makeEpochs(quality==0);
for i=1:size(bad,1)
    ind = ts2ind(bad(i,1),vt,dt,'extrap'):ts2ind(bad(i,2),vt,dt,'extrap');
    vm(ind)=nan;
end

% Replace stimulation periods with nans

% changed by Shan 4/10/15
% stimPad = .025; % sec
% for i=1:length(stimOn)
%     ind = ts2ind(stimOn(i) - stimPad, vt,dt) : ts2ind(stimOn(i) + stimDur(i) + stimPad, vt, dt);
%     vm(ind) = nan;
% end

% Assign outputs
if nargout == 1
    varargout{1}=vm;
elseif nargout==2
    varargout{1}=vt;
    varargout{2}=vm;
elseif nargout==3
    varargout{1}=vt;
    varargout{2}=vm;
    varargout{3}=fs;
end
    
