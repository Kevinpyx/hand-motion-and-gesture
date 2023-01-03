function [directionLabel, direction, logic] = opticalFlowDirection(vectors)

% OPTICALFLOWDIRECTION given an optical flow vector field, will produce a
% direction string that will state what general direction the optical flow
% is moving in. This function will return direction as a string label and
% an integer. 
% 
% Preconditions: vectors : an N by M by 2 vector field, where N and M are
% deteremined by the images produced by the optical flow function. 
%
% directionLabel: A string direction that will determine what direction the robot
% will need to move in. 
% 
% direction: An int that will represent the direction the robot will move
% im 

%extracting x and y components
dy = vectors(:, :, 1);
dx = vectors(:, :, 2);

%making it into a complex number and threshold the vectors
%(This method was suggested by Professor Weinman in the comments of our proposal)
M = dx + dy*1i; 
logmag = log(abs(M)); %getting the log of magnitude of the vectors
thresh = -0.5; %empirical value from observation
logic = logmag > thresh; %logic matrix of "big" vectors

% Displaying logic matrix
figure;
imagesc(logic,[0, 1]); % Display the image with black 0 and white 1
colormap(gray);     % Render in grayscale
axis equal off;     % Use square pixels and turn off borderstitle('logic matrix');

ind = find(logic); %getting ind of big vectors
meandx = mean(dy(ind), 'all');
meandy = mean(dx(ind), 'all');
angle = atan2(-meandy, -meandx); %calculating the mean angle
%angle = angle + pi; %to flip the angle

% Determining direction based off of angle
if (angle>3*pi/4) || (angle<-3*pi/4)
    direction = 1;
    directionLabel = 'left';
elseif (angle>pi/4) && (angle<3*pi/4)
    direction = 0;
    directionLabel = 'up';
elseif (angle>-pi/4) && (angle<pi/4)
    direction = 3;
    directionLabel = 'right';
elseif (angle>-3*pi/4) && (angle<-pi/4)
    direction = 2;
    directionLabel = 'down'; 
else
    direction = -1;
    directionLabel = 'null direction'; 
end


end