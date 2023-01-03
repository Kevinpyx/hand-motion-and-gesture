function [defect, distance, angle] = findDefect(lineSeg,vertices)
%findDefect finds a point on lineSegment that is farthest from both vertices
%   lineSeg: N*2 matrix with each row being a vertex on the line segment
%   vertices: 2*2 matrix with each row being a vertex
%
%   defect is a row vector indicating the farthest pixel from the two
%   vertices in ij coord
%
%   distance is perpendicular distance from the defect to the line
%   connecting v1 and v2 (which will be used to determine if this defect is
%   a valid defect between fingers
%
%   angle is the angle at the defect between the two vertices, presumably 
%   the opening of the fingers (which will also be used to determine its
%   validity)

%get v1 v2
vert1 = vertices(1, :);
vert2 = vertices(2, :);

%calculate difference and distance
diff1 = lineSeg - vert1;
diff2 = lineSeg - vert2;
dist1 = sqrt(sum(diff1.^2, 2));
dist2 = sqrt(sum(diff2.^2, 2));

dist = dist1 + dist2;
[biggest, ind] = max(dist);
defect = lineSeg(ind, :); %getting the defect point

%finding angle between line v1v2 and v1d
v1 = vert2 - vert1;
v2 = defect - vert1;
lv1 = norm(v1);
lv2 = norm(v2);
theta = acos(dot(v1,v2)/(lv1*lv2));

%calculate the perpendicular distance
distance = lv2*sin(theta);

%find the angle of finger opening
v1 = vert1 - defect;
v2 = vert2 - defect;
lv1 = norm(v1);
lv2 = norm(v2);
angle = acos(dot(v1,v2)/(lv1*lv2));

end