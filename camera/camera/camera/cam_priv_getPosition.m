function [x, y, direction, error] = cam_priv_getPosition(img)
% computes the position of one robot.
% do not call this funktion. its called by cam_getCoord
    %@parameter:img: a picture with one Robot having the lights on
    %@return:   x: X coordinate of robot (center)
    %           y: Y coordinate of robot (center)
    %           direction: direction of robot in rad
    %           error: true, if one LED was not found

    
%options
    %choose if to use visualization or not
        mkOutputIMG = false;
    %choose if to use (0)whole picture or (1)Cut Out Frames
    % (0) is better performance but wore result. not testet in latest
    % versions
        useCOF = true;
    %choose cut main frame;
    % frame shows the used area on the image, where robots are possibly to
    % be found
        FRAME_X1 = 50;
        FRAME_X2 = 1000;
        FRAME_Y1 = 50;
        FRAME_Y2 = 750;
        
        
%--for output image
    %save original IMG for later output
        if (mkOutputIMG)
            outputIMG = img;
        end

% cut the used area showing on the image
        img = img(FRAME_Y1:FRAME_Y2,FRAME_X1:FRAME_X2,:);

%turn off warnings thus conversion rounding and out of rage values forced
warning('off', 'all');  


%filter the diode colors blue and red
        img_copy = img;
        img(:,:,1) = (img(:,:,1)*1.2 - 1.5*img_copy(:,:,2) - img_copy(:,:,3));
        img(:,:,2) = img_copy(:,:,2) - img(:,:,1) - img_copy(:,:,3);
        img(:,:,3) = (img(:,:,3) - img_copy(:,:,1) - img_copy(:,:,2));
 
%--for output image
    % write the used area with amplify colors
        if (mkOutputIMG)
            imwrite((img(:,:,1)), 'output_red.bmp');
            imwrite((img(:,:,2)), 'output_green.bmp');
            imwrite((img(:,:,3)), 'output_blue.bmp');
        end
%threshold filter
        img(:,:,1) = img(:,:,1) - 55;
        img(:,:,2) = img(:,:,2) - 55;
        img(:,:,3) = img(:,:,3) - 55;
%         img = img;

%--for output image
    % write final filtered area
        if (mkOutputIMG)
            imwrite(img*3,'output_filtered.bmp');
        end

%error test
    if ((max(max(img(:,:,1)))) <= 2) || ((max(max(img(:,:,3)))) <= 2) %#ok<ALIGN> ends line 207
        x = 0;
        y = 0;
        direction = 0;
        error = true;
        print_Status('Camera-Error: No robot found!');
        return;
    else
        error = false;
    
%get position of both lights
if(useCOF)
    
    %cut out frames
            framesize = 10;
            
      % red diode
        %finding max red value
            [redY,redX] = find (img(:,:,1) == max(max(img(:,:,1))));
            redX = int32(sum(redX)/length(redX));
            redY = int32(sum(redY)/length(redY));
        %cutting out red frame
            redFrame = img((redY-framesize):(redY+framesize),(redX-framesize):(redX+framesize),1);

        %get position or red light
            [y,x,z] = find (redFrame);
            if sum(z) <= 0
                print_Status('Red LED not found');
                error = 2;
            else
                rX = (sum(double(x).*(double(z)))/sum(z)) + double(redX) - framesize - 1;
                rY = (sum(double(y).*(double(z)))/sum(z)) + double(redY) - framesize - 1;
            end

      % blue diode  
        %findung max blue value
            [blueY,blueX] = find (img(:,:,3) == max(max(img(:,:,3))));
            blueX = int32(sum(blueX)/length(blueX));
            blueY = int32(sum(blueY)/length(blueY));
            
        %cutting out blue frame
            blueFrame = img((blueY-framesize):(blueY+framesize),(blueX-framesize):(blueX+framesize),3);
        
        %get position or blue light
            [y,x,z] = find (blueFrame);
            if sum(z) <= 0
                print_Status('Blue LED not found');
                error = 3;
            else
                bX = (sum(double(x).*(double(z)))/sum(z)) + double(blueX) - framesize - 1;
                bY = (sum(double(y).*(double(z)))/sum(z)) + double(blueY) - framesize - 1;
            end
else
    
    %using whole picture
        %get position of red light
            [y,x,z] = find (img(:,:,1));
            rX = sum(double(x).*(double(z)))/sum(z);
            rY = sum(double(y).*(double(z)))/sum(z);
        
        %get position of blue light
            [y,x,z] = find (img(:,:,3));
            bX = sum(double(x).*(double(z)))/sum(z);
            bY = sum(double(y).*(double(z)))/sum(z);
end %if

%============================================================

%get disorted pixelposition on whole picture
    posX=((rX+bX)/2)+FRAME_X1-1;
    posY=((rY+bY)/2)+FRAME_Y1-1;

%get undisorted position - for world or pixel coordinate system see cam_priv_undisort
     [x, y] = cam_priv_undisort(posX, posY);

%use position of blue diode only - for checking real positon
%   [x, y] = cam_priv_undisort(bX+FRAME_X1-1, bY+FRAME_Y1-1);
%    disp(x);
%    disp(y);

%calculating direction
  %direction used in the image coordinate system (left top is 0,0)
%   direction = atan2((bY-rY),(bX-rX));
  %direction used in the visualisation coordinate system (left top is 0,0)
    direction = atan2(-(bY-rY),(bX-rX));
%     direction = (-direction)+pi/2;
    
%============================================================

%--output image
if (mkOutputIMG)

redX = int32(rX)+FRAME_X1-1;
redY = int32(rY)+FRAME_Y1-1;
blueX = int32(bX)+FRAME_X1-1;
blueY = int32(bY)+FRAME_Y1-1;

  %lines will be drawn green
    
    %size of the highlighted frames
        size1 = 10;
        size2 = 15;

    %set frame onto red light
        [a,b] = find (img(:,:,1) == max(max(img(:,:,1))));
        a = int32(sum(a)/length(a));
        b = int32(sum(b)/length(b));

        outputIMG((a-size1):(a+size1),(b-size2),2) = 255;
        outputIMG((a-size1):(a+size1),(b+size2),2) = 255;
        outputIMG((a-size2),(b-size1):(b+size1),2) = 255;
        outputIMG((a+size2),(b-size1):(b+size1),2) = 255;

    %set frame onto blue light
        [a,b] = find (img(:,:,3) == max(max(img(:,:,3))));
        a = int32(sum(a)/length(a));
        b = int32(sum(b)/length(b));

        outputIMG((a-size1):(a+size1),(b-size2),2) = 255;
        outputIMG((a-size1):(a+size1),(b+size2),2) = 255;
        outputIMG((a-size2),(b-size1):(b+size1),2) = 255;
        outputIMG((a+size2),(b-size1):(b+size1),2) = 255;

    %set cross size
        size = 2;
    %set red cross
        outputIMG((redY-size):(redY+size), redX, 2) = 255; 
        outputIMG(redY, (redX-size):(redX+size), 2) = 255; 
    %set blue cross
        outputIMG((blueY-size):(blueY+size), blueX, 2) = 255; 
        outputIMG(blueY, (blueX-size):(blueX+size), 2) = 255; 
    
    %=========================================================
    % set returned position cross
    
      %set cross size
        size = 5;
        outputIMG((int32(posY)-size):(int32(posY)+size), int32(posX), 2) = 255; 
        outputIMG(int32(posY), (int32(posX)-size):(int32(posX)+size), 2) = 255; 
    
    
    %=========================================================
    
    %Show Image
     % do not use while running visualisation
%       imshow(outputIMG);
    %Print out
        imwrite(outputIMG,'output_image.bmp');
        
end %output image

end %error test

%turn on warnings again
warning('on', 'all'); 

end %function
