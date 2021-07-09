function Image_Pre_Edge_Detect(tit,scale_mag)

[I] = imread(tit);
I = imresize(I,scale_mag);

%----------------------------Edge Detection-------------------------------%
figure
imshow(I);     % show the image 
title('Select the ROI & then double click');  
h = imrect;            % use this function to select region of interest ROI
position = wait(h);
position = round(position);
RGB = I(position(2):position(2)+position(4),position(1):position(1)+position(3),:);    % obtain the intensity values of the selected ROI

close


if size(RGB,3)==3
RGB = rgb2gray(RGB);  %Conver image from RedGreenBlue to grayscale image 
end
figure (9)
imshow(RGB)
title('Gray Scale Transformed Image')

J = flip(RGB);        % flip the image (turn upside down) by reversing each element of the intensity values in each column
 figure (10)
 imshow(J)
 title('Fliped Image of the GrayScale Image')
 
J_Filt = imgaussfilt(J,1);  % filter image
 figure (11)
 imshow(J_Filt)
 title(' Filtered Fliped Image of the GrayScale Image')

J_Edges = edge(J_Filt,'Canny');  % detect egdes using Canny algorithm. Returns a binary image by assigning 1 to points (location of pixel) with edge and 0 elsewhere
figure (12)
imshow(J_Edges)
title(' Detected Egdes using Canny Algorithm')

boundary_thickness = 3;%[pixel]

SE = strel('disk',1);

J_Dil = imdilate(J_Edges,SE);     % Dilate (enlarge) the edges of the Image (i.e. dilate J_Edges) still a binary image
figure (13)
imshow(J_Dil)
title('Dilated Image of the detcted edges')

position_objects = J_Dil + 1;      
Taps_Drawings{1,1} = position_objects(:);    % Saves Position of edge objects **position_objects** as column vector instead of matrix
Taps_Drawings{1,2} = J;
    
save('Taps_Drawings.mat','Taps_Drawings');

figure(14)
imshowpair(flip(J_Edges),flip(J));
title('Detected Edges')

end
