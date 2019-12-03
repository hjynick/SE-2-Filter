function q = ToQuaternion(xytheta)
    x = xytheta(1);
    y = xytheta(2);
    theta = xytheta(3);
    s = sin(theta/2);
    c = cos(theta/2);
    q = [c; s; 0.5*(c*x + s*y); 0.5*(c*y - s*x)]; 
end
