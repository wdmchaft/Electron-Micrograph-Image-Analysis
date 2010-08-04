function feat = cbi_vesicledetector(I, F, K)

FR = imfilter(double(I), F, 'replicate', 'conv');

% Detect Interest Points and Keep K(15) strongest points
bw = FR > imdilate(FR, [1 1 1; 1 0 1; 1 1 1]);
bw(1,:) = 0; bw(:,1) = 0; bw(end,:)= 0; bw(:,end)= 0;
[y x]  =find(bw);

% Cull lower magnitude peaks
resmag = FR(sub2ind(size(FR), y, x));
[sort_val sort_ind] = sort(resmag, 'descend');
y(sort_ind(K+1:end)) = []; x(sort_ind(K+1:end)) = [];

% Plot Filter Response and Interest Points
        figure(1);subplot(211); imagesc(FR);
                  subplot(212); imshow(uint8(I));
        hold on; plot(x, y, 'r*'); hold off;

% Sample Patches around the descriptors
        WIN_SIZE = 15;
        WE = (WIN_SIZE-1)/2;
        Ipad = padarray(FR, [WE WE], 'symmetric');
        ypad = y + (WIN_SIZE-1)/2;
        xpad = x + (WIN_SIZE-1)/2;

% For all patches in the image, extract features
        for iter = 1:K
            curr_patch = Ipad(ypad(iter)-WE:ypad(iter)+WE, xpad(iter)-WE:xpad(iter)+WE);
    
            tp = 1 - im2bw(uint8(curr_patch)); 
            CC = bwconncomp(tp);        numPixels = cellfun(@numel,CC.PixelIdxList);        [biggest,idx] = max(numPixels);
                if(isempty(biggest))
                    imshow(uint8(curr_patch)); pause;
                    biggest = 0;
                end
            [ys xs] = find(tp);
            [Ix Iy gradmag] = vrl_imgrad(curr_patch);
            feat(iter, :) = [mean(curr_patch(:))/255; std(curr_patch(:))/255];
                                % biggest/(WIN_SIZE^2); cbi_meascirc(xs, ys); entropy(curr_patch);     entropy(gradmag);];           
        end