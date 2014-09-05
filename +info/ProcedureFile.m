%{
info.ProcedureFile (manual) # my newest table$
-> info.ProcedureSession
opt_file        : smallint              # optical movie id within the procedure session
---
material_type=null          : enum('slice','in vivo')       # materials of imaging
img_type=null               : enum('2P','CCD','Other')      # methods of imaging
filename                    : varchar(255)                  # filename of the movie
lens                        : float                         # objective lens magnification
fov                         : float                         # field of view: microns across the image (assume isometric pixels)
img_location="Unknown"      : enum('Overall','V1','V2','AL','LM','PM','Unknown')# location in the brain
img_purpose="Unknown"       : enum('Overall','Primary inj site','Traced axons','Traced cell bodies','Traced dendrites','Unknown')# purpose in terms of injection
surfz=null                  : float                         # (um) position from manipulator, surface
z=null                      : float                         # (um) position from manipulator, imaging site
notes                       : varchar(4095)                 # other info
power                       : double                        # comment
wave_length                 : int                           # comment
zoom                        : double                        # comment
%}

%}

classdef ProcedureFile < dj.Relvar

	properties(Constant)
		table = dj.Table('info.ProcedureFile')
	end
end
