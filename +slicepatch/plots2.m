classdef plots2
    
    
    properties(Constant)
        read_dir = getLocalPath('Y:/Shan/PatchInVitro_matlab/');
        save_dir = getLocalPath('Y:/Shan/PatchInVitro_matlab/plots/');
    end
    
      
    methods(Static)
            
        function showTrace_cc(slice, cell_id, stim_num, clamp)
            % get parameters
%             slice = input('Enter slice name: ');
%             cell_id = input('Enter cell id: ');
%             animal_id = input('Enter animal id: ');
%             clamp = input('Enter clamping voltage');
            
            data = xlsread([slicepatch.plots.read_dir slice '/' slice '.xls'], ['CC' num2str(clamp)]);
            idx = cell_id*2+stim_num-1;
            trace = data(:,idx);
            trace = trace(~isnan(trace));
            trace(1)*1000
            trace = (trace - trace(1))*1000;
            trace = smooth(trace);
            time = data(:,1);
            time = time(1:length(trace));
            figure; plot(time, trace);
            set(gcf, 'Position', get(gcf, 'Position').*[1,1,0.35,0.5]);
            xlim([50,300]); ylim([-5,20]);
           
%             [t_peak, amp] = ginput(1);
%             [t_latency, amp2] = ginput(1);
%             amp
%             latency = t_latency-100
%             rise_time = t_peak - t_latency

            
        end
        function showTrace_vc(slice, cell_id, stim_num, clamp)
            % get parameters
%             slice = input('Enter slice name: ');
%             cell_id = input('Enter cell id: ');
%             animal_id = input('Enter animal id: ');
%             clamp = input('Enter clamping voltage');
            
            data = xlsread([slicepatch.plots.read_dir slice '/' slice '.xls'], ['VC' num2str(clamp)]);
            idx = cell_id*2+stim_num-1;
            trace = data(:,idx);
            trace = trace(~isnan(trace));
            trace = (trace - trace(1))*1e12;
            trace = smooth(trace);
            time = data(:,1);
            time = time(1:length(trace));
            figure; plot(time, trace);
            set(gcf, 'Position', get(gcf, 'Position').*[1,1,0.35,0.5]);
            xlim([0,400]); ylim([-1300,100]);
            
%             [t_peak, amp] = ginput(1);
%             [t_latency, amp2] = ginput(1);
%             amp
%             latency = t_latency-100
%             rise_time = t_peak - t_latency
%             
            
        end
        function Connectivity(varargin)
            % compute the connectivity of different cell types
            conn = zeros(1,length(varargin));
            for ii = 1:length(varargin)
                type = varargin{ii};
                keys_all = fetch(slicepatch.Cell & ['cell_type_gene="' type '"']);
                keys_act = fetch(slicepatch.Recording & keys_all & '0<latency<7' & 'psc_amp>0' & 'voltage<=-70' & 'stim_num=1' & 'recording_type="VC"');
                keys_act = fetch(slicepatch.Cell & keys_act);
                conn(ii) = length(keys_act)/length(keys_all);
               
            end
            figure; bar(conn,0.5, 'y'); set(gca, 'XtickLabel', {'pyr', 'PV', 'SST','VIP'});
            ylabel('Percentage of response'); ylim([0,1]);
        end
        
        function Connectivity_psp(varargin)
            % compute the connectivity of different cell types
            conn = zeros(1,length(varargin));
            for ii = 1:length(varargin)
                type = varargin{ii};
                keys = fetch(slicepatch.Slice & 'internal_solution="K"');
                keys_all = fetch(slicepatch.Cell & ['cell_type_gene="' type '"'] & keys);
                keys_act = fetch(slicepatch.Recording & keys_all & '0<latency<7' & 'psp_amp>0' & 'voltage=-70' & 'stim_num=1' & 'recording_type="CC"');
                keys_act = fetch(slicepatch.Cell & keys_act);
                conn(ii) = length(keys_act)/length(keys_all);
               
            end
            figure; bar(conn,0.5, 'y'); set(gca, 'XtickLabel', {'pyr', 'PV', 'SST','VIP'});
            ylabel('Percentage of response'); ylim([0,1]);
        end
        
        function [amp_mean,amp_std,ampMat] = Amplitude_psp(type)
            keys_all = fetch(slicepatch.Cell & ['cell_type_gene="' type '"'] );
            keys_act = fetch(slicepatch.Recording & keys_all & '0<latency<6' & 'voltage=-70' & 'stim_num=1' & 'recording_type="CC"' & 'psp_amp>0.1');
            cnt = 0;
            for ii = keys_act'
                % fetch the value of amplitude
                amp = fetch1(slicepatch.Recording & ii, 'psp_amp');
                % fetch the layer of the cell
                layer = fetch1(slicepatch.Cell & ii, 'cell_layer');
                % fetch the amplitude value of the pyramidal cell in the same layer
                i = struct('animal_id', ii.animal_id, 'injection_id', ii.injection_id, 'slice_id', ii.slice_id);
                keys_pyr = fetch(slicepatch.Cell & i & ['cell_layer="' layer '"'] & 'cell_type_gene="pyr"');
                
                if length(keys_pyr)==0 % if no pyramidal cells are recorded in the same layer, search for pyr cell in other layers
                    keys_pyr = fetch(slicepatch.Cell & i & 'cell_type_gene="pyr"');
                end
                
                if length(keys_pyr)
                    amp_pyr = mean(fetchn(slicepatch.Recording & keys_pyr & 'recording_type="CC"' & 'voltage=-70' & 'stim_num=1','psp_amp'));
                    if amp_pyr>0.05 
                        cnt = cnt+1;
                        ampMat(cnt) = amp/amp_pyr;
                    end
                    
                end
                    
            end
            amp_mean = mean(ampMat);
            amp_std = std(ampMat)/sqrt(length(ampMat));
            
        end
        
        function [amp_mean,amp_std,ampMat] = Amplitude_psc(type)
            keys = fetch(slicepatch.Slice & 'internal_solution="K"');
            keys_all = fetch(slicepatch.Cell & ['cell_type_gene="' type '"']);
            keys_act = fetch(slicepatch.Recording & keys_all & '0<latency<7' & 'voltage<=-70' & 'stim_num=1' & 'recording_type="VC"' & 'psc_amp>3');
            cnt = 0;
            for ii = keys_act'
                % fetch the value of amplitude
                amp = fetch1(slicepatch.Recording & ii, 'psc_amp');
                % fetch the layer of the cell
                layer = fetch1(slicepatch.Cell & ii, 'cell_layer');
                % fetch the amplitude value of the pyramidal cell in the same layer
                i = struct('animal_id', ii.animal_id, 'injection_id', ii.injection_id, 'slice_id', ii.slice_id);
                keys_pyr = fetch(slicepatch.Cell & i & ['cell_layer="' layer '"'] & 'cell_type_gene="pyr"');
                
                if length(keys_pyr)==0 % if no pyramidal cells are recorded in the same layer, search for pyr cell in other layers
                    keys_pyr = fetch(slicepatch.Cell & i & 'cell_type_gene="pyr"');
                end
                
                if length(keys_pyr)
                    amp_pyr = mean(fetchn(slicepatch.Recording & keys_pyr & 'recording_type="VC"' & 'voltage=-70' & 'stim_num=1','psc_amp'));
                    if amp_pyr>5 
                        cnt = cnt+1;
                        ampMat(cnt) = amp/amp_pyr;
                    end
                    
                end
                    
            end
            amp_mean = mean(ampMat);
            amp_std = std(ampMat)/sqrt(length(ampMat));
            
        end
        
        function amplitude_all(num)
            amp_all = zeros(1,num);
            err_all = zeros(1,num);
            [amp_mean, amp_std, ampMat_PV] = slicepatch.plots.Amplitude_psp('PV');
            amp_all(1) = amp_mean;
            err_all(1) = amp_std;
            [amp_mean, amp_std, ampMat_SST] = slicepatch.plots.Amplitude_psp('SST');
            amp_all(2) = amp_mean;
            err_all(2) = amp_std;
            if num==3
                [amp_mean, amp_std, ampMat_VIP] = slicepatch.plots.Amplitude_psp('VIP');
                amp_all(3) = amp_mean;
                err_all(3) = amp_std;
            end
            [h,p]=ttest2(ampMat_PV, ampMat_SST)
            
            figure; bar(amp_all,0.3,'w'); hold on
            errorbar(amp_all, err_all, 'k','LineStyle','None');
            plot(ones(length(ampMat_PV)), ampMat_PV, 'ro');
            plot(2*ones(length(ampMat_SST)), ampMat_SST, 'bo');
            if num==3
                plot(3*ones(length(ampMat_VIP)), ampMat_VIP, 'mo');
            end
            set(gca,'XTickLabel', {'PV', 'SST', 'VIP'});
            ylabel('Amplitude of PSP normalized to Pyr');
            ylim([0,20]);
            
            
        end
        
        function EI_scatter(varargin)
            for ii = 1:length(varargin)
                type = varargin{ii};
                slice = fetch(slicepatch.Slice & 'internal_solution="Cs"');
                keys = fetch(slicepatch.Cell & slice &['cell_type_gene="' type '"']);
                
                cnt = 0;
                for key = keys';
                    epsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage<-70', 'psc_amp');
                    ipsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage=0','psc_amp');
                    if length(epsc) && length(ipsc)
                        if epsc && ipsc
                        cnt = cnt+1;
                        epscVec(cnt) = epsc;
                        ipscVec(cnt) = ipsc;
                        end
                    end
                end
                
                figure; scatter(epscVec, ipscVec);
                uplim =1500; xlim([0,uplim]); ylim([0, uplim]);
                hold on; plot(0:0.1:uplim, 0:0.1:uplim);
                xlabel('EPSC(pA)'); ylabel('IPSC(pA)');
                set(gcf, 'Position', get(gcf, 'Position').*[1,1,0.5,0.5])
            end
        end
        function EI_ratio_layer(varargin)
            nTypes = 1;
            mean_ratio = zeros(nTypes,length(varargin));
            std_ratio = zeros(nTypes,length(varargin));
            ratioMat = cell(nTypes,length(varargin));
            for ii = 1:length(varargin)
                epscVec=0;
                ipscVec=0;
                type2 = 'pyr';
                type = varargin{ii};
                slice = fetch(slicepatch.Slice & 'internal_solution="Cs"');
                keys = fetch(slicepatch.Cell & slice &['cell_type_gene="' type2 '"'] & ['cell_layer="' type '"']);
                
                cnt = 0;
                for key = keys';
                    epsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage<-70', 'psc_amp');
                    ipsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage=0','psc_amp');
                    if length(epsc) && length(ipsc)
                        if epsc && ipsc
                        cnt = cnt+1;
                        epscVec(cnt) = epsc;
                        ipscVec(cnt) = ipsc;
                        end
                    end
                end
                ratio = (ipscVec-epscVec)./(epscVec+ipscVec);
                ratioMat{1,ii} = ratio;
                mean_ratio(1,ii) = mean(ratio);
                std_ratio(1,ii) = std(ratio)/sqrt(length(ratio));
                
%                 type2 = 'PV';
%                 keys = fetch(slicepatch.Cell & slice &['cell_type_gene="' type2 '"'] & ['cell_layer="' type '"']);
%                 epscVec=0;
%                 ipscVec=0;
%                 cnt = 0;
%                 
%                 for key = keys';
%                     epsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage<-70', 'psc_amp');
%                     ipsc = fetchn(slicepatch.Recording & key & 'recording_type = "VC"' & 'stim_num=1' & 'voltage=0','psc_amp');
%                     if length(epsc) && length(ipsc)
%                         if epsc && ipsc
%                         cnt = cnt+1;
%                         epscVec(cnt) = epsc;
%                         ipscVec(cnt) = ipsc;
%                         end
%                     end
%                 end
%                 ratio = (ipscVec-epscVec)./(epscVec+ipscVec);
%                 ratioMat{2,ii} = ratio;
%                 mean_ratio(2,ii) = mean(ratio);
%                 std_ratio(2,ii) = std(ratio)/sqrt(length(ratio));
                
            end
            fig = Figure(101,'size',[50,40]);
            
            barwitherr(std_ratio',mean_ratio'); set(gca, 'XTickLabel', {'L23','L5'}); ylim([-1,1]); ylabel('(IPSC-EPSC)/(IPSC+EPSC)');
            fig.cleanup; fig.save('EIratio.eps');
%             legend('pyr','PV');
           
        end
        function Proportion
            keys_cell = fetch(slicepatch.Cell & 'cell_layer="L23"' & 'cell_type_gene="pyr"' );
            keys = fetch(slicepatch.FineTraceCC & keys_cell & 'baseline<-55' & 'baseline>-65');
            
            cnt_exc = 0; cnt_inh = 0; ratioMat1 = zeros(1,length(keys)); 
            ii = 0;
            for key = keys'
                ii = ii+1;
                [exc, inh, ratio] = fetch1(slicepatch.CurrentProperties & key, 'res_exc', 'res_inh','eiratio');
                if exc
                    cnt_exc = cnt_exc + 1;
                end
                if inh
                    cnt_inh = cnt_inh + 1;
                end
                if ratio==-100000
                    ratio=-1;
                end
                ratioMat1(ii) = ratio;
            end
            prop_exc(1) = cnt_exc/length(keys); prop_inh(1) = cnt_inh/length(keys);
            keys_cell = fetch(slicepatch.Cell & 'cell_layer="L5"' & 'cell_type_gene="pyr"' );
            keys = fetch(slicepatch.FineTraceCC & keys_cell & 'baseline<-55' & 'baseline>-65');
            
            cnt_exc = 0; cnt_inh = 0; ratioMat2 = zeros(1,length(keys));
            for key = keys'
                [exc, inh, ratio] = fetch1(slicepatch.CurrentProperties & key, 'res_exc', 'res_inh', 'eiratio');
                if exc
                    cnt_exc = cnt_exc + 1;
                end
                if inh
                    cnt_inh = cnt_inh + 1;
                end
                if ratio==-100000
                    ratio = -1;
                end
                ratioMat2(ii) = ratio;
            end
            prop_exc(2) = cnt_exc/length(keys); prop_inh(2) = cnt_inh/length(keys);
            fig1 = Figure(101,'size',[60,40]);
            bar(prop_exc,0.5); set(gca,'XTickLabel',{'L23','L5'});
            fig1.cleanup; fig1.save('exc_proportion.eps');
            fig2 = Figure(102,'size',[60,40]);
            bar(prop_inh,0.5);set(gca,'XTickLabel',{'L23','L5'});
            fig2.cleanup; fig2.save('inh_proportion.eps');
            fig3 = Figure(103,'size',[60,40]);
            mean1 = mean(ratioMat1); sem1 = std(ratioMat1)/sqrt(length(ratioMat1));
            mean2 = mean(ratioMat2); sem2 = std(ratioMat2)/sqrt(length(ratioMat2));
            bar([mean1,mean2], 0.5); hold on; set(gca, 'XTickLabel',{'L23','L5'});
            errorbar([mean1,mean2],[sem1, sem2],'LineStyle','None'); ylim([-1,1]);
            fig3.cleanup; fig3.save('eiratio_CC.eps');
            
        end
        
        function amp_hist(varargin)
            for ii = 1:length(varargin)
                type = varargin{ii};
                slice = fetch(slicepatch.Slice & 'internal_solution = "K"');
                keys = fetch(slicepatch.Cell & slice & ['cell_type_gene="' type '"']);
                epsp = fetchn(slicepatch.Recording & keys & 'recording_type="CC"' & 'stim_num=1' & 'voltage = -70','psp_amp');
                figure; hist(epsp,10);
                xlabel('EPSP amplitude (mV)'); ylabel('Cell Counts'); xlim([-2,25]); ylim([0,25])
                set(gcf, 'Position', get(gcf, 'Position').*[1,1,0.3,0.5]);
            end
        end
        
        function slice_summary(varargin)
            for key = fetch(slicepatch.Slice & varargin)'
                mode = input('Please enter the mode you want: ', 's');
                voltage = input('Please enter the membrane voltage:');
                nLed = input('Please enter the number of led stimuli:');
                key_res = fetch(slicepatch.TraceCondCC & key & ['nled=' num2str(nLed)]);
                
                if strcmp(mode, 'VC')
                    if voltage==-70
                        cells = fetch(slicepatch.TraceVC & key & 'vm=-70','*');
                    elseif voltage==-60
                        cells = fetch(slicepatch.TraceVC & key & 'vm=-60', '*');
                    else
                        error('The input voltage is not valid!');
                    end
                    figure; set(gcf,'Position', get(201, 'Position').*[1,1,2,1]);
                     
                    for ii = 1:length(cells)
                        h(ii) = subplot(2,4,cells(ii).cell_id);
                        plot(cells(ii).time, cells(ii).trace - cells(ii).baseline,'k');hold on
                        time_led = cells(ii).time(cells(ii).led==1);
                        plot(time_led,zeros(size(time_led)),'b.');
                        box off
                        key_temp = key;
                        key_temp.cell_id = cells(ii).cell_id;
                        cell_type = fetch1(slicepatch.Cell & key_temp, 'cell_type_gene');
                        cell_layer = fetch1(slicepatch.Cell & key_temp, 'cell_layer');
                        title(['Cell ' num2str(cells(ii).cell_id) '-' cell_layer ' ' cell_type]);
                        ylabel('time/ms','FontSize',12); xlabel('current/pA','FontSize',12);
                    end
                    linkaxes(h); ylim([-200,50]);
                    set(gcf,'Name',key2str(key))
                end
                if strcmp(mode, 'CC')
                    if voltage==-70
                        cells = fetch(slicepatch.FineTraceCC & key & key_res & 'baseline<-65' & 'baseline>-75','*');
                        
                    elseif voltage==-60
                        cells = fetch(slicepatch.FineTraceCC & key & key_res & 'baseline<-55' & 'baseline>-65', '*');
                    else
                        error('The input voltage is not valid!');
                    end
                    figure; set(gcf,'Position', [1,1,1000,300]);
                    clf
                    for ii = 1:length(cells)
                        h(ii) = subplot(2,4,cells(ii).cell_id);
                        plot(cells(ii).time, cells(ii).finetrace - cells(ii).baseline,'k');hold on
                        time_led = cells(ii).time(cells(ii).led==1);
                        plot(time_led,zeros(size(time_led))-1,'b.');
                        box off
                        key_temp = key;
                        key_temp.cell_id = cells(ii).cell_id;
                        cell_type = fetch1(slicepatch.Cell & key_temp, 'cell_type_gene');
                        cell_layer = fetch1(slicepatch.Cell & key_temp, 'cell_layer');
                        title(['Cell ' num2str(cells(ii).cell_id) '-' cell_layer ' ' cell_type]);
                        
                    end
                    linkaxes(h); ylim([-3,5]);
                    set(gcf,'Name',key2str(key))
                end
                
            end
        end
        
        function FiringTrace_on(varargin)
            keys = fetch(slicepatch.Firing & varargin & 'led_stat=1')';
            for key = keys
                trace = fetch(slicepatch.Firing & key, '*');
                figure; set(gcf, 'Position',[500,800,250,100]);
                plot(trace.time, trace.trace,'k');
                idx1 = find(diff(trace.led)==1);
                idx2 = find(diff(trace.led)==-1);
                Ylim = get(gca, 'YLim');
                h = patch([trace.time(idx1),trace.time(idx2),trace.time(idx2),trace.time(idx1)],[Ylim(1) Ylim(1),Ylim(2),Ylim(2)],'c');
                xlim([0,400])
                uistack(h,'bottom');
                key
                in=input('Press Enter to continue:');
                
                if isempty(in)
                    continue
                else
                    break
                end
            end
            
        end
        function FiringTrace_off(varargin)
            keys = fetch(slicepatch.Firing & varargin & 'led_stat=0')';
            for key = keys
                trace = fetch(slicepatch.Firing & key, '*');
                figure; set(gcf, 'Position',[500,800,250,100]);
                plot(trace.time, trace.trace,'k');
                idx1 = find(diff(trace.led)==1);
                idx2 = find(diff(trace.led)==-1);
                Ylim = get(gca, 'YLim');
                h = patch([trace.time(idx1),trace.time(idx2),trace.time(idx2),trace.time(idx1)],[Ylim(1) Ylim(1),Ylim(2),Ylim(2)],'c');
                uistack(h,'bottom')
                xlim([0,400])
                key
                in=input('Press Enter to continue:');
                if isempty(in)
                    continue
                else
                    break
                end
            end
            
        end
        function PSTH(varargin)
            keys = fetch(slicepatch.PeriLed & varargin  & 'peri_led_delay>49' & 'peri_led_delay<151')';
            time = -200:0.04:300;
            spkcount = zeros(size(time));
            for key = keys
                trace = fetch(slicepatch.PeriLed & key,'*');
                spk_time = trace.peri_led_time(logical(trace.peri_led_spk));
                for ii = 1:length(spk_time)
                    spkcount(time==spk_time(ii)) = spkcount(time==spk_time(ii))+1;
                end
            end
            dt = 2;
            time_bin = -200:dt:300;
            spkcount_bin = zeros(size(time_bin));
            for ii = 1:length(time_bin)
                idx = (time<=time_bin(ii)+dt/2)&(time>=time_bin(ii)-dt/2);
                spkcount_bin(ii) = sum(spkcount(idx));
            end
            figure; bar(time_bin,spkcount_bin); ylim([0,15]);
            Ylim = get(gca,'YLim');
            h = patch([0,20,20,0],[Ylim(1) Ylim(1),Ylim(2),Ylim(2)],'c');
            uistack(h,'bottom');
            set(gcf, 'Position', [1,1,500,250]);
            xlabel('Time(ms)'); ylabel('Spike counts')
            title('Pyramidal cells-L23')
        end
    end
end