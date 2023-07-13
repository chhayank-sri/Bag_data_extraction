%% This function transforms YUYV image to RGB image extracted from a BAG file

% Input -
% [color_sig] ---> color signal from *.bag file
% [image_frame] ---> Image frame number

% Output -
% [Image]         ---> Color Image

function image = yuy_422_rbg(color_sig,image_frame)
%     [dat,sig] = extract_info("test.bag");
%     img_struct = readMessages(color_sig(68).TopicBag);

    % Extract 1D data image data for the specific frame
    img_data = color_sig{image_frame}.Data;
    %Get image specs
    Step = color_sig{image_frame}.Step;
    Height = color_sig{image_frame}.Height;
    %Reshape the data according to the Step and image height
    img_data_reshaped1 = reshape(img_data,[Step,Height]);
    img_data_reshaped1 = img_data_reshaped1';

    % Extract Luma data ( YUV422 )
    Y_channel = img_data_reshaped1(:,1:2:end);

    % Extract Chroma data ( YUV422 )
    % Extract U channel
    U_channel = zeros(size(Y_channel));
    U_channel(:,2:2:end) = img_data_reshaped1(:,2:4:end);
    U_channel(:,1:2:end) = U_channel(:,2:2:end);
    % Extract V channel
    V_channel = zeros(size(Y_channel));
    V_channel(:,2:2:end) = img_data_reshaped1(:,4:4:end);
    V_channel(:,1:2:end) = V_channel(:,2:2:end);
    
    % Creating 3D YUV422 image data
    yuv(:,:,1) = Y_channel;
    yuv(:,:,2) = U_channel;
    yuv(:,:,3) = V_channel;
    
    % Converting YUV to RGB data
    image=ycbcr2rgb(yuv);
    
%     imshow(image);
end

%Copyright -- Chhayank Srivastava --
