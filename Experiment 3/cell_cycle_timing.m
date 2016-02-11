% loading image using loadimage4D function
[ I, n_f, n_s, n_c, row, col ] = loadimage4D( 'MbNB_Pos4004_z2-14_t1-341+cropped.tif' );

% Initialising matrix to store frame differences
diff = zeros(row,col,n_f-1);

% Calculating all consecutive frame differences and storing it in diff
for i=1:n_f-1
    diff(:,:,i) = I(:,:,i+1,8,2)-I(:,:,i,8,2);
end

% Calculating mean squared error between frame differences
t = zeros(n_f-2,1);
for i=1:n_f-2
    f_cur = diff(:,:,i);
    f_next = diff(:,:,i+1);
    f_cur_next = immse(f_next,f_cur);
    t(i) = f_cur_next;  
end
  

% Calculating standard deviation of mean squared error between consecutive
% frames
error_diff = zeros(n_f-2,1);
for i=1:n_f-3
    error_diff(i) = t(i+1)-t(i);
end
sd = sqrt(var(abs(error_diff)));

% Finding out frames which have mean squared error greater than its neighbouring frames on either side by the value of standard
% deviation of error 
counter = 1;
frame = zeros();
for i=2:n_f-3
    if (t(i) > t(i-1)+ sd) & (t(i) > t(i+1)+ sd)
            frame(counter) = i+2; 
            counter = counter + 1;    
    end
end



    