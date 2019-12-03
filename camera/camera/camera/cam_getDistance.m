function [distance, error] = cam_getDistance(radio, vid, robot1, robot2)
%!!!!! Scheint nicht mehr verwendet zu werden !!!!!
%<NOTINUSE>


%compute distance between two robots
    %@parameter:radio: all parameter used for radio (see funk_init(port))
    %           vid: video object for camera (see cam_init() )
    %           robot1: ID of one robot used for funk_led(radio, robotID, code)
    %           robot2: ID of an other robot used for funk_led(radio, robotID, code)
    %@return:   distance: disctance between robot1 and robot2
    %           error: true, if one led was not found

%getting coordinates of robot1
    [x, y, dist, error] = cam_getCoord(radio, vid, robot1);
    if (error)
        distance = 0;
        return;
    end
    position1 = [x, y];

%getting coordinates of robot2
    [x, y, dist, error] = cam_getCoord(radio, vid, robot2);
    if (error)
        distance = 0;
        return;
    end
    position2 = [x, y];

%calculating delta beween each coordinate
    pos = (position1 - position2);

%calculating the final distances
    distance = sqrt( (pos(1))^2 + (pos(2))^2);

end