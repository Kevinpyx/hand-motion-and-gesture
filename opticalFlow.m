function vectors = opticalFlow(imgTensor, mask)
% CONSTANTFLOW will use an imgTensor and a mask to solve for the optical
% flow vector field that is present in the imgTensor. It will then return
% a matrix of vectors that can be represented as the optical flow
% Preconditions: imgTensor : A 3-D matrix containing images size h by w
%                           where the third dimension is a  
%                           series of images which will be defined
%                           by the size of the mask
%                mask : a 1-D vector that will be applied to the image
%                       tensor to smooth it spatically, and temporally
%  vectors : a 3-D matrix containing all the optical flow values for images
%            in the image tensor, where the size of the first two
%            dimensions are the size of the images while the third
%            dimension represents the x and y components. 


%% Constants needed for function
windowSize = 20; %blockproc window
h = size(imgTensor, 1); 
w = size(imgTensor, 2); 
gauss = gkern(0.05); % constant so it will be the same size as the mask
imgNum = size(mask, 2); 
mid = ceil(imgNum/2); %index of the middle frame


%% calculating

% smoothing and finding the Deriv spatially'
spatialDeriv(h, w, 2) = 0;
spatialDeriv(:, :, 1) = conv2(gauss, mask, imgTensor(:,:, mid), 'same'); %Ix
spatialDeriv(:, :, 2) = conv2(mask, gauss, imgTensor(:,:, mid), 'same'); %Iy

% display spatial
% figure;
% for k = 1:imgNum
%     subplot(imgNum, 2, 2*k-1);
%     imshow(spatialDeriv(:,:,k, 1),[]);
%     title(['I_' num2str(i) 'x']);
%     subplot(imgNum, 2, 2*k);
%     imshow(spatialDeriv(:,:,k, 2),[]);
%     title(['I_' num2str(i) 'y']);
% end

% smoothing and finding the Deriv temporally
imgStrips = reshape(imgTensor, h*w, imgNum); %reshaping into image strips
imgStrips = conv2(imgStrips, mask, 'valid'); %finding the derivative with respect to time
temporalDeriv = reshape(imgStrips, h, w); %reshaping back
temporalDeriv = conv2(gauss, gauss, temporalDeriv, 'same'); %smoothing the temporalDirev frame

% display temporal
figure;
imshow(temporalDeriv,[]);
title('Temporal Deriv');

%% Constructing A and b

%defining function handle for blockproc
fun = @(block_struct) windowFlow(block_struct.data);

%concatenating the derivatives
allInfo = spatialDeriv;
allInfo(:, :, 3) = temporalDeriv;

%create optical flow using blockproc
vectors = blockproc(allInfo, [windowSize, windowSize], fun);

end 