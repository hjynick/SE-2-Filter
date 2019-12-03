robot = crawler();

robot.execute_movement([0,1,0]); % move 1 step forward
robot.execute_movement([0,2,0]); % move 2 steps forward
robot.execute_movement([1,0,0]); % move 1 step sideways
robot.execute_movement([1,2,0]); % move 2 steps forward, 1 sideways
robot.execute_movement([0,0,1]); % turn the robot

dist = robot.perform_US_measurement(1); % perform measurement using sensor 1
