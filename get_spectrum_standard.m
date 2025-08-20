%% MATLAB script for CoffEE Course Proejct
% Convert color image to spectroscopic line
% For Student's Project in CoffEE Course
% Author:   zenghz@uestc.edu.cn
% Date:     Feb, 2000

% 清除所有变量，但保留持久变量和全局变量
clearvars

%% Modify filename to your photo image
% 读取图像文件
file =  'restoredimage_Hg.png';
colorimage = imread(strcat(file)); 
imshow(colorimage,"Border","tight");
% 转换为灰度图像
gray = colorimage;

% 获取图像尺寸
height = size(gray,1);
width = size(gray,2);

%% Define and Crop the Region of Interest (ROI)
% 提取 ROI
roi_line = gray(1:height, 1:width);

% 计算光谱数据
line_spec = sum(roi_line, 2);

% % 显示光谱数据
% figure(1);
% plot(line_spec, 'b-', 'LineWidth', 1.5);
% title('光谱数据');

%% 使用 Savitzky-Golay 滤波器进行平滑处理
window_size = 41; % 滤波窗口大小（必须为奇数）
polynomial_order = 3; % 多项式阶数
smoothed_line_spec = sgolayfilt(line_spec, polynomial_order, window_size);

% % 显示原始光谱数据和平滑后的光谱数据
% figure(1);
% plot(line_spec, 'b-', 'LineWidth', 1.5); % 原始光谱数据
% hold on;
% plot(smoothed_line_spec, 'r-', 'LineWidth', 1.5); % 平滑后的光谱数据
% title('光谱数据');

%% 计算导数并寻找导数为 0 的点
% 计算平滑后的光谱数据的一阶导数和二阶导数
smoothed_derivative = diff(smoothed_line_spec);
smoothed_second_derivative = diff(smoothed_derivative);

% 初始化存储极大值点的索引
max_points = [];

% 遍历导数值，寻找导数为 0 且二阶导数大于 0 的点
for i = 1:length(smoothed_derivative)-1
    % 检查导数是否在两个点之间变号（即过零点）
    if smoothed_derivative(i) * smoothed_derivative(i+1) < 0
        % 检查二阶导数是否大于 0
        if smoothed_second_derivative(i) < 0
            max_points = [max_points; i]; % 记录极大值点的索引
        end
    end
end


% % % 绘制极值点
figure(1);
plot(smoothed_line_spec, 'b-', 'LineWidth', 1.5); % 原始光谱数据
hold on;
% plot(max_points, smoothed_line_spec(max_points), 'ro', 'MarkerSize', 8); % 绘制极大值点
% title('光谱数据');

%% 保留指定索引的极值点
% 指定需要保留的索引
selected_indices = [2, 5,9,12, 14];

% 从 max_points 中提取对应的点
filtered_max_points = max_points(selected_indices);
% % 绘制保留的极值点
figure(1);
plot(filtered_max_points, smoothed_line_spec(filtered_max_points), 'ro', 'MarkerSize', 20); % 绘制极大值点
title('极值点位置','FontSize', 16);
% 添加注释
Str = '$2x^2 + x + 1$';
an = annotation('textarrow',[0.5,0.5],[0.5,0.5],...
    'Interpreter','latex','String',Str,'FontSize',13);
an.Position = [0.7,0.7,-0.06,-0.07];
an.LineWidth = 1;% 添加注释
Str = '$2x^2 + x + 1$';
an = annotation('textarrow',[0.5,0.5],[0.5,0.5],...
    'Interpreter','latex','String',Str,'FontSize',13);
an.Position = [0.7,0.7,-0.06,-0.07];
an.LineWidth = 1;% 添加注释
Str = '$2x^2 + x + 1$';
an = annotation('textarrow',[0.5,0.5],[0.5,0.5],...
    'Interpreter','latex','String',Str,'FontSize',13);
an.Position = [0.7,0.7,-0.06,-0.07];
an.LineWidth = 1;% 添加注释
Str = '$2x^2 + x + 1$';
an = annotation('textarrow',[0.5,0.5],[0.5,0.5],...
    'Interpreter','latex','String',Str,'FontSize',13);
an.Position = [0.7,0.7,-0.06,-0.07];
an.LineWidth = 1;
an.LineWidth = 1;% 添加注释
Str = '$2x^2 + x + 1$';
an = annotation('textarrow',[0.5,0.5],[0.5,0.5],...
    'Interpreter','latex','String',Str,'FontSize',13);
an.Position = [0.7,0.7,-0.06,-0.07];
an.LineWidth = 1;
disp('保留的极值点索引：');
disp(filtered_max_points);

% 对应的波长值
wavelengths = [405,435,490,544,611]; % 只保留前五个波长

% 确保极值点数量与波长数量一致
if length(filtered_max_points) ~= length(wavelengths)
    error('极值点数量与波长数量不一致，请检查数据！');
end

% 曲线拟合（使用三次多项式拟合）
p = polyfit(filtered_max_points, wavelengths, 3); % 三次多项式拟合
fitted_wavelengths = polyval(p, filtered_max_points); % 计算拟合值

% 打印拟合结果
disp('曲线拟合结果：');
disp(['拟合曲线方程：wavelength = ', num2str(p(1)), ' * index^3 + ', num2str(p(2)), ' * index^2 + ', num2str(p(3)), ' * index + ', num2str(p(4))]);

% 导出拟合系数到 .mat 文件
save('poly_fit_coeffs.mat', 'p');
disp('拟合系数已成功导出到 poly_fit_coeffs.mat');

% 将所有索引值转换为波长值
all_indices = 1:length(line_spec);
all_wavelengths = polyval(p, all_indices);

%% 转换为色彩强度与波长的光谱
% 将像素索引的光谱转换为波长的光谱
intensity_wavelength = interp1(all_wavelengths, line_spec, all_wavelengths, 'nearest', 'extrap');

%% 对强度-波长曲线进行 SG 平滑处理
% 定义 SG 滤波器参数
window_size = 47; % 滤波窗口大小（必须为奇数）
polynomial_order = 7; % 多项式阶数

% 对强度-波长曲线进行平滑
smoothed_intensity_wavelength = sgolayfilt(intensity_wavelength, polynomial_order, window_size);

%% 在强度和波长曲线上寻找极值点
% 计算强度与波长曲线的一阶导数和二阶导数
intensity_derivative = diff(smoothed_intensity_wavelength);
intensity_second_derivative = diff(intensity_derivative);

% 初始化存储极值点的索引
extrema_points = [];

% 遍历导数值，寻找导数为 0 且二阶导数小于 0 的点（极大值点）
for i = 1:length(intensity_derivative)-1
    % 检查导数是否在两个点之间变号（即过零点）
    if intensity_derivative(i) * intensity_derivative(i+1) < 0
        % 检查二阶导数是否小于 0
        if intensity_second_derivative(i) < 0
            extrema_points = [extrema_points; i]; % 记录极大值点的索引
        end
    end
end

% 打印极值点的波长和强度
disp('极值点的波长和强度：');
for i = 1:length(extrema_points)
    disp(['波长: ', num2str(all_wavelengths(extrema_points(i))), ...
          ', 强度: ', num2str(smoothed_intensity_wavelength(extrema_points(i)))]);
end

%% 绘制结果
figure(2);

% 极值点波长拟合

plot(filtered_max_points, wavelengths, 'ro', 'MarkerSize', 8, 'DisplayName', '实际波长'); % 实际波长点
hold on;
plot(filtered_max_points, fitted_wavelengths, 'b-', 'LineWidth', 1.5, 'DisplayName', '拟合曲线'); % 拟合曲线
legend;
title('极值点波长拟合');
xlabel('极值点索引');
ylabel('波长 (nm)');
grid on;

% % 第二幅图：光谱强度与波长的转换（平滑前后对比）
% subplot(2, 1, 2);
% plot(all_wavelengths, smoothed_intensity_wavelength, 'r-', 'LineWidth', 1.5, 'DisplayName', '平滑光谱强度-波长'); % 平滑后的光谱强度与波长
% hold on;

% % 在强度和波长曲线上标记极值点
% scatter(all_wavelengths(extrema_points), smoothed_intensity_wavelength(extrema_points), 'bo', 'filled', ...
%         'DisplayName', '极值点'); % 标记极值点
% % for i = 1:length(extrema_points)
% %     text(all_wavelengths(extrema_points(i)), smoothed_intensity_wavelength(extrema_points(i)), ...
% %          ['\leftarrow ', num2str(all_wavelengths(extrema_points(i)), '%.2f'), ' nm'], ...
% %          'FontSize', 8, 'Color', 'blue');
% % end

% legend;
% title('光谱强度与波长的转换（标记极值点）');
% xlabel('波长 (nm)');
% ylabel('光谱强度');
% grid on;

%%绘制波长与索引的多项式拟合曲线
%计算所有索引的对应拟合波长
all_fitted_wavelengths = polyval(p, all_indices);

% 创建新的图形窗口
figure(3);

% 绘制原始数据点
plot(filtered_max_points, wavelengths, 'ro', 'MarkerSize', 8, 'DisplayName', '原始数据点');

hold on;

% 绘制拟合曲线
plot(all_indices, all_fitted_wavelengths, 'b-', 'LineWidth', 1.5, 'DisplayName', '多项式拟合曲线');

% 添加图例
legend;

% 添加图标题
title('波长与索引的多项式拟合曲线');

% 添加 x 轴和 y 轴标签
xlabel('索引');
ylabel('波长 (nm)');

% 显示网格线
grid on;

% 释放坐标轴
hold off;

% 导出极值点数据到 Excel 文件
outputFileName = 'extrema_points.xlsx';
writematrix([all_wavelengths(extrema_points), smoothed_intensity_wavelength(extrema_points)], outputFileName, 'Sheet', 1, 'Range', 'A1');
disp(['极值点数据已成功导出到 ', outputFileName]);

% 导出平滑后的转换结果到 Excel 文件
outputFileName = 'smoothed_intensity_wavelength.xlsx';
writematrix([all_wavelengths(:), smoothed_intensity_wavelength(:)], outputFileName, 'Sheet', 1, 'Range', 'A1');
disp(['平滑后的转换结果已成功导出到 ', outputFileName]);

%% 索引与波长转换
% 使用多项式拟合函数将索引转换为波长
converted_wavelengths = polyval(p, 1:length(smoothed_line_spec)); % 将所有索引转换为波长

% 限制波长范围在可见光范围内 (380 nm 到 780 nm)
visible_range = (converted_wavelengths >= 380) & (converted_wavelengths <= 780);

% 提取可见光范围内的数据
visible_wavelengths = converted_wavelengths(visible_range);
visible_intensities = smoothed_line_spec(visible_range);

%% 绘制限定范围内的光谱数据
figure;
plot(visible_wavelengths, visible_intensities, 'b-', 'LineWidth', 1.5); % 绘制可见光范围内的光谱数据
title('可见光波长范围内的光谱数据');
xlabel('波长 (nm)');
ylabel('光谱强度');
grid on;
xlim([380, 780]); % 限定横坐标范围

% 计算可见光强度的一阶导数和二阶导数
visible_derivative = diff(visible_intensities);
visible_second_derivative = diff(visible_derivative);

% 初始化存储极大值点的索引
visible_max_points = [];

% 遍历导数值，寻找导数为 0 且二阶导数小于 0 的点（极大值点）
for i = 1:length(visible_derivative)-1
    % 检查导数是否在两个点之间变号（即过零点）
    if visible_derivative(i) * visible_derivative(i+1) < 0
        % 检查二阶导数是否小于 0
        if visible_second_derivative(i) < 0
            visible_max_points = [visible_max_points; i]; % 记录极大值点的索引
        end
    end
end

% 绘制极大值点
hold on;
plot(visible_wavelengths(visible_max_points), visible_intensities(visible_max_points), 'ro', 'MarkerSize', 8, 'DisplayName', '极大值点');

% 标注极大值点的横坐标（波长）
for i = 1:length(visible_max_points)
    text(visible_wavelengths(visible_max_points(i)), visible_intensities(visible_max_points(i)), ...
         ['\leftarrow ', num2str(visible_wavelengths(visible_max_points(i)), '%.2f'), ' nm'], ...
         'FontSize', 8, 'Color', 'red');
end

% 添加图例
legend;

% 释放坐标轴
hold off;


