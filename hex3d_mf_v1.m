close all;
clc;
clear all;

%%% README
%% Perform five simulations
%% 1. Use the choices below
%%    band_start=1;
%%    band_end=8;
%%    choice_contour='more_contours';
%%    choice_contour_3D='yes';
%%    choice_contour_3D_SB='no';
%% 2. Use the choices below
%%    band_start=1;
%%    band_end=8;
%%    choice_contour='more_contours';
%%    choice_contour_3D='no';
%%    choice_contour_3D_SB='yes';
%% 3. Use the choices below
%%    band_start=5;
%%    band_end=5;
%%    choice_contour='more_contours';
%%    choice_contour_3D='yes';
%%    choice_contour_3D_SB='yes';
%% 4. Use the choices below
%%    band_start=5;
%%    band_end=5;
%%    choice_contour='more_contours';
%%    choice_contour_3D='no';
%%    choice_contour_3D_SB='yes';
%% 5. Use the choices below
%%    band_start=5;
%%    band_end=5;
%%    choice_contour='single_contour';
%%    choice_contour_3D='no';
%%    choice_contour_3D_SB='no';
%% Setup some parameters of the run
% Choose the bands to start and end with
band_start=1;
band_end=8;
% Choose if single contour or more
choice_contour='more_contours';
%choice_contour='single_contour';

%choose if 3D representation (valid only for more contours)
choice_contour_3D='yes';
%(valid only for 3D representation)
% yes will plot 2D slices insidividualy 
% no will plot the slice in a 3D representation
choice_contour_3D_SB='no';

% If single contour at what frequency
%(needs to be within the spectral range  the bands chosen
% alternatively run bands 1 to 8 and let the code find it)
freq_out=0.58;
% If more contours are chosen
%choice_contour='more_contours';
% Label them?: yes or no; if labelled reduce the number of contours to see
% the labels properly
choice_contour_label='no';
% Tell how many 
N_Contours=40;
%% Less relevant ones
% Number of point for the interpolation grid
%% Enter here the number of k-points in the mesh
N_Points=20;
%% Correct for the points at the end of the itnerval
N_Points=N_Points+2;
%% read the data: skip first line and first colum.
%% the data read in column format: kindex,kx,ky,kmag/2pi, freq band 1, freq band 2, ...
file_name=['iso_freq_data_mf_v1_' num2str(N_Points-2) '.dat'];
data_in= dlmread(file_name,',', 1, 1);
%% 
%% k-vectors set in rec space coordinates
%% mpb and matlab seem to have different convention for x and y
kx_r=data_in(:,2);
ky_r=data_in(:,3);
k_vectors=[kx_r, ky_r];
freqs=data_in(:,[6:end]);
%% FBZ vertices (hexagon) in cartesian space coordinates
KC1= [0.0 -0.666666666666667];
KC2= [0.577350269189626 -0.333333333333333];
KC3= [0.577350269189626 0.333333333333333];
KC4= [0 0.666666666666667];
KC5= [-0.577350269189625 0.333333333333333];
KC6= [-0.577350269189626 -0.333333333333333];

K1=cartesiantoreciprocal(KC1);
K2=cartesiantoreciprocal(KC2);
K3=cartesiantoreciprocal(KC3);
K4=cartesiantoreciprocal(KC4);
K5=cartesiantoreciprocal(KC5);
K6=cartesiantoreciprocal(KC6);

%% k_vectors on on-recanagular grid => needs regularising
%% the approach is to create a function of (kx,ky) by interpolating the
%% points available and then output it on a rectangular grid
%% For some reason the interpolation works better in the
%% reciprocal space. We prepare two grid one in rec space and its image in
%% cartesian space
%corners of the hexagon
 %corners of the hexagon
AC= [ KC1(1)  KC2(1)  KC3(1)  KC4(1)  KC5(1)  KC6(1)  KC1(1)];
BC= [ KC1(2)  KC2(2)  KC3(2)  KC4(2)  KC5(2)  KC6(2)  KC1(2)];

kx_max_c=max(AC);
kx_min_c=min(AC);
ky_max_c=max(BC);
ky_min_c=min(BC);

kx_grid_c=linspace(kx_min_c,kx_max_c,N_Points);
ky_grid_c=linspace(ky_min_c,ky_max_c,N_Points);
[kx_grid_mesh_c,ky_grid_mesh_c]=meshgrid(kx_grid_c,ky_grid_c);

%Ploting data
%use surf for filled surface plot - use contour for 2D EFS plot
if strcmp(choice_contour_3D_SB,'no');
    figure;
end 
for ix = band_start:band_end
    f_out=reshape(freqs(:,ix),N_Points,N_Points);
    %% we want only points inside the hexagon; 
    %% points outside the hexagon get a NaN
    for i=1:size(f_out,1)
        for j=1:size(f_out,2) 
            kxq_i=kx_grid_mesh_c(i,j);
            kyq_j=ky_grid_mesh_c(i,j);
            in = inpolygon(kxq_i,kyq_j,AC,BC);
            if in==1
              f_out(i,j)=f_out(i,j);
            else
              f_out(i,j)=NaN;%f_out(i,j);
            end
        end
    end

        
%%
    %% Contours labelled by their value (might want to reduce N_Contours)
    
    Min=min(min(f_out));
    Max=max(max(f_out));
    
    if strcmp(choice_contour,'more_contours');
        if strcmp(choice_contour_3D_SB,'yes');
            figure;
        end 
        disp(choice_contour)
        disp(choice_contour_3D)
        disp(choice_contour_3D_SB)
        v=linspace(Min,Max,N_Contours)';
        if strcmp(choice_contour_3D,'no')
            if strcmp(choice_contour_label,'yes') ; 
                [C,h]= contour(kx_grid_c,ky_grid_c,f_out,v, 'linecolor', 'r','ShowText','on');
                t = clabel(C,h,'LabelSpacing',8000,'FontSize',8);
            end
            if strcmp(choice_contour_label,'no')
                %% Plot a number of contours (no labels)        
                contour(kx_grid_c,ky_grid_c,f_out,v);
            end
        end
        if strcmp(choice_contour_3D,'yes');
            surf(kx_grid_c,ky_grid_c,f_out);
        end        
        axis equal
        hold on;           
        %Plots a 2D hexagon 
        plot(AC,BC, '-k','LineWidth',2)
        axis equal
        shading interp
        xlabel('k_x');
        ylabel('k_y');
        zlabel('\omega a/2 \pi c')
        axis([-ky_max_c ky_max_c -ky_max_c ky_max_c])%a
        set(gca,'XTick',-0.7:0.2:0.7) %
        set(gca,'YTick',-0.7:0.2:0.7) 
        set(gca,'ZTick',min(min(f_out)):0.1:max(max(f_out)))
        ax = gca;
        ax.YGrid = 'on';
        ax.XGrid = 'on';
        ax.ZGrid = 'on';
        ax.GridColor = [0 .5 .5];
        ax.GridLineStyle = '--';
        ax.GridAlpha = 0.5;
        ax.Layer = 'top';
        colormap(jet(512))
        hold on;
        if strcmp(choice_contour_3D_SB,'yes') 
            hold off
            disp('inside loop 1')
            colormap(jet(512))
            h = colorbar('horiz');  
            set(gca, 'CLim', [Min, Max])
            set(h, 'XTick', [Min, (Min+Max)/2, Max])
            set(h,'XTickLabel',{num2str(Min,2) ,num2str((Min+Max)/2,2), num2str(Max,2)}) %# don't add units here...
            xlabel(h, 'EFS')  
            title(strcat('EFS;  band ', num2str(ix)));
            fig_name=strcat('tri_lattice_rods_fmin_', num2str(Min), '_fmax_', num2str(Max), '_band_', num2str(ix), '_3D.png');
            %print('f4', '-dpng ',fig_title);
            saveas(gcf, fig_name);
        end
        if strcmp(choice_contour_3D_SB,'no');
            hold on;
        end
        if strcmp(choice_contour_3D_SB,'no');
         Min=min(min(freqs(:,:)));
         Max=max(max(freqs(:,:)));
         set(gca,'ZTick',0:0.1:floor(Max*10)/10)
         ax = gca;
         ax.YGrid = 'on';
         ax.XGrid = 'on';
         ax.ZGrid = 'on';
         ax.GridColor = [0 .5 .5];
         ax.GridLineStyle = '--';
         ax.GridAlpha = 0.5;
         ax.Layer = 'top';
         title(strcat('Band Structure FBZ'));
         fig_name=strcat('tri_lattice_rods_3D.png');
         % control the viewpoint
         az = -37.5;
         el = 15;
         view(az, el);
         %print('f4', '-dpng ',fig_title);
         saveas(gcf, fig_name);
     end
    end
    
     if strcmp(choice_contour,'single_contour');

        %% Single contour at value val
        v=freq_out;
        if(Min<= v && v<=Max)           
            figure
            [C,h]= contour(kx_grid_mesh_c,ky_grid_mesh_c,f_out,[v v] , 'linecolor', 'r','ShowText','on');
            t = clabel(C,h,'LabelSpacing',2000,'FontSize',8);            
            axis equal
            hold on;    
            %Plot a 2D hexagon 
            plot(AC,BC, '-k','LineWidth',2)
            axis equal
            shading interp
            xlabel('kx');
            ylabel('ky');
            zlabel('Normalised Frequency (ω)')        
            axis([-ky_max_c ky_max_c -ky_max_c ky_max_c])
            set(gca,'XTick',-0.7:0.2:0.7) %
            set(gca,'YTick',-0.7:0.2:0.7) 
            set(gca,'ZTick',min(min(f_out)):0.1:max(max(f_out)))
            ax = gca;
            ax.YGrid = 'on';
            ax.XGrid = 'on';
            ax.GridColor = [0 .5 .5];
            ax.GridLineStyle = '--';
            ax.GridAlpha = 0.5;
            ax.Layer = 'top';
            hold off
            colormap(jet(512))
            h = colorbar('horiz');  
            set(gca, 'CLim', [Min, Max])
            set(h, 'XTick', [Min, (Min+Max)/2, Max])
            set(h,'XTickLabel',{num2str(Min) ,num2str((Min+Max)/2), num2str(Max)})
            xlabel(h, 'EFS')     
            title(strcat('f=', num2str(v), ';  band=', num2str(ix)));
            fig_name=strcat('tri_lattice_rods_f_', num2str(v), '_band_', num2str(ix), '_v1.png');
            saveas(gcf, fig_name);
        end
    end
end

%% If choice_rec is yes, then plot the EFS in rec space


