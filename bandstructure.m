clear all
clc
data_1 = dlmread('notomi_te.dat',',',1,1)
%% k_index is in column 1 and will be used as x-coordinate
k_index_1 = data_1(:,1);
%% frequency data is in columns 6-13 and will be used as y coordinates
freqs_1 = data_1(:,6:end);
figure
%% set up the axes
axes
set(gca,'XTick',1:5:16)
set(gca,'XTickLabel',{'X','M','Î“','X'})
title('Band Structure Hexagonal Lattice');
xlabel('Wavevector');
ylabel('w');
axis([1 16 0 0.8])
hold on
%% plot the data
plot(k_index_1, freqs_1, 'r*-')
%% save the figure in a png file
hold off;
print( '-f1', '-dpng', 'hexagonal_lattice_rods_band_structure.png');