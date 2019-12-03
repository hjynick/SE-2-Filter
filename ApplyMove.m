function newxytheta = ApplyMove(xytheta, move)
    t = move(1:2)';
    r = move(3);
    R = RotationMat2D(xytheta(3) - pi/2);
    theta = xytheta(3) + r;
    pos = xytheta(1:2) + (R*t)';
    newxytheta = [pos, theta];
end