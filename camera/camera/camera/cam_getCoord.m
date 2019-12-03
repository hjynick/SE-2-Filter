function [x, y, direction, error] = cam_getCoord(radio, vid, robotID, initRun) %#ok<INUSL>
%get Position of one robot
    %@parameter:radio: all parameter used for radio (see funk_init(port))
    %           vid: video object for camera (see cam_init() )
    %           robotID used for funk_led(radio, robotID, code)
    %@return:   x: X coordinate of robot (center)
    %           y: Y coordinate of robot (center)
    %           direction: direction of robot in rad
    %           error: true, if one led was not found


if nargin == 3
    initRun = 0;
end

if initRun
    numOfRadioAttempts = 0;
else
    numOfRadioAttempts = 5;
end
    
%turn off all LEDs    
%     funk_led(radio, '00', 0);
%     pause(0.05);
    
%turn on LED
    funk_led(radio, robotID, 3, numOfRadioAttempts);  
    pause(0.3);
%     funk_led(radio, robotID, 3);
%     pause(0.2);  
    
%take picture
    img = cam_takeShot(vid);
    pause(0.2);
    
%turn off LED
    funk_led(radio, robotID, 0, numOfRadioAttempts);
%     pause(0.1);
%     funk_led(radio, robotID, 0);

%compute position of robot
    [x, y, direction, error] = cam_priv_getPosition(img);

end
