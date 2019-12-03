function init_rereadRobot(radio, vid, robotID)
%checks which robot is available
    %@parameter:radio: all parameter used for radio (see funk_init(port))
    %           vid: video object for camera (see cam_init() )
    %           robotID: Robot ID of robot to reread if available.
%robot stored in ids, if available.

% global ROBOTS;
% global ids;
global robotparameter;      %Parameter jedes Roboters

firstTimeAdd = -1; %has robot bee drawn before?

%check if robot is on image
    id = str2num(robotID); %#ok<ST2NM>
    structIDPostition = 0;
    for i=1:length(robotparameter)
        if robotparameter(i).ID == id
            structIDPostition = i;
            firstTimeAdd = 0;
            break;
        end
    end
    
    
    tmp_postion = [-1; -1; 0];
    [tmp_postion(1), tmp_postion(2), tmp_postion(3), error] = cam_getCoord(radio, vid, robotID, 1);

    %add available ID to output vector and save robot-position.
        if (~error)
        
            if (structIDPostition == 0)
                firstTimeAdd = 1;
                robotparameter = [robotparameter, setup('getParameterList', id)]; %#ok<AGROW>
                structIDPostition = length(robotparameter);
            end
            
            print_Status(['robot ', robotID, ' found at (', num2str(tmp_postion(1)), ', ', num2str(tmp_postion(2)), ')']);
            
            %save robot position
                robotparameter(structIDPostition).start = tmp_postion;
                robotparameter(structIDPostition).center = robotparameter(structIDPostition).start;
                robotparameter(structIDPostition).realCenter = robotparameter(structIDPostition).start;
                robotparameter(structIDPostition).finish = robotparameter(structIDPostition).start;
                robotparameter(structIDPostition).exists = 3;
            
            %draw robot in visualization and update id vector with available robot
                if firstTimeAdd == 1
                    %robotparameter = [robotparameter, setup('getParameterList', id)];
%                     ids = [ids, id];
                    draw('measurement',structIDPostition);
                else
                    draw('prediction',structIDPostition,0);
                end

        else
            print_Status(['robot ', robotID, ' is not available']);
        end %if not error

end %function
