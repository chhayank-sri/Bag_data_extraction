function rosbag_yuyv_align(filename)
    % Validate input
    validateattributes(filename, {'char','string'}, {'scalartext', 'nonempty'}, '', 'filename', 1);
    % Create display
    figure('WindowState','maximized');
    ButtonHandle = uicontrol('Style', 'PushButton', ...
                             'String', 'Stop loop', ...
                             'Callback', 'delete(gcbf)');
    % Number of frames
    bagfile = rosbag(filename);
    Data.TopicBag = select(bagfile,"Topic",'/device_0/sensor_0/Depth_0/image/data');
    Data.Message = readMessages(Data.TopicBag,"DataFormat","Struct");
    no_frames = length(Data.Message);
    
    % Video Start lines
    video_name = strcat(filename(1:end-4),'.mp4');
    v = VideoWriter(video_name,'MPEG-4');
    v.FrameRate = 30;
    open(v);

    % Make Config object to manage pipeline settings
    cfg = realsense.config();
    % Tell pipeline to stream from the given rosbag file
    cfg.enable_device_from_file(filename)

    % Make Pipeline object to manage streaming  
    pipe = realsense.pipeline();

    % Start streaming from the rosbag with default settings
    profile = pipe.start(cfg);

    % Get streaming device's name
    device = profile.get_device();
    name = device.get_info(realsense.camera_info.name);

    % Get playback duration
    playback = realsense.playback(device.objectHandle,-1);
    % Play each frame
    playback.set_real_time(false);

    % get depth image parameters
    depthSensor = device.first('depth_sensor');
    depthScale = depthSensor.get_depth_scale();

    % Align to depth frame
    align_to = realsense.stream.color();
    align = realsense.align(realsense.stream.color());
    
    ii=1;

    while ishandle(ButtonHandle)
        % Get frames
        fs = pipe.wait_for_frames();

        % Get aligned frames 
        aligned_fs = align.process(fs);

        %Get Color frame
        color_frame = aligned_fs.get_color_frame();
        color_data = color_frame.get_data();

        %Get Depth frame
        depth_frame = aligned_fs.get_depth_frame();
        depth_data  = depth_frame.get_data();

        %Frame dimension
        if align_to == realsense.stream.color
            width = color_frame.get_width();
            height = color_frame.get_height();
        elseif align_to == realsense.stream.depth
            width = depth_frame.get_width();
            height = depth_frame.get_height();
        end

        %Frame number
        frame_no(ii,1) = aligned_fs.get_frame_number();
        frame_elapsed = max(frame_no)-min(frame_no);
        
        %To close at the end of bag file
        if frame_elapsed == no_frames-1
            break;
        end

        %Process depth image
        depth_img = double(transpose(reshape(depth_data, [depth_frame.get_width(),depth_frame.get_height()]))) .* depthScale;
        %Process color image
        color_img = yuyv2rgb_optimized_mex(color_data,height,width);


        %Display Image
        speed_display(color_img,depth_img,name,depthScale,frame_no(ii,1));
        frame = getframe(gcf);
        writeVideo(v,frame);
        drawnow;
        ii = ii+1;
        
    end
    playback.stop();
    pipe.stop();

    %Closes all figure and video
    close all;
    
    function speed_display(color_img,depth_img,name,depthScale,frame_no)
        subplot(2,2,1)
        imshow(color_img)
        title("Color Channel")
        subplot(2,2,3)
        imshow(rescale(depth_img,0,255))
        title(sprintf("Depth Channel (depth scale - %f)",depthScale))
        sgtitle(strcat(name," Image channels"))
        subplot(2,2,[2,4])
        thres = adaptthresh(rescale(depth_img,0,255));
        fore_mask = imbinarize(rescale(depth_img,0,255),thres);
        imshow(imfuse(color_img,fore_mask));
        title(sprintf("Frame Number -> %d)",frame_no));
    end
end