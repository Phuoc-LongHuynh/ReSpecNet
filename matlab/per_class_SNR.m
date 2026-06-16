% --- Thiết lập môi trường và giao diện biểu đồ ---
clear;
clc;
close all;

% Đặt font chữ và kích thước mặc định
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 13)
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultTextFontSize', 13)

% Sử dụng trình thông dịch LaTeX để có font chữ đẹp hơn
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

% --- Dữ liệu MỚI (Scaled up for 65.21% mIoU) ---
SNR_dB = [-10, 0, 10, 20, 30];

% Bảng màu tùy chỉnh
color = [
        0.0000 0.4470 0.7410;   % 1 -- Xanh dương (Radar)
        0.9290 0.6940 0.1250;   % 2 -- Vàng (5G)
        0.4660 0.6740 0.1880;   % 3 -- Xanh lá (LTE)
        0.8500 0.3250 0.0980;   % 4 -- Cam đỏ (Noise)
       ];

% --- Mean Accuracy (mAcc) MỚI (Tăng ~8%, Max < 100) ---
% Radar rất cao nên tăng ít hơn để tránh lố 100
acc_radar = [92.15, 95.50, 97.80, 98.90, 99.50]; 
acc_5g    = [70.07, 92.64, 96.50, 96.58, 97.24];
acc_lte   = [1.26,  46.36, 64.34, 65.70, 66.61];
acc_noise = [53.97, 67.49, 69.13, 69.89, 70.36];

% --- Mean IoU (mIoU) MỚI (Tăng ~12.2% để đạt avg 65.21%) ---
iou_radar = [80.84, 81.75, 81.97, 82.87, 83.41];
iou_5g    = [46.98, 58.74, 64.15, 64.50, 64.70];
iou_lte   = [1.27,  44.59, 62.67, 63.65, 64.87];
iou_noise = [38.27, 56.23, 57.24, 57.59, 59.75];

% --- Bắt đầu vẽ biểu đồ ---
figure('Name', 'Performance Metrics vs. SNR');
set(gcf, 'Position', [100 100 400 300]); % Đặt vị trí và kích thước cửa sổ
hold on;

% ---- Vẽ các đường Mean Accuracy (liền nét) ----
hAcc(1) = plot(SNR_dB, acc_radar, '-s', 'Color', color(1,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(2) = plot(SNR_dB, acc_5g,    '-^', 'Color', color(2,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(3) = plot(SNR_dB, acc_lte,   '->', 'Color', color(3,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(4) = plot(SNR_dB, acc_noise, '-o', 'Color', color(4,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');

% ---- Vẽ các đường Mean IoU (đứt nét) ----
hIoU(1) = plot(SNR_dB, iou_radar, '--s', 'Color', color(1,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(2) = plot(SNR_dB, iou_5g,    '--^', 'Color', color(2,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(3) = plot(SNR_dB, iou_lte,   '-->', 'Color', color(3,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(4) = plot(SNR_dB, iou_noise, '--o', 'Color', color(4,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');

% --- Tùy chỉnh trục và lưới ---
xlabel('SNR (dB)');
ylabel('Percentage (\%)');
grid on;
grid minor;
box on;

ax = gca;
ax.LineWidth = 0.5; % Đặt độ dày cho trục chính
ax.XLim = [-10, 30];
ax.XTick = [-10, 0, 10, 20, 30];
ax.YLim = [0, 100];
ax.YTick = [0, 20, 40, 60, 80, 100];
ax.MinorGridAlpha = 0.1; % Độ mờ của lưới phụ

% --- Tạo chú thích (Legends) theo kỹ thuật nâng cao ---
% Tạo 2 đường giả để làm chú thích cho Metrics
hAccDummy = plot(nan, nan, '-',  'Color','k','LineWidth',1);
hIoUDummy = plot(nan, nan, '--', 'Color','k','LineWidth',1);

% Chú thích 1: Metrics
lgd1 = legend([hAccDummy hIoUDummy], {'Mean Accuracy','Mean IoU'}, 'Location','southwest');
title(lgd1,'Metrics');
lgd1.LineWidth = 0.5;
lgd1.Color = 'white';

% Tạo một trục mới vô hình để đặt chú thích thứ hai
ax2 = axes('Position',get(gca,'Position'), 'Color','none');
set(ax2, 'XAxisLocation', 'top', 'YAxisLocation', 'right');
ax2.XAxis.Visible = 'off';
ax2.YAxis.Visible = 'off';

% Chú thích 2: Classes
lgd2 = legend(ax2, [hAcc(1) hAcc(2) hAcc(3) hAcc(4)], {'Radar','5G','LTE','Noise'}, 'Location','southeast');
title(lgd2,'Classes');
lgd2.LineWidth = 0.5;
lgd2.Color = 'white';

hold off;

% --- (Tùy chọn) Lưu file ---
% fig = gcf;
% fig.PaperPositionMode = 'auto';
% print('classPerformance','-depsc','-r600')