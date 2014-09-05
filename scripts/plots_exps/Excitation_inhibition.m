key.animal_id = 1482;
key.slice_id = 1;
key.cell_id = 6;

key_exc = fetch(slicepatch.TraceVC & key & 'trace_idx=6','*');
key_inh = fetch(slicepatch.TraceVC & key & 'trace_idx=2','*');


time = key_exc.time;
trace_exc = key_exc.trace - key_exc.baseline;
trace_inh = key_inh.trace - key_inh.baseline;

fig = Figure(101,'size',[60,45]); hold on
plot(time, trace_exc, 'k')
plot(time, trace_inh+50, 'r')

legend('EPSC','IPSC');

plot(300:302, [25,25,25], 'b','LineWidth', 5);
plot(600:650, -150*ones(1,length(600:650)), 'k')
plot(600*ones(1,length(-250:-150)), -250:-150, 'k')

fig.cleanup; fig.save('/Volumes/lab/users/Shan/V2_project/FineResults/summary/epsc-ipsc-pyr')
