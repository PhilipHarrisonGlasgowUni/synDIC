function FEM(handles,height,no_images)

%Written by Kenneth Nwanoro

global nodes elements
elemType='Q4';
load('MatMap.mat','Elsets','elements','nodes');
strch=handles.strch;

% Determine user defined load type
if handles.Gravity_load ==1
    Load_Type='Gravity_Load';
elseif  handles.Displacement_load ==1
    Load_Type='Displacement_Load';
end

W= ones(4,1); % Guassian weights
Q= [0.5774  0.5774; 0.5774  -0.5774;-0.5774  0.5774;-0.5774  -0.5774 ]; % Guass points
elements =elements(:,2:5);

Fixed_Nodes = find(nodes(:,3)>0.99999999*max(nodes(:,3)));
Moving_Nodes =  find(nodes(:,3)<0.000000001+min(nodes(:,3)));
numelSet= size(Elsets,2);
nodes=nodes(:,2:end);

%%%%%%Apply fixed boundary conditions

for ic=1:length(Fixed_Nodes)
    Vdof= [Fixed_Nodes(ic) 2 0];
    Udof= [Fixed_Nodes(ic) 1 0];
    VDOF(ic,:)=Vdof;
    UDOF(ic,:) = Udof;
end
SDISPT1=[UDOF;VDOF];

numelem = size(elements,1);
numnode= size(nodes,1);

NEQ=2*numnode;
GKF = zeros(NEQ,NEQ);   % Global stiffness matrix
FORCE= zeros(NEQ,1);

Xdisp = zeros(numnode,1); % 1 3 5 7 ...
Ydisp= zeros(numnode,1);  % 2 4 6 8 ...
DISPALCEMENT =[(1:numnode)',Xdisp,Ydisp];

ALL_Displacements{1,1}=DISPALCEMENT;


for el= 1: numelem
    sctr = elements(el,:);
    nn   = length(sctr);
    sctrB=assemblyA(el);
    
    for elSet= 1: numelSet
        
        if (ismember(el,Elsets{1,elSet}))
            
            E= handles.Youngs(elSet);
            nu= handles.Poissons(elSet);
            continue
        end
    end

    C = E/(1-nu^2)*[ 1   nu 0;
        nu  1  0 ;
        0   0  0.5*(1-nu) ];    
    
% Assemble global stiffness matrix

    for kk= 1: size(W)   
        pt =Q(kk,:);
        [B,J0,~] = Bmatrix(pt,elemType,el);
        GKF(sctrB,sctrB)=GKF(sctrB,sctrB)+B'*C*B*W(kk)*det(J0);
    end
end


switch Load_Type

    case 'Displacement_Load'
        
        switch handles.Tabular_Load
            case 1
                
                for numImage=1:no_images
                    defl=handles.Data_table(1,numImage);
                    for id=1:length(Moving_Nodes)
                        Dispdof = [Moving_Nodes(id) 2 defl];
                        SDISPT2(id,:)= Dispdof;
                    end
                    SDISPT=[SDISPT1; SDISPT2];
                    SDISPT=sortrows(SDISPT,1);
                    
                    FIXEDDOF=(2*(SDISPT(:,1)-1)+ SDISPT(:,2))';
                    
                    
                    bcval=SDISPT(:,3)';
                    n=length(FIXEDDOF);
                    sdof=size(GKF);
                    
                    for i=1:n
                        c=FIXEDDOF(i);
                        for j=1:sdof
                            GKF(c,j)=0;
                        end
                        
                        GKF(c,c)=1;
                        FORCE(c)=bcval(i);
                    end
                    
                    
                    [L,U] = lu(GKF) ;
                    y = L\FORCE;
                    DISPTD= U\y ;
                    
                    DISPTDT(:,numImage)= full(DISPTD);
                    Xdisp = DISPTD(1:2:2*numnode-1) ; % 1 3 5 7 ...
                    Ydisp= DISPTD(2:2:2*numnode) ; % 2 4 6 8 ...
                    DISPALCEMENT =[(1:numnode)',Xdisp,Ydisp];
                    
                    ALL_Displacements{numImage+1,1}=DISPALCEMENT;
                end
                
            case 0

                deflection =(height*(strch));
                for numImage=1:no_images
                    loadFactor =numImage/no_images ;
                    defl = deflection * loadFactor;
                    for id=1:length(Moving_Nodes)
                        Dispdof = [Moving_Nodes(id) 2 defl];
                        SDISPT2(id,:)= Dispdof;
                    end
                    SDISPT=[SDISPT1; SDISPT2];
                    SDISPT=sortrows(SDISPT,1);
                    
                    FIXEDDOF=(2*(SDISPT(:,1)-1)+ SDISPT(:,2))';
                    
                    
                    bcval=SDISPT(:,3)';
                    n=length(FIXEDDOF);
                    sdof=size(GKF);
                    
                    for i=1:n
                        c=FIXEDDOF(i);
                        for j=1:sdof
                            GKF(c,j)=0;
                        end
                        
                        GKF(c,c)=1;
                        FORCE(c)=bcval(i);
                    end
                    
                    
                    [L,U] = lu(GKF) ;
                    y = L\FORCE;
                    DISPTD= U\y ;
                    
                    DISPTDT(:,numImage)= full(DISPTD);
                    Xdisp = DISPTD(1:2:2*numnode-1) ; % 1 3 5 7 ...
                    Ydisp= DISPTD(2:2:2*numnode) ; % 2 4 6 8 ...
                    DISPALCEMENT =[(1:numnode)',Xdisp,Ydisp];
                    
                    ALL_Displacements{numImage+1,1}=DISPALCEMENT;
                    
                end
        end
        
    case 'Gravity_Load'
        density = handles.Density;
        gravity= handles.gravity;
        NDISP=size(SDISPT1,1);
        PROPu(1)=113e9;
        
        FIXEDDOF=2*(SDISPT1(:,1)-1)+ SDISPT1(:,2);
        GKF(FIXEDDOF,:)=zeros(NDISP,NEQ);
        GKF(FIXEDDOF,FIXEDDOF)=PROPu(1)*eye(NDISP);
        
        for numImage=1:no_images
            loadFactor = numImage/no_images ;
            for el= 1: numelem
                f = zeros(4,1);
                sctrB=assemblyA(el);
                for kk= 1: size(W)
                    pt =Q(kk,:);
                    [~,J0,N] = Bmatrix(pt,elemType,el);
                    
                    f = f + N*W(kk)*density*gravity*loadFactor*det(J0);
                    
                end
                weight = [0 -f(1) 0 -f(2) 0 -f(3)  0 -f(4)]';
                FORCE(sctrB)= FORCE(sctrB) + weight;
            end
            
            FORCE(FIXEDDOF)=0;
            DISPTD = GKF\FORCE ;
            Xdisp = DISPTD(1:2:2*numnode-1) ; % 1 3 5 7 ...
            Ydisp= DISPTD(2:2:2*numnode) ; % 2 4 6 8 ...
            DISPALCEMENT =[(1:numnode)',Xdisp,Ydisp];
            DISPTDT(:,numImage)= DISPTD ;
            ALL_Displacements{numImage+1,1}=DISPALCEMENT;
        end
        
end


waitbar(3/4)
order = [ 1 , 4 ; 2 , 3 ];
gauss = [ -0.577350269189626E+00 , 0.577350269189626E+00 ];
Nodal = [(1:numnode)',(zeros(numnode,3))];
ALL_Strains{1,1}=Nodal;

for ImageNum=1:no_images
    NodalR= zeros(numnode,4);
    for iel=1: numelem
        sctr = elements(iel,:);
        U =element_dispN(iel,DISPTDT(:,ImageNum));
        
        
  %%%%%%% Gauss strain as computation strain      
%         for kk= 1:size(W,1)
%              pt= Q(kk,:);
%              [B,~,~] =Bmatrix(pt,elemType,iel);
%               STRAIN =B*U;   % strain at gauss point
%               
%               Nodal(sctr(kk),1) = sctr(kk);
%               Nodal(sctr(kk),2) = STRAIN(1);
%               Nodal(sctr(kk),3) = STRAIN(2);
%               Nodal(sctr(kk),4) = STRAIN(3);            
%         end
                
        
   %%%%%%% Nodal average strain as computation strain      
        
        STRAIN=[];
        for i=1:2
            for j=1:2
             
                pt= [gauss(i) gauss(j)];
                [B,~,~] =Bmatrix(pt,elemType,iel);
                
                pt= [1/pt(1),1/pt(1)];
           
                STRAIN(:,order(i,j)) =B*U;   % strain at gauss point
                [~,~,Xtrap(order(i,j),:)]=Bmatrix(pt,elemType,iel);
                
            end
        end
        NodStrain =transpose(Xtrap*transpose(STRAIN));  %element nodal strain
        
        % Assign each element node its strain components

        for inod =1: 4
            for istr= 1:3
                NodalR(sctr(inod),istr)= NodalR(sctr(inod),istr)+ NodStrain(istr,inod);             
            end
        end
        NodalR(sctr,4) = NodalR(sctr,4) + 1;
        
    end
    
%     Nodal(:,2:end)=NodalR(:,1:3);   % Nodal strain
    
    NodalMean= [];
    for imean = 1 : numnode
    NodalMean = [NodalMean ; NodalR(imean,1:3)/NodalR(imean,4)]; % Nodal average strain
    end
    Nodal(:,2:end)=NodalMean(:,1:3);
    ALL_Strains{ImageNum+1,1}=Nodal;
end


waitbar(4/4)
save('FEM.mat','ALL_Displacements','ALL_Strains');
clear GKF FORCE FIXEDDOF U y L bcval SDISPT Moving_Nodes Moving_Nodes nodes elements Elsets
clear DISPALCEMENT  Xdisp  Ydisp DISPTDT Nodal NodalR NodalMean 

