function [mesRobotPositions, error] = cam_getAllCoord(radio, vid, estRobotPositions) %#ok<INUSL>
%get Position of one robot
    %@parameter:radio: all parameter used for radio (see funk_init(port))
    %           vid: video object for camera (see cam_init() )
    %           robotID used for funk_led(radio, robotID, code)
    %@return:   x: X coordinate of robot (center)
    %           y: Y coordinate of robot (center)
    %           direction: direction of robot in rad
    %           error: true, if one led was not found

    
%turn on LED
    funk_led(radio, '00', 3, 0);  
    pause(0.15);
    funk_led(radio, '00', 3, 0);  
    pause(0.2);
    
%take picture
    img = cam_takeShot(vid);
    pause(0.2);
    
%turn off LED
    funk_led(radio, '00', 0, 0);
    pause(0.15);
    funk_led(radio, '00', 0, 0);

%compute position of robot
    [mesRobotPositions, error] = cam_priv_getAllPositions(estRobotPositions ,img);
end
