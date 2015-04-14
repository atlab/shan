function PeriLedFiring(func,varargin)
% PeriLedFiring, raster plot of spike trains, with LED on or off.

if strcmp(func,'on')
    table = 'slicepatch.PeriLed';
else
    table = 'slicepatch.PeriLedOff';
end
fig = Figure(103,'size', [90,60]); hold on
baseline = 0;
animal_restrict = fetch(common.Animal  & 'animal_id!=3024' & 'owner="Shan"' &  'line!="WFS1-Cre"' & 'line!="Etv1-Cre"');
keys_restrict = fetch(slicepatch.PeriLed & 'peri_led_delay>49' & 'peri_led_delay<151');
keys_cell = fetch(slicepatch.Cell & animal_restrict & keys_restrict & 'cell_type_morph="pyr"'& varargin)';
% key_temp = fetch(eval(table) & keys_cell);
% key_temp = fetch(eval(table)&key_temp(1),'*');
for key = keys_cell
    keys = fetch(eval(table) & key & 'peri_led_delay>49' & 'peri_led_delay<151')';

    if ~isempty(keys)
        baseline = baseline + 100;
        
    else
        continue
    end
    for key2 = keys
        trace = fetch(eval(table) & key2, '*');
        baseline = baseline+3;
        plot(trace.peri_led_time(logical(trace.peri_led_spk)),baseline,'k.','markersize',3);
    end

end
ylim([0,6000]);
yLim = get(gca,'YLim');
h = patch([0,20,20,0],[yLim(1) yLim(1),yLim(2),yLim(2)],'c'); xlim([-50,100])
uistack(h,'bottom');
fig.cleanup; 
fig.save('firing_on')