%A = fetch(tp.FreqMap('animal_id=785','ca_opt=7'),'*');
A = fetch(tp.FreqMap('animal_id=851','ca_opt=7'),'*');

IM = fetch(tp.Align(A),'*');

sf = {'.02','.04','.08','.12','.16'};
tf = {'2','4','6','8','10'};

for w=7%1:length(A)
    a=A(w);
    im=IM(w);
    
    figure(1)
    for i=1:25;
        subplot(5,5,i)
        
        b = squeeze(a.fm_bmap(:,:,i));
        
        r2 = a.fm_r2map;
        mask = r2>.005;
        r2 = r2-min(r2(:));
        r2 = r2/.005;
        r2(r2>1) = 1;
        
        
        w = hamming(5);
        w = w/sum(w);
        r2 = imfilter(r2,w,'symmetric');
        r2 = imfilter(r2,w','symmetric');
        
        imagesc(b.*r2.*mask)
        caxis([0 .2]);
        if i<6
            title(sf{i});
        end
        if mod(i,5) == 1
            ylabel(tf{ceil(i/5)});
        end
        axis image
    end
    figure(2)
    subplot(1,2,1);imagesc(im.green_img)
    axis image
    subplot(1,2,2);imagesc(im.red_img)
    axis image
   %% 
   figure(2)
    p=round(ginput(1));
    win=15;
    roiX=[p(2)-win:p(2)+win];
    roiY=[p(1)-win:p(1)+win];
    k=1;R=cell(5);
    for i=1:5
        for j=1:5
            b = squeeze(a.fm_bmap(roiX,roiY,k));
        
        r2 = a.fm_r2map(roiX,roiY);
        mask = r2>.01;
        r2 = r2-min(r2(:));
        r2 = r2/.01;
        r2(r2>1) = 1;
        w = hamming(5);
        w = w/sum(w);
        r2 = imfilter(r2,w,'symmetric');
        r2 = imfilter(r2,w','symmetric');
            R{i,j}=(b.*r2.*mask);
            k=k+1;
        end
    end
     figure;imagesc(cell2mat(R))
    
     caxis([0 .2]);
     hold on
     g=[];
     for i=0:4
         for j=0:4
             plot(j*(win*2+1)+win,i*(win*2+1)+win,'marker','x','color','k','linewidth',1)
             g(i+1)=i*(win*2+1)+win;
         end
     end
     
     for i=1:4
         for j=1:4
             line([j*(win*2+1) j*(win*2+1)],[0 (win*2+1)*5],'color','w')
             line([0 (win*2+1)*5],[i*(win*2+1) i*(win*2+1)],'color','w')
         end
     end
     set(gca,'xtick',g,'xticklabel',sf,'ytick',g,'yticklabel',tf);
     xlabel('Spatial Freq (cyc/deg)')
     ylabel('Temp Freq (Hz)')
     title(['Mouse ' num2str(a.animal_id) '  Session ' num2str(a.tp_session) '  Scan ' num2str(a.scan_idx)])
     colorbar
      axis image

end
%%
key=[];
key.animal_id=718;
key.scan_idx=11;
a = fetch(tp.OriFreqMap(key));
k=1;
sf = unique([a.sf]);
tf = unique([a.tf]);
for i=1:length(sf)
    figure(i)
    set(gcf,'position',[500+i*50 300-i*50 3200 700])
    for j=1:length(tf)
        key.sf = sf(i);
        key.tf = tf(j);
        
        b = fetch1(tp.OriFreqMap(key),'ofm_bmap');
        [amp,b]=max(b,[],3);
        
        r2 = fetch1(tp.OriFreqMap(key),'ofm_r2map');
        mask = r2>.004;
        r2 = r2-min(r2(:));
        r2 = r2/.01;
        r2(r2>1) = 1;
        mask = repmat(mask,[1 1 3]);
        r2 = repmat(r2,[1 1 3]);
        
        w = hamming(5);
        w = w/sum(w);
        r2 = imfilter(r2,w,'symmetric');
        r2 = imfilter(r2,w','symmetric');
        
        img = ind2rgb(b,hsv(6));
        img = img.*r2.*mask;
        subplot(1,4,j)
        image(img);
        ylabel(['SF=' num2str(sf(i))])
        title(['TF=' num2str(tf(j))])
        
        k=k+1;
    end
end

%%
%cmap=load('/mnt/lab/users/jake/work/local/schemaBrowser/circCmap.mat');
%cmap=cmap.cmap;
key=[];
key.animal_id=723;
key.scan_idx=3;
a = fetch(tp.Cos2FreqMap(key));
k=1;
sf = unique([a.sf]);
tf = unique([a.tf]);
for i=1:length(sf)
    figure(i)
    set(gcf,'position',[500+i*50 300-i*50 3200 700])
    for j=1:length(tf)
        key.sf = sf(i);
        key.tf = tf(j);
        
        p = fetch1(tp.Cos2FreqMap(key),'cos2f_fp');
        amp = fetch1(tp.Cos2FreqMap(key),'cos2f_amp');
        r2 = fetch1(tp.Cos2FreqMap(key),'cos2f_r2');
        mask = (p<.0001).*(r2>.001).*(amp>.1);
        
        amp = amp-min(amp(:));
        amp = amp/.1;
        amp(amp>1) = 1;
        
        r2 = r2-min(r2(:));
        r2 = r2/.001;
        r2(r2>1) = 1;
 
        
        mask = repmat(mask,[1 1 3]);
        r2 = repmat(r2,[1 1 3]);
        amp = repmat(amp,[1 1 3]);
        
        ori = fetch1(tp.Cos2FreqMap(key),'cos2f_ori');
        ori = ceil(((ori+(pi/2))/pi) * 16);
        %ori = ceil((abs(ori)/(pi/2)) * 8);
        img = ind2rgb(ori,hsv(16));
         w = hamming(3);
         w = w/sum(w);
%         r2 = imfilter(r2,w,'symmetric');
%         r2 = imfilter(r2,w','symmetric');
         mask = imfilter(mask,w,'symmetric');
         mask = imfilter(mask,w','symmetric');
        
        img = img.*mask;
        
        figure(i)
        subplot(1,length(tf),j)
        image(img);
        ylabel(['SF=' num2str(sf(i))])
        title(['TF=' num2str(tf(j))])
        axis image
        
        figure(5)
        subplot(length(tf),length(sf),k)
        image(img);
        ylabel(['SF=' num2str(sf(i))])
        title(['TF=' num2str(tf(j))])
        axis image
       
        k=k+1;
    end
end