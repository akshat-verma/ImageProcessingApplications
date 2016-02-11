%Obtains images path and count
function segmentation(img)
fname = img;
info = imfinfo(fname);
num_images = numel(info);

cform = makecform('srgb2lab');

for k = 1:num_images
    clearvars -except fname k cform
    A = imread(fname, k);
    
    %cform
    lab_A = applycform(A,cform);
    
    ab = double(lab_A(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);
    nColors = 3;   %# of colors
    
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', ...
        'Replicates',3);
    pixel_labels = reshape(cluster_idx,nrows,ncols);%Reshapes into image-form
    
    rgb_label = repmat(pixel_labels,[1 1 3]);
    
    for i = 1:nColors
            color = A;
            color(rgb_label ~= i) = 0;
            
            
            indices_mat=zeros(size(A,1),size(A,2));
            
            threshold=mean(mean(nonzeros(sum(double(color(:,:,:)),3))))*.5;
            
            %indices_mat=zeros(size(color,1),size(color,2));
            for ii=1:size(color,1)
                for jj=1:size(color,2)
                    tmp=find((color(ii,jj,:)==max(color(ii,jj,:)) & sum(double(color(ii,jj,:)))>threshold & min(double(color(ii,jj,:)))/max(double(color(ii,jj,:)))<.5),1);%
                    if isempty(tmp)==0
                        indices_mat(ii,jj)=tmp;
                    end
                end
            end
            rgb_index(i)=mode(mode(indices_mat(find(indices_mat(:,:)~=0))));
            occurences(i)=size(find(indices_mat==rgb_index(i)),1);
            
            rgb_str={'red','green','blue'};
            imwrite(color, sprintf('%s.tif',char(rgb_str(rgb_index(i)))),'tif','writemode','append');
        end
        display(rgb_index);
        display(occurences);
        
end
