% --- 1. KHỞI TẠO MÔI TRƯỜNG ---
clear; clc; close all;

% Cài đặt chuẩn LaTeX
set(groot,'defaultAxesTickLabelInterpreter','latex');  
set(groot,'defaultTextInterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontName','latex');
set(groot,'defaultTextFontName','latex');
set(groot,'defaultAxesFontSize', 13); 

% --- 2. DỮ LIỆU ---
% Rows    = Ground Truth
% Columns = Prediction
% Class order: ASR, 5G NR, LTE, Noise
cm_data = [
    93.03,  2.57,  1.25,  3.15;
     0.15, 80.02,  0.75, 19.08;
     0.12, 10.57, 66.40, 22.91;
     0.15, 22.52,  2.14, 75.19;
];
labels = {'ASR', '5G NR', 'LTE', 'Noise'};

% --- 3. FIGURE ---
fig = figure('Color', 'w', ...
    'Units', 'pixels', ...
    'Position', [100 100 415 300]);

% Tạo axes thủ công để dễ dời trái/phải/lên/xuống
ax = axes(fig);

% --- 4. VẼ BIỂU ĐỒ ---
imagesc(ax, cm_data, [0 100]);

% --- 5. TÙY CHỈNH MÀU SẮC ---
start_color = [1, 1, 1];    
end_color   = [0, 0, 0.6];  

m = 256; 
cmap = [linspace(start_color(1), end_color(1), m)', ...
        linspace(start_color(2), end_color(2), m)', ...
        linspace(start_color(3), end_color(3), m)'];

colormap(ax, cmap);

% --- 6. TÙY CHỈNH TRỤC VÀ NHÃN ---
axis(ax, 'square');
box(ax, 'on');

set(ax, 'TickDir', 'in');   
set(ax, 'TickLength', [0.01, 0.01]); 
set(ax, 'LineWidth', 0.5);    
set(ax, 'Layer', 'top'); 

xticks(ax, 1:4);
yticks(ax, 1:4);
xticklabels(ax, labels);
yticklabels(ax, labels);
xtickangle(ax, 30); 

xlabel(ax, 'Predicted Class', ...
    'FontSize', 13, ...
    'Interpreter', 'latex');

ylabel(ax, 'True Class', ...
    'FontSize', 13, ...
    'Interpreter', 'latex');

% --- 7. CHÈN SỐ ---
for i = 1:4 
    for j = 1:4 
        val = cm_data(i, j);

        if val > 50 
            text_color = 'white';
        else
            text_color = 'black';
        end

        text(ax, j, i, sprintf('%.2f', val), ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 13, ...         
            'FontName', 'latex', ...
            'Interpreter', 'latex', ...
            'Color', text_color);
    end
end

colorbar(ax, 'off');

% --- 8. DỜI ẢNH QUA TRÁI + GIẢM MARGIN TRÊN ---
drawnow;

set(ax, 'Units', 'normalized');

% [left bottom width height]
% left  nhỏ hơn  -> dời ảnh qua trái
% bottom lớn hơn -> dời ảnh lên trên
% width/height lớn hơn -> ảnh lớn hơn
set(ax, 'Position', [0.1 0.22 0.74 0.74]);

% Giảm khoảng trắng tự động của axes
set(ax, 'LooseInset', [0 0 0 0]);

% --- 9. XUẤT FILE ---
exportgraphics(fig, 'ConfusionMatrix_ReSpecNet.png', ...
    'Resolution', 600, ...
    'BackgroundColor', 'white');

exportgraphics(fig, 'ConfusionMatrix_ReSpecNet.eps', ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');