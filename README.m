%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     Handimatronics: Controlling Robots with Your Hand
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

This project uses the Lucas Kanade optical flow Method with gesture
recognition to produce Robot Motion using the MyroC Library.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   Description of Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Our motivation for this project was to control a robot with our hands,
where we needed to utilize computer vision. To solve this problem, we
utilized optical flow, gesture recognition, and MyroC to achieve this
process. For optical flow, we used the Lucas Kanade Method to solve for a
least squares method that would detect motion. We would want to improve
our optical flow so that it is a lot more lenient with the motion it
allows, as for some cameras, the motion will have to be fairly slow (due
to slow frame rate). This process could involve changing the optical flow
algorithms or modifying the current optical flow algorithm we have. For
gesture recognition, we used a process of skin pigmentation, edge
detection and convex hull to simplify the hand into a polygon and then
find and count the defects in that polygon to estimate the number of
fingers we have pointed up. We will want to improve this algorithm by
improving the success rate of the defect detection algorithm by
increasing the accuracy of the skin pigmentation and edge detection
algorithms in non ideal scenarios, and by optimizing our method for
telling apart zero and one finger. Finally, we used the MyroC library,
which was produced by Professor Henry Walker from Grinnell College, to
control the robot motion that the robot will have. Future improvements
would be moving away from this library into a more complex robot library,
to expand what we can do with the robot and simplify the installation
process, as MyroC is hard to install on personal machines and we need to
change the file directories when installed on a new device.

To see a more extensive explanation of the project, please see our
written report attached with this README file.

Learn more about MyroC: https://walker.cs.grinnell.edu/MyroC/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   Installation of the Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Handimatronics requires access to MATLAB, as all of the code is built in
MATLAB. In addition, the package, Webcam Support from MATLAB, is required
as it connects the cameras to MATLAB and allows for the process to
happen. Finally, the MyroC library will need to be installed (from the
link provided above) with a Scribbler 2 Robot as we used this library for
a robot and robot motion. After this, installation of our code library
will be needed as well.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                       Use of Project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
After installation, you will need to adjust the setenv and mex functions
to point to the directory where your MyroC was installed, essentially
changing the generic home/walker/MyroC to your directory with MyroC.
After this change, you will be able to run the main program,
robotMotion.m and move the robot with your gestures into the camera.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constants for Optical flow and Camera
load('exampleImgs.mat');
windowSize = 30;
mask = [-1, 8, 0, -8, 1]/12; % Found in paper in acknowledgements
imgNum = size(mask, 2); %the number of images is related to dgauss kernel size)
numFrames = size(imgs, 3)/3;

% Setting up the camera and imageTensor
sampleImg = imgs(:,:,1); %we don't resize it because the images are resized already for portability
[h, w] = size(sampleImg); %size after downsampling
h = h - mod(h, windowSize); %trimming h so that block size is consistent
w = w - mod(w, windowSize); %trimming w so that block size is consistent
imgTensor(h, w, imgNum) = 0; %tensor to store the sequences of images

for i = 1:imgNum*3:size(imgs,3)/3:
    for k = i:imgNum
        img = imgs(h, w, )
        
    end
    img = imgs(h, w, )
imgTensor(:,:,imgNum) = imgs(h, w, i:i+imgNum-1);
colorImg = imgs(h, w, i:i+2);
%% Collecting the Data
vectors = opticalFlow(imgTensor, mask);

figure(1);
quiver(vectors(:, :, 1), vectors(:, :, 2));
axis ij;
title('vector field');

[directionLabel, direction, logic] = opticalFlowDirection(vectors); 

fingers = gesture(colorImg, logic); 
figure(2);
imshow(colorImg);

fprintf('direction: %s, finger number: %d\n', directionLabel, fingers);

end

%% Motion to Robot
%The C file that will contain the functions with the robot commands
% speed = .5; duration = .5;
% 
% motion(direction, speed, duration);
% 
% 
% 
% disconnect



%% Display functions

% columnNum = 5; figure; for i = 1:imgNum
%     subplot(ceil(imgNum/columnNum), columnNum, i);
%     imshow(imgTensor(:,:,i)); title(['I_{' num2str(i) '}']);
% end

% Displaying Vectorfield figure; quiver(dy, dx); axis ij; title('vector
% field');