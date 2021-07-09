
function [I,VAL_DIC_Intp,abaqus_VAL,xgrid,ygrid,PercentError,difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum)


scal_fact = 1;
a = what;                                           % Gives current working directory
frame = ['\frame_0000',num2str(0),'.tiff'];
tit_image = [a.path,'\',pattern_type,frame];

switch DIC_SOFTWARE    %To get result file path in a folder
    
    case 0               %% VIC 2D NOT WAS USED
if id_frame < 10

    frame_mat = ['\frame_0000',num2str(id_frame),'.mat'];
end

if id_frame > 9

    frame_mat = ['\frame_000',num2str(id_frame),'.mat'];
end

tit_mat = [a.path,'\',pattern_type,frame_mat];

  case 1                         %% VIC 2D WAS USED
  mat_file=(dir([pattern_type '/*.mat']));
  tit_mat=[mat_file.folder,'\',mat_file.name];

end

load('Delta_Shifts.mat');


if  FEA_SOFTWARE == 1
    tit_raw = ['ABAQUS_SIMULATIONS\DATA\ABAQUS_RAW.mat'];
    load(tit_raw,'ALL_Displacements','ALL_Strains','Taps_Drawings');
else
    load('FEM.mat','ALL_Displacements','ALL_Strains')
    load('Taps_Drawings.mat','Taps_Drawings')
end



if abaqus_var < 3
    VAL_INPUT_ABAQUS = ALL_Displacements{id_frame+1,1}(:,abaqus_var+1);
end

if abaqus_var > 2 && abaqus_var < 6
    VAL_INPUT_ABAQUS = ALL_Strains{id_frame+1,1}(:,abaqus_var-1);
end

if abaqus_var >= 6
    VAL_INPUT_ABAQUS = 1;
end

if TEARS == 1 && abaqus_var >= 3   % ABAQUS NODAL STRAINS ARE LESS THAN ACTUAL NODES IN THE MODEL WHEN ELEMENTS ARE DEACTIVATED
    Newstrain= zeros(size(ALL_Displacements{1,1},1),2);
    Newstrain(:,1) = (1:size(Newstrain,1));
    strainId = ALL_Strains{id_frame+1,1}(:,1);
    Newstrain(strainId,2)=VAL_INPUT_ABAQUS;
    VAL_INPUT_ABAQUS=Newstrain(:,2);
end

I = imread(tit_image);
[xgrid,ygrid] = meshgrid(1:size(I,2),1:size(I,1));

if DIC_SOFTWARE == 0  %vic 2D was used for DIC
     
    load(tit_mat,'x','y','sigma');
    if abaqus_var == 1
        val_dic = load(tit_mat, 'u');
        val_dic = val_dic.u;
    end
    if abaqus_var == 2
        val_dic = load(tit_mat, 'v');
        val_dic = val_dic.v;
    end
    if abaqus_var == 3
        val_dic = load(tit_mat, 'exx');
        val_dic = val_dic.exx;
    end
    if abaqus_var == 4
        val_dic = load(tit_mat, 'eyy');
        val_dic = val_dic.eyy;
    end
    if abaqus_var == 5
        val_dic = load(tit_mat, 'exy');
        val_dic = val_dic.exy;
    end
    
    if abaqus_var == 6
        val_dic = load(tit_mat, 'sigma');
        val_dic = val_dic.sigma;
        abaqus_VAL=1;
    end
    %------------------------------------------------------------%
    
    val_dic(find(sigma==-1)) = nan;
    VAL_DIC_Intp = griddata(x,y,val_dic,xgrid,ygrid,'cubic');
    
    
else  %%%% Ncorr was used for the DIC analysis
    
    load (tit_mat,'data_dic_save') 
        
    if abaqus_var == 1
        val_dic = data_dic_save.displacements(id_frame);   
        val_dic = val_dic.plot_u_cur_formatted;              
    end
    if abaqus_var == 2
        val_dic = data_dic_save.displacements(id_frame);
        val_dic = val_dic.plot_v_cur_formatted;            
    end
    if abaqus_var == 3
        val_dic = data_dic_save.strains(id_frame);
        val_dic = val_dic.plot_exx_cur_formatted;              
    end
    if abaqus_var == 4
        val_dic = data_dic_save.strains(id_frame);
        val_dic = val_dic.plot_eyy_cur_formatted;
    end
    if abaqus_var == 5
        val_dic = data_dic_save.strains(id_frame);
        val_dic = val_dic.plot_exy_cur_formatted;
    end
    
 %%compute location of data points and map the results on reference image
      
    fac= 1+ data_dic_save.dispinfo.spacing;
    
        if isdeployed
        load (tit_mat,'roi_mask')
        dic_roi = roi_mask(id_frame).val;
        if isempty(dic_roi)
            h = msgbox('Please use the ncorr data extraction script to extract the ref roi data points');
            uiwait(h)
            return
        end
        else
        dic_roi = data_dic_save.displacements(1).roi_dic.mask;
        end
    
    dic_roi = data_dic_save.displacements(1).roi_dic.mask;
    
    Xdisp_ref = data_dic_save.displacements(id_frame).plot_u_ref_formatted;
    
    Ydisp_ref = data_dic_save.displacements(id_frame).plot_v_ref_formatted;
    
    [ROI_Ref_Loc_Y,ROI_Ref_Loc_X] = find(dic_roi);
    Ref_Pos_Init = [ROI_Ref_Loc_X,ROI_Ref_Loc_Y];
    Ref_Pos_Init = (Ref_Pos_Init-1)*fac+1; 
   
    XPos = Xdisp_ref(dic_roi);  % x location of data point
    Ypos = Ydisp_ref(dic_roi);

    
    Loc=[Ref_Pos_Init(:,1) + XPos,Ref_Pos_Init(:,2) + Ypos];
    x = Loc(:,1); y = Loc(:,2);
    
    plot_data = val_dic(dic_roi);
    plot_data(plot_data==0) = nan;
    VAL_DIC_Intp = griddata(x,y,plot_data,xgrid,ygrid,'cubic');
    
end


if abaqus_var <= 5
    if FEA_SOFTWARE == 1
        tit_nodes = ['ABAQUS_SIMULATIONS\DATA\nodes.txt'];
        load(tit_nodes);
    else
        load('MatMap.mat','nodes')
    end
    
    
    nodes(:,2:end) = 1.*nodes(:,2:end);%rescaling
    
    nodes_shifted = [nodes(:,2)+delta_shift_y(1),nodes(:,3)+delta_shift_x(1)];
    %------------------------------------------------------------%
    
    [in_final] = FE_IMG_MAP(nodes_shifted,[nodes(:,1),0.*nodes(:,2),0.*nodes(:,3)],delta_shift_x,delta_shift_y,Taps_Drawings,xgrid,ygrid,I,1,FEA_SOFTWARE,deNum);  % Map finite element on the image
    
    
    %------------------------------------------------------------%
    VAL_abaqus_Intp = griddata(nodes_shifted(:,1),nodes_shifted(:,2),VAL_INPUT_ABAQUS,xgrid(in_final),ygrid(in_final),'cubic');
    id_deformed = isnan(VAL_abaqus_Intp);
    id_deformed = find(id_deformed==0);
    
    idnan = isnan(VAL_abaqus_Intp); idnan = find(idnan==0); VAL_abaqus_Intp = VAL_abaqus_Intp(idnan);
    
    abaqus_VAL = zeros(size(I))+nan;
    abaqus_VAL(in_final(id_deformed)) = VAL_abaqus_Intp;
    
   
end



if abaqus_var==2
    yy = flip(abaqus_VAL);
   
    difference = -VAL_DIC_Intp-yy;
    PercentError = abs((difference./yy)*100);
     aa = find(PercentError>50);
     PercentError(aa) = nan;
    
else
    yy = flip(abaqus_VAL);
    difference = VAL_DIC_Intp-yy;
    PercentError = abs((difference./yy)*100);
    aa = find(PercentError>55);
    PercentError(aa)=nan;
end
end

