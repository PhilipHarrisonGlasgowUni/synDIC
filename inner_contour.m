function [all_pts] = inner_contour(nodes_tmp);

all_pts = [];


nodes_tmp0 = nodes_tmp;
id_tmp0 = [1:size(nodes_tmp,1)]';  % Get number of search points
firts_pt = nodes_tmp(1,:);
firts_pt_org = firts_pt;

id_tmp0_up = setxor(1,id_tmp0);  % get search points
nodes_tmp0_up = nodes_tmp0(id_tmp0_up,:);  % get coordinates of search points

all_pts = [firts_pt];  % initialise first point array with the first node that is outside the polygon

for i = 1:size(nodes_tmp0,1)-2
idx = knnsearch(nodes_tmp0_up,firts_pt);  % find the nearest node to the current first_pt
all_pts = [all_pts;nodes_tmp0_up(idx,:)];  % store nearest point to first points array
firts_pt = nodes_tmp0_up(idx,:);         % make the current nearest point as the first_pt

id_tmp0 = [1:size(nodes_tmp0_up,1)]';    % update the number of search points

id_tmp0_up = setxor(idx,id_tmp0);        % get current search points
nodes_tmp0_up = nodes_tmp0_up(id_tmp0_up,:);  % coordinates of current  search points
end

all_pts = [all_pts;nodes_tmp0_up;firts_pt_org]; %  all points 

end

