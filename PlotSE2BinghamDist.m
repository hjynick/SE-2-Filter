function PlotSE2BinghamDist(se, fig)

    [samples, ~] = se.sampleDeterministic();
    L = size(samples, 2);
    xytheta = zeros(3,L);
    for i = 1:L
        xytheta(:,i) = FromQuaternion(samples(:,i));
    end
    figure(33);
    plot(xytheta(1,:),xytheta(2,:),'+r');

    hold on
    mode = FromQuaternion(se.mode);
    plot(mode(1), mode(2),'*b');
    q = quiver(xytheta(1,:),xytheta(2,:), cos(xytheta(3,:)), sin(xytheta(3,:)));
    q.AutoScaleFactor = 0.2;
    q.Marker = 'o';
    hold off
end