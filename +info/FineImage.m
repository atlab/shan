%{
info.FineImage (manual) # record information of fine image
-> info.ProcedureFile
fine_file                : smallint # number of fine file coming from the same raw file
-----
channel=null                : enum('red','green','red and green')       # materials of imaging
filename                    : varchar(255)                  # filename of the movie
methods=null                : enum('matlab','imagej')       # methods to get the fine image
img_location="Unknown"      : enum('Overall','V1','V2','AL','LM','PM','Unknown')  # location in the brain
img_purpose="Unknown"       : enum('Overall','Primary inj site','Traced axons','Traced cell bodies','Traced dendrites','Unknown')  # purpose in terms of injection
infection_layer             : enum('L1','L23','L4','L5','Multilayer')   # layers infected (cell body)
conclusive="Unknown"        : enum('Low','Mid','High','Unknown')      # how conclusive the result is?
notes                       : varchar(4095)                 # other info
%}

classdef FineImage < dj.Relvar

	properties(Constant)
		table = dj.Table('info.FineImage')
	end
end
