%{
patch.Patch (manual) # anything that gets patched$
-> patch.Session
patch           : smallint              # patch index (double patches have the same patch index and different amps)
---
anesthesia="awake"          : enum('awake','iso','fentanyl','urethane','awake/iso','other')# Anesthesia
patch_notes                 : varchar(4095)                 # free-text notes
patch_ts=CURRENT_TIMESTAMP  : timestamp                     # automatic
filebase                    : varchar(20)                   # comment
%}

classdef Patch < dj.Relvar


end
