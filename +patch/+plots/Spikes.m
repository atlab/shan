function Spikes(varargin)
% for a given recording file, plot Spikes as a raster plot
key = varargin{1};

if nargin==2
    y = varargin{2}(1);
    height = varargin{2}(2);
else
    y = 0;
    height = .1;
end

assert(length(patch.Recording & key)==1, 'One recording at a time please.');

vt = fetch1(patch.Ephys & (patch.Recording & key),'ephys_time');

c = {'r','m'};

key = fetch(patch.Ephys & key);

for i=1:length(key)
    
    spk = fetchn(patch.Spikes & key(i),'spk_ts');
    figure;h = line([spk spk]',repmat([y-height/2 y+height/2],size(spk))','color',c{key(i).amp});
    ylim([-1,1])
    
end
