%{
info.StitchSession (manual) # all the files in one session belong to a stitch
-> common.Animal
stitch_sess       : smallint              # session id, files in each session will become a stitch
---
row_num                     : tinyint                       # number of row files
column_num                  : tinyint                       # number of column files
procesure_date=null         : date                          # date of procedure
material_type=null          : enum('slice','in vivo')       # materials of imaging
file_base                   : varchar(255)                  # base of file name for this stitch
proc_path                   : varchar(255)                  # root path to raw data
lens                        : float                         # objective lens
fov                         : float                         # field of view: microns across the image (assume isometric pixels)
power                       : double                        # power of the beam
wave_length                 : int                           # wavelength of the beam
zoom                        : double                        # magnification of the imaging
opt_note                    : varchar(4095)                 # notes
%}

classdef StitchSession < dj.Relvar

	properties(Constant)
		table = dj.Table('info.StitchSession')
	end
end
