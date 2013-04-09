clc;
clear variables;
[dir_input, dir_output] = steganography_init();

% Encode
% ======

%@@ Input image and output location
carrier_image_filename = [dir_input, 'lena.jpg'];
output_image_filename = [dir_output, 'lena_fusion.jpg'];

%@@ Message string to encode into carrier image
%@@ Leave blank to automatically generate a message
secret_msg_str = '';

%@@ Which colour channel to use (1=r, 2=g, 3=b)
channel = 3;

%@@ Output image quality
output_quality = 75;

%@@ Alpha value for encoding
alpha = 0.05;

%@@ Wavelet transformation
mode = 'db1';

% Load image, generate message if necessary
im = imread(carrier_image_filename);
[w h ~] = size(im);
msg_length_max = w / 2 * h / 2; % One bit per pixel, in one quarter
msg_length_max = msg_length_max / 8; % Convert to bytes
if isempty(secret_msg_str)
    secret_msg_str = generate_test_message(msg_length_max);
end;
secret_msg_bin = str2bin(secret_msg_str);

% Take chosen channel and encode
imc = im(:,:,channel);
[imc_stego, im_wavelet_original, im_wavelet_stego] = steg_fusion_encode(imc, secret_msg_bin, alpha, mode);

im_stego = im;
im_stego(:,:,channel) = imc_stego;

% Output
subplot(2,2,1);
imshow(im, [0 255]);
title('Original image');
subplot(2,2,2);
imshow(im_wavelet_original);
title('Original wavelet transform');
subplot(2,2,3);
imshow(im_wavelet_stego);
title('Stego wavelet transform');
subplot(2,2,4);
imshow(im_stego);
title('Stego image');

imwrite(im_stego, output_image_filename, 'quality', output_quality);

% Decode
% ======

im_stego = imread(output_image_filename);
im_original = imread(carrier_image_filename);

imc_stego = im_stego(:,:,channel);
imc_original = im_original(:,:,channel);

[extracted_msg_bin] = steg_fusion_decode(imc_stego, imc_original, mode);

extracted_msg_str = bin2str(extracted_msg_bin);

% Print statistics
steganography_statistics(imc, imc_stego, secret_msg_bin, extracted_msg_bin);