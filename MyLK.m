%% My lucas-kanade

%% Setup
clear;
close all;

cam = webcam(1);
windowSize = 30; %window size of block proc

%determine windowSize-compatible dimension of img
sampleImg = snapshot(cam);
h = size(sampleImg, 1);
w = size(sampleImg, 2);
h = h - mod(h, windowSize);
w = w - mod(w, windowSize);

%number of imgs (always 2 (for now))
imgNum = 2; %the number of images from which we will be doing our calculation
imgTensor(h, w, imgNum) = 0; %tensor to store the sequences of images
%captureDelaySecs = 1/100; %time delay between each image in second

fun = @(block_struct) windowFlow(block_struct.data, windowSize, windowSize, imgNum);

%% Start
figure;
img1 = im2double(rgb2gray(snapshot(cam)));
imgTensor(:,:,1) = img1(1:h, 1:w);
angleDrag(1:3) = NaN(3,1); %the first two are the last two angles, the last is the current angle. The drag is for eliminating too much sensitivity

for k = 1:500
    angleMean(3) = 0; %output mean angle every three angles
    for i = 1:3

        %take the second picture
        img2 = im2double(rgb2gray(snapshot(cam)));
        imgTensor(:,:,2) = img2(1:h, 1:w);
        subplot(1,3,1);
        imshow(imgTensor(:,:,2));
        title('image');

        %find spatialDeriv
        spatialDeriv(:, :, 1) = conv2([1 1], [1 -1], imgTensor(:,:,1), 'same'); %Ix
        spatialDeriv(:, :, 2) = conv2([1 -1], [1 1], imgTensor(:,:,1), 'same'); %Iy

        %find temporalDeriv
        temporalDeriv = imgTensor(:,:,1) - imgTensor(:,:,2);

        %coleect data and send to blockproc and get v
        allInfo = spatialDeriv;
        allInfo(:,:,3) = temporalDeriv;
        vectors = blockproc(allInfo, [windowSize, windowSize], fun);

        dy = vectors(:, :, 1);
        dx = vectors(:, :, 2);

        subplot(1, 3, 2)
        quiver(dy, dx);
        axis ij;
        title('vector field');

        M = dx + dy*1i;
        thresh = 0.2; %empirical value from observation
        logmag = log(abs(M)); %getting the log of magnitude of the vectors

        logic = logmag>thresh; %logic matrix of big vectors
        subplot(1, 3, 3);
        imshow(logic);
        title('valid vectors');

        ind = find(logic); %getting ind of big vectors
        meandx = mean(dy(ind), 'all');
        meandy = mean(dx(ind), 'all');
        angleDrag(3) = atan2(meandy, meandx); %calculating the mean angle
        angleMean(i) = mean(angleDrag);
        angleDrag(1:2) = angleDrag(2:3);
        %angleFlipped = angle + pi;

        %second img now becomes the first
        imgTensor(:,:,1) = imgTensor(:,:,2);
    end

    angle = mean(angleMean);

    %determine the direction of motion based on the angle calculated
    if (angle>3*pi/4) || (angle<-3*pi/4)
        direction = 'left';
    elseif (angle>pi/4) && (angle<3*pi/4)
        direction = 'up';
    elseif (angle>-pi/4) && (angle<pi/4)
        direction = 'right';
    elseif (angle>-3*pi/4) && (angle<-pi/4)
        direction = 'down';
    else
        direction = 'nullDirection';
    end

    fprintf('angle: %f, direction: %s\n', angle, direction);

end
