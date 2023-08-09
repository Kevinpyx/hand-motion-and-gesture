%% Refreshing the data
clear; 
pause(2);

% 1 for mirror mode, other value for non-mirror mode
% mirror mode flips left and right
MIRROR_MODE = 0; % not implemented yetttt!
% note on mirror mode: 
% better go back to OpticalFlowDirection and fix the direction logic
% and put it in comments here

% how many rounds the demo runs
ITER_ROUND_NUM = 100;

%% Constants for Optical flow and Camera
cam = webcam(1);
windowSize = 20;
captureDelaySecs = 1/100; %time delay between each image in second
mask = [-1, 8, 0, -8, 1]/12; % Found in paper in acknowledgements
DSfactor = 0.4; %down sample factor
imgNum = size(mask, 2); %the number of images is related to dgauss kernel size)

% Setting up the camera and imageTensor
sampleImg = rgb2gray(snapshot(cam));
[h, w] = size(imresize(sampleImg, DSfactor)); %size after downsampling
h = h - mod(h, windowSize); %trimming h so that block size is consistent
w = w - mod(w, windowSize); %trimming w so that block size is consistent
imgTensor(h, w, imgNum) = 0; %tensor to store the sequences of images
%% Capturing Images

fprintf("Image capturing starts in\n");
pause(1);
fprintf("3\n");
pause(1);
fprintf("2\n");
pause(1);
fprintf("1\n");
pause(1);
fprintf("CHEESE\n");


for iter = 1:ITER_ROUND_NUM

for i = 1:imgNum
    img = flip(imresize(im2double(rgb2gray(snapshot(cam))), DSfactor), 2); %to gray, to double, resize, mirror
    imgTensor(:, :, i) = img(1:h, 1:w);
    pause(captureDelaySecs);    
end


%% Collecting the Data
vectors = opticalFlow(imgTensor, mask);

[directionLabel, meandx, meandy, logic] = opticalFlowDirection(vectors); 
fprintf('%s    ', directionLabel);

if MIRROR_MODE == 1
    colorImg = flip(snapshot(cam), 2);

else
    colorImg = snapshot(cam);

end

fingers = gesture(colorImg, logic); 
fprintf('%d\n', fingers)

figure(1);
subplot 131;
quiver(meandx, meandy);
axis ij;
axis([0, 2, 0, 2]);
title(['vector field:'  directionLabel]);
subplot 132;
imshow(colorImg);


end

