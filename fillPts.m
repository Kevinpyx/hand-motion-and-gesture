function [pts] = fillPts(vertices)
%fill returns an evenly distributed connected points between the two vertices
% 
% vertices: 2*2 matrix where first row is the first vertex, second row is
% the second vertex (in i,j coordinate)
%
% pts: an evenly distributed set of connected points between v1 and v2

% acknowledgement: https://www.mathworks.com/matlabcentral/answers/226455-finding-the-path-between-two-points

v1 = vertices(1, :);
v2 = vertices(2, :);
len = ceil(norm(v1 - v2)); %roughly how many points do we need

pts = [round((linspace(v1(1), v2(1), len))'), round((linspace(v1(2), v2(2), len))')];

end