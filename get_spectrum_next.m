% 读取光谱数据
% 清除所有变量，但保留持久变量和全局变量
clearvars

% 读取拟合系数
load('poly_fit_coeffs.mat', 'p');
disp('拟合系数已成功加载');
disp(['拟合系数: ', num2str(p)]);

%% Modify filename to your photo image
% 读取图像文件
file1 =  'selected_roi.jpg';
image1 = imread(strcat(file1));
% file2 = 'restoredimage_Hg.png';
% image_standard = imread(file2); 
% imagesize_standard = size(image_standard);
% 转换为灰度图像
gray = rgb2gray(image1);
% %将image1的尺寸调整为与标准图像相同
% gray = imresize(gray, [imagesize_standard(1), imagesize_standard(2)]);
% 显示图像
figure;
imshow(gray, "Border", "tight");
% 获取图像尺寸
height = size(gray,1);
width = size(gray,2);

%% Define and Crop the Region of Interest (ROI)
% 提取 ROI
roi_line = gray(1:height, 1:width);

% 计算光谱数据
line_spec = sum(roi_line, 2); % 沿着列方向求和，得到光谱数据

% 将所有索引值转换为波长值
all_indices = 1:length(line_spec);
all_wavelengths = polyval(p, all_indices);
%% 索引与波长转换
% 使用多项式拟合函数将索引转换为波长
converted_wavelengths = polyval(p, 1:length(line_spec)); % 将所有索引转换为波长

% 限制波长范围在可见光范围内 (380 nm 到 780 nm)
visible_range = (converted_wavelengths >= 380) & (converted_wavelengths <= 780);

% 提取可见光范围内的数据
visible_wavelengths = converted_wavelengths(visible_range);
visible_intensities = line_spec(visible_range);
% 绘制可见光范围内的光谱数据
figure; 
plot(visible_wavelengths, visible_intensities, 'b-', 'LineWidth', 1.5);
title('可见光范围内的光谱数据');
xlabel('波长 (nm)');
ylabel('强度');
grid on;
% 设置 x 轴范围
xlim([380 780]);