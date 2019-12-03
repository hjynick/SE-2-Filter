function [x_out, y_out, error] = cam_getObstacle(img, edges)

%img := image shot by the camera. Obstacle lights musst be switched on
%points := amount of edges of the obstacte to be detected

%x = [1.20, 1.30, 1.40, 1.40, 1.30, 1.20];
%y = [1.30, 1.20, 1.30, 1.40, 1.50, 1.40];

%error = 0;


%% initialize funktion

    global ARENA_HEIGHT;

    EXPECTED_DISTANCE = 405; %expected distance between edges in mm
    TOLLERANCE = 20; %tollerance for expected distances in mm

    used_edges = 1; %saves order of found edges
    distace_matrix = zeros(edges); %saves the distances between each edge
    coordinates = zeros(edges,2); %saves the position of each edge

    error = 0;

%turn off warnings thus conversion rounding and out of rage values forced
warning('off', 'all');  

%% search points in img

    %choose cut main frame;
    % frame shows the used area on the image, where obstacle is possibly to
    % be found
        FRAME_X1 = 50;
        FRAME_X2 = 1000;
        FRAME_Y1 = 50;
        FRAME_Y2 = 750;

    % cut the used area showing on the image
        img = img(FRAME_Y1:FRAME_Y2,FRAME_X1:FRAME_X2,:);

    %filter the diode color green
        img_copy = img;
        img(:,:,2) = img(:,:,2) - 0.5*img_copy(:,:,1) - 0.5*img_copy(:,:,3);

    %threshold filter
        img = img-45;


    %error test
    if (max(max(img(:,:,2)))) <= 2
        x_out = 0;
        y_out = 0;
        error = true;
        print_Status('Camera-Error: No obstacle found!');
        return;
    else 
      %beginn LOOP for each edge
      for i=1:edges
      

          %cut out frames over each edge
            framesize = 10;

          %finding max green value
            [greenY,greenX] = find (img(:,:,2) == max(max(img(:,:,2))));
            greenX = greenX(1);%int32(sum(greenX)/length(greenX));
            greenY = greenY(1);%int32(sum(greenY)/length(greenY));
          %cutting out red frame
            greenFrame = img((greenY-framesize):(greenY+framesize),(greenX-framesize):(greenX+framesize),2);

          %get position or red light
            [y,x,z] = find (greenFrame);
          if sum(z) <= 0
              print_Status('Some green LEDs not found');
              error = 2;
          else
              gX = (sum(double(x).*(double(z)))/sum(z)) + double(greenX) - framesize - 1;
              gY = (sum(double(y).*(double(z)))/sum(z)) + double(greenY) - framesize - 1;
          end


          %get disorted pixelposition on whole picture
            posX= gX+FRAME_X1-1;
            posY= gY+FRAME_Y1-1;

          %get undisorted position - for world or pixel coordinate system see cam_priv_undisort
            [coordinates(i,1), coordinates(i,2)] = cam_priv_undisort(posX, posY);

          %dye position black
             img((int32(gY)-framesize):(int32(gY)+framesize),(int32(gX)-framesize):(int32(gX)+framesize),2) = 0;
             
      end %end LOOP for each edge
    end %if error test
       
        
%% calculate distance Matrix

    for i=1:edges
       for j=1:edges
           
           if i ~= j
           distace_matrix(j,i) = sqrt( (coordinates(i,1) - coordinates(j,1))^2 + (coordinates(i,2) - coordinates(j,2))^2);
           distace_matrix(i,j) = distace_matrix(j,i);
           end
           
       end
    end



%% find edge order
    %intitialize variables
    last_wrong_edge = 1;

    %begin LOOP find whole edge order
    while true %breaks to end while. (line 146)
        
        found = 0; %found matching edge
        
        %find all edges with matching distance
        possible_edges = find( (distace_matrix(:, used_edges(length(used_edges) )) > EXPECTED_DISTANCE - TOLLERANCE) & (distace_matrix(:, used_edges(length(used_edges) )) < EXPECTED_DISTANCE + TOLLERANCE) );
        
        %choose next edge
        for i=1:length(possible_edges)
            if possible_edges(i) > last_wrong_edge
                
                if isempty(find(used_edges == possible_edges(i))) %#ok<EFIND>
                    used_edges = [used_edges, possible_edges(i)]; %#ok<AGROW>
                    found = 1;
                    break;
                end
                
            end
        end

        %wrong matching edge in list. Go one step back and choose other edge.
        if ~found 
            last_wrong_edge = used_edges(length(used_edges));
            used_edges = used_edges(1:length(used_edges)-1);
        else
            last_wrong_edge = 1;
        end
        
        %check if last found edge matches with first one
        if length(used_edges) == edges
            if (distace_matrix(used_edges(edges), used_edges(1)) > EXPECTED_DISTANCE - TOLLERANCE) && (distace_matrix(used_edges(edges), used_edges(1)) < EXPECTED_DISTANCE + TOLLERANCE)
                break;
            else
                last_wrong_edge = used_edges(edges);
                used_edges = used_edges(1:edges-1);
            end
        end
        
        
    end %end LOOP

%% set parameter 4 return & transform  for output
    %sort coordinates
    out = zeros(edges,2);
    
    for i=1:edges
        out(i,1) = coordinates(used_edges(i),1);
        out(i,2) = coordinates(used_edges(i),2);
    end

    %transform coordinates (x and y swapped)
    x_out = out(:,1)';
    y_out = out(:,2)'; %ARENA_HEIGHT - 

%turn on warnings again
warning('on', 'all'); 


%%
end %function
