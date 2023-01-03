%% Refreshing the data
close all; 
clear all; 

%% Setup for robot and camera
% setenv LD_RUN_PATH /home/walker/MyroC/lib
% mex connect.c -I/home/walker/MyroC/include -L/home/walker/MyroC/lib  -lm -lMyroC -lbluetooth -ljpeg
% mex motion.c -I/home/walker/MyroC/include -L/home/walker/MyroC/lib -lm -lMyroC -lbluetooth -ljpeg
% mex disconnect.c -I/home/walker/MyroC/include -L/home/walker/MyroC/lib -lm -lMyroC -lbluetooth -ljpeg -v
% % change /home/walker/MyroC/... with the dir w/ myroC
% 
% connect();

%%
% Constants for Optical flow and Camera
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
k = 1; 
while(k < 9)

fprintf("Image capturing starts in\n");
pause(1);
fprintf("3\n");
pause(1);
fprintf("2\n");
pause(1);
fprintf("1\n");
pause(1);
fprintf("CHEESE\n");

for i = 1:imgNum
    img = imresize(im2double(rgb2gray(snapshot(cam))), DSfactor);
    imgTensor(:, :, i) = img(1:h, 1:w);
    pause(captureDelaySecs);    
end
colorImg = snapshot(cam); 

fprintf("Image sequence acquired\n");

%% Collecting the Data
vectors = opticalFlow(imgTensor, mask);

[directionLabel, direction, logic] = opticalFlowDirection(vectors); 
fprintf('%s\n', directionLabel);

load perfectHand.mat; 
fingers = gesture(colorImg, logic); 

figure;
quiver(vectors(:, :, 1), vectors(:, :, 2));
axis ij;
title(['I_{' num2str(i) '}']);
title(['vector field:'  directionLabel]);

%% Motion to Robot
%The C file that will contain the functions with the robot commands
% speed = 1; 
% duration = 3; 
% 
% motion(direction, speed, duration); 
% 
% k = k + 1; 
end
%% 

% disconnect(); 


%% Display functions

% columnNum = 5;
% figure;
% for i = 1:imgNum
%     subplot(ceil(imgNum/columnNum), columnNum, i);
%     imshow(imgTensor(:,:,i));
%     title(['I_{' num2str(i) '}']);
% end

% %% Displaying Vectorfield 
% figure;
% quiver(dy, dx);
% axis ij;
% title('vector field');

