function varargout = OriTuningSpk(varargin)
%h = OriTuningSpk(key)
%
% Plots orientation tuning of spikes for OriTrials

[s,dur,preblank, dir] = fetchn(patch.PeriOriTrial * patch.OriTrial & varargin,'peri_ori_spk','ori_dur','preblank','direction');

cond = unique([dur preblank],'rows');

[dirs,~,dirInd] = unique(dir);
tuning = zeros(size(dirs));
tuningStd = zeros(size(dirs));
tuningN = zeros(size(dirs));
for i=1:size(cond,1)
    ix = dur==cond(i,1) & preblank==cond(i,2);
    sMat = cellfun(@(x) x(1:min(cellfun(@length,s(ix)))),s(ix),'uniformoutput',0);
    sMat = [sMat{:}];
    
    [dirs,~,dirInd] = unique(dir);
    dirInd = dirInd(ix);
    
    ix = find(ix,1,'first');
    len = size(sMat,1);
    t = 2*preblank(ix) + dur(ix);
    trialDur = dur(ix);
    
    ix = round(preblank(ix)/t * len) : round((preblank(ix)+dur(ix))/t * len);
    sHz = sum(sMat(ix,:))/trialDur;
    tuning = tuning + accumarray(dirInd,sHz,[],@mean);
    tuningStd = tuningStd + accumarray(dirInd,sHz,[],@std);
    tuningN = tuningN + accumarray(dirInd,ones(size(sHz)));
end

tuning = tuning / size(cond,1);
tuningStd = tuningStd / size(cond,1);

%h = plot(dirs,tuning);
%h = errorbar(dirs,tuning,tuningStd./ sqrt(tuningN));

h=[];
if ~isempty(tuning)
    h(1) = plot(dirs,tuning,'o');
    %h = errorbar(dirs,tuning,tuningStd./sqrt(tuningN));
    
    von = fit(ne7.rf.VonMises2, tuning);
    theta = linspace(min(dirs),max(dirs),length(dirs)*3);
    F = von.compute(theta/180*pi);
    hold on
    %h(2) = plot(theta,F);
    
    for i=unique(dirInd)'
        dirHz=sHz(dirInd==i);
        dirBootHz(:,i) = bootstrp(1000,@mean,dirHz);
    end
    
    clear F;
    for i=1:1000
        dispEvery(i,100)
        von = fit(ne7.rf.VonMises2, dirBootHz(i,:)');
        F(:,i) = von.compute(theta/180*pi);
    end
    h(2) = errorbar(theta, mean(F,2),std(F,[],2)/mean(tuningN));
    h(3) = plot(theta, quantile(F',.05),'linestyle','--');
    h(4) = plot(theta, quantile(F',.95),'linestyle','--');
    
    
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
