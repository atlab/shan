%{
info.ProcedureSession (manual) # Procedure sessions after injections$
-> common.Animal
proc_sess       : smallint              # session id
---
proc_path                   : varchar(255)                  # root path to raw data
opt_note                    : varchar(4095)                 # notes
%}

classdef ProcedureSession < dj.Relvar

	properties(Constant)
		table = dj.Table('info.ProcedureSession')
	end
end
