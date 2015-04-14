classdef plots
    
    
    methods(Static)
        function slider(src, event)
            ax = get(src,'userdata');
            c = caxis(ax);
            v = get(src,'value');
            t = get(src,'tag');
            switch t
                case 'min'
                    assert(v<c(2),'Image caxis min must be less than caxis max')
                    caxis(ax,[v c(2)]);
                case 'max'
                    assert(v>c(1),'Image caxis max must be greater than caxis min')
                    caxis(ax,[c(1) v]);
            end
        end
        
        function moveMarker(src,event)
            xy = get(gca,'currentpoint');
            xy = xy(1,:);
            h = [findobj(101,'type','axes');findobj(102,'type','axes')];
            for i=1:length(h)
                pHandle = get(h(i),'userdata');
                if ishandle(pHandle) && ~isempty(pHandle)
                    set(pHandle,'xdata',xy(1),'ydata',xy(2));
                else
                    axes(h(i));
                    hold on
                    pHandle = plot(xy(1),xy(2),'marker','x','linewidth',2);
                    set(h(i),'userdata',pHandle,'buttondownfcn',@opt.plots.moveMarker);
                end
            end
        end
        
        function SpotMap(varargin)
            
            if ishandle(varargin{1})
                src = varargin{1};
                t = get(src,'tag');
                d = get(101,'userdata');
                switch t
                    case 'prev'
                        if d.keyInd == 1
                            return
                        end
                        
                        d.keyInd = max(1,d.keyInd-1);
                    case 'next'
                        if d.keyInd == length(d.key)
                            return
                        end
                        d.keyInd = min(length(d.key),d.keyInd+1);
                end
                set(101,'userdata',d);
                h = findobj(101,'tag','index');
                set(h,'string',[num2str(d.keyInd) '/' num2str(length(d.key))]);
            else
                d.key = fetch(opt.SpotMap2(varargin{:}))';
                if ~length(d.key)
                    warning('No tuples found');
                    return
                end
                d.keyInd = 1;
                figure(101)
                set(101,'userdata',d);
                if length(d.key)>1
                    uicontrol('string','<<','units','pixels','position',[0 5 50 20],'tag','prev','callback',@info.plots.SpotMap)
                    uicontrol('style','text','units','pixels','position',[60 5 50 20],'tag','index','string',[num2str(d.keyInd) '/' num2str(length(d.key))])
                    uicontrol('string','>>','units','pixels','position',[120 5 50 20],'tag','next','callback',@info.plots.SpotMap)
                end
            end
            
            key = d.key(d.keyInd);
            % fetch spotmap
            amp = fetch1(opt.SpotMap2(key), 'spot_amp');
            
            % fetch structure
            structKey.animal_id=key.animal_id;
            
            structImg=fetchn(info.Infection(structKey),'img');
            structMask=fetchn(info.InfectionMask(structKey),'structure_mask');
            if length(structImg)>1
                structImg=structImg{end};
                warning('More than one structural image for this session. Using {end}');
            end
            
            if length(structMask)>1
                structMask=structMask{1};
                warning('More than one structural mask for this session. Using {1}');
            end
            
            structImg=double(structImg{1}.*uint8(structMask{1}));
            
            amp = bsxfun(@times, amp, double(structMask{1}));
            
            % filter spotmap
            k = hamming(5);
            k = k/sum(k);
            amp = imfilter(amp,k,'symmetric');
            amp = imfilter(amp,k','symmetric');
            img = amp;
            
            % Spot map
            figure(101)
            if size(amp,3)==1
                % One spot
                subplot(2,1,1)
                hold off
                h=imagesc(img,[-1 1]*max(abs(img(:))));
                set(h,'buttondownfcn',@opt.plots.moveMarker);
                colormap('summer')
                axis image
                set(gca,'xdir','reverse','xtick',[],'ytick',[])
                
                p=get(gca,'position');
                p=[p(1) p(2)-.01 p(3) .03];
                c=caxis;
                uicontrol('style','slider','min',c(1)-.005,'max',c(1)+.005,'value',c(1),'units','normalized','position',p,'tag','min','callback',@opt.plots.slider,'userdata',gca);
                uicontrol('style','slider','min',c(2)-.005,'max',c(2)+.005,'value',c(2),'units','normalized','position',p-[0 .03 0 0],'tag','max','callback',@opt.plots.slider,'userdata',gca);
            elseif size(amp,3)==4
                
                % Four spots - separate subplots
                pos=[1 5 2 6];
                for i=1:4
                    subplot(2,4,pos(i))
                    hold off
                    img = amp(:,:,i);
                    h=imagesc(img,[-1 1]*max(abs(img(:))));
                    set(h,'buttondownfcn',@opt.plots.moveMarker);
                    colormap('bone')
                    axis image
                    set(gca,'xdir','reverse','xtick',[],'ytick',[])
                    p=get(gca,'position');
                    p=[p(1) p(2)-.01 p(3) .03];
                    c=caxis;
                    uicontrol('style','slider','min',c(1)-.005,'max',c(1)+.005,'value',c(1),'units','normalized','position',p,'tag','min','callback',@opt.plots.slider,'userdata',gca);
                    uicontrol('style','slider','min',c(2)-.005,'max',c(2)+.005,'value',c(2),'units','normalized','position',p-[0 .03 0 0],'tag','max','callback',@opt.plots.slider,'userdata',gca);
                end
                
                % Four spots - mgyb
                
                subplot(1,2,2)
                hold off
                
                for ii = 1:4
                    im = squeeze(amp(:,:,ii));
                    amp2(:,:,ii) = info.plots.normalize(im);
                end
                
                               
                
                m = cat(3,1,0,1);
                y = cat(3,1,1,0);
                b = 1-y;
                g = 1-m;
                img = bsxfun(@times, amp2(:,:,1), g) ...
                    + bsxfun(@times, amp2(:,:,2), b) ...
                    + bsxfun(@times, amp2(:,:,3), y) ...
                    + bsxfun(@times, amp2(:,:,4), m);
                
                R = img(:,:,1);
                G = img(:,:,2);
                B = img(:,:,3);
                
%                 R = R - median(R(:));    R = R / quantile(abs(R(:)),0.99);
%                 G = G - median(G(:));    G = G / quantile(abs(G(:)),0.99);
%                 B = B - median(B(:));    B = B / quantile(abs(B(:)),0.99);
                
%                 thres = 0.3;
%                 R(R>quantile(R(:),thres))=0;
%                 G(G>quantile(G(:),thres))=0;
%                 B(B>quantile(B(:),thres))=0;
              
                img = cat(3,R,G,B)*4+0.2;
%                 img = cat(3,R,G,B);
                img = max(0, min(1, img));
                % % Luminance info
                % v = sqrt(R.^2+G.^2+B.^2);
                % v = v/quantile(v(:),0.999);
                % img = rgb2hsv(img);
                % img(:,:,3) = v;
                % img = hsv2rgb(img);
             
                h=imshow(img);
                set(h,'buttondownfcn',@opt.plots.moveMarker);
                keyTitle(key);
                axis image
                set(gca,'xdir','reverse')
                
            else
                error('Can only plot for 1 or 4 spots');
            end
            
            
            % Structural image
            figure(102)
            hold off
%             structImg2 = zeros(size(structImg));
%             structImg2(16:end, :) = structImg(1:end-15,:);
%             structImg2(:, 11:end) = structImg2(:,1:end-10);
            h=imagesc(structImg); colormap('gray');
            set(h,'buttondownfcn',@opt.plots.moveMarker);
            keyTitle(structKey);
            axis image
            set(gca,'xdir','reverse','xtick',[],'ytick',[])
            p=get(gca,'position');
            p=[p(1) p(2)-.03 p(3) .03];
            uicontrol('style','slider','min',0,'max',127,'value',0,'units','normalized','position',p,'tag','min','callback',@opt.plots.slider,'userdata',gca);
            uicontrol('style','slider','min',128,'max',255,'value',255,'units','normalized','position',p-[0 .03 0 0],'tag','max','callback',@opt.plots.slider,'userdata',gca);
            
            h = [findobj(101,'type','axes');findobj(102,'type','axes')];
            for i=1:length(h)
                if  isempty(get(h(i),'userdata')) || ~ishandle(get(h(i),'userdata'))
                    axes(h(i));
                    hold on
                    pHandle = plot(0,0,'marker','x','linewidth',2);
                    set(h(i),'userdata',pHandle);
                end
            end
            
            % spotmap on top of vessels
            
            figure(103)
            img2 = rgb2hsv(img);
            structImg = convn(structImg, gausswin(5)*gausswin(5)', 'valid');
            structImg = (structImg-min(structImg(:)))./(max(structImg(:))-min(structImg(:)));
            img2(:,:,3) = structImg;
            img2 = hsv2rgb(img2);
            imshow(img2);
            set(gca,'xdir','reverse','xtick',[],'ytick',[])
        end
        
        
        function Structure(varargin)
            for key = fetch(info.Infection(varargin{:}))'
                figure(103)
                structImg=fetchn(info.Infection(key),'img');
                structMask=fetchn(info.InfectionMask(key),'structure_mask');
                %structImg=double(structImg{end});
                structImg=double(structImg{end}).*double(structMask{end});
                h = imagesc(structImg); colormap('gray');
                set(h,'buttondownfcn',@opt.plots.moveMarker);
                
                axis image
                set(gca,'xdir','reverse','xtick',[],'ytick',[])
                p=get(gca,'position');
                p=[p(1) p(2)-.03 p(3) .03];
                uicontrol('style','slider','min',0,'max',127,'value',0,'units','normalized','position',p,'tag','min','callback',@opt.plots.slider,'userdata',gca);
                uicontrol('style','slider','min',128,'max',255,'value',255,'units','normalized','position',p-[0 .03 0 0],'tag','max','callback',@opt.plots.slider,'userdata',gca);

                h = findobj(103,'type','axes');
                for i=1:length(h)
                    if  isempty(get(h(i),'userdata')) || ~ishandle(get(h(i),'userdata'))
                        axes(h(i));
                        hold on
                        pHandle = plot(0,0,'marker','x','linewidth',2);
                        set(h(i),'userdata',pHandle);
                    end
                end
            end
        end
        
        function SpotMap_two_color(varargin)
            if ishandle(varargin{1})
                src = varargin{1};
                t = get(src,'tag');
                d = get(101,'userdata');
                switch t
                    case 'prev'
                        if d.keyInd == 1
                            return
                        end
                        
                        d.keyInd = max(1,d.keyInd-1);
                    case 'next'
                        if d.keyInd == length(d.key)
                            return
                        end
                        d.keyInd = min(length(d.key),d.keyInd+1);
                end
                set(101,'userdata',d);
                h = findobj(101,'tag','index');
                set(h,'string',[num2str(d.keyInd) '/' num2str(length(d.key))]);
            else
                d.key = fetch(opt.SpotMap2(varargin{:}))';
                if ~length(d.key)
                    warning('No tuples found');
                    return
                end
                d.keyInd = 1;
                figure(201)
                set(201,'userdata',d);
                if length(d.key)>1
                    uicontrol('string','<<','units','pixels','position',[0 5 50 20],'tag','prev','callback',@info.plots.SpotMap2)
                    uicontrol('style','text','units','pixels','position',[60 5 50 20],'tag','index','string',[num2str(d.keyInd) '/' num2str(length(d.key))])
                    uicontrol('string','>>','units','pixels','position',[120 5 50 20],'tag','next','callback',@info.plots.SpotMap2)
                end
            end
            
            key = d.key(d.keyInd);
            % fetch spotmap
            amp = fetch1(opt.SpotMap2(key), 'spot_amp');
            
            % fetch structure
            structKey.animal_id=key.animal_id;
            
            structImg=fetchn(info.Infection(structKey),'img');
            structMask=fetchn(info.InfectionMask(structKey),'structure_mask');
            if length(structImg)>1
                structImg=structImg{end};
                warning('More than one structural image for this session. Using {end}');
            end
            
            if length(structMask)>1
                structMask=structMask{1};
                warning('More than one structural mask for this session. Using {1}');
            end
            
            structImg=double(structImg{1}.*uint8(structMask{1}));
            
            amp = bsxfun(@times, amp, double(structMask{1}));
            
            % filter spotmap
            k = hamming(5);
            k = k/sum(k);
            amp = imfilter(amp,k,'symmetric');
            amp = imfilter(amp,k','symmetric');
           
            
            r = cat(3,1,0,0);
            b = cat(3,0,0,1);
            % two color spotmap
            img = bsxfun(@times, amp(:,:,1), r) ...
                    + bsxfun(@times, amp(:,:,2), b);
            
                
            R = img(:,:,1);
            B = img(:,:,3);
            G = zeros(size(B));
            R = R - median(R(:));    R = R / quantile(abs(R(:)),0.99);
            G = G - median(G(:));    G = G / quantile(abs(G(:)),0.99);
            B = B - median(B(:));    B = B / quantile(abs(B(:)),0.99); 
            
            img = cat(3,R,G,B)+0.5;
            figure(201); imshow(img)
            set(gca,'xdir','reverse','xtick',[],'ytick',[])
        end
        
        function im2 = normalize(im,do_smooth)
            if ndims(im)~=2
                assert('Input image is not valid!');
            end
            if ~exist('do_smooth','var')
                do_smooth=1;
            end
            im(im<quantile(im(:),0.005))=quantile(im(:),0.005);
            im2 = max(im(:)) - im;
            im2(im2<quantile(im2(:),0.7)) = 0;
            if do_smooth
                im2 = convn(im2, gausswin(5)*gausswin(5)', 'valid');
            end
            im2 = im2/max(im2(:))*16;
            
            im2 = exp(im2);
            
            im2 = im2/max(im2(:));
            
        end
        function Stack2Img(varargin)
            keys = fetch(info.Stack2Img & varargin{:})';
            for iKey = keys
                tuple = fetch(info.Stack2Img & iKey,'*');
                if tuple.green_channel
                    img = tuple.green_img;
                    G = img/quantile(img(:),0.995); G(G>1) = 1; R = zeros(size(G)); B = zeros(size(G)); img2 = cat(3,R,G,B);
                    figure; imshow(img2); keyTitle(iKey);
                end
%                 if tuple.green_channel && tuple.red_channel
%                     img_g = tuple.green_img; img_r = tuple.red_img;
%                     G = img_g/quantile(img_g(:),0.995); G(G>1) = 1; 
%                     R = img_r/quantile(img_r(:),0.995); R(R>1) = 1; 
%                     B = zeros(size(G)); img2 = cat(3,R,G,B);
%                     figure; imshow(img2); keyTitle(iKey);
%                 end
            end
        end
        
        function h = Stitch(saturation,channel,varargin)
            % plot the green channel of the stitching image, if there is a
            % red channel, plot the merging image as well
            % SS 2014-03-25
            keys = fetch(info.Stitch & varargin)';
            for iKey = keys
                tuple = fetch(info.Stitch & iKey,'*');
                switch channel
                    case 'both'
                        if ~(tuple.green_channel && tuple.red_channel)
                            assert('The image does not have both channels!')
                        else
                            img_g = tuple.img_green; img_r = tuple.img_red;
                            G = img_g/quantile(img_g(:),saturation); G(G>1) = 1; 
                            R = img_r/quantile(img_r(:),0.99); R(R>1) = 1; 
                            B = zeros(size(G)); img2 = cat(3,R,G,B);
                            h=figure; imshow(img2); keyTitle(iKey);
                        end
                    case 'green'
                        if ~tuple.green_channel
                            assert('The image does not have green channel!')
                        else
                            img = tuple.img_green;
                            G = img/quantile(img(:),saturation); G(G>1) = 1; R = zeros(size(G)); B = zeros(size(G)); img2 = cat(3,R,G,B);
                            h=figure; imshow(img2); keyTitle(iKey);
                        end
                    case 'red'
                        if ~tuple.red_channel
                            assert('The image does not have red channel!')
                        else
                            img = tuple.img_red;
                            R = img/quantile(img(:),0.99); R(R>1) = 1; G = zeros(size(R)); B = zeros(size(R)); img2 = cat(3,R,G,B);
                            h=figure; imshow(img2); keyTitle(iKey);
                        end
                end
            end
        end
        
        function cmpRetin(varargin)
           % compare the fluorescence values of different retinotopy for a
           % single stitch session
           keys = fetch(info.StitchSession & varargin);
           for iKey = keys'
               keys_mask = fetch(info.RetinotopyMask & iKey & 'quality>0');
               if isempty(keys_mask)
                   continue
               end
               valuesMat = cell(1,length(keys_mask));
               for ii = 1:length(valuesMat)
                   [values,bg] = fetch1(info.Extract & iKey & keys_mask(ii),'fluo_values','bg_values');
                   
                   valuesMat{ii} = values/mean(bg);
                   
               end
               fig = Figure(101,'size',[80,45]);
               barfun(valuesMat);
               set(gca, 'XTick', 1:length(valuesMat));
               ylabel('Fluorescence');
%                ylim([0,3]);
               fig.cleanup;
               fig.save('V2_project/FineResults/Retin_stat1')
           end
        end
        
        function cmpRetin_all(varargin)
            keys = fetch(info.NormRetinFluo & varargin, '*');
            mat_rel = [keys.mean_rel_norm];
            mat_unrel = [keys.mean_unrel_norm];
            
            mean_rel = mean(mat_rel);
            ste_rel = std(mat_rel)/sqrt(length(mat_rel));
            
            mean_unrel = mean(mat_unrel);
            ste_unrel = std(mat_unrel)/sqrt(length(mat_unrel));
            
            [h,p] = ttest(mat_rel, mat_unrel)
            
            fig = Figure(101,'size',[60,35]); bar([mean_rel,mean_unrel], 'barwidth', 0.5, 'facecolor', [0.8,0.8,0.8]); hold on
            errorbar([mean_rel,mean_unrel], [ste_rel,ste_unrel],'LineStyle','None', 'Color', 'k');
            ylim([0,3]); xlim([0.2,2.8])
            set(gca, 'xTickLabel',{'Retin', 'Non-retin'});
            ylabel('Fluorescence nomalized to background')
       
            fig.cleanup; 
            fig.save('V2_project/FineResults/Retin_stat_all'); 
        end
        function cmpRetin_all2(varargin)
             % based on Andreas' suggestion, z scores of all the pixels
            keys = fetch(info.RetinFluoZscore & varargin, '*');
            mat_rel = [keys.mean_rel];
            mat_unrel = [keys.mean_unrel];
            var_rel = [keys.var_rel];
            var_unrel  = [keys.var_unrel];
            
            mean_rel = mean(mat_rel);
            std_rel = sqrt(mean(var_rel))/sqrt(length(keys));
            
            mean_unrel = mean(mat_unrel);
            std_unrel = sqrt(mean(var_unrel))/sqrt(length(keys));
            
            
%            [h,p] = ttest(mat_rel, mat_unrel)
            
            fig = Figure(101,'size',[50,40]); bar([mean_rel,mean_unrel], 'barwidth', 0.5, 'facecolor', [0.8,0.8,0.8]); hold on
            errorbar([mean_rel,mean_unrel], [std_rel,std_unrel],'LineStyle','None', 'Color', 'k');
%             ylim([0,3]); 
            xlim([0.2,2.8])
            set(gca, 'xTickLabel',{'Retinotopic', 'Non-retinotopic'});
            ylabel('Mean z scores')
       
            fig.cleanup; 
            fig.save('Retin_stat_all'); 
        end
            
    end
end