# UESTC_Coffee_Engineering_Perspective
电子科技大学新生研讨课——电子工程师眼中的咖啡，光谱仪项目相关代码
项目名称:利用简易光谱仪实现太阳暗特征谱线的测定
项目简介
本项目基于“电子工程师眼中的咖啡”课程的简易光谱仪，旨在通过光谱数据采集与处理，实现太阳光谱中暗特征谱线（夫琅禾费线）的测定。项目包括光谱仪的搭建、程序设计、数据处理与分析等环节。

简介
----
本项目用于对光谱图像进行ROI选取、去卷积处理、光谱提取与分析。支持多种光谱图像的处理流程，包括图像去模糊、极值点检测、波长拟合等，适用于课程论文或相关科研工作。

项目结构
--------
- ROI_Select.py / ROI_Select_Decon.py:用于手动框选光谱图像区域并保存ROI。
- color_dampar.m / color_deconvolution.m / dampar_select.m / deconvolution.m：MATLAB脚本，完成图像去卷积、PSF估算、噪声分析及恢复。
- get_spectrum_standard.m / get_spectrum_next.m：MATLAB脚本，提取并分析光谱数据，进行波长拟合与极值点检测。
- poly_fit_coeffs.mat / poly_fit_coeffs_filtered.mat：保存多项式拟合系数的MAT文件。
- extrema_points.xlsx / smoothed_intensity_wavelength.xlsx：保存极值点和光谱强度-波长数据。
- deconvolved_image.jpg / restored_image.jpg / restored_image.png / restoredimage_Hg.png / restoredimage.png / selected_roi_Hg.jpg / selected_roi.jpg：中间及结果图像文件。
- Spectrum_Picture/：存放原始光谱图片。

使用方法
--------
1. 运行 `ROI_Select.py` 或 `ROI_Select_Decon.py`，手动框选光谱区域，生成 `selected_roi.jpg`。
2. 使用 `color_dampar.m`、`dampar_select.m` 或 `deconvolution.m` 进行图像去卷积与恢复，生成去卷积后的图像。
3. 运行 `get_spectrum_standard.m` 或 `get_spectrum_next.m`，提取光谱数据并进行波长拟合、极值点检测，结果保存为Excel和MAT文件。
4. 查看生成的图像和数据文件，进行后续分析或论文撰写。

依赖环境
--------
- Python 3,需安装 OpenCV、NumPy、SciPy 等库
- MATLAB R2018a 及以上版本

注意事项
--------
- 图像路径需根据实际文件位置进行修改。
- 部分脚本需手动交互选取区域。
- 结果文件会覆盖同名文件，请注意备份。

作者
----
- zenghz@uestc.edu.cn(提供原始代码)
- Corleone
---
README文件由AI助手生成。
---
曾老师非常注重学术诚信，我将代码开源是出于之后的同学能够将曾老师的课程项目做的越来越好，而非直接搬用，我在做该课程项目的时候犯了没有控制拍摄的原始光谱图像与标准图像大小一致的错误，导致最后的实验结果出现了误差（哭），最后如果我的代码对你有帮助的话，希望你能给我star鼓励一下哦。
第一次使用git传项目，有问题欢迎随时comment
