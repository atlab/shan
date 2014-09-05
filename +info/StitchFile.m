%{
info.StitchFile (manual) # my newest table
-> info.StitchSession
opt_file        : smallint              # id within the stitch session
---
row_idx                     : tinyint                       # row index of this image file
column_idx                  : tinyint                       # column index of this image file
file_extension              : varchar(255)                  # extension of the file name
surfz=null                  : float                         # (um) position from manipulator, surface
z=null                      : float                         # (um) position from manipulator, imaging site
notes                       : varchar(4095)                 # other info

%}

%}

classdef StitchFile < dj.Relvar

	properties(Constant)
		table = dj.Table('info.StitchFile')
	end
end
