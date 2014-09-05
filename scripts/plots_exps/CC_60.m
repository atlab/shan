key.animal_id = 3349;
key.slice_id = 1;
key.cell_id = 2;

key_60 = fetch(slicepatch.TraceCC & key & 'trace_idx=1','*');


time = key_60.time;
trace = key_60.trace;

fig = Figure(101,'size',[60,45]); hold on
plot(time, trace, 'k')

plot(100:0.5:102, -61*ones(1,length(100:0.5:102)), 'b','LineWidth', 5);
plot(200:250, -61*ones(1,length(200:250)), 'k')
plot(200*ones(1,length(-61.5:0.05:-61)), -61.5:0.05:-61, 'k')

fig.cleanup; fig.save('/Volumes/lab/users/Shan/V2_project/FineResults/summary/cc_60_2')
