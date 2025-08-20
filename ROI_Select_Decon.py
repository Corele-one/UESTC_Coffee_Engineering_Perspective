import cv2
import numpy as np
from scipy.signal import convolve2d
from numpy.fft import fft2, ifft2

def wiener_deconvolution(image, psf, K=0.01):
    """
    使用维纳滤波算法对图像进行去卷积操作
    :param image: 输入图像（灰度图像）
    :param psf: 点扩散函数（Point Spread Function）
    :param K: 维纳滤波参数，用于控制噪声抑制
    :return: 去卷积后的图像
    """
    # 将图像和 PSF 转换到频域
    image_fft = fft2(image)
    psf_fft = fft2(psf, s=image.shape)

    # 计算维纳滤波器
    psf_fft_conj = np.conj(psf_fft)
    wiener_filter = psf_fft_conj / (np.abs(psf_fft) ** 2 + K)

    # 应用维纳滤波器
    deconvolved_fft = image_fft * wiener_filter

    # 转换回空间域
    deconvolved = np.abs(ifft2(deconvolved_fft))
    return deconvolved

def select_roi_from_large_image(image_path, scale_factor=0.3):
    # 读取原始图片
    original_image = cv2.imread(image_path)
   
    # 对图片进行压缩处理
    compressed_image = cv2.resize(original_image, None, fx=scale_factor, fy=scale_factor)

    # 显示压缩后的图片并选择ROI区域
    roi = cv2.selectROI('Select ROI', compressed_image, False)
    if roi is None:
        print("Error: Unable to load image.")
        return None
    # 计算原始图片中ROI区域的坐标
    x, y, w, h = roi
    original_x = int(x / scale_factor)
    original_y = int(y / scale_factor)
    original_w = int(w / scale_factor)
    original_h = int(h / scale_factor)

    # 提取原始图片中的ROI区域
    original_roi = original_image[original_y:original_y + original_h, original_x:original_x + original_w]

    # 保存ROI区域为图像文件
    roi_filename = 'selected_roi.jpg'
    if original_roi is None:
        print("Error: Unable to extract ROI.")
        return None
        
    cv2.imwrite(roi_filename, original_roi)
    print(f"ROI区域已保存为 {roi_filename}")

    # 显示原始图片中的ROI区域
    cv2.imshow('Original ROI', original_roi)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    return original_roi

def gaussian_psf_from_lens(aperture_diameter, defocus_distance, focal_length, pixel_size):
    """
    根据镜头参数计算高斯 PSF 的标准差 (sigma)
    :param aperture_diameter: 光圈直径 (mm)
    :param defocus_distance: 失焦距离 (mm)
    :param focal_length: 镜头焦距 (mm)
    :param pixel_size: 传感器像素大小 (mm/pixel)
    :return: 高斯 PSF 的标准差 (sigma)
    """
    # 计算模糊范围（以像素为单位）
    blur_diameter = (aperture_diameter * defocus_distance) / focal_length  # 模糊范围 (mm)
    sigma = blur_diameter / (2.355 * pixel_size)  # 转换为像素单位，2.355 是高斯分布的 FWHM 转换系数
    return sigma

def gaussian_psf(size, sigma):
    x = np.linspace(-size // 2, size // 2, size)
    y = np.linspace(-size // 2, size // 2, size)
    x, y = np.meshgrid(x, y)
    psf = np.exp(-(x**2 + y**2) / (2 * sigma**2))
    psf /= psf.sum()  # 归一化
    return psf

# 实际参数
aperture_diameter = 13.18   # 光圈直径 (mm)
defocus_distance = 2.0   # 失焦距离 (mm)
focal_length = 29      # 焦距 (mm)
pixel_size = 0.0015       # 像素大小 (mm/pixel)

# 计算高斯 PSF 的 sigma
sigma = gaussian_psf_from_lens(aperture_diameter, defocus_distance, focal_length, pixel_size)

# 生成高斯 PSF
psf = gaussian_psf(size=11, sigma=sigma)

path = "D:\\23644\\Pictures\\Spectrum_Picture\\Hg_Spectrum\\1.jpg"
# 读取光谱图像
image = cv2.imread(path)

if image is not None:
    # 转换为灰度图像
    gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # 定义点扩散函数（PSF），可以根据实际情况调整
    psf = gaussian_psf(size=5, sigma=1.0)  # 5x5 高斯 PSF，标准差为 1.0

    # 使用维纳滤波进行去卷积
    deconvolved_image = wiener_deconvolution(gray_image, psf, K=0.01)

    # 将去卷积后的图像转换为 uint8 类型
    deconvolved_image = np.clip(deconvolved_image, 0, 255)  # 限制像素值范围在 0 到 255
    deconvolved_image = deconvolved_image.astype(np.uint8)

    # 将灰度图像转换为彩色图像
    color_deconvolved_image = cv2.cvtColor(deconvolved_image, cv2.COLOR_GRAY2BGR)

    # 保存去卷积后的图像
    cv2.imwrite('deconvolved_image.jpg', deconvolved_image)

    # 显示去卷积后的图像
    cv2.imshow('Deconvolved Image', deconvolved_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
else:
    print("Error: Unable to load image.")



cropped_image=select_roi_from_large_image('E:\\matlab_code\\deconvolved_image.jpg', scale_factor=0.2)

