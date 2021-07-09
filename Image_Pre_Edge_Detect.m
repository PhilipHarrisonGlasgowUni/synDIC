
function Image_Pre_Edge_Detect(ROI,handles)


 if handles.actal_dimensions==1
 realWidth=handles.realWidth *1000; realHeight=handles.realHeight *1000;
 [I] =handles.ref_Image;
 [I]= imresize(I,[realHeight,realWidth]);
 else
[I] =handles.ref_Image;
 end

Resiz_Val = handles.Scale_val;
%  I= tit;
%----------------------------Edge Detection-------------------------------%

if ROI==1   % A ROI is to be manually selected from the whole image
 I = imresize(I,Resiz_Val, 'cubic');   

set(handles.RefImage_panel,'Title','Select the ROI & then double click to continue', 'FontSize',9, 'FontWeight',' bold')

h = imrect;
position = wait(h);
position = round(position);
RGB = I(position(2):position(2)+position(4),position(1):position(1)+position(3),:);
imshow(RGB);
set(handles.RefImage_panel,'Title','Reference Image', 'FontSize',9,'FontWeight',' normal')
else            % If the whole image for analysis is the region of interest
    I = imresize(I,Resiz_Val, 'cubic');
    RGB = I;   
   

%   close
end

if size(RGB,3)==3
RGB = rgb2gray(RGB);
end
J = flip(RGB);

J_Filt = imgaussfilt(J,1);

J_Edges = edge(J_Filt,'Canny');


boundary_thickness = 3;%[pixel]

SE = strel('disk',1);

J_Dil = imdilate(J_Edges,SE);

position_objects = J_Dil + 1;
Taps_Drawings{1,1} = position_objects(:);
Taps_Drawings{1,2} = J;
    
save('Taps_Drawings.mat','Taps_Drawings');

% imshowpair(flip(J_Edges),flip(J));
% title('Detected Edges')

end
