%{
patch.Session (manual) # record the patch session and data directory$
-> common.Animal
session         : smallint              # session index
---
session_date                : date                          # date
path                        : varchar(255)                  # file path
session_notes               : varchar(4095)                 # free-text notes
session_ts=CURRENT_TIMESTAMP: timestamp                     # automatic
%}

classdef Session < dj.Relvar

	properties(Constant)
		table = dj.Table('patch.Session')
    end
    
    methods
		function self = Session(varargin)
			self.restrict(varargin)
		end
	end
	
end
