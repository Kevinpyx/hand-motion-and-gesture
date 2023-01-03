close all;
clear;
pause(2);
cam = webcam(2);


%% setup
%
% fprintf("Image capturing starts in\n");
% pause(1);
% fprintf("3\n");
% pause(1);
% fprintf("2\n");
% pause(1);
% fprintf("1\n");
% pause(1);
% fprintf("CHEESE\n");


%pause(1);
sampleImg = imresize(snapshot(cam), 1);
%sampleImg = imread('hands.png');
%load('reasonableFour.mat');
%load('perfectHand.mat');
%load('perfectFour.mat');
%load('perfectThree.mat');
%load('perfectTwo.mat');
%load('perfectOne.mat');
%load('FailedZeroFrontR.mat');
%load('FailedOneFrontR.mat');
%load('FailedZeroBackR.mat');
%load('FailedZeroPalmR.mat');
%load('FailedOneBackR.mat');

figure(1);
subplot 221
imshow(sampleImg);
title('img');


%% Calc
ycbcr = rgb2ycbcr(sampleImg);
[h, w] = size(ycbcr, [1 2]);
Y = ycbcr(:,:,1);
Cb = ycbcr(:,:,2);
Cr = ycbcr(:,:,3);
% Logic for skin pigmentation: Y > 80, 85 < b < 135, 135 < r < 180

YBool = Y(:)>80;
CbBool = (Cb(:) > 85) & (Cb(:) < 135);
CrBool = (Cr(:) > 135) & (Cb(:) < 180);

skin = (YBool & CbBool & CrBool);
skin = reshape(skin, h, w);

%display
%figure(1);
subplot 222;
imshow(skin);
title('skin');

%% Edge
% std = 4;
% gauss = gkern(std^2);
% dgauss = gkern(std^2, 1);

% Ix = conv2(dgauss, gauss, skin, 'valid');
% Iy = conv2(gauss, dgauss, skin, 'valid');
% mag = Ix.^2 + Iy.^2;
% thresh = 0.0012;
% edgeBool = (mag > thresh);
% edgeBoolLine = bwskel(edgeBool);
edgeBool = edge(skin, 'log');
edgeBoolLine = bwskel(edgeBool);

% figure(2);
% imshow(Ix, []);
% figure(3);
% imshow(Iy, []);
% figure(4);
% subplot 233
% imshow(mag, []);
% title('edge strength');
% impixelinfo;

%figure(5);
subplot 223
imshow(edgeBoolLine);
title('edgeBoolLine');

%% BWCONNCOMP

sets = bwconncomp(edgeBoolLine);
numPixels = cellfun(@numel, sets.PixelIdxList);
[biggest,idx] = max(numPixels);
hand = zeros(size(edgeBoolLine));
hand(sets.PixelIdxList{idx}) = 1;
%figure(6);
subplot 224
imshow(hand);
title('biggest set');

%% convex hull and real vertices

[y, x] = find(hand); % y, x bc find returns in ij axis
[k, av] = convhull([x, y], 'Simplify',true);

%filter out close vertices
num = size(k, 1) - 1;
vts = [y(k(1:num)), x(k(1:num))]; %coordinates of the vertices except the last one (because the last is the first)
vts2(1:num-1, :) = vts(2:num, :); %vertices2 is vertices shifted by 1 position
vts2(num, :) = vts(1, :); %last is the first
diff = vts2 - vts;
dist = sqrt(sum(diff.^2, 2)); % ith row is dist between ith and (i+1)th vert

realVts = vts(dist>(mean(dist)/4), :); %delete some very close vertices
realNum = size(realVts, 1);
realVts(realNum+1, :) = realVts(1,:); %insert the first vertex at the last so the polygon plotted is closed

%debugging purpose
% figure(3);
% plot(x, y, 'g*');
% hold on;
% plot(realVts(:,2), realVts(:,1), 'b-');

%% finding defects

ptsBetween = 0; %so that the first two vertices will always use findMiddleStart
defects(realNum, 4) = 0; %pre-assigning space

for v = 1:realNum

    %getting vertices
    v1 = realVts(v, :);
    v2 = realVts(v+1, :);

    i1 = v1(1);
    j1 = v1(2);
    surrPixNum = sum(hand(i1-1:i1+1, j1-1:j1+1), 'all'); %check the number of surrounding pixels

    if (surrPixNum > 2) %whether we have more than one path to go
        %More than one path: we have to look in two directions
        ptsBetween = findMiddleStart(hand, [v1;v2]);
    else
        %One path: the second to last pixel is set black so only one path
        %is visible (second-to-last pixel is in clockwise direction while
        %we store points in counterclockwise direction)
        ptsBetween = findMiddle(hand, [v1;v2]);
    end

    [defect, depth, angle] = findDefect(ptsBetween, [v1;v2]); %finding the defect among ptsBetween
    ptsNum = size(ptsBetween, 1); %find the number of points in between so we know the index of the pixel prior to the second vertex

    %set the second to last pixel black so it's invisible in findMiddle
    if (ptsNum > 1)
        secondLast = ptsBetween(ptsNum-1, :);
        hand(secondLast(1), secondLast(2)) = 0;
    end

    defects(v, :) = [defect, depth, angle];
end

%finding center and distances
defects = defects(defects(:, 3) ~= 0, :);
defectCenter = mean(defects(:, 1:2), 1); %we consider the center of defects as palm center
vertexCenter = mean(realVts, 1);
centerDiff = defects(:, 1:2) - defectCenter;
defectCenterDist = mean(sqrt(sum(centerDiff.^2, 2))); %we consider this palm radius

idx1 = defects(:, 3)>defectCenterDist/2; %reject all the defects with depth smaller than half the palm radius
idx2 = defects(:,4)<pi/2; %reject all the defects whose finger opening is greater than 90 degrees
%idx2 = ones(8, 1);
idx = idx1 & idx2;
validDefects = defects(idx, :);

%plotting the hand, the polygon, and the centers
figure(7);
plot(x, y, 'g*');
title('convex hull');
hold on;
plot(realVts(:,2), realVts(:,1), 'b-.');
plot(defectCenter(2), defectCenter(1), 'r+');
plot(vertexCenter(2), vertexCenter(1), 'b+');
plot(validDefects(:, 2), validDefects(:, 1), 'ro');
hold off;
axis ij;

%count valid defects for gesture: gesture n will have n-1 defects
%telling 1 and 0 apart: look at the vertex that is farthest from the palm

numDef = size(validDefects, 1);
if (numDef == 0) %there's no defects for one finger or fist, so we need to tell them apart
    vertexCenterDist = sqrt(sum((realVts - defectCenter).^2, 2));
    longest = max(vertexCenterDist);
    numFingers = longest > defectCenterDist*1.5; %we consider a vertex finger if it's longer than 1.5*palm radius
elseif (numDef>=1 && numDef <= 4) %in range
    numFingers = numDef + 1;
else %our of range
    numFingers = -1;
end

numFingers

%% debuggin'
% figure(5);
% plot(x, y, 'g*');
% hold on;
% v = 3;
% v1 = realVts(v, :);
% v2 = realVts(v+1, :);
% plot(v1(2), v1(1), 'bo');
% plot(v2(2), v2(1), 'bo');
% plot(VDpair(v, 2, 3), VDpair(v, 1, 3), 'ro'); %defect
hold off;


