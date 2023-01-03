function [pts] = findMiddle(hand, vertices)
% findMiddle takes in a logic matrix of hand edge and vertices and search for
% the shortest counter-clockwise path along the edge from one vertex to the
% other
%
% hand: 2D logic matrix of hand edge with the pixel in the clockwise
% direction of vertex 1 zerod so it will find in counterclockwise direction
% for sure.
%
% vertices: 2*2 matrix where first row is the first vertex, second row is
% the second vertex (in i,j coordinate). Both vertices are pixels on the
% hand.
%
% pts: a N*2 list of points in between the vertices in hand in the order
% from vertex 1 to vertex 2 (the shortest path is going counterclockwise
% from vertex 1 to vertex 2) if there exists a connected shortest path while
% part of the path will be filled by a strightline if we encounter breaking
% or branching points. 


%% defining constants

offset = [-2, -2]; %for in-window coordinate normalization
index = 1; %for point list index
diagInd = [1;3;7;9]; %linear index of up, left, right, down pixel in a 3*3 window
do = true;

i1 = vertices(1, 1); %i coordinate of the vertex1
j1 = vertices(1, 2); %j coordinate of the vertex1
vert1 = vertices(1,:); %duplicate information but for convenience
vert2 = vertices(2,:); %vertex 2

hand(i1, j1) = 0; %set vert1 to 0 so that find will find new pixels only

%% Start
window = hand(i1-1:i1+1, j1-1:j1+1); %getting 3*3 window

%check if the window is legitmate (we assume the window contains the other adjacent pixel)

if (sum(window(:)) > 1)
    window(diagInd) = 0;
end %window legitmate

if (sum(window(:)) ~= 1)
    do = false;
    pts = fillPts(vertices);
end %window legitmate

if (do)

    [i, j] = find(window); %finding the pixel
    A = [i, j];
    A = A + offset + vert1; %converting back to the big image coordinate
    listA(index,:) = A; %saving A into a list

    while(any(A ~= vert2))
        
        %figure(4);
        %imshow(hand);

        index = index + 1; %increment index
        hand(A(1), A(2)) = 0; %setting found points to 0

        %moving forward
        iA = A(1);
        jA = A(2);
        windowA = hand(iA-1:iA+1, jA-1:jA+1);

        if (sum(windowA(:)) > 1)
            window(diagInd) = 0; %try to fix it if it has more than one pixel
        end %window legitmate

        if (sum(windowA(:)) ~= 1)
            listA = [listA; fillPts([A;vert2])]; %take the good points so far and find the straitline from A to vert2
            A = vert2; %and pronounce vert2 found
            break;
        end %window legitmate

        %get new A head
        %fprintf('%d', sum(windowA(:)));
        [iAnew, jAnew] = find(windowA); %search windowA
        Awindow = [iAnew, jAnew]; %save coord of A in window coordinate
        A = Awindow + offset + A; %get 'hand' coordinate of A
        listA(index, :) = A; %point saved to the list
      
    end %while A not vert2

    %% return pts
    % two possibilities out of the loop:
    % 1. nothing wrong traveling from vert1 to vert2 -> listA is the
    % correct path
    % 2. we encounter a breaking or branching point -> listA is part of the
    % correct path + filled straight path from current A to the target
    pts = listA;

end %if do

end %function