function init_availableRobots(radio, vid, robotIDs)
%checks which robot is available
    %@parameter:radio: all parameter used for radio (see funk_init(port))
    %           vid: video object for camera (see cam_init() )
    %           robotIDs: IDs to check if available. Use the form [ID1;
    %                     ID2;...;IDn]
%available robots are saved in ids.

% global ROBOTS;
% global ids;
global robotparameter;      %Parameter jedes Roboters

%save copy of ids
% copy_ids = ids;
% ids = [];

%undraw robots and set exists to 0
% for i=1:length(copy_ids)
%     ROBOTS(copy_ids(i)).start(1) = -1; %position in invisible area
%     ROBOTS(copy_ids(i)).center(1) = -1; %position in invisible area
%     ROBOTS(copy_ids(i)).realCenter(1) = -1; %position in invisible area
%     ROBOTS(copy_ids(i)).exists = 0;
%     
%     draw(copy_ids(i));
%     
% end %for



%initialize function
i = 1;


while(i <= length(robotIDs))
    %check if robot is on image
        id = str2num(robotIDs(i,:)); %#ok<ST2NM>
        startPosition = [-1;-1;0];
        [startPosition(1), startPosition(2), startPosition(3), error] = cam_getCoord(radio, vid, robotIDs(i,:), 1);

    %add available ID to output vector and save robot-position.
        if (~error)
        
            print_Status(['robot ', robotIDs(i,:), ' is available']);
           
            %update id vector with available robot
%                 ids = [ids, id]; %#ok<AGROW>
                robotparameter = [robotparameter, setup('getParameterList', id)]; %#ok<AGROW>
                structIDPostition = length(robotparameter);
%                 if ismember(id, copy_ids)
                    %save robot positionrobotparameter(structIDPostition).center
                    robotparameter(structIDPostition).start = startPosition;
                    robotparameter(structIDPostition).center = startPosition;
                    robotparameter(structIDPostition).realCenter = startPosition;
                    robotparameter(structIDPostition).finish = startPosition;
                    robotparameter(structIDPostition).exists = 3;

                    draw('measurement',structIDPostition);
%                 else
                    %save robot position
%                     ROBOTS(id).center = ROBOTS(id).start;
%                     ROBOTS(id).realCenter = ROBOTS(id).start;
%                     ROBOTS(id).finish = ROBOTS(id).start;
%                     ROBOTS(id).exists = 3;
% 
%                     drawFirst(id);
%                 end
                
                
            
            %draw robot in visualization
            %    drawFirst(id);

        else
            print_Status(['robot ', robotIDs(i,:), ' is not available']);
        end %if not error
    %next robot
    i=i+1;
end %while




end %function
