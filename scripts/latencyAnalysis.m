% latencies of all the traces
slices = fetch(slicepatch.Slice & 'drug_applied=0'); 
traces = fetch(slicepatch.CurrentProperties & slices & 'vm>0' & 'res=1' & 'latency between 0 and 20','*');

fig1 = Figure(101,'size',[80,50]); 
hist([traces.latency],15);
h = findobj(gca,'Type','patch'); set(h,'FaceColor','w');
xlabel('latency(ms)'); ylabel('cell number')
fig1.cleanup; fig1.save('latency_histogram_all');

% latencies for traces approved by the drugs
slices_drug = fetch(slicepatch.Slice & 'drug_applied=1');

traces_4AP = fetch(slicepatch.CurrentProperties & slices_drug & 'ap4=1' & 'latency>0' & 'res=1');

cells = fetch(slicepatch.Cell & traces_4AP);

latencies = fetchn(slicepatch.CurrentProperties & cells & struct('cnqx',0,'apv',0,'ttx',0,'ap4',0) & 'vm>0' & 'latency>0' & 'res=1','latency');

fig2 = Figure(102,'size',[80,50]); hist([latencies],10); h = findobj(gca,'Type','patch'); set(h,'FaceColor','w');
xlim([0,20]); xlabel('latency(ms)'); ylabel('cell number')
fig2.cleanup; fig2.save('latency_histogram_4AP');


% inhibitory latency
 
traces = fetch(slicepatch.CurrentProperties & slices & 'vm=0' & 'res=1' & 'latency between 0 and 20','*');

fig3 = Figure(103,'size',[80,50]); 
hist([traces.latency],15);
h = findobj(gca,'Type','patch'); set(h,'FaceColor','w');
xlabel('latency(ms)'); ylabel('cell number')
fig3.cleanup; fig3.save('latency_IPSC_all');