import cv2
import numpy as np
from scipy.signal import convolve2d

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


path = "E:\matlab_code\Spectrum_Picture\Sun_Spectrum\\final2.jpg"
# 读取光谱图像
image = cv2.imread(path)

cropped_image=select_roi_from_large_image(path, scale_factor=0.2)

