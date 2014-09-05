function varargout = OriTuningVm(varargin)
%h = OriTuningVm(key)
%
% Plots orientation tuning of Vm for OriTrials

[v,dur,preblank, dir] = fetchn(patch.PeriOriTrial * patch.OriTrial & varargin,'peri_ori_vm','ori_dur','preblank','direction');

cond = unique([dur preblank],'rows');

[dirs,~,dirInd] = unique(dir);
tuning = zeros(size(dirs));
tuningStd = zeros(size(dirs));
tuningN = zeros(size(dirs));
for i=1:size(cond,1)
    ix = dur==cond(i,1) & preblank==cond(i,2);
    vMat = cellfun(@(x) x(1:min(cellfun(@length,v(ix)))),v(ix),'uniformoutput',0);
    vMat = [vMat{:}];
    if abs(median(vMat)<1)
        vMat = vMat * 1000;
    end
    [dirs,~,dirInd] = unique(dir);
    dirInd = dirInd(ix);
    
    ix = find(ix,1,'first');
    len = size(vMat,1);
    t = 2*preblank(ix) + dur(ix);
    ix = round(preblank(ix)/t * len) : round((preblank(ix)+dur(ix))/t * len);
    vMean = mean(vMat(ix,:));
    tuning = tuning + accumarray(dirInd,vMean,[],@mean);
    tuningStd = tuningStd + accumarray(dirInd,vMean,[],@std);
    tuningN = tuningN + accumarray(dirInd,ones(size(vMean)));
end

tuning = tuning / size(cond,1);
tuningStd = tuningStd / size(cond,1);

h=[];
if ~isempty(tuning)
    h(1) = plot(dirs,tuning,'o');
    %h = errorbar(dirs,tuning,tuningStd./sqrt(tuningN));
    
    von = fit(ne7.rf.VonMises2, tuning);
    F = von.compute(von.phi);
    hold on
    h(2) = plot(dirs,F);
    
    von = fit(ne7.rf.VonMises2, tuning);
    theta = linspace(min(dirs),max(dirs),length(dirs)*3);
    F = von.compute(theta/180*pi);
    hold on
    h(2) = plot(theta,F);
    
%     e = exp(1i*pi*dirs/90)/sqrt(length(dirs));
%     b = tuning'*e;
%     F = real(2*b*e') + mean(tuning);
%     h(3) = plot(dirs,F);
    
    %pref_dir  = von.w(5);
    %sharpness = von.w(4);
    %peak_amp1 = von.w(2);
    %peak_amp2 = von.w(3);
    %von_base  = von.w(1)
end

if nargout
    varargout{1}=h;
end
