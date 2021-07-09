function plotsNew( DIC_SOFTWARE, abaqus_var, no_image, compare, Result_type, Analysis_status, tilt,app)

% To plot processed results


if abaqus_var == 2
    AutoScale = 1; % 1 plots each domain data as supplied, 0 uses DIC scale for all supplied data
else
    AutoScale = 0;
end

if app.FEA_SOFTWARE==1
    FEA_Title= 'ABAQUS simulation';
else
    FEA_Title = 'FEA with inbuit FEM code';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% START %%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if Result_type == 1 || Result_type == 2
    
    switch abaqus_var
        case 1
            tit = 'x displacment (u)';
        case 2
            tit = 'y displacement (v)';
        case 3
            tit = ' x strain ( )';
        case 4
            tit = ' y strain';
            
        case 5
            tit = ' Shear strain';
    end
    
elseif Result_type == 3

    switch abaqus_var
        case 1
            tit = 'Percent difference for x displacment (u)';
        case 2
            tit = 'Percent difference for y displacement (v)';
        case 3
            tit = 'Percent difference for x strain ( )';
        case 4
            tit = 'Percent difference for y strain';
            
        case 5
            tit = ' Percent difference for Shear strain';
    end
    
elseif Result_type == 4
    
    switch abaqus_var
        case 1
            tit = 'Difference for x displacment (u)';
        case 2
            tit = 'Difference for y displacement (v)';
        case 3
            tit = 'Difference for x strain ( )';
        case 4
            tit = 'Difference for y strain';
            
        case 5
            tit = 'Difference for Shear strain';
    end

elseif Result_type == 5
    switch abaqus_var
        case 1
            tit = 'X displacment(u) global average ';
        case 2
            tit = 'Y displacement(v) global average ';
        case 3
            tit = 'X strain global average ';
        case 4
            tit = 'Y strain global average ';
            
        case 5
            tit = 'Shear strain global average ';
    end
end


%%%%% plotting %%%%%%%%%

if Result_type == 1 ||  Result_type==2
    cla(app.axes1,'reset');
    set(app.axes1,'visible','off')
    legend(app.axes1,'hide')
    set(app.RefImage_panel,'BackgroundColor','default')
    
    
    
    space= ' '; ok=[tit, space,'for image number',space];

    switch compare
        case 'NO'
            
            f = figure('NumberTitle','off','Name',tit,'Visible','on','MenuBar','none');
            
            id_frame = no_image;
            VAL_DIC_Intp_fabric = app.Dic_results{abaqus_var,id_frame};
            abaqus_VAL = app.abaqus_results{abaqus_var,id_frame};
            xgrid = app.xgrid;  ygrid = app.ygrid; I_Fabric = app.I_Fabric;
            num=num2str(id_frame);
            tit=[ok ,num];
            
            grid off ;axis off
            xxMax = max(max( abaqus_VAL));
            xxMin= min(min( abaqus_VAL));
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
            
          
            subplot 121
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),flip(abaqus_VAL),'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            colorbar
            title(FEA_Title, 'FontSize', 10, 'Fontweight','normal')
            colormap('jet');
            set(gcf,'color','white');
            
            if AutoScale==0
                caxis([xxMin xxMax]);
            end
            
            
            subplot 122
            imshow(Irgb);
            hold on;
            if abaqus_var==2
                surf(xgrid,ygrid,1000+ 0.*(xgrid),-VAL_DIC_Intp_fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            else
                surf(xgrid,ygrid,1000+ 0.*(xgrid),VAL_DIC_Intp_fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            end
            title('DIC simulation, Fabric Images', 'FontSize', 10, 'Fontweight','normal')
            colorbar
            colormap('jet');
            
            if AutoScale==0
                caxis([xxMin xxMax]);
            end
            
            
        case 'YES'
            
            f = figure('NumberTitle','off','Name',tit,'Visible','on','MenuBar','none');
            id_frame = no_image;
            num = num2str(id_frame);
            tit=[ok ,num];
            
            VAL_DIC_Intp_speckle =app.Dic_results_speckle{abaqus_var,id_frame};
            VAL_DIC_Intp_fabric =app.Dic_results_fabric{abaqus_var,id_frame};
            abaqus_VAL =app.abaqus_results{abaqus_var,id_frame};
            
            
            xgrid = app.xgrid; I_Speckle = app.I_Speckle;
            ygrid = app.ygrid;
            
            grid off ;axis off ; 
            Irgb = cat(3,I_Speckle,I_Speckle,I_Speckle);
            
            
            
            subplot (2,2,1)
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),flip(abaqus_VAL),'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            colorbar
            title(FEA_Title, 'FontSize',10,'Fontweight','normal')
            colormap('jet');
            
            if AutoScale==0
                xxMax = max(max(VAL_DIC_Intp_speckle));
                xxMin= min(min(VAL_DIC_Intp_speckle));
                caxis([xxMin xxMax]);
            end
            
            %
            
            subplot (2,2,2)
            
            
            imshow(Irgb);
            hold on;
            if abaqus_var==2
                surf(xgrid,ygrid,1000+ 0.*(xgrid),-VAL_DIC_Intp_speckle,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            else
                surf(xgrid,ygrid,1000 + 0.*(xgrid),VAL_DIC_Intp_speckle,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            end
            
            colorbar
            title('DIC simulation: Speckle Images','FontSize',10,'Fontweight','normal')
            colormap('jet');
            
            if AutoScale==0
                caxis([xxMin xxMax]);
            end
            
            I_Fabric= app.I_Fabric;            
            subplot (2,2,3)
            
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
            imshow(Irgb);
            hold on;
            
            surf(xgrid,ygrid,1000+ 0.*(xgrid),flip(abaqus_VAL),'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            colorbar
            title(FEA_Title,'FontSize',10,'Fontweight','normal')
            colormap('jet');
            set(gcf,'color','white');

            if AutoScale==0
                caxis([xxMin xxMax]);
            end
            
            
            subplot (2,2,4)
            imshow(Irgb);
            hold on;
            if abaqus_var==2
                surf(xgrid,ygrid,1000+ 0.*(xgrid),-VAL_DIC_Intp_fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            else
                surf(xgrid,ygrid,1000+ 0.*(xgrid),VAL_DIC_Intp_fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            end
            title('DIC simulation, Fabric Images', 'FontSize',10,'Fontweight','normal')
            colorbar
            colormap('jet');
            
            if AutoScale==0
                caxis([xxMin xxMax]);
            end
            
            
            
            %             end
    end
    
    
elseif Result_type==3

    cla(app.axes1,'reset');
    set(app.axes1,'visible','off')
    legend(app.axes1,'hide')
    set(app.RefImage_panel,'BackgroundColor','default')
    space= ' '; ok=[tit, space,'for image number',space];

    switch compare
        case 'YES'
 
            f = figure('NumberTitle','off','Name',tit,'Visible','on','MenuBar','none');
            xgrid = app.xgrid;
            ygrid = app.ygrid;
            id_frame = no_image;
            num = num2str(id_frame);
            tit=[ok ,num];
            PercentError_Fabric = app.fabric_percentError{abaqus_var,id_frame};
            PercentError_Speckle = app.Speckle_percentError{abaqus_var,id_frame};
            
            
            
            subplot 121
            grid off ;axis off
            I_Speckle = app.I_Speckle;
            Irgb = cat(3,I_Speckle,I_Speckle,I_Speckle);
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),PercentError_Speckle,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            colorbar
            title('Percentage difference between FEA and DIC with speckle image', 'FontSize',10,'Fontweight','normal')
            colormap('jet');
            
            
            
            I_Fabric = app.I_Fabric;
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
             %if AutoScale==0
             MaxP= max(max(PercentError_Fabric)); MinP= min(min(PercentError_Fabric));
                caxis([MinP MaxP]);
           % end
            subplot 122
            
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),PercentError_Fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            colorbar
            title('Percentage difference between FEA and DIC with fabric image', 'FontSize',10,'Fontweight','normal')
            colormap('jet');
            set(gcf,'color','white')
            
            %if AutoScale==0
                MaxP= max(max(PercentError_Fabric)); MinP= min(min(PercentError_Fabric));
                caxis([MinP MaxP]);
            %end
            
            %             end
            
        case 'NO'
    
            
            I_Fabric = app.I_Fabric;
            xgrid = app.xgrid;
            ygrid = app.ygrid;
            id_frame = no_image;
            num=num2str(id_frame);
            tit=[ok ,num];
            PercentError_Fabric =app.fabric_percentError{abaqus_var,id_frame};
            grid off ;axis off
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),PercentError_Fabric,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            colorbar
            cb= colorbar;
            aa = get(cb,'Position');
            set(cb,'Position',[0.92 aa(2) 0.02 0.7]);
            title('Percentage difference between FEA and DIC', 'FontSize',10,'Fontweight','normal')
            colormap('jet');
            set(app.RefImage_panel,'BackgroundColor','white')
            if AutoScale==0
                MaxP= max(max(PercentError_Fabric)); MinP=min(min(PercentError_Fabric));
                
                caxis([MinP MaxP]);
            end
    end
    %     end
    
    
elseif Result_type== 4

    cla(app.axes1,'reset')
    set(app.axes1,'visible','off')
    legend(app.axes1,'hide')
    set(app.RefImage_panel,'BackgroundColor','default')
    space= ' '; ok=[tit, space,'for image number',space];
    switch compare
        
        case 'NO'
            % set(app.axes1, 'Units','Normalized','Position', [0.05 0.1 0.85, 0.9], 'visible', 'off','NextPlot','replace')
            %             for id_frame = 1:no_images
            xgrid = app.xgrid; I_Fabric=app.I_Fabric;
            ygrid = app.ygrid;
            id_frame =no_image;
            num=num2str(id_frame);
            tit=[ok ,num];
            difference=app.fabric_difference{abaqus_var,id_frame};
            
            grid off ;axis off
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
            imshow(Irgb);
            hold on;
            
            surf(xgrid,ygrid,1000+ 0.*(xgrid),difference,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            cb= colorbar;
            aa = get(cb,'Position');
            set(cb,'Position',[0.92 aa(2) 0.02 0.7]);
            
            title('Fabric DIC data - abaqus simulation, Difference values', 'FontSize',10,'Fontweight','normal')
            colormap('jet');
            
            if AutoScale==0
                MaxP= max(max(difference)); MinP= min(min(difference));
                caxis([MinP MaxP]);
            end
            %             end
            set(app.RefImage_panel,'BackgroundColor','white')
            
        case 'YES'
            
            
            f = figure('NumberTitle','off','Name',tit,'Visible','on','MenuBar','none');
            
            
            
            xgrid = app.xgrid; I_Fabric=app.I_Fabric;
            ygrid = app.ygrid;I_Speckle=app.I_Speckle;
            
            id_frame =no_image;
            num=num2str(id_frame);
            tit=[ok ,num];
            difference_speckle= app.Speckle_difference{abaqus_var,id_frame};
            difference_fabrice=app.fabric_difference{abaqus_var,id_frame};
            
            
            subplot 121
            grid off ;axis off
            Irgb = cat(3,I_Speckle,I_Speckle,I_Speckle);
            subplot 121
            imshow(Irgb);
            hold on;
            
            surf(xgrid,ygrid,1000+ 0.*(xgrid),difference_speckle,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            colorbar
            title('Speckle DIC data - abaqus simulation, Difference values','FontSize',9,'Fontweight','normal')
            colormap('jet');
            set(gcf,'color','white')
            if AutoScale==0
                MaxP= max(max(difference_speckle)); MinP= min(min(difference_speckle));
                caxis([MinP MaxP]);
            end
            
            
            
            Irgb = cat(3,I_Fabric,I_Fabric,I_Fabric);
            
            subplot 122
            
            imshow(Irgb);
            hold on;
            surf(xgrid,ygrid,1000+ 0.*(xgrid),difference_fabrice,'LineStyle','none','FaceColor','interp','FaceAlpha',0.8);
            
            colorbar
            title('Fabric DIC data - abaqus simulation, Difference values','FontSize',9,'Fontweight','normal')
            colormap('jet');
            
            if AutoScale==0
                MaxP= max(max(difference_speckle)); MinP= min(min(difference_speckle));
                caxis([MinP MaxP]);
            end
            
            
            
            
    end
    
    
elseif Result_type ==5

    cla(app.axes1,'reset')
    set(app.axes1,'visible','on')
    legend(app.axes1,'hide')
    
    set(app.pushdecrease,'Visible','off')
    set(app.push_Increase,'Visible','off')
    set(app.resultNum_disp,'Visible','off')
    set(app.text3,'Visible','off')
    set(app.RefImage_panel,'BackgroundColor','white')
    
    switch compare
        
        case 'NO'
            
            
            for id = 1 : no_image
                strain(:,id) =  app.Global_Aver_Val_fabric{abaqus_var,id};
                Error(:,id) =   app.Global_Ave_PercentError_fabric{abaqus_var,id};
            end
            
            
            
            if app.Tabular_Load == 1
                time= [1:1:no_image];
                yyaxis left
                plot(app.axes1,time,strain)
                
                xlabel (app.axes1,'Time (Image series)');
                
                
                if abaqus_var >= 3
                    ylabel (app.axes1,'Global Average Strain');
                else
                    ylabel (app.axes1,'Global Average Displacement');
                end
                
                yyaxis right
                plot(app.axes1,time,Error)
                ylabel (app.axes1,'Global Average Percent Error');
                
                legend(app.axes1, 'Fabric Image: Average strain','Fabric Image: Percent error','Location','best');

            else
                
                plot(app.axes1,strain,Error)
                legend( app.axes1,'Fabric Image','Location','best');

                if abaqus_var>=3
                    xlabel (app.axes1,'Global Average Strain Level');
                    ylabel (app.axes1,'Global Average Percent Error');
                else
                    xlabel (app.axes1,'Global Average Displacement');
                    ylabel (app.axes1,'Global Average Percent Error');
                end
                
            end
            
            
            
        case 'YES'

            
            for id = 1 : no_image
             
                strain_speckle(:,id) =  app.Global_Aver_Val_speckle{abaqus_var,id};
                Error_speckle(:,id) =app.Global_Ave_PercentError_speckle{abaqus_var,id};app
                
                strain_fabric(:,id) =  app.Global_Aver_Val_fabric{abaqus_var,id};
                Error_fabric(:,id) = app.Global_Ave_PercentError_fabric{abaqus_var,id};
            end
            
            
            if app.Tabular_Load==1
                time= [1:1:no_image];
                yyaxis left
                plot(app.axes1,time,strain_speckle)
                hold on
                plot(app.axes1,time,strain_fabric)
                xlabel (app.axes1,'Time (Image series)');
                
                if abaqus_var>=3
                    ylabel (app.axes1,'Global Average Strain');
                else
                    ylabel (app.axes1,'Global Average Displacement');
                end
                
                yyaxis right
                plot(app.axes1,time,Error_speckle)
                hold on
                plot(app.axes1,time,Error_fabric)
                
                hold off
                
                ylabel (app.axes1,'Global Average Percent Error');
                
                legend(app.axes1,'Speckle Image: Average strain','Fabric Image: Average strain','Speckle Image: Percent error','Fabric Image: Percent error','Location','best');
            else
                
                plot(app.axes1,strain_speckle,Error_speckle);
                hold (app.axes1,'on')
                plot(app.axes1,strain_fabric,Error_fabric);
                
                legend(app.axes1,'Speckle Image', 'Fabric Image','Location','best');
                
                
                
                
                if abaqus_var >= 3
                    xlabel (app.axes1,'Global Average Strain Level');
                    ylabel (app.axes1,'Global Average Percent Error');
                else
                    xlabel (app.axes1,'Global Average Displacement');
                    ylabel (app.axes1,'Global Average Percent Error');
                end
            end
    end
end
end