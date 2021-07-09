function [in_final] = FE_IMG_MAP(nodes_shifted,deformed_nodes,delta_shift_x,delta_shift_y,Taps_Drawings,xgrid,ygrid,I,mag_fact,FEA_SOFTWARE,deNum)

if FEA_SOFTWARE==1

tit = ['ABAQUS_SIMULATIONS\DATA\elements.txt'];
load(tit);
else
   load('MatMap.mat','elements') 
end
a = elements(:,2:end);
counts = histc(a(:),unique(elements(:,2:end)));   % get the number of times a node is repeated in the mesh
c = find(counts<4);       % remove single nodes connecting 4 elements to get nodes at the edges of the fea model

min_x = 20+min(nodes_shifted(:,1));  % add 20 to the x component node at the origin of the 
min_y = 20+min(nodes_shifted(:,2));   %add 20 to the y component node at the origin of the 
max_x = max(nodes_shifted(:,1))-20;   %substract 20 from the x component node at the end of image width 
max_y = max(nodes_shifted(:,2))-20;   %substract 20 from the x component node at the end of image height

vrt = [min_x,min_y;max_x,min_y;max_x,max_y;min_x,max_y];  % points coord of the resulting polygon


id_in = inpolygon(nodes_shifted(c,1),nodes_shifted(c,2),vrt(:,1),vrt(:,2)); % check if points in c are in the polygon vrt
id_in = find(id_in==1); % get points that are inside the polygon 

id_out = setxor(c,c(id_in)); % get points that are outside the polygon 
id_in = c(id_in);


nodes_tmp = nodes_shifted(id_out,:);   % Get the  image coordinates of the nodes that are outside the polygon
[all_pts] = inner_contour(nodes_tmp);
idx = knnsearch(nodes_shifted,all_pts);    % get all nodes in nodes_shifted that are near all_points coordinates
x = nodes_shifted(idx,1)+deformed_nodes(idx,2); % add x displacement to these nodes
y = nodes_shifted(idx,2)+deformed_nodes(idx,3); % add y displacement to these nodes

%Interpolate the deformation along the corner pixels
all_nodes_q = [];
for i = 1:size(x,1)-1
    xt1 = x(i)+(0.0000001.*rand);
    xt2 = x(i+1)+(0.0000001.*rand);
    yt1 = y(i)+(0.0000001.*rand);
    yt2 = y(i+1)+(0.0000001.*rand);
    xq = xt1:(xt2-xt1)/deNum:xt2;  
    yq = interp1([xt1,xt2],[yt1,yt2],xq);  % interpolate the nodal displaces along the points xq between two consecutive horizontal nodes
    all_nodes_q  = [all_nodes_q;[xq',yq']]; 
end

all_nodes_q = round(all_nodes_q);

I0 = zeros(size(I));
idI0 = sub2ind(size(I0),all_nodes_q(:,2),all_nodes_q(:,1));  % get the coordiantes of the all_nodes_q (corner pixels of reference image) from the enlarged image
I0(idI0) = 1;  % set the values of these points to 1


I0 = ~I0;  % convert I0 to binary image 
CC = bwconncomp(I0,4);  % returns 4 connected components in the binary image IO

% for i = 1:size(CC.PixelIdxList,2)
%     siz_i(i,1) = size(CC.PixelIdxList{1,i},1);
% end
% 
% id_inner_0 = CC.PixelIdxList{1,find(siz_i==max(siz_i))};

tst_pt = ceil(size(xgrid)./2);
[txt_pt_indx] = sub2ind(size(xgrid),tst_pt(1),tst_pt(2));
if ismember(txt_pt_indx,CC.PixelIdxList{1,1})==1
    id_inner_0 = CC.PixelIdxList{1,1};
end
if ismember(txt_pt_indx,CC.PixelIdxList{1,2})==1
    id_inner_0 = CC.PixelIdxList{1,2};
end


I0 = ~I0;
id_inner_0 = [id_inner_0;find(I0==1)];

in_final = unique(id_inner_0);   % gives the coordinates of all the pixels in the deformed image from the  englarged image

end
