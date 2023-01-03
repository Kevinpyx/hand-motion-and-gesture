function [vector] = windowFlow(block)
%WINDOWFLOW find the optical flow of a m*n window
%   Preoconditions:
%       block: a 3-D block where (:,:,1) is the spatialDerivX, (:,:,2) is
%       the spatialDerivY, and (:,:,3) is the temporalDerive
%       m: height of the window
%       n: width of the window
%
%       vector: 1*1*2 matrix with (1,1,1) the motion in the x direction and
%       (1,1,2) the motion in the y direction.


tol = 0.1; %arbitrarily picked thresh, was not determined empirically

%extracting and putting spatial derivs into A
Sx = block(:, :, 1);
Sy = block(:, :, 2);
A = [Sx(:), Sy(:)];

%discard A that's rank deficient
if(rank(A, tol) < 2)
    v = [0 0];
else
    %putting temporal derivs into b
    b = -block(:, :, 3);

    %solve for v and save it into vTot
    v = A \ b(:);
end

vector = reshape(v, 1, 1, 2);
end