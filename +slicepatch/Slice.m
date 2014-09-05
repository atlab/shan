%{
slicepatch.Slice (manual) #  record the information of slices recorded

-> info.Injections
slice_id                    : smallint    # slice number from lateral to medial
-----
slice_name                  : varchar(255)               # name of the slice in xiaolong's system
activity_level="Unknown"    : enum('Unknown','High','Mid','Low','No activity')      # how responsive the cells are
axon_density="N/A"          : enum('N/A','High','Mid','Low')          # axon density of the slice
confidence="N/A"            : enum('N/A','High','Mid','Low')          # how confident about the location
internal_solution="Unknown" : enum('Unknown','K','Cs')                # internal solution type
drug_applied=0              : tinyint                                 # 1 represents drug application
data_path                   : varchar(4095)                           # path of data file
slice_notes                 : varchar(4095)                           # other comments
slice_ts=CURRENT_TIMESTAMP  : timestamp                   # automatic
%}

classdef Slice < dj.Relvar

	properties(Constant)
		table = dj.Table('slicepatch.Slice')
	end
end
