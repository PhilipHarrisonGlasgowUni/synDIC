function Synthetic_Defor(inp,handles)

if handles.Meshdensity <= 6
deNum=10;       %  number of interpolation points that determines pixel locations along a element length
elseif handles.Meshdensity<=20
    deNum=40;
else
   deNum=120; 
end

scal_fact = 1;
FEA_SOFTWARE=handles.FEA_SOFTWARE;
if FEA_SOFTWARE==1
tit_raw = ['ABAQUS_SIMULATIONS\DATA\ABAQUS_RAW.mat'];

load(tit_raw,'ALL_Displacements'); 


tit_nodes = ['ABAQUS_SIMULATIONS\DATA\nodes.txt'];
load(tit_nodes);
else
    load('FEM.mat','ALL_Displacements')
    load('MatMap.mat','nodes')   
end

deformed_nodes = ALL_Displacements{inp+1,1};

deformed_nodes(:,2:end) = 1.*deformed_nodes(:,2:end);%rescaling
nodes = nodes(deformed_nodes(:,1),:);

nodes(:,2:end) = 1.*nodes(:,2:end);%rescaling

load('Taps_Drawings.mat');
Speckle_Image = Taps_Drawings{1,2};  %Tapestry image (ROI)

Speckle_Image = imnoise(Speckle_Image,'gaussian',0,4e-4);%4e-4 is variance and not std!

Speckle_Image = double(Speckle_Image)./255;%65535;%---->change this for uint8,16,32 accordingly

Speckle_Image = imresize(Speckle_Image,scal_fact,'cubic');%rescaling

maxDisp = max(abs(ALL_Displacements{handles.no_images+1,1}(:,3)));  % get the maximum displacement value




if maxDisp< 100
expected_defor=0.1;   % use 0.4 or higher for large deformation
elseif maxDisp< 450
expected_defor=0.2;
else
expected_defor=0.8;
end
siz = ceil(size(Speckle_Image).*(1+(2*expected_defor)));
siz = siz+100;  

I = zeros(siz);
I_cent = round(0.5.*size(I));
Sp_cent = floor(0.5.*size(Speckle_Image));

 if mod(size(Speckle_Image,1),2)==1 
delta_shift_x = [I_cent(1)-Sp_cent(1):I_cent(1)+Sp_cent(1)];
else
delta_shift_x = [I_cent(1)-Sp_cent(1):I_cent(1)+ Sp_cent(1)-1];  
end

if mod(size(Speckle_Image,2),2)==1
delta_shift_y = [I_cent(2)-Sp_cent(2):I_cent(2)+Sp_cent(2)];
else
delta_shift_y = [I_cent(2)-Sp_cent(2):I_cent(2)+Sp_cent(2)-1];  
end

I(delta_shift_x,delta_shift_y) = Speckle_Image;


save('Delta_Shifts.mat','delta_shift_x','delta_shift_y');

nodes_shifted = [nodes(:,2)+ delta_shift_y(1),nodes(:,3)+delta_shift_x(1)];  % centres the FE nodes on the image pixel locations
%------------------------------------------------------------%

[xgrid,ygrid] = meshgrid(1:size(I,2),1:size(I,1));

% gives the coordinates of all the pixels in the deformed image from the  englarged image
[in_final] = FE_IMG_MAP(nodes_shifted,deformed_nodes,delta_shift_x,delta_shift_y,Taps_Drawings,xgrid,ygrid,I,1,FEA_SOFTWARE,deNum);

%------------------------------------------------------------%

U_delta =  (deformed_nodes(:,2));
V_delta =  (deformed_nodes(:,3));  

% Interpolate the displacement on the valid points fron FE_IMG_MAP
U_delta_Intp = griddata(nodes_shifted(:,1)+U_delta,nodes_shifted(:,2)+V_delta,U_delta,xgrid(in_final),ygrid(in_final),'cubic');
V_delta_Intp = griddata(nodes_shifted(:,1)+U_delta,nodes_shifted(:,2)+V_delta,V_delta,xgrid(in_final),ygrid(in_final),'cubic');
id_deformed = isnan(U_delta_Intp); id_deformed = find(id_deformed==0);
%------------------------------------------------------------%

idnan = isnan(U_delta_Intp); idnan = find(idnan==0); U_delta_Intp = U_delta_Intp(idnan);
idnan = isnan(V_delta_Intp); idnan = find(idnan==0); V_delta_Intp = V_delta_Intp(idnan);

J = zeros(size(I)); 
J(in_final(id_deformed)) = 1;
[Y_Intp,X_Intp] = ind2sub(size(J),find(J==1));
GI = I;


if inp<10
FINTP = griddedInterpolant(xgrid',ygrid',GI','cubic');
I_deformed = zeros(size(I));
G = FINTP(X_Intp-U_delta_Intp,Y_Intp-V_delta_Intp);
I_deformed(in_final(id_deformed)) = G;
I_deformed = imresize(I_deformed,1/scal_fact,'cubic');
imwrite((flip(I_deformed)),['frame_0000',num2str(inp),'.tiff']);
end
if inp>9
FINTP = griddedInterpolant(xgrid',ygrid',GI','cubic');
I_deformed = zeros(size(I));
G = FINTP(X_Intp-U_delta_Intp,Y_Intp-V_delta_Intp);
I_deformed(in_final(id_deformed)) = G;
I_deformed = imresize(I_deformed,1/scal_fact,'cubic');
imwrite((flip(I_deformed)),['frame_000',num2str(inp),'.tiff']);
end

