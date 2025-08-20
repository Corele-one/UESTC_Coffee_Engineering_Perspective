%%使用非盲反卷积对图像进行清晰度恢复
I = imread("selected_roi.jpg");
I2 = imread("selected_roi.jpg"); % 彩色图像
I = rgb2gray(I);
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
n =3; % 调整 PSF 的大小以适应光谱大小
psf_size = floor(min(image_height, image_width) / n); 
psf_size = psf_size + mod(psf_size, 2); % 确保 PSF 尺寸为奇数

% 重新生成 PSF
PSF = fspecial('gaussian', [psf_size, image_width], sigma);

% 确保 PSF 的总和为 1
PSF = PSF / sum(PSF(:));

% 显示调整后的 PSF
figure;
imshow(PSF, []);
title("Resized PSF (Image Size)");

%% 使用三个不同的PSF进行图像恢复
    
i = 7; % 迭代次数
[J, P] = deconvblind(I, PSF, i); % 使用盲反卷积对图像进行清晰度恢复
figure(2);
imshow(J);
title("Restored Image with PSF");

%% 使用循环观察不同迭代次数下的清晰度
figure('Name', 'Deconvolution with Different Iterations', 'NumberTitle', 'off');


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

% 循环迭代次数从 1 到 10
for i = 1:10
    restored_channels = zeros(size(I2));
    % 对彩色图像 I2 的每个通道分别进行盲反卷积
    for channel = 1:3
        % 将 dampar 转换为与输入图像相同的数据类型
        dampar_cast = cast(dampar, class(I2(:,:,channel)));
        [restored_channels(:,:,channel), ~] = deconvblind(I2(:,:,channel), PSF, i, dampar_cast);
    end
    restored_channels = uint8(restored_channels);

    % 在子图中显示恢复后的彩色图像
    subplot(2, 5, i); % 创建 2 行 5 列的子图
    imshow(restored_channels, []);
    title(['Iterations: ', num2str(i)]);
    
    % 导出第七次迭代的图像
    if i == 4
        imwrite(restored_channels, 'restored_image.png', 'png');
        disp('第七次迭代的去卷积图像已导出为 restored_image_iteration_7.png');
    end
end

imwrite(J, 'restoredimage.png', 'png');
% 总标题
sgtitle('Restored Color Images with Different Iterations');