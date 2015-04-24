function h = Vm(varargin)
% h = patch.plot.Vm(key)
%
% h: handle(s) to lines

% assert(length(fetch(patch.Recording & varargin))==1, 'One recording at a time please.');

c = {'k','b'};

key = fetch(patch.Ephys & varargin);

for i=1:length(key)
    
    [vt,vm,fs] = patch.utils.cleanVm(key(i));
    if ~patch.utils.isWholeCell(fetch(patch.Ephys & key(i)))
        vm = ezfilt(vm,150,fs,'high');
    end
    fig = Figure(101,'size',[160,120]); hold on
    plot(vt,vm*1000,c{key(i).amp});
    
    % mark led stimulation
    led = fetch1(patch.LedSet & key(i), 'led_trace');
    
    scale = nanstd(vm);
    baseline = min(vm) - scale;
    
    scaled_led = (led - min(led))/(max(led)-min(led));
    plot(vt,(scaled_led*scale+baseline)*1000)
    
%     idx_led = scaled_led>0.2;
%     plot(vt(idx_led),vm(idx_led)*1000,'b','LineStyle','None','Marker','.','MarkerSize',1.5);
%     h1 = plot([39.2,39.7],[-20,-20],'k');
%     h2 = plot([39.2,39.2],[-20,0],'k');
%     ylim([-100,20]); xlim([31.5,39.7]);
    % mark visual stimuli
    key_trials = fetch(patch.Trial & key,'*');
    directions = unique([key_trials.direction]);
    colors = colormap;
    color_idx = round(linspace(1,length(colors),length(directions)));
    colorref = min(colors(color_idx,:)+0.65,1);
    yLim = get(gca,'ylim');
    for iKey = key_trials'
        ind = find(directions==iKey.direction);
        onset = iKey.trial_onset;
        dur = iKey.trial_duration;
        offset = onset+dur;
        h = patch([onset,offset,offset,onset],[yLim(1),yLim(1),yLim(2),yLim(2)],colorref(ind,:),'LineStyle','None');
        uistack(h,'bottom');
        if onset>225  && onset<230
            iKey.direction
        end
    end
    
    fig.cleanup
    
end