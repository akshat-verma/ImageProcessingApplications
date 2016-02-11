clc;
clear;
close all;
load('TheTemplates.mat');

fname = 'TheImages.tif';
info = imfinfo(fname);
num_images = numel(info);

F = fspecial('Gaussian',[6,6],0.5 ); %Gaussian filter

% Initialising the local maxima finder object and setting parameters
hLocalMax = vision.LocalMaximaFinder;
hLocalMax.MaximumNumLocalMaxima = 100;
hLocalMax.NeighborhoodSize = [5 5];

% templateMatch array contains the index of best matching template for each pixel in all the frames
templateMatch = zeros(277,283,100);
% location array contains the x,y location of peaks/local maxima in all the frames
location = zeros(100,2,100);

for k = 1:100 % Loop over all the frames
    
    I = imread(fname, k); % Read image
    I = imfilter(I, F, 'same'); % Image after Gaussian
    [m,n] = size(I);
    % Initialise matrix to find maximum correlation between image and template for each frame
    maxCor = ones(m+20-1,n+20-1)*(-1); 

    % Initalise matrix to store index of best matching template for each frame
    maxTemplate = zeros(m+20-1,n+20-1); 
    
    for i = 1:20  % Loop over all the templates
        T = template(i,:,:); 
        T = squeeze(T); % Get the individual template matrix
       
        I_T = normxcorr2(T,I); % Perform normalized cross correlation of template with image
       
        prevMax = maxCor;
        
        % Updating the maximum correlation matrix if correlation between
        % current template and image is better than previous correlation
        maxCor = max(maxCor,I_T);
     
        % Saving the index of best matching template till now for every pixel
        nz = find(maxCor - prevMax);
        maxTemplate(nz) = i;
        
    end
    
    % Choosing threshold to find local maxima peaks as mean + 3 * standard
    % deviation in the maximum correlation matrix 
    hLocalMax.Threshold = mean2(maxCor) + 3*std2(maxCor);
    
    % Calculating local maxima in the correlation matrix
    loc = step(hLocalMax, maxCor);
    loc(loc(:,1)>258 | loc(:,2)>264 | loc(:,1)==0 | loc(:,2)==0  ,:) = [];
    loc(100,2) = 0; % Extending size of matrix to 100
    location(:,:,k) = loc ; % Appending the location matrix for individual frame to 3-d array that contains locations for all frames
    templateMatch(:,:,k) = maxTemplate; % Appending the best template matrix for individual frame to 3-d array
end

% After executing above steps:
% location array contains the x,y location of peaks/local maxima in all the frames
% templateMatch array contains the index of best matching template for each pixel in all the frames
% x = [1,40,90,100,150,200,250,300];
% y = [1,50,80,120,150,160,450,230];
% f = fit(x.',y.','gauss2');
% plot(f,x,y)

C = permute(location,[1 3 2]);
C = reshape(C,[],size(location,2),1);
counter = 1;
for i = 1:100:10000 
    C(i:i+99,3) = counter;
    counter = counter + 1;
end
C(C(:,1)==0 | C(:,2)==0 ,:) = [];
for ii = 1:size(C,1)
C(ii,4) = templateMatch(C(ii,1),C(ii,2),C(ii,3));
end

% Y = pdist(C(:,[1 2 4]),'euclidean');
% Z = linkage(Y);
% dendrogram(Z);
% cluster = cluster(Z,'maxclust',8);
% C(:,5 ) = cluster;