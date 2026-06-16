% --- Thiết lập môi trường và giao diện biểu đồ ---
clear;
clc;
close all;
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 13)
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultTextFontSize', 13)
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

% ==== Dữ liệu cho biểu đồ Resolution ====
globalAcc = [69.28, 74.58, 78.66, 80.67]; 
meanIoU   = [53.51, 61.43, 65.21, 67.71];

size_px   = [64 128 256 512];
speed     = [4.07 5.11 6.56 22.11];   % in ms

% --- Vẽ biểu đồ Resolution vs. Performance ---
figure; 
set(gcf, 'Position', [100 100 400 300]); % Đặt vị trí và kích thước cửa sổ
hold on; 
grid on;
plot(size_px, globalAcc, '-o', 'LineWidth', 1.25, 'MarkerFaceColor', 'w', 'Color', [0 0.447 0.741]);
plot(size_px, meanIoU,   '--s','LineWidth', 1.25, 'MarkerFaceColor', 'w', 'Color', [0.85 0.325 0.098]);

% --- Tùy chỉnh biểu đồ ---
xlim([64 512]);
xticks(size_px);
ylim([50, 85]); % <<< THÊM: Ổn định trục Y để căn chỉnh
yticks([50, 55, 60, 65, 70, 75, 80, 85]); % <<< THÊM: Đặt vạch chia Y

xlabel('Spectrogram size (pixel$\times$pixel)');
ylabel('Percentage (\%)');


legend('Mean Accuracy', 'Mean IoU','Position',[0.20, 0.20, 0.35, 0.15]); 

% --- Thêm Textbox cho tốc độ ---
str = sprintf(['Speed (ms)\n' ...
               '064 x 064: %.2f\n' ...
               '128 x 128: %.2f\n' ...
               '256 x 256: %.2f\n' ...
               '512 x 512: %.2f'], ...
               speed(1), speed(2), speed(3), speed(4));
text(340, 58.5, str, ...
     'FontSize', 12, ...
     'BackgroundColor', 'w', ...  
     'EdgeColor', 'none', ...
     'Margin', 0.1);      
     
grid minor
box on
ax = gca;
ax.MinorGridAlpha = 0.1;

% --- (Tùy chọn) Lưu file ---
fig = gcf;
fig.PaperPositionMode = 'auto';
print('speed_linechart','-depsc','-r600')

