# Bag_data_extraction  																																																				
A Matlab routine to extract data from *.bag file created by Intel realsense camera. 

[![View Bag_data_extraction on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/132912-bag_data_extraction)

### Usage 
#### extract_info.m
This function is to extract all the information out of the bag file. The output to the function are (all data with name and values),(Names of signals with more than one output),(Name of signals with 0 messages)
```matlab
[Data,Signal_Info] = extract_info(input)
```


#### rosbag_yuyv_align.m
This function opens a pre-recorded *.bag file aligns it to the color stream and displays the color stream, depth stream, and the overlap. The output is saved as a *.mp4 to be viewed later.
```matlab
rosbag_yuyv_align(filename)
```
![image](https://github.com/chhayank-sri/Bag_data_extraction/assets/117337144/e29797c2-9e3d-4236-b206-a1d6154f4d1a)


#### yuyv2rgb_optimized_mex.mexw64
This function is used to convert 32bit YUYV data from Intel realsense camera to RGB image
```matlab
image = yuyv2rgb_optimized_mex(color_frame.get_data(),color_frame.get_height(),color_frame.get_width())
```
