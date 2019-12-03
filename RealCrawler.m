classdef RealCrawler < AbstractCrawler
    
    
    properties
        pos
        rot
        vid
        offsetX = 0
        offsetY = 0
    end
    
    methods
        function obj=RealCrawler(xytheta, map)
            
            obj = obj@AbstractCrawler(map);
            addpath(genpath('camera'));
            addpath(genpath('crawler_minimal'));
            %obj.vid = cam_init();
        end
        
        function zyx=move(~, dir, param)
            switch dir
                case 'fwdStep'
                    zyx = tcpMove(movement_primitives.forward, 100, 1)
                case 'turnl'
                    zyx = tcpMove(movement_primitives.turn_left, 100, 1);  
                case 'turnr'
                    zyx = tcpMove(movement_primitives.turn_right, 100, 1);  
                case 'turn'
                    if param > 0
                        zyx = tcpMove(movement_primitives.turn_right, 100, param);                    
                    else
                        zyx = tcpMove(movement_primitives.turn_left, 100, param);                    
                    end  
                case 'fwd'
                    zyx = tcpMove(movement_primitives.forward, 100, param)
            end

        end
      
        
        function dists=getUS(obj)
             dists=[tcpUS(0,1),tcpUS(1,1),tcpUS(2,1),tcpUS(3,1)];
        end
        
        function imu=getIMU(obj)
            imu = tcpIMU();
        end
        
        function pos=get.pos(obj)
            [real_pos1, real_pos2] = obj.getRobotPositionCm(obj.vid, obj.offsetX, obj.offsetY);
            pos = [(real_pos1 / 10.0), -(real_pos2 / 10.0)];
        end
        
        function rot=get.rot(obj)
            rot = obj.getRobotRotation(obj.vid, obj.offsetX, obj.offsetY);
            if rot < 0
                rot = rot + 2*pi;
            end
        end
        
        
        function [cm_x, cm_y] = getCameraOffsets(~, vid)
            b = getsnapshot(vid);            
            red = b(:,:,1);            
            [x,y] = find(red==max(max(red)));
            pos = mean([x,y]);
            [cm_x, cm_y] =  cam_priv_undisort(pos(1), pos(2));
        end
        
        function [cm_n_x, cm_n_y] = getRobotPositionCm(~,vid, offset_x, offset_y) 
            offset_x=0;
            offset_y=-10;
            
            %img = getsnapshot(vid);            
            img=imread(shot);
            
            Irgb = im2double(img);
            b= rgb2hsv(Irgb);
            
            h = b(:,:,1);
            s = b(:,:,2);
            v = b(:,:,3);
            [redX,redY] = find(((h>0 & h<1/24) | h>23/24) & s>0.9 & v>0.9);
            
            pos = mean([redX,redY]);
%             disp(pos);
            [cm_x, cm_y] =  cam_priv_undisort(pos(1), pos(2));
            cm_n_x = (cm_x - offset_x)*-1;
            cm_n_y = (cm_y - offset_y)*-1;
%             disp('Found real Cameraposition:'),
%             disp([cm_n_x, cm_n_y]);
%             figure(1);
%             image(img);
%             text(redY,redX,'\leftarrow Red','Color','red','FontSize',14);
            
        end
        
        function theta=getRobotRotation(~, vid, offset_x, offset_y)
              addpath(genpath('camera'));
              offset_x=0;
              offset_y=0;
            
              %img = getsnapshot(vid);            
              img = imread('xymitthetad.png');
            
              Irgb = im2double(img);
              b= rgb2hsv(Irgb);
              h = b(:,:,1);
              s = b(:,:,2);
              v = b(:,:,3);
             [redX,redY] = find(((h>0 & h<1/12) | h>11/12)& s>0.8&v>0.8);
              [gelbX,gelbY] = find(((h>0.1 & h<0.2)& s>0.8&v>0.8));
              posr = mean([redX,redY], 1);
              posg = mean([gelbX,gelbY], 1);
              disp('redPos');
              disp(posr);
              disp('gelbPos');
              disp(posg);
              figure(2);
              imshow(img);
            %plot(posr(1),posr(2),'*r',posg(1),posg(2),'*r');
               text(posr(2),posr(1),'\leftarrow rot','Color','red','FontSize',14);
               text(posg(2),posg(1),'\leftarrow gelb','Color','yellow','FontSize',14);
            
              [cm_x_r, cm_y_r] =  cam_priv_undisort(posr(1), posr(2));
              cm_n_x_r = (cm_x_r - offset_x)*-1;
              cm_n_y_r = (cm_y_r - offset_y)*-1;
              [cm_x_g, cm_y_g] =  cam_priv_undisort(posg(1), posg(2));
              cm_n_x_g = (cm_x_g - offset_x)*-1;
              cm_n_y_g = (cm_y_g - offset_y)*-1;
              theta = atan2((cm_n_x_g-cm_n_x_r),(cm_n_y_g-cm_n_y_r));
               disp('Found real theta:'),
               disp(theta);
        end
     end
end
    


