function [cm_n_x, cm_n_y] = getRobotPositionCm(vid, offset_x, offset_y)
    %[offset_x, offset_y] = [1.004999e+03, 0.4113e+03];
    b = getsnapshot(vid);
    blue = b(:,:,3);
    [x,y] = find(blue==max(max(blue)));
    pos = mean([x,y]);
    [cm_x, cm_y] =  cam_priv_undisort(pos(1), pos(2));
    cm_n_x = (cm_x - offset_x)*-1;
    cm_n_y = (cm_y - offset_y)*-1;
    disp('Found real Cameraposition:'),
    disp([cm_n_x, cm_n_y]);
end
