function [pts] = findMiddleStart(hand, vertices)
%findMiddleStart takes in a logic matrix of hand edge and vertices and search for
%the shortest counter-clockwise path along the edge from one vertex to the
%other
%
% hand: 2D logic matrix of hand edge (we are NOT assuming in hand there is
% a single closed cycle of white points) (i.e. we check for branching and
% disconnected points and return 0 if we encounter such problems)
%
% vertices: 2*2 matrix where first row is the first vertex, second row is
% the second vertex (in i,j coordinate). Both vertices are pixels on the
% hand.
%
% pts: a N*2 list of points in between the vertices in hand in the order
% from vertex 1 to vertex 2 (the shortest path is going counterclockwise
% from vertex 1 to vertex 2) if there exists a single closed cycle of while
% points. 0 if branching or disconnection happens.
%
% We are changing 'hand' matrix because we assume MATLAB is pass-by-value,
% and it seems it is indeed pass-by-value
%
% DIFFERENCE WITH findMiddle: this function looks in two directions rather
% than one and maintain two lists for those two directions.

%% defining constant

offset = [-2, -2]; %for in-window coordinate normalization
index = 1; %for point list index
diagInd = [1;3;7;9]; %linear index of up, left, right, down pixel in a 3*3 window
crosInd = [2;4;5;6;8];
orthFilt = [0, 1, 0; 1, 0, 1; 0, 1, 0];
do = true;

i1 = vertices(1, 1); %i coordinate of the vertex1
j1 = vertices(1, 2); %j coordinate of the vertex1
vert1 = vertices(1,:); %duplicate information but for convenience
vert2 = vertices(2,:); %vertex 2

hand(i1, j1) = 0; %set vert1 to 0 so that find will find new pixels only

%% Start
window = hand(i1-1:i1+1, j1-1:j1+1); %getting 3*3 window

%check if the window is legitmate (we assume the window contains the middle pixel (set to 0 already) and two other adjacent pixels)
if (sum(window(:)) > 2)
    convWindow = conv2(window, orthFilt); %use filt to find corner pixels that are adjacent to cross pixels
    convWindow(crosInd) = 0; %set non-corner pixels to 0
    window(convWindow == 1) = 0; %set bad corners to 0
    if (sum(window(:)) > 2)
        do = false;
        pts = fillPts(vertices); %just find the straightline between the two vertices
    end
end %window legitmate


if (sum(window(:)) == 2)
    %as expected
elseif (sum(window(:)) == 1)
    do = false;
    pts = findMiddle(hand, vertices);
else
    do = false;
    pts = fillPts(vertices);
end

if (do)

    [is, js] = find(window); %finding the two other pixels
    A = [is(1), js(1)];
    B = [is(2), js(2)];

    %converting back to the big image coordinate
    A = A + offset + vert1;
    B = B + offset + vert1;

    %calculating which pixel is closer to the target
    distA = sqrt(sum((A - vert2).^2));
    distB = sqrt(sum((B - vert2).^2));

    %let A be the one closer to the target
    if (distA > distB) %swap A and B if B is closer to
        temp = B;
        B = A;
        A = temp;
    end

    %saving the adjacent pixels into two lists
    listA(index,:) = A;
    listB(index,:) = B;

    %setting found points to 0
    hand(A(1), A(2)) = 0;
    hand(B(1), B(2)) = 0;

    %% biased BFS to find vert2 in the two directions
    while(any(A ~= vert2) && any(B ~= vert2)) %problem 2: this should be any while I used all

        %figure(4);
        %imshow(hand);

        %increment index
        index = index + 1;

        for Aind = 2*index-2:2*index-1 %we are exploring at A's end twice per loop because A is closer to the target
        %moving forward in A direction (direction of A, not a direction)
        iA = A(1);
        jA = A(2);
        windowA = hand(iA-1:iA+1, jA-1:jA+1);
        if(sum(windowA(:)) > 1) %checking in-window pixel num
            windowA(diagInd) = 0; %set the corners to 0
        end   

        if (sum(windowA(:)) ~= 1)
            listA = [listA; fillPts([A;vert2])]; %take the good points so far and find the straitline from A to vert2
            A = vert2; %and pronounce vert2 found
            break;
        end %check windowA

        %get new A head
        [iAnew, jAnew] = find(windowA); %search windowA
        Awindow = [iAnew, jAnew]; %save coord of A in window coordinate
        A = Awindow + offset + A; %get 'hand' coordinate of A
        listA(Aind, :) = A; %point saved to the list
        hand(A(1), A(2)) = 0; %setting new A to 0
        
        if (all(A == vert2))
            break;
        end %check A == vert2

        end %A search loop


        %moving forward in B direction
        iB = B(1);
        jB = B(2);
        windowB = hand(iB-1:iB+1, jB-1:jB+1);
        if(sum(windowB(:)) > 1) %checking in-window pixel num
            windowB(diagInd) = 0; %set up,down,left, right to 0
        end

        if (sum(windowB(:)) ~= 1)
            listB = [listB; fillPts([A;vert2])]; %take the good points so far and find the straitline from A to vert2
            B = vert2; %and pronounce vert2 found
            break;
        end %check windowB

        %get new B head
        [iBnew, jBnew] = find(windowB);
        Bwindow = [iBnew, jBnew];
        B = Bwindow + offset + B;
        listB(index, :) = B; %point saved to the list
        hand(B(1), B(2)) = 0; %set B point to 0

    end %while AB not vert2

    %% Chekcing the reason the loop broke
    if(A == vert2) %if we find vert2 on A's side
        pts = listA;

    elseif(B == vert2) %if we find vert2 on B's side
        pts = listB;

    else %break out of loop before we find vert2
        pts = fillPts(vertices);
    end

end %if do

end %function




