function Mesh_Gen_ABAQUS(height,width,mesh_order_x,mesh_order_y,handles)

[status,msg] = mkdir('ABAQUS_SIMULATIONS');

NumMat = handles.NumMaterials; % get total number of materials in the image as supplied by user
no_images = handles.no_images;
time = handles.time;
NumMat = handles.NumMaterials;
Scale_val=handles.Scale_val;
strch = handles.strch;

Tabular_Load= handles.Tabular_Load; Explicit_Analysis= handles.Explicit; Static= handles.Static;
DISPLACEMENT_LOAD =handles.Displacement_load; GRAV_LOAD  =handles.Gravity_load;

Init_Increment = time/no_images;
Min_Increment = Init_Increment;Max_Increment =Init_Increment;

  if GRAV_LOAD==1 && Tabular_Load ==1
        Init_Increment = 0.01;
        Min_Increment = 1e-09;  % uses very small step size, slow but allows large deformation conv.
        Max_Increment = 1;   
  end


Material_Prop = handles.Material_Prop;
waitbar(1/5)

if Tabular_Load == 1
    deflection=1;                    % if the displacement values know, then 1 is used to fill the magnitude value
    deflection=num2str(deflection);
else
    deflection = num2str(height*(strch));   % How much to stretch the image
   
end



[x,y] = meshgrid(0:width/mesh_order_x:width,0:height/mesh_order_y:height);
x = x'; y = y';

tot_num_nodes = size(x,1)*size(x,2);
element_labels = [reshape([1:tot_num_nodes],size(x,1),size(x,2))]';

nodes = [[1:tot_num_nodes]',x(:),y(:)];

siz_col = size(element_labels,2);
siz_row = 1;
ref_label = [element_labels(1,1),element_labels(1,2),element_labels(2,2),element_labels(2,1)];

n = 0;
for i = 0:mesh_order_y-1
    for j = 0:mesh_order_x-1
        n = n+1;
        elements(n,:) = [n,ref_label+(j*siz_row)+(i*siz_col)];
    end
end

if handles.Plot_Mesh == 1
 figure('NumberTitle','off','Name','Finite element mesh','Visible','on','MenuBar','none');
 imshow(handles.ref_Image)
plotMesh(nodes(:,2:end),elements(:,2:end),'Q4', '-b')
end

if handles.Slits == 1
    Slit = handles.SlittedElements;
    element = elements(:,2:end);
    slitElems = [];
    
    switch handles.SlitType
        case 1
            for islit = 1:size(Slit,1)
                getSlit = Slit(islit,:);
                xmin = getSlit(1); xmax = getSlit(2); ymin = getSlit(3); ymax = getSlit(4); % Image coordinates
                yy(1,1) = height-ymin; yy(1,2) =height-ymax;
                yymin = min(yy); yymax = max(yy);
                %     pos = [xmin ymin (xmax-xmin) (ymax-ymin)]; Need to this in Image_Pre
                SlitNodes = find (nodes(:,2)>=xmin & (nodes(:,2) <=xmax) & (nodes(:,3)>=yymin) & (nodes(:,3)<=yymax));
                slitElem = [];
                for ielem = 1:size(element,1)
                    elem = element(ielem,:);
                    aa = ismember(elem,SlitNodes);
                    if aa == 1
                        slitElem = [slitElem ;ielem];  % elements within the stitched region can also be used as elements to be removed for tears
                    end
                end
                slitElems = [slitElems;slitElem];
            end
            clear element slitElem Slit SlitNodes getSlit
            
        case 2
            for islit = 1:size(Slit,1)
                getSlit = Slit(islit,:);
                xmin = getSlit(1); xmax = getSlit(2); ymin = getSlit(3); ymax = getSlit(4); % Image coordinate
                yy(1,1) = height-ymin; yy(1,2) = height-ymax;
                yymin = min(yy);  yymax = max(yy);
                
                SlitNodes = find(nodes(:,2) >= xmin & (nodes(:,2) <= xmax) & (nodes(:,3) >= yymin) & (nodes(:,3) <= yymax));  % get all nodes within this coordinates
                slitElem = [];
                for ielem = 1:size(element,1)
                    elem = element(ielem,:);
                    aa = any(ismember(elem,SlitNodes));  % any element that contains a slitnode will be deleted
                    if aa == 1
                        slitElem = [slitElem ;ielem];  % elements within the stitched region can also be used as elements be removed as tears
                    end
                end
                slitElems = [slitElems;slitElem];
            end
         clear element slitElem Slit SlitNodes getSlit  
    end
end




if handles.SticthedElement == 1    %For patched Fabric
    Stitched = handles.StitchedElements;  %in Image coordinates
    element = elements(:,2:end);
    stitElems = [];

    for istitch = 1:size(Stitched,1)
        getStitched = Stitched(istitch,:);
        xmin = getStitched(1); xmax = getStitched(2); ymin = getStitched(3); ymax = getStitched(4);
        yy(1,1) = height-ymin; yy(1,2) = height-ymax;  %FEA Coordinate
        yymin = min(yy); yymax = max(yy);
        StitchedNodes = find(nodes(:,2) >= xmin & (nodes(:,2) <= xmax) & (nodes(:,3)>= yymin) & (nodes(:,3)<= yymax));
        stitElem=[];
        for ielem = 1:size(element,1)
            elem = element(ielem,:);
            aa = ismember(elem,StitchedNodes);
            if aa == 1
                stitElem = [stitElem ;ielem];  % elements within the stitched region can also be used as elements to be removed for tears
            end
        end
        stitElems = [stitElems ;stitElem];
    end
    clear element StitchedNodes elem stitElem Stitched
end



%---------------------Material Definiton----%  IDENTIFY ELEMENTS
%LOCATED ON THE EDGES AND ELEMENTS MESH THAT MAKE UP THE TAPESTRY GEOMETRY
load Taps_Drawings.mat;
idx_mat = Taps_Drawings{1,1};    % image edges (in bibary form. Previously known as Poistion_objects
I = Taps_Drawings{1,2};          % Tapestry Image
num_of_reg = size(unique(idx_mat),1)-1;

%%%%COMPUTE CENTRE OF EACH ELEMENT%%%%%
e_cents = 0.25.*(nodes(elements(:,2),2)+nodes(elements(:,3),2)+nodes(elements(:,4),2)+nodes(elements(:,5),2));
e_cents(:,2) = 0.25.*(nodes(elements(:,2),3)+nodes(elements(:,3),3)+nodes(elements(:,4),3)+nodes(elements(:,5),3));


I_tmp = zeros(size(I));                 %Initialise empty image same size as ROI from Tapestry Image
I_tmp(find(Taps_Drawings{1,1}==2)) = 1;  %Gives back the binary edge image

waitbar(3/5)
% figure(15)
% imshow(I_tmp)
% title('Regenerated Dilated Edge Image')

% xx= size(I_tmp);
% xy = find(I_tmp==1);  % find points located on the detected egdes (pixels that made up the edges)
[y0,x0] = ind2sub(size(I_tmp),find(I_tmp==1)); % y0 and xo gives the row and column number respectively of each point in find(I_tmp==1)
id_edge0 = knnsearch(e_cents,[x0,y0]); % search for every point in xo,yo its closest values in e_cents values and return the index of the elements. These are elements located along the edges

[~,id_taps] = setxor([1:size(elements,1)]',[id_edge0]); % returns difference between the two vectors i.e returns values not common in the two vectors. Gives number of finite elements that marches the Tapestry geometry.

id_taps = elements(id_taps,1);  %Gives the finite element numbers that marches the Tapestry geometry.

id_edge = id_edge0;

if NumMat > 1
    
    Elsets{1,1} = unique(id_taps);  % set of element numbers that matches tapestry geometry
    Elsets{1,2} = unique(id_edge);  % set of element numbers that matches tapstry edges
    ele_id = unique([Elsets{1,1};Elsets{1,2}]);
    if   handles.SticthedElement == 1
        Elsets{1,3} = stitElems;
    end
else
    ele_id = elements(:,1);
    Elsets{1,1} = ele_id;
    if handles.SticthedElement == 1
        Elsets{1,2} = stitElem;
    end
end

%--------------------------------Set Mapping-----------------------------%
switch Material_Prop
    case 'Linear_elastic'
        young  =   handles.Youngs;
        poisson =  handles.Poissons;
        for matNum = 1:NumMat
            Elastic_Mod(matNum ,1) = young(matNum);
            Poisson_Ratio(matNum ,1) = poisson(matNum);
        end
        if handles.SticthedElement == 1
            Elastic_Mod(NumMat+1 ,1) = handles.PatchedYoungs ;
            Poisson_Ratio(NumMat+1 ,1) = handles.PatchedPoissons ;
            NumMat=NumMat+1;
        end
        Fixed_Nodes = find(nodes(:,3)>0.99999999*max(nodes(:,3)));
        Moving_Nodes =  find(nodes(:,3)<0.000000001+min(nodes(:,3)));
        save('MatMap.mat','Elsets','Elastic_Mod','Poisson_Ratio','elements','e_cents','nodes');

    case 'Hyper_elastic'
        mu = handles.mu;
        alpha =  handles.alpha;
        D =  handles.D;
        for matNum = 1:NumMat
            Mu(matNum ,1) = mu(matNum);
            Alpha(matNum ,1) = alpha(matNum);
            Dee(matNum ,1) = D(matNum);
        end

        if handles.SticthedElement == 1
            Mu(NumMat+1  ,1) =  handles.Patch_mu;
            Alpha(NumMat+1 ,1) = handles.Patch_alpha;
            Dee(NumMat+1 ,1) =  handles.Patch_D;
            NumMat=NumMat+1;
        end

        Fixed_Nodes = find(nodes(:,3)>0.99999999*max(nodes(:,3)));
        Moving_Nodes =  find(nodes(:,3)<0.000000001+min(nodes(:,3)));
        save('MatMap.mat','Elsets','Mu','alpha','elements','e_cents','nodes');
end

waitbar(4/5)
if handles.FEA_SOFTWARE == 0
    return
else
    %--------------------------------------------%
    
    dlmwrite('ABAQUS_SIMULATIONS\elements.txt',elements(ele_id,:), 'delimiter', ',','precision', 20);
    dlmwrite('ABAQUS_SIMULATIONS\nodes.txt',nodes, 'delimiter', ',','precision', 20);
    
    
    %--------------------------------------------%
    
    filename = ['ABAQUS_SIMULATIONS\','EL_SETS.txt'];
    if exist(filename)
        delete(filename);
    end

    for k = 1:size(Elsets,2)
        header = ['*Elset, Elset=Set-',num2str(k)];
        [mat_set,padded_set] = vec2mat(Elsets{1,k},16);
        if isempty(padded_set)==1
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,'-append',mat_set, 'delimiter', ',','precision', 20);
        else
            clear M N
            M = mat_set(1:size(mat_set,1)-1,:);
            N = mat_set(size(mat_set,1),:);
            id = find(N>0);
            N = N(id);
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,M, '-append','delimiter', ',','precision', 20);
            dlmwrite(filename,N,'-append','delimiter',',','precision', 20,'roffset',0);
        end
        clear header mat_set padded_set M N id
    end
    
    for k = 1
        filename = ['ABAQUS_SIMULATIONS\','ND_SETS.txt'];
        if exist(filename)
            delete(filename);
        end
        header = ['*Nset, nset=Fixed_Nodes'];
        [mat_set,padded_set] = vec2mat(Fixed_Nodes,16);

        if isempty(padded_set) == 1
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,'-append',mat_set, 'delimiter', ',','precision', 20);
        else
            clear M N
            M = mat_set(1:size(mat_set,1)-1,:);
            N = mat_set(size(mat_set,1),:);
            id = find(N>0);
            N = N(id);
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,M, '-append','delimiter', ',','precision', 20);
            dlmwrite(filename,N,'-append','delimiter',',','precision', 20,'roffset',0);
        end

        clear header mat_set padded_set M N id
        header = ['*Nset, nset=Moving_Nodes'];
        [mat_set,padded_set] = vec2mat(Moving_Nodes,16);

        if isempty(padded_set) == 1
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,'-append',mat_set, 'delimiter', ',','precision', 20);
        else
            clear M N
            M = mat_set(1:size(mat_set,1)-1,:);
            N = mat_set(size(mat_set,1),:);
            id = find(N>0);
            N = N(id);
            dlmwrite(filename,header,'-append','delimiter','');
            dlmwrite(filename,M, '-append','delimiter', ',','precision', 20);
            dlmwrite(filename,N,'-append','delimiter',',','precision', 20,'roffset',0);
        end
        clear header mat_set padded_set M N id
    end
    
    %--------Write Abaqus Input File--------%
    waitbar(5/5)
    file=fopen(['ABAQUS_SIMULATIONS\','TAPS_FEM.inp'],'w');
    fprintf(file,'*Heading\n');
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*Node, input = nodes.txt\n');
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*Element, type=M3D4R, input = elements.txt\n');
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*include, input=EL_SETS.txt\n');
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*include, input=ND_SETS.txt\n');
    fprintf(file,'**---------------------------------------------------\n');
    for i = 1:size(Elsets,2)
        tit = ['*Membrane Section, elset=Set-',num2str(i),',material=material-',num2str(i),'\n'];
        fprintf(file,tit);
        fprintf(file,'1., 5\n');
    end
    
    fprintf(file,'**---------------------------------------------------\n');
    if Tabular_Load ==1
        % fprintf(file,'*Amplitude, name=Amp-1, definition = Tabular\n');   %Tabular load , you can change the amplitude time here
        RH=handles.Data_table;
        fprintf(file,'*Amplitude, name=Amp-1\n');
        fprintf(file,'%f,  %f,  %f,  %f,  %f,  %f,  %f,  %f \r \n', RH');
        fprintf(file,'\n');
        clear RH
    else  % Ramp load
        fprintf(file,'*Amplitude, name = Amp-1\n');
        fprintf(file,'0., 0., 1., 1.\n');
        
    end
    
    
    for i = 1:NumMat
        tit = ['*Material, name=material-',num2str(i),'\n'];
        fprintf(file,tit);
        if GRAV_LOAD == 1 || Explicit_Analysis==1
            Density = handles.Density;
            Density=num2str(Density);
            fprintf(file,'*Density\n');
            tit = [Density '\n'];
            fprintf(file,tit);
        end

        switch Material_Prop
            case 'Linear_elastic'
                fprintf(file,'*Elastic\n');
                tit = [num2str(Elastic_Mod(i,1)),',',num2str(Poisson_Ratio(i,1)),'\n'];
                fprintf(file,tit);
            case 'Hyper_elastic'
                tit='*Hyperelastic, ogden\n';
                fprintf(file,tit);
                tit = [num2str(Mu(i,1)),',',num2str(Alpha(i,1)),',',num2str(Dee(i,1)),'\n'];
                fprintf(file,tit);
        end
    end
    
    fprintf(file,'**---------------------------------------------------\n');
    
    if Tabular_Load == 1
     fprintf(file,'*Step, name=Step-1, nlgeom=YES, inc=10000\n');
    else
      fprintf(file,'*Step, name=Step-1, nlgeom=YES\n');       
    end

    if Explicit_Analysis == 1
        fprintf(file,'*Dynamic, Explicit\n');
        tit = [',', num2str(time),'\n'];
        fprintf(file,tit);
        fprintf(file,'*Bulk Viscosity\n');
        fprintf(file,'0.06, 1.2\n');   
    else
        fprintf(file,'*Static\n');
        tit = [num2str(Init_Increment),',',num2str(time),',',num2str(Min_Increment),',',num2str(Max_Increment),'\n'];
        fprintf(file,tit);
        
    end
    
    if handles.Slits == 1
        fprintf(file,'*MODEL CHANGE, TYPE=ELEMENT, REMOVE\n');
        fprintf(file,'%d,  %d,  %d,  %d,  %d,  %d,  %d,  %d \r \n', slitElems');
        fprintf(file,'\n');
    end
    
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*Boundary\n');
    fprintf(file,'Fixed_Nodes, ENCASTRE\n');
    
    %%%%%%% TRY GRAVITY LOAD %%%%%%%
    fprintf(file,'**-----------------------LOAD---------\n');
    
    if GRAV_LOAD == 1 && Tabular_Load == 0
        fprintf(file,'*Dload, amplitude= Amp-1\n');
        grav = handles.gravity;
        grav = num2str(grav);
        tit=[',GRAV,',grav,',', '0, -1, 0, \n'];
        fprintf(file,tit);
    elseif GRAV_LOAD == 1 && Tabular_Load == 1
        Init_Increment = 0.01;
        Min_Increment = 1e-09;
        Max_Increment = 1;
        fprintf(file,'*Dload, amplitude=Amp-1\n');   % Time dependent load
        fprintf(file,', GRAV,1, 0, -1, 0, \n');
    end
    
    if DISPLACEMENT_LOAD == 1
        fprintf(file,'*Boundary, amplitude= Amp-1\n');   % Should be same amplitude names as in the loading if amplidtude displacement is used as tabular disp
        fprintf(file,['Moving_Nodes, 2, 2,',deflection,'\n']);
    end
    
    fprintf(file,'**---------------------------------------------------\n');
    fprintf(file,'*Restart, write, number interval=1, time marks=NO\n');
    fprintf(file,['*Output, field, time interval=',num2str(time/no_images),', time marks=YES\n']);
    fprintf(file,'*Node Output\n');
    fprintf(file,'RF, U, UR\n');
    fprintf(file,'*Element Output, directions=YES\n');
    fprintf(file,'LE, S\n');
    fprintf(file,'*Output, history, variable=PRESELECT\n');
    fprintf(file,'*End Step\n');
    fclose all;
    
   
    
end
end
