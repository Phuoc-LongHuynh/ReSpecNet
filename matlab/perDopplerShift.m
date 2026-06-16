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

% --- Dữ liệu (Trích xuất từ 5 khối SNR) ---
SNR_dB = [-10, 0, 10, 20, 30]; % Giả định 5 khối SNR_1 -> SNR_5 tương ứng

% Bảng màu tùy chỉnh
color = [
        0.0000 0.4470 0.7410;   % 1 -- Xanh dương (Doppler 0)
        0.9290 0.6940 0.1250;   % 2 -- Vàng (Doppler 5)
        0.4660 0.6740 0.1880;   % 3 -- Xanh lá (Doppler 70)
        0.8500 0.3250 0.0980;   % 4 -- Cam đỏ (Doppler 500)
       ];
       
% --- Mean Accuracy (mAcc) Sắp xếp theo Doppler Shift (đã * 100) ---
acc_dop0   = [63.39, 76.15, 87.87, 88.02, 89.40];
acc_dop5   = [62.05, 73.98, 86.19, 86.45, 87.61];
acc_dop70  = [61.99, 73.13, 85.52, 86.45, 86.62];
acc_dop500 = [59.92, 71.61, 83.96, 84.25, 85.11];

% --- Mean IoU (mIoU) MỚI ---
iou_dop0   = [47.85, 61.82, 74.73, 75.10, 76.47];
iou_dop5   = [46.54, 60.38, 73.46, 73.81, 75.03];
iou_dop70  = [45.74, 59.27, 72.18, 73.29, 73.37];
iou_dop500 = [44.20, 57.95, 70.50, 70.55, 71.96];

% --- Bắt đầu vẽ biểu đồ ---
figure('Name', 'Performance Metrics vs. SNR by Doppler Shift');
set(gcf, 'Position', [100 100 400 300]); % Đặt vị trí và kích thước cửa sổ
hold on;

% ---- Vẽ các đường Mean Accuracy (liền nét) ----
hAcc(1) = plot(SNR_dB, acc_dop0,   '-s', 'Color', color(1,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(2) = plot(SNR_dB, acc_dop5,   '-^', 'Color', color(2,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(3) = plot(SNR_dB, acc_dop70,  '->', 'Color', color(3,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hAcc(4) = plot(SNR_dB, acc_dop500, '-o', 'Color', color(4,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');

% ---- Vẽ các đường Mean IoU (đứt nét) ----
hIoU(1) = plot(SNR_dB, iou_dop0,   '--s', 'Color', color(1,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(2) = plot(SNR_dB, iou_dop5,   '--^', 'Color', color(2,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(3) = plot(SNR_dB, iou_dop70,  '-->', 'Color', color(3,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');
hIoU(4) = plot(SNR_dB, iou_dop500, '--o', 'Color', color(4,:), 'LineWidth', 1.25, 'MarkerFaceColor', 'white');

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
ax.YLim = [30, 90]; % <<< ĐÃ THAY ĐỔI GIỚI HẠN TRỤC Y
ax.YTick = [30, 40, 50, 60, 70, 80, 90]; % <<< ĐÃ THAY ĐỔI CÁC VẠCH CHIA
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

% Chú thích 2: Doppler Shift (Hz)
lgd2 = legend(ax2, [hAcc(1) hAcc(2) hAcc(3) hAcc(4)], {'0 Hz','5 Hz','70 Hz','500 Hz'}, 'Location','southeast');
title(lgd2,'$f_D$ (Hz)'); % Sử dụng LaTeX cho f_D
lgd2.LineWidth = 0.5;
lgd2.Color = 'white';

hold off;

% --- (Tùy chọn) Lưu file ---
% fig = gcf;
% fig.PaperPositionMode = 'auto';
% print('dopplerPerformance_zoomed','-depsc','-r600')