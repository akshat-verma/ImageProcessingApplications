% Function to label and count nuclei and euroblasts
function labelcount(img,outdir)

% Create output directory if it doesn't exist
if (exist(out_dir)~=7)
    mkdir(out_dir);
    
fname = img;
info = imfinfo(fname);
num_images = numel(info);

% Preallocate Image Matrix to store 3D image from cropped 2D slices
[x,y,z] = size(imcrop(imread(fname,1),[28.5 29.5 206 220]));
allImgs = uint8(zeros(x, y, num_images));

% Define a structural element disk of radius 3
se_disk = strel('disk',3);


% Read the input stack frame by frame
for k = 1:num_images
    A = imread(fname,k);
    
    if isempty(strfind(fname, 'blue')) % if the stack is not blue i.e red
        A = A(:,:,1); % Extract red channel from the image
        label = 'NB'; % Define the label "NB" for neuroblasts

    else 
        A = A(:,:,3); % Extract blue channel from the image
        label = 'N';  % Define the label "N" for nuclei

    end
    
    A = imcrop(A,[28.5 29.5 206 220]) % Cropping the iage to get rid of other cell parts
   
    A = medfilt2(A); % Applying median filter
   
    A = im2bw(A,graythresh(A)); % Thresholding using graythresh
   
    A = imfill(A,'holes'); % fill holes
    
    A = imopen(A,se_disk); % open operation using disk as structural element

   
    %  Finding connected components which are greater than 30 and removing
    %  them, as they constitute noise
    CC = bwconncomp(A,8);
    S = regionprops(CC, 'Area'); 
    L = labelmatrix(CC);
    A = ismember(L, find([S.Area] <= 30));
    
    % Visualizing and printing the labelled 2D image, it is just for the
    % purpose of visualisation, actual count is calculated on the 3D image
    % using bwlabeln below
    [L2,N] = bwlabel(A);
    vislabels(L2,label);
    print(strcat(outdir,'//',num2str(k),'.png'),'-dpng')
    
    % Creating 3D image from the 2D slices by stacking them
    allImgs(:,:,k) = A;
end

% Calling bwlabeln on 3D image and get the count
[L, NUM] = bwlabeln(allImgs)
