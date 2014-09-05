%{
slicepatch.CellSummary (computed) # summarize the responsiveness of a cell based on all the recordings
-> slicepatch.Cell
-----
response              : tinyint      # whether the cell is responsive to feedback activation, in CC or VC, -1 means the cell is untested
has_norm_epsc         : tinyint      # whether the cell has epsc that can be normalized to L23 pyramidal cells, vm = -70,-80,-85,-90
norm_epsc             : double       # EPSC normalized to L23 pyramidal cells
has_norm_ipsc         : tinyint      # whether the cell has inhibitory current that can be normailzed to L23 pyramidal cells, vm = 0
norm_ipsc             : double       # IPSC normalzied to L23 pyramidal cells
has_eiratio           : tinyint      # whether the cell has both ipsc and ipsc, and not zero
eiratio               : double       # epsc-ipsc/epsc+ipsc, between -1 and 1
has_norm_epsp         : tinyint      # whether the cell has epsp that can be normalized to L23 pyramidal cells, vm = 70mV
norm_epsp             : double       # EPSP normalized to L23 pyramidal cells
has_cc_60             : tinyint      # whether the cell has been recorded in cc model vm = -60
res_exc               : tinyint      # whether the cell has excitation in cc vm = -60. -1 if untested
res_inh               : tinyint      # whether the cell has inhibition in cc vm = -60, -1 if untested
has_ppr_vc            : tinyint      # whether the cell has ppr in vc mode
ppr_vc                : double       # ppr in vc mode
has_ppr_cc            : tinyint      # whether the cell has ppr in cc mode
ppr_cc                : double       # ppr in cc mode
vm                    : double       # clamping voltage of VC recording
latency_threshold_exc : double       # threshold of latency of monosynaptic excitation
latency_threshold_inh : double       # threshold of latency of inhibition

%}

classdef CellSummary < dj.Relvar & dj.AutoPopulate
    
    properties
        popRel = slicepatch.Cell
    end
    
    
	methods(Access=protected)

		function makeTuples(self, key)
            tuple = key;
            % initialize all attributes
            tuple.response = -1;
            tuple.has_norm_epsc = 0;
            tuple.norm_epsc = -1;
            tuple.has_norm_ipsc = 0;
            tuple.norm_ipsc = -1;
            tuple.has_eiratio = 0;
            tuple.eiratio = -2;
            tuple.has_norm_epsp = 0;
            tuple.norm_epsp = -1;
            tuple.has_cc_60 = 0;
            tuple.res_exc = -1;
            tuple.res_inh = -1;
            tuple.has_ppr_vc = 0;
            tuple.ppr_vc = -1;
            tuple.has_ppr_cc = 0;
            tuple.ppr_cc = -1;
            tuple.latency_threshold_exc = 8;
            tuple.latency_threshold_inh = 18;
            tuple.vm = -1000;
            
            % get L23 cells in the same slice
            
            keys_temp = fetch(slicepatch.Slice & key);
            keys_L23 = fetch(slicepatch.Cell & keys_temp & 'cell_type_morph="pyr"' & 'cell_layer="L23"');
            
            % VC properties
            
            keys_rel = fetch(slicepatch.CurrentProperties & key & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0' & 'quality>0');
            
            if ~isempty(keys_rel)
                if tuple.response ==-1
                    tuple.response = 0;
                end
            end
            
            vc_props_60 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm=60' & 'latency>0'  & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res=1');
            
            if ~isempty(vc_props_60)
                tuple.response = 1;
            end
            
            vc_e_existed = 0;
            vc_i_existed = 0;
            vc_props_70 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm>60' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res=1', '*');
            
            if ~isempty(vc_props_70)
                vc_e_existed = 1;
                tuple.response = 1;
                vc_props_L23_exc = fetch(slicepatch.CurrentProperties & keys_L23 & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0' & 'vm>60' & 'quality>0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res=1','*');
                tuple.vm = vc_props_70(1).vm;
                mean_amp_exc = mean([vc_props_70.amp]);
                if ~isempty(vc_props_L23_exc)
                    tuple.has_norm_epsc = 1;
                    
                    mean_amp_exc_L23 = mean([vc_props_L23_exc.amp]);
                    tuple.norm_epsc = mean_amp_exc/mean_amp_exc_L23;
                end
            end
            
            vc_props_0 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm=0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_inh)] & 'res=1', '*');
            
            if ~isempty(vc_props_0)
                vc_i_existed = 1;
                vc_props_L23_inh = fetch(slicepatch.CurrentProperties & keys_L23 & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0' & 'vm=0' & 'quality>0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_inh)] & 'res=1','*');
                mean_amp_inh = mean([vc_props_0.amp]);
                if ~isempty(vc_props_L23_inh)
                    tuple.has_norm_ipsc = 1;
                    
                    mean_amp_inh_L23 = mean([vc_props_L23_inh.amp]);
                    tuple.norm_ipsc = mean_amp_inh/mean_amp_inh_L23;
                end
            end
            
            if vc_e_existed && vc_i_existed
                tuple.has_eiratio = 1;
                tuple.eiratio = (mean_amp_exc - mean_amp_inh)/(mean_amp_exc + mean_amp_inh);
            end
            
            % ppr vc
            vc_props_ppr = fetch(slicepatch.CurrentProperties & keys_rel & 'vm>60' & 'quality>0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'ppr>0','*');
            
            if ~isempty(vc_props_ppr)
                tuple.has_ppr_vc = 1;
                tuple.ppr_vc = vc_props_ppr(1).ppr;
            end
            
            % CC properties
            keys_rel = fetch(slicepatch.VoltageProperties & key & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0');
            
            
            if ~isempty(keys_rel)
                if tuple.response==-1
                    tuple.response = 0;
                end
            end
            
            keys_rel_cc = fetch(slicepatch.TraceCC & keys_rel & 'baseline<-55' & 'baseline>-65');
            cc_props_60 = fetch(slicepatch.VoltageProperties & keys_rel_cc);
            
            if ~isempty(cc_props_60)
                tuple.has_cc_60 = 1;
            end
             
            cc_props_60 = fetch(slicepatch.VoltageProperties & keys_rel_cc & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res_exc=1','*');
            
            if ~isempty(cc_props_60)
                tuple.response = 1;
                tuple.res_exc = cc_props_60(1).res_exc;
            end
            
            cc_props_60_inh = fetch(slicepatch.VoltageProperties & keys_rel_cc & 'res_inh=1','*');
            if ~isempty(cc_props_60_inh)
                tuple.res_inh = cc_props_60_inh(1).res_inh;
            end
            
            
            keys_rel_cc = fetch(slicepatch.TraceCC & keys_rel & 'baseline<-65' & 'baseline>-75');
            cc_props_70 = fetch(slicepatch.VoltageProperties & keys_rel_cc  & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res_exc=1', '*');
            
            if ~isempty(cc_props_70)
                tuple.response = 1;
                keys_rel_cc_L23 = fetch(slicepatch.TraceCC & keys_L23 & 'baseline<-65' & 'baseline>-75');
                cc_props_L23 = fetch(slicepatch.VoltageProperties & keys_rel_cc_L23 & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'res_exc=1','*');
                if ~isempty(cc_props_L23)
                    tuple.has_norm_epsp = 1;
                    mean_amp_exc = mean([cc_props_70.amp_exc]);
                    mean_amp_exc_L23 = mean([cc_props_L23.amp_exc]);
                    tuple.norm_epsp = mean_amp_exc/mean_amp_exc_L23;
                end
            end
            
            % ppr cc
            cc_props_ppr = fetch(slicepatch.VoltageProperties & keys_rel_cc & 'cnqx=0' & 'apv=0' & 'ttx=0' & 'picrotoxin=0' & 'ap4=0' & 'latency>0' & ['latency<' num2str(tuple.latency_threshold_exc)] & 'ppr>0','*');
            
            if ~isempty(cc_props_ppr)
                tuple.has_ppr_cc = 1;
                tuple.ppr_cc = cc_props_ppr(1).ppr;
            end
            
            self.insert(tuple)
		end
	end

end