%{
slicepatch.CellSummary (computed) # summarize the responsiveness of a cell based on all the recordings
-> slicepatch.Cell
-----
response              : tinyint      # whether the cell is responsive to feedback activation, in CC or VC, -1 means unrecorded
res_epsc              : tinyint      # whether the cell is responsive based on epsc, -1 if unrecorded
epsc                  : double       # epsc, take the mean if there are two sets of recordings
res_ipsc              : tinyint      # whether the cell is responsive based on ipsc recorded vm = 0mV, -1 if unrecorded
ipsc                  : double       # ipsc, take the mean if there are twosets of recordings
res_epsp              : tinyint      # whether the cell is responsive based on epsp recorded vm = -70mV, -1 if unrecorded
epsp                  : double       # epsp, take the mean of all the recordings, 0 if the cell is not responsive
has_eiratio           : tinyint      # whether the cell has both ipsc and ipsc, and not zero
eiratio               : double       # epsc-ipsc/epsc+ipsc, between -1 and 1
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
            tuple.res_epsc = -1;
            tuple.epsc = 0;
            tuple.res_ipsc = -1;
            tuple.ipsc = 0;
            tuple.res_epsp = -1;
            tuple.epsp = 0;
            tuple.has_eiratio = 0;
            tuple.eiratio = -2;
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
            
            drug_res = struct('cnqx',0,'apv',0,'ttx',0,'picrotoxin',0,'ap4',0);
            lat_exc_res = ['latency between 0 and ' num2str(tuple.latency_threshold_exc)];
            lat_inh_res = ['latency between 0 and ' num2str(tuple.latency_threshold_inh)];
            
            % VC properties
            keys_rel = fetch(slicepatch.CurrentProperties & key & drug_res & 'quality>0');
            
            if ~isempty(keys_rel)
                if tuple.response ==-1
                    tuple.response = 0;
                end
            end
            
            vc_props_60 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm=60' & lat_exc_res & 'res=1');
            
            if ~isempty(vc_props_60)
                tuple.response = 1;
            end
            
            vc_props_70 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm>60' & lat_exc_res, '*');
            vc_props_70_res = fetch(slicepatch.CurrentProperties & keys_rel & 'vm>60' & lat_exc_res & 'res=1', '*');
            
            if ~isempty(vc_props_70)
                tuple.res_epsc = 0;
            end
            
            if ~isempty(vc_props_70_res)
                tuple.res_epsc = 1;
                tuple.response = 1;
                tuple.vm = vc_props_70_res(1).vm;
                tuple.epsc = mean([vc_props_70_res.amp]);
            end
            
            vc_props_0 = fetch(slicepatch.CurrentProperties & keys_rel & 'vm=0' & lat_inh_res, '*');
            vc_props_0_res = fetch(slicepatch.CurrentProperties & keys_rel & 'vm=0' & lat_inh_res & 'res=1', '*');
            
            if ~isempty(vc_props_0)
                tuple.res_ipsc = 0;
            end
            
            if ~isempty(vc_props_0_res)
                tuple.res_ipsc = 1;
                tuple.ipsc = mean([vc_props_0_res.amp]);
            end
            
            if tuple.res_epsc==1 && tuple.res_ipsc==1
                tuple.has_eiratio = 1;
                tuple.eiratio = (tuple.epsc - tuple.ipsc)/(tuple.epsc + tuple.ipsc);
            end
            
            % ppr vc
            vc_props_ppr = fetch(slicepatch.CurrentProperties & keys_rel & 'vm>60' & 'quality>0' & lat_exc_res & 'ppr>0','*');
            
            if ~isempty(vc_props_ppr)
                tuple.has_ppr_vc = 1;
                tuple.ppr_vc = vc_props_ppr(1).ppr;
            end
            
            % CC properties
            keys_rel = fetch(slicepatch.VoltageProperties & key & drug_res);
            
            if ~isempty(keys_rel)
                if tuple.response==-1
                    tuple.response = 0;
                end
            end
            
            keys_rel_cc = fetch(slicepatch.TraceCC & keys_rel & 'baseline between -65 and -55');
            cc_props_60 = fetch(slicepatch.VoltageProperties & keys_rel_cc);
            
            if ~isempty(cc_props_60)
                tuple.has_cc_60 = 1;
            end
             
            cc_props_60 = fetch(slicepatch.VoltageProperties & keys_rel_cc & lat_exc_res & 'res_exc=1','*');
            
            if ~isempty(cc_props_60)
                tuple.response = 1;
                tuple.res_exc = cc_props_60(1).res_exc;
            end
            
            cc_props_60_inh = fetch(slicepatch.VoltageProperties & keys_rel_cc & 'res_inh=1','*');
            
            if ~isempty(cc_props_60_inh)
                tuple.res_inh = cc_props_60_inh(1).res_inh;
            end
            
            
            keys_rel_cc = fetch(slicepatch.TraceCC & keys_rel & 'baseline<-65' & 'baseline>-75');
            cc_props_70 = fetch(slicepatch.VoltageProperties & keys_rel_cc & lat_exc_res & 'res_exc=1', '*');
            
            if ~isempty(keys_rel_cc)
                if tuple.response==-1
                    tuple.response = 0;
                end
            end
            
            if ~isempty(cc_props_70)
                tuple.response = 1;
                tuple.res_epsp = 1;
                tuple.epsp = mean([cc_props_70.amp_exc]);
                   
            end
            
            % ppr cc
            cc_props_ppr = fetch(slicepatch.VoltageProperties & keys_rel_cc & drug_res & lat_exc_res & 'ppr>0','*');
            
            if ~isempty(cc_props_ppr)
                tuple.has_ppr_cc = 1;
                tuple.ppr_cc = cc_props_ppr(1).ppr;
            end
            
            self.insert(tuple)
		end
	end

end