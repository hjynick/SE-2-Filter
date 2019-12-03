function xytheta = FromQuaternion(q)
    theta = 2 * atan2(q(2),q(1));
    if theta < 0
        theta = theta + 2 * pi;
    end
    x = 2 * (q(1)*q(3) - q(2)*q(4));
    y = 2 * (q(2)*q(3) + q(1)*q(4));
    xytheta = [x,y,theta];
end