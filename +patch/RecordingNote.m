%{
patch.RecordingNote (manual) # manual notes about each file for a cell
-> patch.Cell
file_num                    : smallint              # number of file appended to hd5 basename (excluding trailing 0)
-----
recording_caveat = 0        : boolean               # true if there are unusual or atypical circumstances associated with this file that need to be taken into account
stimulus_type = "Unknown"   : enum('Unknown', 'gratings', 'natural image','None') # type of stimulus used in this recording
recording_purpose = "Unknown"  : enum('Unknown', 'orientation tuning','spontaneous activity', 'natural discriminability', 'others') # what is this recording for
recording_note = ""         : varchar(4095)         # free-text notes
recording_ts=CURRENT_TIMESTAMP  : timestamp         # automatic
%}

classdef RecordingNote < dj.Relvar
end