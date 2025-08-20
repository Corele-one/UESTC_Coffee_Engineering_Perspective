%%使用非盲反卷积对图像进行清晰度恢复
I = imread("selected_roi.jpg");
I = rgb2gray(I);
file2 = 'selected_roi_Hg.jpg';
image_standard = imread(file2); 
imagesize_standard = size(image_standard);
% 将图像调整为与标准图像相同的尺寸
I = imresize(I, [imagesize_standard(1), imagesize_standard(2)]);
% 显示原始图像
figure; 
imshow(I);
title("Original Image");%读取图像，将图像转换为灰度图像
hold on;
%% 根据镜头参数估计 PSF
% 已知镜头参数
aperture_diameter = 13.18;   % 光圈直径 (mm)
defocus_distance = 2.0;      % 失焦距离 (mm)
focal_length = 29;           % 焦距 (mm)
pixel_size = 0.0015;         % 像素大小 (mm/pixel)

% 计算模糊直径 (单位：mm)
blur_diameter = (aperture_diameter * defocus_distance) / focal_length;

% 转换为像素单位
blur_diameter_pixels = blur_diameter / pixel_size;

% 计算高斯 PSF 的标准差 (sigma)
sigma = blur_diameter_pixels / 2.355;

% 获取图像的大小
[image_height, image_width] = size(I);

% 生成高斯 PSF
n=4;% 调整 PSF 的大小以适应光谱大小
psf_size = floor(min(image_height, image_width)/n); 
psf_size = psf_size + mod(psf_size, 2); % 确保 PSF 尺寸为奇数

% 重新生成 PSF
PSF = fspecial('gaussian', [psf_size, image_width], sigma);

% 确保 PSF 的总和为 1
PSF = PSF / sum(PSF(:));

% 显示调整后的 PSF
figure;
imshow(PSF, []);
title("Resized PSF (Image Size)");

%% 交互式选择噪声区域并确定 dampar
figure;
imshow(I);
title('Select a noise region using the mouse');
disp('请用鼠标选择一个噪声区域，然后双击确认');

% 使用 imrect 交互式选择噪声区域
h = imrect;
position = wait(h); % 等待用户完成选择
noise_region = imcrop(I, position); % 提取噪声区域

% 计算噪声区域的标准差
noise_std = std2(noise_region);
disp(['Noise standard deviation: ', num2str(noise_std)]);

% 确保 dampar 的类型与图像 I 的类型一致
dampar = cast(2 * noise_std, class(I)); % 转换 dampar 的类型
disp(['Calculated dampar: ', num2str(dampar)]);

%% 使用盲去卷积进行图像恢复
i = 15; % 迭代次数
[J, P] = deconvblind(I, PSF, i, dampar);

% 显示恢复后的图像
figure;
imshow(J, []);
title(['Restored Image with dampar = ', num2str(dampar)]);
%存储恢复后的图像
imwrite(J, 'restored_image.jpg');
%% 使用循环观察不同迭代次数下的清晰度
figure('Name', 'Deconvolution with Different Iterations', 'NumberTitle', 'off');

% 循环迭代次数从 1 到 10
for i = 1:10
    % 使用盲去卷积进行图像恢复
    [J, P] = deconvblind(I, PSF, i, dampar);
    
    % 在子图中显示恢复后的图像
    subplot(2, 5, i); % 创建 2 行 5 列的子图
    imshow(J, []);
    title(['Iterations: ', num2str(i)]);
end

% 总标题
sgtitle('Restored Images with Different Iterations');

% 提取 ROI
height1 = size(I,1);
width1 = size(I,2);
roi_line1 = I(1:height1, 1:width1);

% 计算光谱数据
line_spec1 = sum(roi_line1, 2);


% % 显示光谱数据% 获取图像尺寸
figure(7);
plot(line_spec1, 'b-', 'LineWidth', 1.5);
title('去卷积前光谱数据');

% 提取 ROI
height2 = size(J,1);
width2 = size(J,2);

roi_line2 = J(1:height2, 1:width2);

% 计算光谱数据
line_spec2 = sum(roi_line2, 2);

% % 显示光谱数据
figure(8);
plot(line_spec2, 'b-', 'LineWidth', 1.5);
title('去卷积后光谱数据');