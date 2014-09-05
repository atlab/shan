function epochs = makeEpochs(varargin)

% epochs defined by boolean vector
if nargin == 1
    x=varargin{1};
    if isempty(x)
        epochs=[];
        return
    end
    t1 = find(diff(x)==1);
    if x(1)
        t1 = [1;t1];
    end
    t2 = find(diff(x)==-1)+1;
    if x(end)
        t2 = [t2;length(x)];
    end
    mod = 'before';
elseif nargin == 2
    t1 = varargin{1};
    t2 = varargin{2};
    mod = 'before';
elseif nargin == 3
    t1 = varargin{1};
    t2 = varargin{3};
    mod = varargin{2};
else
    return
end


switch mod
    case 'before' %indexes off left side of block; epochs defined by first t2 following each t1
        k=1;
        epochs=[];
        for i = 1:length(t1)
            if ~isempty(find(t2 > t1(i)))
                ind = min(find(t2 > t1(i)));
                epochs(k,:) = [t1(i) t2(ind)];
                k=k+1;
            end
        end
    case 'follows' %indexes off right side of block; epochs defined by last t2 preceeding each t1
        k=1;
        epochs=[];
        for i = 1:length(t1)
            if ~isempty(find(t2 < t1(i)))
                ind = max(find(t2 < t1(i)));
                epochs(k,:) = [t2(ind) t1(i)];
                k=k+1;
            end
        end
end
