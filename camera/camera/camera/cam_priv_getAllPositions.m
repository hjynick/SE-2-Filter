function [mesRobotPositions, error] = cam_priv_getAllPositions(estRobotPositions, img)

%% Function Description %%
% updates positions of all robots.
% do not call this function directly. its called by cam_getCoord
    %@parameter:estRobotPositions: a Nx3 matrix with estimated positions, N=robotcount, 
    %               for all robots: [x,y,direction] in mm and rad
    %           img: a picture with all robots having the lights on
    %@return:   mesRobotPositions: a Nx3 matrix with measured positions, N=robotcount, 
    %               for all robots: [x,y,direction] in mm and rad

    
%% Options %%

    %choose cut main frame;
    % frame shows the used area on the image, where robots are possibly to
    % be found
        FRAME_X1 = 1;
        FRAME_X2 = 1024;
        FRAME_Y1 = 1;
        FRAME_Y2 = 768;

%% Constants and Initialisation %%
 
    %Length between robotcenter and diode in mm
    HALF_ROBOTLENGTH = 80;
    
    %height of used field
    global ARENA_HEIGHT;
%    ARENA_HEIGHT = 1800;
        
    %Amount of Robots Available
    N = length(estRobotPositions(:,1));
    
    %allocate return variables
    mesRobotPositions = zeros(N,3);
    error = 0;
   
    
%% Proceed Image %%
    % cut the used area showing on the image
    img = img(FRAME_Y1:FRAME_Y2,FRAME_X1:FRAME_X2,:);
    
    
%turn off warnings thus conversion rounding and out of rage values forced
warning('off', 'all');          


    %filter the colors blue and red
    img_copy = img;
    img(:,:,1) = (img(:,:,1)*1.2 - 1.5*img_copy(:,:,2) - img_copy(:,:,3))*1.5;
    img(:,:,2) = img_copy(:,:,2) - img(:,:,1) - img_copy(:,:,3);
    img(:,:,3) = (img(:,:,3) - img_copy(:,:,1) - img_copy(:,:,2))*1.5;
 
    %threshold filter
    img = img-50;


%% Find Estimated Diode Positions%%

    estDiodePos = zeros(N,4);
    
     estRobotPositions(:,3) = estRobotPositions(:,3);

for i=1:N
    %Caution: Camera works in different coordinate system -> transform
    % koordinates before further use! 
   
    %find blue diode, save x,y at estDiodePos(i,1:2)
    estDiodePos(i,1) = estRobotPositions(i,1) +  ( HALF_ROBOTLENGTH * cos(estRobotPositions(i,3)) );
    estDiodePos(i,2) = estRobotPositions(i,2) +  ( HALF_ROBOTLENGTH * sin(estRobotPositions(i,3)) );
    
    %find red diode, save x,y at estDiodePos(i,3:4)
    estDiodePos(i,3) = estRobotPositions(i,1) -  HALF_ROBOTLENGTH * cos(estRobotPositions(i,3));
    estDiodePos(i,4) = estRobotPositions(i,2) -  HALF_ROBOTLENGTH * sin(estRobotPositions(i,3));
    
end %for i=1:N

%transformation to camera koordinate system:
%  estDiodePosTMP = estDiodePos(:,1);
%  estDiodePos(:,1) = ARENA_HEIGHT - estDiodePos(:,2);
%  estDiodePos(:,2) = estDiodePosTMP;
%  
%  estDiodePosTMP = estDiodePos(:,3);
%  estDiodePos(:,3) = ARENA_HEIGHT - estDiodePos(:,4);
%  estDiodePos(:,4) = estDiodePosTMP;
 




%% Find Diodes in Image and Save in World Coodinates %%

mesDiodePos = zeros(N, 4);

for i=1:N

%get position of all lights
    
    %cut out diode frames
            framesize = 10;
            
    % blue diode  
        %findung max blue value
            [blueY,blueX] = find (img(:,:,3) == max(max(img(:,:,3))));
            
            %errortest
            if ( (sum(blueX) <= 0) || (sum(blueY) <= 0) )
                print_Status(['Blue LED ', i, ' not found']);
                error = 1;
                return;
            end
                
            blueX = blueX(1);
            blueY = blueY(1);
            
            %errortest
            if ( (blueX <= framesize) || (blueY <= framesize) )
                print_Status(['Blue LED ', i, ' to close to image border or is not been found']);
                error = 1;
                return;
            end            

        %cutting out blue frame
            blueFrame = img((blueY-framesize):(blueY+framesize),(blueX-framesize):(blueX+framesize),3);
        
        %get position of blue light
            [y,x,z] = find (blueFrame);
            
             %get diode position
             bX = (sum(double(x).*(double(z)))/sum(z)) + double(blueX) - framesize - 1;
             bY = (sum(double(y).*(double(z)))/sum(z)) + double(blueY) - framesize - 1;
                
             %delete diode from img
             img((int32(bY)-framesize):(int32(bY)+framesize),(int32(bX)-framesize):(int32(bX)+framesize),3) = 0;
            
     % red diode
        %finding max red value
            [redY,redX] = find (img(:,:,1) == max(max(img(:,:,1))));
            
            %errortest
            if ( (sum(redX) <= 0) || (sum(redY) <= 0) )
                print_Status(['Red LED ', i, ' not found']);
                error = 1;
                return;
            end
            
            redX = redX(1);
            redY = redY(1);
            
            %errortest
            if ((redX <= framesize) || (redY <= framesize))
                print_Status(['Red LED ', i, ' to close to image border or is not been found']);
                error = 1;
                return;
            end   
            
        %cutting out red frame
            redFrame = img((redY-framesize):(redY+framesize),(redX-framesize):(redX+framesize),1);

        %get position of red light
            [y,x,z] = find (redFrame);

             %get diode position
             rX = (sum(double(x).*(double(z)))/sum(z)) + double(redX) - framesize - 1;
             rY = (sum(double(y).*(double(z)))/sum(z)) + double(redY) - framesize - 1;
                
             %delete diode from img
             img((int32(rY)-framesize):(int32(rY)+framesize),(int32(rX)-framesize):(int32(rX)+framesize),1) = 0;
            
             img(int32(rY),int32(rX),2) = 255;
             img(int32(bY),int32(bX),2) = 255;
             
             
     %get undisorted position - for world or pixel coordinate system see cam_priv_undisort     
     [mesDiodePos(i,1), mesDiodePos(i,2)] = cam_priv_undisort(bX, bY);
     [mesDiodePos(i,3), mesDiodePos(i,4)] = cam_priv_undisort(rX, rY);
     
     
     
end %for i=1:N

warning('on', 'all');  


% mesDiodePosTMP =  mesDiodePos(:,2);
% mesDiodePos(:,2) = ARENA_HEIGHT - mesDiodePos(:,1);
% mesDiodePos(:,1) = mesDiodePosTMP;
% 
% mesDiodePosTMP =  mesDiodePos(:,4);
% mesDiodePos(:,4) = ARENA_HEIGHT - mesDiodePos(:,3);
% mesDiodePos(:,3) = mesDiodePosTMP;


%       estDiodePos
%       mesDiodePos

%% Allocate Measured Diodes to Robots %%

    %calculate distances between estimatet and measured diodes 
    distanceBlue = zeros(N,N);
    distanceRed = zeros(N,N);

 for i=1:N
     for j=1:N
            distanceBlue(i,j) = sqrt( (mesDiodePos(i,1)-estDiodePos(j,1))^2 + (mesDiodePos(i,2) - estDiodePos(j,2))^2 );
             distanceRed(i,j) = sqrt( (mesDiodePos(i,3)-estDiodePos(j,3))^2 + (mesDiodePos(i,4) - estDiodePos(j,4))^2 );
     end %for j=1:N
 end % for i=1:N 
 
 [sortDistBlue, posDistBlue] = sort(distanceBlue);
 [sortDistRed, posDistRed] = sort(distanceRed);
 
%  sortDistBlue
%  sortDistRed
 
 %inconsistentSmallestBlue = zeros(N);
 %inconsistentSmallestRed = zeros(N);
 
 for i=1:N
    if length( find(posDistBlue(1,:) == posDistBlue(1, i) )) > 1
        %inconsistentSmallestBlue(i) = 1;
        print_Status('Inconsitant value. One estimated blue diode is nearest of two measured');
        mesRobotPositions =estRobotPositions;
        error = 1;
        return;
    end
    
    if length( find(posDistRed(1,:) == posDistRed(1, i) )) > 1
        %inconsistentSmallestRed(i) = 1;
        print_Status('Inconsitant value. One estimated red diode is nearest of two measured');
        mesRobotPositions =estRobotPositions;
        error = 1;
        return;
    end
 end
 
 %TODO:
 % works only with all diodes nearest to estimated yet.
 % add alternative calculation
 
%  inconsistentSmallestBlue = find(inconsistentSmallestBlue);
%  inconsistentSmallestRed = find(inconsistentSmallestRed);

%save measured diodes with robot-order
mesDiodeToRobot = zeros(N,4);

for i=1:N
    mesDiodeToRobot(i,1) = mesDiodePos( posDistBlue(1,i), 1);
    mesDiodeToRobot(i,2) = mesDiodePos( posDistBlue(1,i), 2);
    mesDiodeToRobot(i,3) = mesDiodePos( posDistRed(1,i), 3);
    mesDiodeToRobot(i,4) = mesDiodePos( posDistRed(1,i), 4);
end

%save return vector and calculate direction
for i=1:N
    mesRobotPositions(i,1) = (mesDiodeToRobot(i,1) + mesDiodeToRobot(i,3) ) /2;
    mesRobotPositions(i,2) = (mesDiodeToRobot(i,2) + mesDiodeToRobot(i,4) ) /2;
    
    mesRobotPositions(i,3) = atan2((mesDiodeToRobot(i,2) - mesDiodeToRobot(i,4)), (mesDiodeToRobot(i,1) - mesDiodeToRobot(i,3)));
    
end


%% convert positions from camera coordinate system to output system %%
% 
% mesRobotPositionsTMP =  mesRobotPositions(:,2);
% mesRobotPositions(:,2) = ARENA_HEIGHT - mesRobotPositions(:,1);
% mesRobotPositions(:,1) = mesRobotPositionsTMP;
%   mesRobotPositions(:,3) = (-mesRobotPositions(:,3))+pi;%/2;



%% parts of unsed old code.... some was used to measure area

%============================================================

% %get disorted pixelposition on whole picture
%     posX=((rX+bX)/2)+FRAME_X1-1;
%     posY=((rY+bY)/2)+FRAME_Y1-1;

% get undiorted positions of all found diode

% TODO


% %get undisorted position - for world or pixel coordinate system see cam_priv_undisort
%     [x, y] = cam_priv_undisort(posX, posY);

%use position of blue diode only - for checking real positon
%   [x, y] = cam_priv_undisort(bX+FRAME_X1-1, bY+FRAME_Y1-1);
%    disp(x);
%    disp(y);


%calculating direction
  %direction used in the image coordinate system (left top is 0,0)
%   direction = atan2((bY-rY),(bX-rX));
  %direction used in the visualisation coordinate system (left top is 0,0)
%     direction = atan2((bX-rX),-(bY-rY));
%     direction = (-direction)+pi/2;
    
%============================================================

% end %error test

end %function
