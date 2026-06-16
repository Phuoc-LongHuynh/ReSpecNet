% ===== PHẦN 1: THIẾT LẬP BAN ĐẦU =====
clear;
clc;
close all;
% --- Cài đặt chung cho biểu đồ ---
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 14)
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultTextFontSize', 14)
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');

font_size = 28;
% !!! THAY ĐỔI CÁC ĐƯỜNG DẪN DƯỚI ĐÂY CHO PHÙ HỢP !!!
input_folder = "E:\Lab401b\J02\test"; % Thư mục chứa các file .mat
output_folder_png = "E:\Lab401b\J02\test";   % Thư mục để lưu các ảnh .png
output_folder_epsc = "E:\Lab401b\J02\test"; % Thư mục để lưu các file .epsc
% --- Tự động tạo thư mục đầu ra ---
if ~exist(output_folder_png, 'dir'), mkdir(output_folder_png); disp(['Đã tạo thư mục PNG tại: ', output_folder_png]); end
if ~exist(output_folder_epsc, 'dir'), mkdir(output_folder_epsc); disp(['Đã tạo thư mục EPSC tại: ', output_folder_epsc]); end
% --- Lấy danh sách file .mat ---
mat_files = dir(fullfile(input_folder, '*.mat'));
% ===== PHẦN 2: BẮT ĐẦU VÒNG LẶP XỬ LÝ =====
fprintf('Bắt đầu xử lý %d file .mat...\n', length(mat_files));
for k = 1:length(mat_files)
    current_filename = mat_files(k).name;
    full_path_to_file = fullfile(input_folder, current_filename);
    
    fprintf('Đang xử lý file (%d/%d): %s\n', k, length(mat_files), current_filename);
    
    % --- 1. Tải Dữ liệu ---
    try
        data = load(full_path_to_file);
    catch ME
        warning('Không thể tải file: %s. Bỏ qua file này.', current_filename);
        continue;
    end
    
    noisy_image = data.noisy_image;
    true_label_mask = double(data.true_label_mask);
    predicted_denoised_image = data.predicted_denoised_image;
    predicted_label_mask = double(data.predicted_label_mask);
    
    % --- 2. Chuẩn bị thông số vẽ ---
    time_axis = linspace(0, 40, size(noisy_image, 1)); 
    freq_axis = linspace(-30, 30, size(noisy_image, 2)); 
    
    num_classes = 3;
    label_colormap_ordered = [                              
        94/255, 223/255, 255/255;   % Class 0: 5G     
        233/255, 0/255, 255/255;    % Class 1: LTE
        62/255, 38/255, 168/255;   % Class 2: Background  
    ];
    class_names = {'5G NR', 'LTE', 'Noise'};
    
    % --- 3. Bắt đầu Vẽ hình ---
    fig = figure('Position', [100, 100, 1000, 1000], 'Color', 'w', 'Visible', 'off');

    % --- CÁCH TÍNH TOÁN BỐ CỤC MỚI ---
    margin_left = 0.1;    % Lề trái 
    margin_right = 0.09;   % Lề phải (chừa chỗ cho colorbar)
    margin_bottom = 0.12;   % Lề dưới
    margin_top = 0.07;     % Lề trên
    vertical_gap = 0.17;   % Khoảng cách dọc giữa các subplot

    total_plot_width = 1 - margin_left - margin_right;
    
    % Tính toán chiều cao của mỗi subplot bằng cách chia đều không gian còn lại
    total_vertical_space = 1 - margin_bottom - margin_top - (3 * vertical_gap);
    subplot_height = total_vertical_space / 4; % Chia cho 4 plot
    
    % Tính toán vị trí 'bottom' cho mỗi subplot (vẽ từ dưới lên)
    y_pos4 = margin_bottom; % Subplot dưới cùng
    y_pos3 = y_pos4 + subplot_height + vertical_gap;
    y_pos2 = y_pos3 + subplot_height + vertical_gap;
    y_pos1 = y_pos2 + subplot_height + vertical_gap;
    % ----------------------------------------

    % --- Vẽ từng Subplot với vị trí đã tính toán ---
    % Subplot 1: Input Spectrogram
    ax1_pos = [margin_left, y_pos1, total_plot_width, subplot_height];
    ax1 = axes('Position', ax1_pos);
    imagesc(ax1, freq_axis, time_axis, noisy_image);
    title(ax1, 'Input Spectrogram', 'FontSize', font_size);
    ylabel(ax1, 'Time (ms)', 'FontSize', font_size);
    xlabel(ax1, 'Frequency (MHz)', 'FontSize', font_size); % <<< ĐÃ THÊM LẠI
    set(ax1, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
    colormap(ax1, 'parula'); colorbar(ax1); clim(ax1, [0 1]);

    % Subplot 2: Ground Truth Segmentation
    ax2_pos = [margin_left, y_pos2, total_plot_width, subplot_height];
    ax2 = axes('Position', ax2_pos); 
    imagesc(ax2, freq_axis, time_axis, true_label_mask); 
    title(ax2, 'Ground Truth Segmentation', 'FontSize', font_size);
    ylabel(ax2, 'Time (ms)', 'FontSize', font_size);
    xlabel(ax2, 'Frequency (MHz)', 'FontSize', font_size); % <<< ĐÃ THÊM LẠI
    set(ax2, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
    colormap(ax2, label_colormap_ordered); 
    clim(ax2, [0 num_classes-1]);
    cb2 = colorbar(ax2); cb2.Limits = [-0.5 num_classes-0.5];
    % tick_positions = 0:(num_classes-1);
    % =========================================================
    % THAY ĐỔI Ở ĐÂY: Dịch chuyển vị trí nhãn đầu và cuối
    % =========================================================
    offset = 0.5; % << Bạn có thể điều chỉnh giá trị này để dịch chuyển nhiều hay ít
    tick_positions = [0 - offset, 1, 2 + offset]; % Vị trí mới: [-0.2, 1, 2.2]
    % =========================================================

    set(cb2, 'Ticks', tick_positions, 'TickLabels', class_names, 'FontSize', font_size);

    % Subplot 3: Reconstructed Spectrogram
    ax3_pos = [margin_left, y_pos3, total_plot_width, subplot_height];
    ax3 = axes('Position', ax3_pos);
    imagesc(ax3, freq_axis, time_axis, predicted_denoised_image);
    title(ax3, 'Reconstructed Spectrogram', 'FontSize', font_size);
    ylabel(ax3, 'Time (ms)', 'FontSize', font_size);
    xlabel(ax3, 'Frequency (MHz)', 'FontSize', font_size); % <<< ĐÃ THÊM LẠI
    set(ax3, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1); 
    colormap(ax3, 'parula'); colorbar(ax3); clim(ax3, [0 1]);

    % Subplot 4: Predicted Segmentation
    ax4_pos = [margin_left, y_pos4, total_plot_width, subplot_height];
    ax4 = axes('Position', ax4_pos);
    imagesc(ax4, freq_axis, time_axis, predicted_label_mask); 
    title(ax4, 'Predicted Segmentation', 'FontSize', font_size);
    ylabel(ax4, 'Time (ms)', 'FontSize', font_size);
    xlabel(ax4, 'Frequency (MHz)', 'FontSize', font_size);
    set(ax4, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
    colormap(ax4, label_colormap_ordered); 
    clim(ax4, [0 num_classes-1]);
    cb4 = colorbar(ax4); cb4.Limits = [-0.5 num_classes-0.5];
    offset = 0.5; % << Bạn có thể điều chỉnh giá trị này để dịch chuyển nhiều hay ít
    tick_positions = [0 - offset, 1, 2 + offset]; % Vị trí mới: [-0.2, 1, 2.2]
    set(cb4, 'Ticks', tick_positions, 'TickLabels', class_names, 'FontSize', font_size);
    
    set(findall(fig,'-property','FontName'),'FontName','Times New Roman');
    
    % --- 4. Lưu hình ở 2 định dạng ---
    [~, base_filename, ~] = fileparts(current_filename);
    
    png_filename = [base_filename, '.png'];
    full_path_to_png = fullfile(output_folder_png, png_filename);
    print(fig, full_path_to_png, '-dpng', '-r300');
    
    epsc_filename = [base_filename, '.eps'];
    full_path_to_epsc = fullfile(output_folder_epsc, epsc_filename);
    print(fig, full_path_to_epsc, '-depsc', '-r600');
    
    % --- 5. Đóng cửa sổ hình lại ---
    close(fig);
    
end
disp('Hoàn thành! Tất cả các hình đã được lưu vào các thư mục đầu ra.');