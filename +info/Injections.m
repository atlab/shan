%{
info.Injections (manual) # record of injections
->common.Animal
injection_id       : tinyint      # number of injection
-----
injection_guidance="2P"     : enum('2P','stereotactic','other')# guidance method
intrinsic_imaging=0         : tinyint                      # true if intrinsic imaging is used
injection_type="virus"      : enum('virus','dye','beads','other') # substance injected
virus_id=0                  : int                           # id number of injected virus
injection_date=null         : date                          # date of injection
intrin_map_quality="N/A"    : enum('very clear','clear','acceptable','bad','N/A') # quality of intrinsic imaging map 
injection_site="Unknown"    : enum('V1','V2','LM','AL','PM','Visual Cortex','Nucleus Basalis','LGN','Retina','Unknown')# site of injection
injection_size="unknown"    : enum('very large','large','medium','small','very small','unknown')# qualitative size
injection_depth=0           : float                         # depth of the center of the injection site from the surface, 0 means unknown
injection_layer="N/A"       : enum('L1','L2/3','L4','L5','L6','Uknown','N/A') # presumed injection layer
inject_confidence="Unknown" : enum('High','Mid','Low','Unknown')      # how good do I feel about the injection quality
proc_after_injection=null   : enum('in vitro patching', 'in vivo patching','histology','unsuccessful') # procedure after injection 
injection_note=null         : varchar(4096)                 # injection notes
injection_ts=CURRENT_TIMESTAMP: timestamp                   # automatic
%}


classdef Injections < dj.Relvar

	properties(Constant)
		table = dj.Table('info.Injections')
    end
    
    methods
        function self = Injections(varargin)
            self.restrict(varargin)
        end
    end
end

        