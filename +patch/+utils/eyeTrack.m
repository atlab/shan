%%
%eye = mmread('/mnt/scratch01/WholeCell/jake/130504/m1339E22eyetracking.avi',[1:1000]);
%eye = mmread('/mnt/scratch01/WholeCell/jake/130501/m1336D8eyetracking.avi');
tic;eye = mmread('/mnt/scratch01/WholeCell/jake/130503/m1337D9eyetracking.avi',[1:2000]);toc

nFrames=length(eye.frames);
eye=[eye.frames(:).cdata];
frames=reshape(squeeze(eye(:,:,1)),size(eye,1),[],nFrames);

% frames=zeros([size(eye.frames(1).cdata,1) size(eye.frames(1).cdata,2) nFrames],'int8');
% for i=1:nFrames
%     frames(:,:,i)=eye.frames(i).cdata(:,:,1);
% end

% parameters

lthr = [.7:.1:.8]; % threshold parameter for expanding blob
ptile = 20; % threshold parameter for global image
xind = 350:950; % xlim in pixels
yind = 300:820; % ylim in pixels
rsz = 0.5; % downsizing for faster processing

%%
track=[];
for i = 1000:nFrames
    frame = squeeze(frames(:,:,i));
    
    frame = imresize(single(frame(yind-50,xind+50,1)),rsz);
    
    imagesc(frame);
    axis image
    colormap gray
    
    frame = imfilter(frame,ones(3));
    prc =  prctile(frame(:),ptile);
    frame(frame>prc) = prc;
    frame = normalize(frame);
    
    f1 = imextendedmin(frame,.65,8);
    for j=lthr(2:end)
        f2=imextendedmin(frame,j,8);
        if sum(f2(:))/sum(f1(:)) > 1.2
            continue
        end
        f1=f2;
    end
    imagesc(f1)
    
    
    frame = f1;
    
    L = bwlabel(frame, 4);
    edgeB = unique([L(:,1)' L(:,end)' L(1,:) L(end,:)]);
    hc = hist(L(:),length(unique(L(:))));
    hc(edgeB+1) = 0;
    [~,iblob] = max(hc(2:end));
    frame = L==iblob;
    stat = regionprops(frame,'EquivDiameter','Centroid');
   
    hold on
    r = stat.EquivDiameter/2;
    [x, y] = circlepoints(r);
    plot(x+stat.Centroid(1), y+stat.Centroid(2), 'g-');
    
    track(i,:) = [stat.Centroid(1) stat.Centroid(2) r];
    drawnow
    clf
end

