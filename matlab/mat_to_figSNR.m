% ===== PHẦN 1: THIẾT LẬP BAN ĐẦU =====
clear;
clc;
close all;
% --- Cài đặt chung cho biểu đồ ---
set(0,'DefaultAxesFontName', 'Helvetica')
set(0,'DefaultAxesFontSize', 28)
set(0,'DefaultTextFontname', 'Helvetica')
set(0,'DefaultTextFontSize', 28)
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
font_size = 28;
% !!! THAY ĐỔI ĐƯỜNG DẪN DƯỚI ĐÂY CHO PHÙ HỢP !!!
input_folder = "D:\paper\REV\matlab\fig\30_SNR"; % <<< THAY ĐỔI: Thư mục chứa file .mat của bạn
output_folder_png = "D:\paper\REV\matlab\fig\30_SNR";   % Thư mục để lưu các ảnh .png
output_folder_epsc = "D:\paper\REV\matlab\fig\30_SNR"; % Thư mục để lưu các file .epsc
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
    
    % Lấy dữ liệu từ file .mat
    noisy_image = data.noisy_image;
    true_label_mask = double(data.true_label_mask);
    predicted_label_mask = double(data.predicted_label_mask);
    
    % Kiểm tra xem có ảnh khử nhiễu hay không
    has_denoised_image = isfield(data, 'predicted_denoised_image');
    if has_denoised_image
        predicted_denoised_image = data.predicted_denoised_image;
    end
    
    % --- 2. Chuẩn bị thông số vẽ ---
    time_axis = linspace(0, 40, size(noisy_image, 1)); 
    freq_axis = linspace(-30, 30, size(noisy_image, 2)); 
    
    num_classes = 4; 
    
    
    % Bảng màu đa sắc
    % Đặt lại thứ tự màu sắc cho phù hợp với yêu cầu: Noise, LTE, 5G NR, Radar
    label_colormap_ordered = [   
        0/255, 255/255, 255/255;   % Class 0: Noise (xanh ngọc)
        85/255, 170/255, 255/255;   % Class 1: LTE (xanh lam)
        170/255, 85/255, 255/255;   % Class 2: 5G NR (tím)
        255/255, 0/255, 255/255;    % Class 3: Radar (hồng)
    ];
    
    % Tên các lớp tương ứng
    % Sắp xếp tên theo đúng thứ tự của màu sắc
    class_names = {'Noise', 'LTE', '5G NR', 'ASR'};

    % Đảo ngược giá trị dữ liệu để khớp với bảng màu mới
    true_label_mask_modified = true_label_mask;
    predicted_label_mask_modified = predicted_label_mask;
    
    % Tạo một ma trận ánh xạ để hoán đổi các giá trị dữ liệu
    % Giá trị ban đầu -> Giá trị mới
    % 0 (NR) -> 2
    % 1 (LTE) -> 1
    % 2 (Radar) -> 3
    % 3 (Noise) -> 0
    mapping = [3, 2, 1, 0];
    
    for i = 0:3
        true_label_mask_modified(true_label_mask == i) = mapping(i+1);
        predicted_label_mask_modified(predicted_label_mask == i) = mapping(i+1);
    end

    % --- 3. Bắt đầu Vẽ hình ---
    fig = figure('Position', [100, 100, 1000, 1000], 'Color', 'w', 'Visible', 'off');
    set(fig, 'Units', 'Inches');
    pos = get(fig, 'Position');
    set(fig, 'PaperPositionMode', 'Manual');
    set(fig, 'PaperUnits', 'Inches');
    set(fig, 'PaperSize', [pos(3), pos(4)]);
    set(fig, 'PaperPosition', [0, 0, pos(3), pos(4)]);
    margin_left = 0.1;
    margin_right = 0.09;
    margin_bottom = 0.1;
    margin_top = 0.05;
    
    total_plot_width = 1 - margin_left - margin_right;
    if has_denoised_image % Trường hợp có 4 plot
        vertical_gap = 0.17;
        total_vertical_space = 1 - margin_bottom - margin_top - (3 * vertical_gap);
        subplot_height = total_vertical_space / 4;
        
        y_pos4 = margin_bottom;
        y_pos3 = y_pos4 + subplot_height + vertical_gap;
        y_pos2 = y_pos3 + subplot_height + vertical_gap;
        y_pos1 = y_pos2 + subplot_height + vertical_gap;
        % --- VẼ 4 SUBPLOTS ---
        % Subplot 1: Input
        ax1 = axes('Position', [margin_left, y_pos1, total_plot_width, subplot_height]);
        imagesc(ax1, freq_axis, time_axis, noisy_image);
        title(ax1, '\textbf{Received Spectrogram}', 'FontSize', font_size);
        ylabel(ax1, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax1, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax1, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        colormap(ax1, 'parula'); colorbar(ax1); clim(ax1, [0 1]);
    
        % Subplot 2: Ground Truth
        ax2 = axes('Position', [margin_left, y_pos2, total_plot_width, subplot_height]); 
        imagesc(ax2, freq_axis, time_axis, true_label_mask_modified); % Dùng dữ liệu đã sửa
        title(ax2, '\textbf{Ground Truth}', 'FontSize', font_size);
        ylabel(ax2, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax2, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax2, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        colormap(ax2, label_colormap_ordered); clim(ax2, [0 num_classes-1]);
        cb2 = colorbar(ax2); cb2.Limits = [-0.5 num_classes-0.5];
        set(cb2, 'Ticks', 0:(num_classes-1), 'TickLabels', class_names, 'FontSize', font_size);
    
        % Subplot 3: Reconstructed
        ax3 = axes('Position', [margin_left, y_pos3, total_plot_width, subplot_height]);
        imagesc(ax3, freq_axis, time_axis, predicted_denoised_image);
        title(ax3, 'Reconstructed Spectrogram', 'FontSize', font_size);
        ylabel(ax3, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax3, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax3, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        colormap(ax3, 'parula'); colorbar(ax3); clim(ax3, [0 1]);
    
        % Subplot 4: Predicted
        ax4 = axes('Position', [margin_left, y_pos4, total_plot_width, subplot_height]);
        imagesc(ax4, freq_axis, time_axis, predicted_label_mask_modified); % Dùng dữ liệu đã sửa
        title(ax4, '\textbf{Predicted Labels}', 'FontSize', font_size);
        ylabel(ax4, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax4, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax4, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        colormap(ax4, label_colormap_ordered); clim(ax4, [0 num_classes-1]);
        cb4 = colorbar(ax4); cb4.Limits = [-0.5 num_classes-0.5];
        set(cb4, 'Ticks', 0:(num_classes-1), 'TickLabels', class_names, 'FontSize', font_size);
    else % Trường hợp chỉ có 3 plot
        vertical_gap = 0.18;
        total_vertical_space = 1 - margin_bottom - margin_top - (2 * vertical_gap);
        subplot_height = total_vertical_space / 3;
        y_pos3 = margin_bottom; % Subplot dưới cùng
        y_pos2 = y_pos3 + subplot_height + vertical_gap;
        y_pos1 = y_pos2 + subplot_height + vertical_gap;
        % --- VẼ 3 SUBPLOTS ---
        % Subplot 1: Input
        ax1 = axes('Position', [margin_left, y_pos1, total_plot_width, subplot_height]);
        imagesc(ax1, freq_axis, time_axis, noisy_image);
        title(ax1, '\textbf{Received Spectrogram}', 'FontSize', font_size);
        ylabel(ax1, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax1, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax1, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        colormap(ax1, 'parula'); colorbar(ax1); clim(ax1, [0 1]);
        % Subplot 2: Ground Truth
        % Subplot 2: Ground Truth
        ax2 = axes('Position', [margin_left, y_pos2, total_plot_width, subplot_height]); 
        imagesc(ax2, freq_axis, time_axis, true_label_mask_modified); % Dùng dữ liệu đã sửa
        title(ax2, '\textbf{Ground Truth}', 'FontSize', font_size);
        ylabel(ax2, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax2, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax2, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        
        % Ép colormap rời rạc theo số class
        colormap(ax2, label_colormap_ordered);
        caxis(ax2, [-0.5 num_classes-0.5]);   % mỗi class chiếm đúng 1 ô
        
        % Tạo colorbar và chỉnh tick
        cb2 = colorbar(ax2);
        cb2.Ticks = 0:(num_classes-1);
        cb2.TickLabels = class_names;
        cb2.Limits = [-0.5 num_classes-0.5];
        cb2.TickLength = 0;   % bỏ vạch nhỏ trong colorbar
        set(cb2, 'FontSize', font_size);

    
        % Subplot 3: Predicted
        ax3 = axes('Position', [margin_left, y_pos3, total_plot_width, subplot_height]);
        imagesc(ax3, freq_axis, time_axis, predicted_label_mask_modified); % Dùng dữ liệu đã sửa
        title(ax3, '\textbf{Predicted Labels}', 'FontSize', font_size);
        ylabel(ax3, 'Time (ms)', 'FontSize', font_size);
        xlabel(ax3, 'Frequency (MHz)', 'FontSize', font_size);
        set(ax3, 'YDir', 'normal', 'FontSize', font_size, 'LineWidth', 1);
        
        % Ép colormap rời rạc
        colormap(ax3, label_colormap_ordered);
        caxis(ax3, [-0.5 num_classes-0.5]);   % mỗi class chiếm đúng 1 ô
        
        % Tạo colorbar rời rạc
        cb3 = colorbar(ax3);
        cb3.Ticks = 0:(num_classes-1);
        cb3.TickLabels = class_names;
        cb3.Limits = [-0.5 num_classes-0.5];
        cb3.TickLength = 0;   % bỏ vạch nhỏ
        set(cb3, 'FontSize', font_size);

    end
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