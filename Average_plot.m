clc
RH= dlmread('RH.txt');
RHr= RH(:,2);
RHr= RHr(2:end);

time =RH(:,1);
time=time(2:end);
no_flames=50;
pattern_type = 'Fabric_Images';
a = what;                                           % Gives current working directory

for id_frame = 1:no_flames
    
if id_frame<10
    frame_mat = ['\frame_0000',num2str(id_frame),'.mat'];
end
if id_frame>9
    frame_mat = ['\frame_000',num2str(id_frame),'.mat'];
end
tit_mat = [a.path,'\',pattern_type,frame_mat];

load (tit_mat)
val_dic = load(tit_mat, 'eyy');
val_dic = val_dic .eyy;
aveg= mean(val_dic,'all');
GlobAveg_Fabric(id_frame,:)=aveg;
end


pattern_type = 'Speckle_Images';

for id_frame = 1:no_flames
    
if id_frame<10
    frame_mat = ['\frame_0000',num2str(id_frame),'.mat'];
end
if id_frame>9
    frame_mat = ['\frame_000',num2str(id_frame),'.mat'];
end
tit_mat = [a.path,'\',pattern_type,frame_mat];

load (tit_mat)
val_dic = load(tit_mat, 'eyy');
val_dic = val_dic .eyy;
aveg= mean(val_dic,'all');
GlobAveg_Speckle(id_frame,:)=aveg;
end

glob_Fab= sort(GlobAveg_Fabric);
glob_Spec= sort(GlobAveg_Speckle);
RHr=sort(RHr);
% dis= sort(Disp);
% time= [1:1:no_flames]';

figure(1)
plot(time,GlobAveg_Fabric)
hold on
plot(time,GlobAveg_Speckle)
title('time vs global average strain from DIC')
xlabel ('time (hrs)')
ylabel('Global average strain')
legend('Fabric','Speckle')

figure(4)
plot(RHr,glob_Fab)
hold on
plot(RHr,glob_Spec)
title('Percent gravity vs global strain')
xlabel ('Gravity )')
ylabel('Global average strain')
legend('Fabric','Speckle')


%   hold on
%  figure(2)
%  plot(time, RHr)
%  title('Displacement vs time')
%  xlabel ('time (hr)')
%  ylabel('Displacement (m)')
%  




