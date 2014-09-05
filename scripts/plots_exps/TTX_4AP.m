key.animal_id = 1482;
key.slice_id = 1;
key.cell_id = 2;

key_non = fetch(slicepatch.TraceVC & key & 'trace_idx=7','*');

key_TTX = fetch(slicepatch.TraceVC & key & 'trace_idx=6','*');

key_TTX_4AP = fetch(slicepatch.TraceVC & key & 'trace_idx=5','*');

time = key_non.time;
trace_non = key_non.trace - key_non.baseline;
trace_TTX = key_TTX.trace - key_TTX.baseline;
trace_TTX_4AP = key_TTX_4AP.trace - key_TTX_4AP.baseline;

fig = Figure(101,'size',[60,45]); hold on
plot(time, trace_non, 'k')
plot(time, trace_TTX, 'r')
plot(time, trace_TTX_4AP, 'g')

legend('None', 'TTX', 'TTX+4AP')

plot(300:302, [25,25,25], 'b','LineWidth', 5);
plot(600:650, -150*ones(1,length(600:650)), 'k')
plot(600*ones(1,length(-250:-150)), -250:-150, 'k')

fig.cleanup; fig.save('/Volumes/lab/users/V2_project/FineResults/summary/epsc_wdrug_exp')
