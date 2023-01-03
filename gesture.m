function [numFingers] = gesture(sampleImg, logic)
% GESTURE will return the number of figures that are pointing up in the
% sample image. LogImg will be used to stabilize the feature detection of
% the hand
%
% Preconditions: sampleImg : The image of the hand with the fingers
%                            pointing in a specific direction
%                logImg : A logical matrix dervived from the optical flow
%                         to help find the hand in sample image
% Postconditions: numFingers: The number of fingers that are pointing up in
%                             the sampleImg.


sampleImg = imresize(sampleImg, 0.5);
[h, w] = size(sampleImg, [1 2]);

%% find Skin

sampleImg = rgb2ycbcr(sampleImg);
Y = sampleImg(:,:,1);
Cb = sampleImg(:,:,2);
Cr = sampleImg(:,:,3);
%Y > 80, 85 < b < 135, 135 < r < 180

YBool = Y(:)>80;
CbBool = (Cb(:) > 85) & (Cb(:) < 135);
CrBool = (Cr(:) > 135) & (Cb(:) < 180);

skin = (YBool & CbBool & CrBool);
skin = reshape(skin, h, w);

% logic = imresize(logic, h/size(logic, 1));
% figure; imshow(logic); title('logic resized');
% skinMotion = skin+logic;
% actualSkin = skinMotion > 1.1;

% We decide not to use the code above because the logic image of the
% vectors above threshold is very coarse, so it messes up the shape of
% the hand. We will refine the hand shape by using a black/gray
% backdrop

%% check condition
activation = 10; %the number of greater-than-thresh vectors & skin pixels needed
if (sum(logic, 'all') < activation || sum(skin, 'all') < activation)
    numFingers = -1;
else


    %% Edge
    edgeBool = edge(skin, 'log');
    edgeBoolLine = bwskel(edgeBool);

    %% BWCONNCOMP

    sets = bwconncomp(edgeBoolLine);
    numPixels = cellfun(@numel, sets.PixelIdxList);
    [biggest,idx] = max(numPixels);
    hand = zeros(size(edgeBoolLine));
    hand(sets.PixelIdxList{idx}) = 1;

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
    realVts(realNum+1, :) = realVts(1,:);%insert the first vertex at the last so the polygon plotted is closed

    %% finding defects
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

        %set the second to last pixel black so the next findMiddle will
        %know which way to go
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
    idx = idx1 & idx2;
    validDefects = defects(idx, :);

    %plotting the hand, the polygon, the defects, and the centers
    figure(7);
    subplot 122;
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

end %if logic

end %function