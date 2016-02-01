function ptarget = targetModel(I,cameraParams)

% Taken from https://www.youtube.com/watch?v=Z2-kDVF37FQ, with
% modifications

dI = imsubtract(I(:,:,1),rgb2gray(I)); 
dI = medfilt2(dI,[5,5]); 
dI = im2bw(dI,0.18); 
dI = bwareaopen(dI,200); 

bw = bwlabel(dI,8); 
imshow(bw)
stats = regionprops(logical(bw),'BoundingBox','Centroid'); 

for object = 1:length(stats)
    bb = stats(object).BoundingBox; 
    bc = stats(object).Centroid; 

    r1 = rectangle('Position',bb,'EdgeColor','r','LineWidth',1);
    r2 = plot(bc(1),bc(2),'-m+'); 
end

objwidth = 30; 
ff = cameraParams.FocalLength(1); 

% (Object distance from camera) = 
%   (object size * focal length) / (object size in image)
dest = (objwidth * ff) / bb(3); % depth estimate

% Use pinhole camera model: https://en.wikipedia.org/wiki/Pinhole_camera_model
cameracenter = [320 240]; 
rcamera = bc - cameracenter; 

xest = dest * sin( atan2( -rcamera(1), ff ) ); 
yest = dest * sin( atan2( -rcamera(2), ff) ); 

ptarget = [xest -yest dest]; 

