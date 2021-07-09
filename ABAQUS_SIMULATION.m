function ABAQUS_SIMULATION(handles)

% Written by Jafar Alsayednoor 
%Modified and extended by Kenneth Nwanoro

%-----------------------------Pre simulation step-------------------------%
load('Taps_Drawings.mat');
height = size(Taps_Drawings{1,2},1);%mesh_order_y
width =  size(Taps_Drawings{1,2},2);%mesh_order_x
Num =handles.Meshdensity;
mesh_order_x = round(width/Num);%number of S4R elements in each edge
mesh_order_y = round(height/Num);%number of S4R elements in each edge

no_images =handles.no_images;


f=waitbar(0,'Please wait, FEA input file is being generated');
   Mesh_Gen_ABAQUS(height,width,mesh_order_x,mesh_order_y,handles);
delete(f)



if handles.FEA_SOFTWARE==1
    
    %-----------------------Execute ABAQUS Simulation-------------------------%
    
    cd ABAQUS_SIMULATIONS
    
    
    if handles.OBD==0  % RUN ABAQUS FROM THIS COMPUTER
        f=waitbar(0,'Please wait ABAQUS FEA simulation is running');
        waitbar(1/5)
        !abaqus input=TAPS_FEM job=JOB_TAPS interactive cpus=4
        
        delete('JOB_TAPS.com','JOB_TAPS.dat','JOB_TAPS.msg','JOB_TAPS.prt','JOB_TAPS.sim','JOB_TAPS.sta');
        delete('JOB_TAPS.abq','JOB_TAPS.pac','JOB_TAPS.sel','JOB_TAPS.stt','JOB_TAPS.mdl','JOB_TAPS.res');
        waitbar(2/5)
    
    elseif handles.OBD==1 && handles.UpgradeRequired==0    % USE odb file from elsewhere but same version as in user's PC
        h=msgbox('Please use the files in the ABAQUS_SIMULATIONS folder to perform the finite element analysis using ABAQUS software. Name the ABAQUS job as JOB_TAPS. Then copy the odb file named JOB_TAPS.odb into the  ABAQUS_SIMULATIONS folder. Press OK to conitnue','Info');
        set(h, 'position', [500 400 300 100])
        uiwait(h)
        
          if isempty(dir('*.odb'))
              
                h=msgbox('External odb file not found, please copy the external odb file named JOB_TAPS.odb to the ABAQUS_SIMULATIONS folder and press the Deform Images button again to conitnue','Error');
                set(h, 'position', [500 400 300 80])
                uiwait(h)
        
                cd ..
                return
        
          end
        
        
    elseif handles.OBD==1 && handles.UpgradeRequired==1  
        
         h=msgbox('Please use the files in the ABAQUS_SIMULATIONS folder to perform the finite element analysis using ABAQUS software. Name the ABAQUS job as JOB_Ext. Then copy the odb file named JOB_Ext.odb into the  ABAQUS_SIMULATIONS folder. Press OK to conitnue','Info');
          set(h, 'position', [500 400 300 100])
          uiwait(h)
            if ~isempty(dir('*.odb'))
                
            !abaqus upgrade job=JOB_TAPS odb=JOB_Ext 
           
            else
             
                h=msgbox('External odb file not found, please copy the external odb file named JOB_Ext to the ABAQUS_SIMULATIONS folder and press the Deform Images button again to conitnue','Error');
                set(h, 'position', [500 400 300 80])
                uiwait(h)
        
                cd ..
                return
        
            end
        % odb is the original abaqus odb file from external source, job is the name of the upgraded odb file used in the
        %     python script
    end
    
    
    
    
    %----------------------Extracting Data from ABAQUS odb file---------------%
    for i = 0:no_images
%         ABAQUS_POST_SCRIPT(i);   % writing abaqus python script to extract results
id_frame = num2str(i);
output_name_1=['''displacements_',num2str(id_frame),'.txt'''];
output_name_2=['''strains_',num2str(id_frame),'.txt'''];
fid_file=fopen('post_processing.py','wt');
fprintf(fid_file,'from abaqus import *\n');
fprintf(fid_file,'from abaqusConstants import *\n');
fprintf(fid_file,['session.Viewport(name=''','Viewport: 1''',',','origin=(0.0, 0.0),width=390.685394287109,\n']);
fprintf(fid_file,'   height=246.397491455078)\n');
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].makeCurrent()\n']);
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].maximize()\n']);
fprintf(fid_file,'from caeModules import *\n');
fprintf(fid_file,'from driverUtils import executeOnCaeStartup\n');
fprintf(fid_file,'executeOnCaeStartup()\n');
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].partDisplay.geometryOptions.setValues(\n']);
fprintf(fid_file,'   referenceRepresentation=ON)\n');
fprintf(fid_file,'Mdb()\n');
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].setValues(displayedObject=None)\n']);
fprintf(fid_file,['import os\n']);
fprintf(fid_file,['o1 = session.openOdb(\n']);
fprintf(fid_file,[' name=''','JOB_TAPS.odb''',')\n']);
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].setValues(displayedObject=o1)\n']);
fprintf(fid_file,['odb = session.odbs[''','JOB_TAPS.odb'']\n']);
fprintf(fid_file,['session.fieldReportOptions.setValues(printTotal=OFF, printMinMax=OFF)\n']);
fprintf(fid_file,['session.writeFieldReport(fileName=',output_name_1,',',' append=ON,\n']);
fprintf(fid_file,['   sortItem=''','Node Label''',',','odb=odb, step=0, frame=',id_frame,', outputPosition=NODAL,\n']);
fprintf(fid_file,['    variable=((''','U''',',',' NODAL, ((COMPONENT,''','U1''','), (COMPONENT,''','U2''','),)),))\n']);
fprintf(fid_file,['session.viewports[''','Viewport: 1''','].odbDisplay.basicOptions.setValues(\n']);
fprintf(fid_file,['    useRegionBoundaries=False, averagingThreshold=100)\n']);
fprintf(fid_file,['odb = session.odbs[''','JOB_TAPS.odb'']\n']);
fprintf(fid_file,['session.writeFieldReport(fileName=',output_name_2,',',' append=ON,\n']);
fprintf(fid_file,['   sortItem=''','Node Label''',',','odb=odb, step=0, frame=',id_frame,', outputPosition=NODAL,\n']);
fprintf(fid_file,['variable=((''','LE''',',',' INTEGRATION_POINT, ((COMPONENT,''LE11''',')',',','(COMPONENT,\n']);
fprintf(fid_file,['''LE22''','), (COMPONENT, ''LE12''','), )),)) \n']);
%fclose('all')
    !abaqus cae noGUI=post_processing.py
    end
    
    
    try
        n = 0;
        for i = 0:no_images
            filename = ['displacements_',num2str(i),'.txt'];
            startRow = 14;
            formatSpec = '%16s%16s%s%[^\n\r]';
            fileID = fopen(filename,'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'ReturnOnError', false);
            fclose(fileID);
            raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
            for col=1:length(dataArray)-1
                raw(1:length(dataArray{col}),col) = dataArray{col};
            end
            result0 = cellfun(@str2num, raw, 'UniformOutput', false);
            n = n+1;
            ALL_Displacements{n,1} = cell2mat(result0);
        end
        
        clearvars filename startRow formatSpec fileID dataArray ans raw
        clearvars col numericData rawData row regexstr result numbers result0
        clearvars invalidThousandsSeparator thousandsRegExp me R i n
        
        n = 0;
        for i = 0:no_images
            filename = ['strains_',num2str(i),'.txt'];
            startRow = 17;
            formatSpec = '%16s%16s%16s%s%[^\n\r]';
            fileID = fopen(filename,'r');
            textscan(fileID, '%[^\n\r]', startRow-1, 'ReturnOnError', false);
            dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'ReturnOnError', false);
            fclose(fileID);
            raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
            for col=1:length(dataArray)-1
                raw(1:length(dataArray{col}),col) = dataArray{col};
            end
            result0 = cellfun(@str2num, raw, 'UniformOutput', false);
            n = n+1;
            ALL_Strains{n,1}  = cell2mat(result0);
        end
        clearvars filename startRow formatSpec fileID dataArray ans raw
        clearvars col numericData rawData row regexstr result0 numbers
        clearvars invalidThousandsSeparator thousandsRegExp me R i n
        
        delete('displacements*');
        delete('strains*');
        delete('abaqus.rpy*');
        delete('post_processing.py');
        
        save 'ABAQUS_RAW.mat'
        waitbar(5/5)
        mkdir('DATA');
        movefile('EL_SETS.txt','DATA'); movefile('elements.txt','DATA');
        movefile('nodes.txt','DATA'); movefile('TAPS_FEM.inp','DATA');
        movefile('ND_SETS.txt','DATA'); movefile('ABAQUS_RAW.mat','DATA');
        delete(f)
        cd ..
        clear
        uiwait( msgbox('Abaqus Simulation completed','Successful'));

    catch
            % Delete input files, if abaqus exited with error
        
        Currentfolder = pwd;
        folderFiles = dir(fullfile(Currentfolder,'*.*'));
        
        for fileNum = 1 : length(folderFiles)
            Delfile = fullfile(Currentfolder, folderFiles(fileNum).name);
            delete(Delfile);
        end
        delete(f)
        cd ..
        clear
        clc
        uiwait(msgbox('Abaqus exited with error','Error','modal'))
        
        
    end
    
else     %%%%% Use inbuilt FEA codes

    f =waitbar(0,'Please wait FEA simulation is running');
    waitbar(1/4)
    FEM(handles,height,no_images)
    delete(f)
end
