function Process_Results(DIC_SOFTWARE,no_images,compare,FEA_SOFTWARE,TEARS,deNum, result_components,Paral,Result_Components,TabularLoad)

 % first ensure that the selected result components increases by 1 for
 % parfor to work
if Paral == 1
if diff(result_components)~=ones((size(result_components,2)-1),1)'
  Paral=0;
end
end

switch compare

    case 'NO'
        
        if Paral == 1
            for id_frame = 1:no_images
                parfor abaqus_var = result_components
                    
                    waitbar(id_frame/no_images)
                    pattern_type = ['Fabric_Images'];
                                      
                    [I_Fabric,VAL_DIC_Intp_fabric,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
                    
                    Dic_results{abaqus_var,id_frame}=VAL_DIC_Intp_fabric;
                    abaqus_results{abaqus_var,id_frame}=abaqus_VAL;
                    fabric_percentError{abaqus_var,id_frame}=percentError; 
                    fabric_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_fabric(isnan(VAL_DIC_Intp_fabric))=0;
                    KKB = find(VAL_DIC_Intp_fabric);
                    VAL_DIC_Intp_fabric = VAL_DIC_Intp_fabric(KKB);
                    Average_val= mean(VAL_DIC_Intp_fabric,'all');
                    
                 
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    Global_Aver_PercentError{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val{abaqus_var,id_frame}=Average_val;

                end
            end
                pattern_typ = ['Fabric_Images'];abaqus_va = 1;
               [I_Fabric,~,~,xgrid,ygrid,~,~] = Post_Processing(id_frame,pattern_typ,abaqus_va,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
               ref_Image{1,1}=I_Fabric;
            save('Results.mat','Dic_results','abaqus_results','xgrid','ygrid','I_Fabric','fabric_percentError','fabric_difference','compare','DIC_SOFTWARE','no_images','ref_Image','Global_Aver_PercentError','Global_Aver_Val','Result_Components','TabularLoad','FEA_SOFTWARE')
            
        else
            
           for id_frame = 1:no_images
                for abaqus_var = result_components
                    
                    waitbar(id_frame/no_images)
                    pattern_type = ['Fabric_Images'];
                                      
                    [I_Fabric,VAL_DIC_Intp_fabric,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
                    
                    Dic_results{abaqus_var,id_frame}=VAL_DIC_Intp_fabric;
                    abaqus_results{abaqus_var,id_frame}=abaqus_VAL;
                    fabric_percentError{abaqus_var,id_frame}=percentError; 
                    fabric_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_fabric(isnan(VAL_DIC_Intp_fabric))=0;
                    KKB = find(VAL_DIC_Intp_fabric);
                    VAL_DIC_Intp_fabric = VAL_DIC_Intp_fabric(KKB);
                    Average_val= mean(VAL_DIC_Intp_fabric,'all');
                    
                 
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    Global_Aver_PercentError{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val{abaqus_var,id_frame}=Average_val;
                ref_Image{1,1}=I_Fabric; 
                end
            end
 
                      
            save('Results.mat','Dic_results','abaqus_results','xgrid','ygrid','I_Fabric','fabric_percentError','fabric_difference','compare','DIC_SOFTWARE','no_images','ref_Image','Global_Aver_PercentError','Global_Aver_Val','Result_Components','TabularLoad','FEA_SOFTWARE')  
        end
        
        
        
    case 'YES'
        
               
        if Paral==1
            for  id_frame = 1:no_images
                parfor  abaqus_var = result_components
                    waitbar(id_frame/no_images)
                    pattern_type = ['Speckle_Images'];
                    [I_Speckle,VAL_DIC_Intp_speckle,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
                    
                    
                    
                    Dic_results_speckle{abaqus_var,id_frame}=VAL_DIC_Intp_speckle; 
                    abaqus_results{abaqus_var,id_frame}=abaqus_VAL;
                    Speckle_percentError{abaqus_var,id_frame}=percentError;
                    Speckle_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_speckle(isnan(VAL_DIC_Intp_speckle))=0;
                    KKB = find(VAL_DIC_Intp_speckle);
                    VAL_DIC_Intp_speckle = VAL_DIC_Intp_speckle(KKB);
                    Average_val= mean(VAL_DIC_Intp_speckle,'all');
                    
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    
                    Global_Aver_PercentError_speckle{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val_speckle{abaqus_var,id_frame}=Average_val;
                    
                    
                    pattern_type = ['Fabric_Images'];
                    
                    [I_Fabric,VAL_DIC_Intp_fabric,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE,FEA_SOFTWARE,TEARS,deNum);
                    
                    Dic_results_fabric{abaqus_var,id_frame}=VAL_DIC_Intp_fabric;
                    fabric_percentError{abaqus_var,id_frame}=percentError;
                    fabric_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_fabric(isnan(VAL_DIC_Intp_fabric))=0;
                    KKB = find(VAL_DIC_Intp_fabric);
                    VAL_DIC_Intp_fabric = VAL_DIC_Intp_fabric(KKB);
                    Average_val= mean(VAL_DIC_Intp_fabric,'all');
                    
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    Global_Aver_PercentError_fabric{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val_fabric{abaqus_var,id_frame}=Average_val;
                    
                    
                    
                end
            end

                 

                     %if parfor is used
                pattern_typ = ['Fabric_Images'];abaqus_va = 1;
               [I_Fabric,~,~,xgrid,ygrid,~,~] = Post_Processing(id_frame,pattern_typ,abaqus_va,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
               
               pattern_typ = ['Speckle_Images'];abaqus_va = 1;
               [I_Speckle,~,~,xgrid,ygrid,~,~] = Post_Processing(id_frame,pattern_typ,abaqus_va,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
         
               ref_Image{2,1}=I_Speckle; ref_Image{1,1}=I_Fabric;
                   %end of if parfor was used
               
               save('Results.mat','Dic_results_speckle','Dic_results_fabric','abaqus_results','xgrid','ygrid','fabric_percentError','fabric_difference','ref_Image',...
                'Speckle_percentError','Speckle_difference','Global_Aver_PercentError_fabric','Global_Aver_Val_fabric','I_Fabric','I_Speckle','Global_Aver_PercentError_speckle','Global_Aver_Val_speckle','compare','DIC_SOFTWARE','no_images','Result_Components','TabularLoad','FEA_SOFTWARE')
            
        else
                     
            for  id_frame = 1:no_images
                for  abaqus_var = result_components
                    waitbar(id_frame/no_images)
                    pattern_type = ['Speckle_Images'];
                    [I_Speckle,VAL_DIC_Intp_speckle,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE, FEA_SOFTWARE,TEARS,deNum);
                    
                    
                    
                    Dic_results_speckle{abaqus_var,id_frame}=VAL_DIC_Intp_speckle; 
                    abaqus_results{abaqus_var,id_frame}=abaqus_VAL;
                    Speckle_percentError{abaqus_var,id_frame}=percentError;
                    Speckle_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_speckle(isnan(VAL_DIC_Intp_speckle))=0;
                    KKB = find(VAL_DIC_Intp_speckle);
                    VAL_DIC_Intp_speckle = VAL_DIC_Intp_speckle(KKB);
                    Average_val= mean(VAL_DIC_Intp_speckle,'all');
                    
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    
                    Global_Aver_PercentError_speckle{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val_speckle{abaqus_var,id_frame}=Average_val;
                    
                    
                    pattern_type = ['Fabric_Images'];
                    
                    [I_Fabric,VAL_DIC_Intp_fabric,abaqus_VAL,xgrid,ygrid,percentError,Difference] = Post_Processing(id_frame,pattern_type,abaqus_var,DIC_SOFTWARE,FEA_SOFTWARE,TEARS,deNum);
                    
                    Dic_results_fabric{abaqus_var,id_frame}=VAL_DIC_Intp_fabric;
                    fabric_percentError{abaqus_var,id_frame}=percentError;
                    fabric_difference{abaqus_var,id_frame}=Difference;
                    
                    VAL_DIC_Intp_fabric(isnan(VAL_DIC_Intp_fabric))=0;
                    KKB = find(VAL_DIC_Intp_fabric);
                    VAL_DIC_Intp_fabric = VAL_DIC_Intp_fabric(KKB);
                    Average_val= mean(VAL_DIC_Intp_fabric,'all');
                    
                    percentError(isnan(percentError))=0;
                    KKD= find(percentError);
                    percentError =percentError(KKD);
                    Average_PercentError = mean(percentError,'all');
                    Global_Aver_PercentError_fabric{abaqus_var,id_frame}=Average_PercentError;
                    Global_Aver_Val_fabric{abaqus_var,id_frame}=Average_val;
                    
                  ref_Image{2,1}=I_Speckle; ref_Image{1,1}=I_Fabric;  
                    
                end
            end
               
               save('Results.mat','Dic_results_speckle','Dic_results_fabric','abaqus_results','xgrid','ygrid','fabric_percentError','fabric_difference','ref_Image',...
                'Speckle_percentError','Speckle_difference','Global_Aver_PercentError_fabric','Global_Aver_Val_fabric','I_Fabric','I_Speckle','Global_Aver_PercentError_speckle','Global_Aver_Val_speckle','compare','DIC_SOFTWARE','no_images','Result_Components','TabularLoad','FEA_SOFTWARE')
              
         
        end
end



