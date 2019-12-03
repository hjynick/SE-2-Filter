function [ image ] = cam_takeShot( vid )
%CAM_TAKESHOT take one Image and converts it to rgb format


image = getsnapshot(vid);
% image = image_org;
% image(:,:,1) = 1.164*(image_org(:,:,1) - 16) + 0.834*(image_org(:,:,3) - 128);
% image(:,:,2) = 1.164*(image_org(:,:,1) - 16) - 0.813*(image_org(:,:,3) - 128) - 0.391*(image_org(:,:,2) - 128);
% image(:,:,3) = 1.164*(image_org(:,:,1) - 16)+ 1.523*(image_org(:,:,2) - 128);


% image(:,:,1) = image_org(:,:,1) + image_org(:,:,3)/0.877;
% image(:,:,2) = 1.7*image_org(:,:,1) - 0.39466*image_org(:,:,2) - 0.5806*image_org(:,:,3);
% image(:,:,3) = image_org(:,:,1) + image_org(:,:,2)/0.493;


% image(:,:,1) = image_org(:,:,1) + 1.403*image_org(:,:,3);
% 
% image(:,:,2) = image_org(:,:,1) - 0.344*image_org(:,:,2) - 0.714*image_org(:,:,3);
% 
% image(:,:,3) = image_org(:,:,1) + 1.770*image_org(:,:,2);
